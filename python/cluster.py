# -*- encoding: utf-8 -*-

import collections
import configparser
import datetime
import itertools
import logging
import math
import operator
import os
import os.path
import re

import matplotlib.pyplot as plt
import matplotlib.colors as colors

import numpy as np
import sklearn.cluster
from sklearn.metrics import pairwise_distances
import networkx as nx
import sqlalchemy
import sqlalchemy_utils
from sqlalchemy.sql import table, text

# mimics mysql Ver 15.1 Distrib 10.1.29-MariaDB
MYSQL_DEFAULT_FILES  = ( '/etc/my.cnf', '/etc/mysql/my.cnf', '~/.my.cnf' )
MYSQL_DEFAULT_GROUPS = ( 'mysql', 'client', 'client-server', 'client-mariadb' )

LOG_HILITE = {
    logging.ERROR : ('\x1B[1m', '\x1B[0m')
}

logger = logging.getLogger ()

def log (level, msg, *aargs, **kwargs):
    """
    Low level log function
    """

    d = {
        'hilite' : LOG_HILITE.get (level, ('', ''))
    }
    logger.log (level, msg, *aargs, extra = d)

def execute (conn, sql, parameters, debug_level = logging.DEBUG):
    sql = sql.strip ().format (**parameters)
    start_time = datetime.datetime.now ()
    result = conn.execute (text (sql), parameters)
    log (debug_level, '%d rows in %.3fs', result.rowcount, (datetime.datetime.now () - start_time).total_seconds ())
    return result


def executemany (conn, sql, parameters, param_array, debug_level = logging.DEBUG):
    sql = sql.strip ().format (**parameters)
    start_time = datetime.datetime.now ()
    result = conn.execute (text (sql), param_array)
    log (debug_level, '%d rows in %.3fs', result.rowcount, (datetime.datetime.now () - start_time).total_seconds ())
    return result


def executemany_raw (conn, sql, parameters, param_array, debug_level = logging.DEBUG):
    sql = sql.strip ().format (**parameters)
    start_time = datetime.datetime.now ()
    result = conn.execute (sql, param_array)
    log (debug_level, '%d rows in %.3fs', result.rowcount, (datetime.datetime.now () - start_time).total_seconds ())
    return result


def rollback (conn, debug_level = logging.DEBUG):
    start_time = datetime.datetime.now ()
    result = conn.execute ('ROLLBACK')
    log (debug_level, 'rollback in %.3fs', (datetime.datetime.now () - start_time).total_seconds ())
    return result


def tabulate (res):
    """ Format and output a rowset

    Uses an output format similar to the one produced by the mysql commandline
    utility.

    """
    cols = range (0, len (res.keys ()))
    rowlen = dict()
    a = []

    def line ():
        for i in cols:
            a.append ('+')
            a.append ('-' * (rowlen[i] + 2))
        a.append ('+\n')

    # convert database types to strings
    rows = []
    for row in res.fetchall():
        newrow = []
        for i in cols:
            if row[i] is None:
                newrow.append ('NULL')
            else:
                newrow.append (str (row[i]))
        rows.append (newrow)

    # calculate column widths
    for i in cols:
        rowlen[i] = len (res.keys ()[i])

    for row in rows:
        for i in cols:
            rowlen[i] = max (rowlen[i], len (row[i]))

    # output header
    line ()
    for i in cols:
        a.append ('| {:<{align}} '.format (res.keys ()[i], align = rowlen[i]))
    a.append ('|\n')
    line ()

    # output rows
    for row in rows:
        for i in cols:
            a.append ('| {:<{align}} '.format (row[i], align = rowlen[i]))
        a.append ('|\n')
    line ()
    a.append ('%d rows\n' % len (rows))

    return ''.join (a)


class MySQLEngine (object):
    """ Database Interface """

    def __init__ (self, fn = MYSQL_DEFAULT_FILES, group = MYSQL_DEFAULT_GROUPS, db = ''):
        # self.params is only needed to configure the MySQL FDW in Postgres
        self.params = self.get_connection_params (fn, group)
        self.params['database'] = db

        url = sqlalchemy.engine.url.URL (**(dict (self.params, password = 'secret')))
        log (logging.INFO, 'MySQLEngine: Connecting to URL: {url}'.format (url = url))
        url = sqlalchemy.engine.url.URL (**self.params)
        self.engine = sqlalchemy.create_engine (url)

        self.connection = self.connect ()


    @staticmethod
    def get_connection_params (filenames, groups):
        if isinstance (filenames, str):
            filenames = [ filenames ]
        if isinstance (groups, str):
            groups = [ groups ]

        filenames = map (os.path.expanduser, filenames)
        config = configparser.ConfigParser ()
        config.read (filenames)
        parameters = {
            'drivername' : 'drivername',
            'host' : 'host',
            'port' : 'port',
            'database' : 'database',
            'user' : 'username',
            'password' : 'password',
        }
        options = {
            'default-character-set' : 'charset',
        }
        params = {
            'drivername' : 'mysql',
            'host' : 'localhost',
            'port' : '3306',
            'query' : {
                'charset' : 'utf8mb4',
            }
        }

        for group in groups:
            if group in config:
                section = config[group]
                for key, alias in parameters.items ():
                    if key in section:
                        params[alias] = section[key].strip ('"')
                for key, alias in options.items ():
                    if key in section:
                        params['query'][alias] = section[key].strip ('"')
        return params


    def connect (self):
        connection = self.engine.connect ()
        # Make MySQL more compatible with other SQL databases
        connection.execute ("SET sql_mode='ANSI'")
        return connection


class PostgreSQLEngine (object):
    """ PostgreSQL Database Interface """

    def __init__ (self, **kwargs):

        args = self.get_connection_params (kwargs)

        self.url = 'postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}'.format (**args)

        if not sqlalchemy_utils.functions.database_exists (self.url):
            log (logging.INFO, "PostgreSQLEngine: Creating database '{database}'".format (**args))
            sqlalchemy_utils.functions.create_database (self.url)

        log (logging.INFO, "PostgreSQLEngine: Connecting to postgres database '{database}' as user '{user}'".format (**args))

        self.engine = sqlalchemy.create_engine (self.url + '?sslmode=disable&server_side_cursors')

        self.params = args


    def connect (self):
        return self.engine.connect ()


    def get_connection_params (self, args = None):
        """ Get connection parameters from environment. """

        defaults = {
            'host'     : 'localhost',
            'port'     : '5432',
            'database' : 'ntg',
            'user'     : 'ntg',
        }

        if args is None:
            args = {}

        params = ('host', 'port', 'database', 'user') # order must match ~/.pgpass
        res = {}

        for p in params:
            pu = 'PG' + p.upper ()
            res[p] = args.get (p) or args.get (pu) or os.environ.get (pu) or defaults[p]

        # scan ~/.pgpass for password
        pgpass = os.path.expanduser ('~/.pgpass')
        try:
            with open (pgpass, 'r') as f:
                for line in f.readlines ():
                    line = line.strip ()
                    if line == '' or line.startswith ('#'):
                        continue
                    # format: hostname:port:database:username:password
                    fields = line.split (':')
                    if all ([field == '*' or field == res[param]
                             for field, param in zip (fields, params)]):
                        res['password'] = fields[4]
                        break

        except IOError:
            print ('Error: could not open %s for reading' % pgpass)

        return res


def natural_sort_key (key):
    def f (mo):
        s = mo.group (0)
        return str (len (s)) + s
    return re.sub ('([0-9]+)', f, key)


def classify (bk):
    m = re.match (r'^(BK|Mordek)\.(\d+)(.*)$', bk)
    if m:
        is_bk = m.group (1) == 'BK'
        label = ('' if is_bk else 'M') + m.group (2) + m.group (3)
        no = int (m.group (2))
        # BK   1-131  Mordek  1-14  < 814
        # BK 132-202  Mordek 15-24  LdF
        # BK 203-307  Mordek 25-26  > 840
        if is_bk:
            class_ = '-814'
            if no >= 132:
                class_ = 'LdF'
            if no >= 203:
                class_ = '840-'
        else:
            class_ = '-814'
            if no >= 15:
                class_ = 'LdF'
            if no >= 25:
                class_ = '840-'
        return { 'label' : label, 'class' : class_ }
    return None


def bk_to_nx (conn):
    """ Load the graph from the database. """

    res = execute (conn, """
    SELECT post_id, meta_value
    FROM wp_postmeta pm
     JOIN wp_posts p ON (p.ID = pm.post_id)
    WHERE meta_key = 'msitem-corresp' AND post_parent = 58
      AND meta_value REGEXP '^(BK|Mordek)'
    GROUP BY post_id, meta_value
    ORDER BY post_id, meta_value
    """, dict ())

    BK = collections.namedtuple ('ms_bk', 'id, bk')

    rows = list (map (BK._make, res))
    G = nx.Graph ()
    no_of_groups = 0
    max_group_size = 0

    for id_, igroup in itertools.groupby (rows, operator.attrgetter ('id')):
        no_of_groups += 1
        group = list (igroup)
        for g in group:
            if not G.has_node (g.bk):
                t = classify (g.bk)
                if t:
                    G.add_node (g.bk, count = 0, **t)

        group_size = len (group)
        max_group_size = max (group_size, max_group_size)

        weight = 1 # / (group_size * (group_size - 1) / 2)
        for i in range (0, group_size):
            bk1 = group[i].bk
            G.nodes[bk1]['count'] += 1
            for j in range (i, group_size):
                bk2 = group[j].bk
                if bk1 == bk2:
                    continue
                if G.has_edge (bk1, bk2):
                    e = G.edges[bk1, bk2]
                    e['count'] += 1
                    e['weight'] += weight
                else:
                    G.add_edge (bk1, group[j].bk, count = 1, weight = weight)

    max_node_count = 0
    for n, data in G.nodes.items ():
        max_node_count = max (data['count'], max_node_count)

    max_edge_count = 0
    for n, data in G.edges.items ():
        max_edge_count = max (data['count'], max_edge_count)

    for n, data in G.nodes.items ():
        data['weight'] = data['count'] / max_node_count
        data['size']   = 15 + math.sqrt (data['weight'] * 100)

    for e, data in G.edges.items ():
        w = math.sqrt (G.nodes[e[0]]['count'] * G.nodes[e[1]]['count'])
        data['weight'] = data['count'] / w # max_edge_count

    CUTOFF = 0.1

    for e, data in list (G.edges.items ()):
        if data['weight'] < CUTOFF:
            G.remove_edge (*e)

    print ('No. of groups:  %d' % no_of_groups)
    print ('Max group size: %d' % max_group_size)
    print ('Max node count: %d' % max_node_count)
    print ('Max edge count: %d' % max_edge_count)
    return G


def load_feature_matrix (conn):
    # get list of bks
    res = execute (conn, """
    SELECT meta_value
    FROM wp_postmeta pm
     JOIN wp_posts p ON (p.ID = pm.post_id)
    WHERE meta_key = 'msitem-corresp' AND post_parent = 58
      AND meta_value REGEXP '^(BK|Mordek)'
    GROUP BY meta_value
    ORDER BY meta_value
    """, dict ())

    bks = sorted ([row[0] for row in res], key = natural_sort_key)
    inv_bks = { bk : n for n, bk in enumerate (bks) }

    # get list of mss
    res = execute (conn, """
    SELECT meta_value
    FROM wp_postmeta pm
     JOIN wp_posts p ON (p.ID = pm.post_id)
    WHERE meta_key = 'tei-xml-id' AND post_parent = 58
    GROUP BY meta_value
    ORDER BY meta_value
    """, dict ())

    mss = sorted ([row[0] for row in res], key = natural_sort_key)
    inv_mss = { ms : n for n, ms in enumerate (mss) }

    res = execute (conn, """
    SELECT pm2.meta_value, pm1.meta_value
    FROM wp_posts p
    JOIN wp_postmeta pm1 ON (p.ID = pm1.post_id)
    JOIN wp_postmeta pm2 ON (p.ID = pm2.post_id)
    WHERE p.post_parent = 58
      AND pm1.meta_key = 'msitem-corresp' AND pm1.meta_value REGEXP '^(BK|Mordek)'
      AND pm2.meta_key = 'tei-xml-id'
    GROUP BY 1, 2
    ORDER BY 1, 2
    """, dict ())

    mss_bks = list (map (collections.namedtuple ('MSS_BKS', 'ms bk')._make, res))

    print ('mss: %d' % len (mss))
    print ('bks: %d' % len (bks))
    print ('mss_bks: %d' % len (mss_bks))

    feature_matrix = np.zeros ((len (bks), len (mss)), dtype=bool)
    for t in mss_bks:
        feature_matrix[inv_bks[t.bk], inv_mss[t.ms]] = True

    return feature_matrix, bks, mss


METRICS = ('cosine', 'jaccard')

def to_distance_matrix (M, metric):
    D = sklearn.metrics.pairwise_distances (M, metric=metric)
    if metric == 'jaccard':
        D[np.isnan (D)] = 1.0
    D = 1.0 - D
    return D


def hierarchical_cluster (D, labels):
    """ https://en.wikipedia.org/wiki/Community_structure """

    model = sklearn.cluster.DBSCAN ()
    # print (D)
    model.fit (D)

    # print clustering results
    for label in set (model.labels_):
        if label == -1:
            continue
        print (label)
        for name, l in zip (labels, model.labels_):
            if l == label:
                print (name)


def colormap_bw ():
    # return colors.from_levels_and_colors ([0, 0.5, 1], ['white', 'black'])
    return (colors.LinearSegmentedColormap.from_list ('BW', ['white', 'black']),
            colors.Normalize (vmin = 0.0, vmax = 1.0))


def colormap_affinity ():
    return ('jet', colors.Normalize (vmin = 0.0, vmax = 1.0))


def heat_matrix (f, ax, m, caption, ylabels, xlabels, colormap):
    """ Plot a heat map of the matrix. """

    mmax = np.max (m)
    m = m / mmax
    ax.matshow (m, aspect = 'auto', cmap = colormap[0], norm = colormap[1])
    # plt.colorbar ()

    xticks = range (0, len (xlabels), 5)
    yticks = range (0, len (ylabels), 5)
    xlabels = [xlabels[i] for i in xticks]
    ylabels = [ylabels[i] for i in yticks]

    ax.set_xticks (xticks)
    ax.set_yticks (yticks)
    ax.set_xticklabels (xlabels, rotation='vertical')
    ax.set_yticklabels (ylabels)
    plt.tick_params (direction = 'out', pad = 5)

    ax.set_title (caption)


if __name__ == '__main__':
    db = MySQLEngine ('~/.my.cnf.capitularia', 'mysql', 'capitularia')

    np.set_printoptions (threshold=np.nan)

    with db.engine.begin () as conn:
        # Whether capitular k occurs in document d (term frequency)
        tf_kd, bklabels, mslabels = load_feature_matrix (conn)

        # the number of documents
        D = len (mslabels)
        print ('No. of Documents: %d' % D)

        # the number of documents that include capitular k
        df_k = np.sum (tf_kd, axis = 0)
        print ('df_k: %s' % df_k)

        # the inverse document frequency of capitular k
        # (the more documents contain k the less weight we give k)
        idf_k = np.log (D / df_k)
        idf_k[np.isinf (idf_k)] = 0.0
        print ('idf_k: %s' % idf_k)

        # the tf-idf weight of capitular k in document d
        tf_idf_kd = tf_kd * idf_k
        # print ('tf_idf_kd: %s' % tf_idf_kd)

        # the number of capitulars
        K = len (bklabels)
        print ('No. of Capitulars: %d' % K)

        # the number of capitulars in document d
        tf_d = np.sum (tf_kd, axis = 1)
        print ('tf_d: %s' % tf_d)

        # the inverse capitular frequency of document d
        # (the more capitulars d contains the less weight we give d)
        itf_d = np.log (K / tf_d)
        itf_d[np.isinf (itf_d)] = 0.0
        print ('itf_d: %s' % itf_d)

        # the df-itf weight of document d regarding capitular k
        df_itf_kd = tf_kd.T * itf_d
        # print ('df_itf_kd: %s' % df_itf_kd)

        f, axes = plt.subplots (1, 2)

        heat_matrix (f, axes[0], tf_idf_kd, "tf-idf Matrix",
                     bklabels, mslabels, colormap_affinity ())
        heat_matrix (f, axes[1], df_itf_kd.T, "tf-itf Matrix",
                     bklabels, mslabels, colormap_affinity ())

        Dms = dict () # the distance matrix(es) of documents
        Dbk = dict () # the distance matrix(es) of capitulars

        metric = 'cosine'
        Dms[metric] = to_distance_matrix (tf_idf_kd.T, metric)
        Dbk[metric] = to_distance_matrix (df_itf_kd.T, metric)

        metric = 'jaccard'
        Dms[metric] = to_distance_matrix (tf_kd.T, metric)
        Dbk[metric] = to_distance_matrix (tf_kd,   metric)

        f, axes = plt.subplots (1, 2)

        for ax, metric in zip (axes, METRICS):
            heat_matrix (f, ax, Dms[metric], "Manuscript Distance using %s metric" % metric,
                         mslabels, mslabels, colormap_affinity ())

        f, axes = plt.subplots (1, 2)

        for ax, metric in zip (axes, METRICS):
            heat_matrix (f, ax, Dbk[metric], "Capitularia Distance using %s metric" % metric,
                         bklabels, bklabels, colormap_affinity ())

        # plt.show ()

        for i, metric in enumerate (METRICS):
            hierarchical_cluster (Dms[metric], mslabels)

        for i, metric in enumerate (METRICS):
            hierarchical_cluster (Dbk[metric], bklabels)

        # Gephi graph of capitulars
        G = nx.Graph (Dbk['cosine'])
        for n, label in enumerate (bklabels):
            data = G.nodes[n]
            data.update (classify (label))
            data['size'] = 15 + math.sqrt (tf_d[n] * 100)

        G.remove_edges_from (nx.selfloop_edges (G))
        G.remove_nodes_from (list (nx.isolates (G)))

        nx.write_gexf (G, "/tmp/bk.gexf")

        # Gephi graph of documents
        G = nx.Graph (Dms['cosine'])
        for n, label in enumerate (mslabels):
            data = G.nodes[n]
            data['label'] = label
            data['size'] = 15 + math.sqrt (df_k[n] * 100)

        G.remove_edges_from (nx.selfloop_edges (G))
        G.remove_nodes_from (list (nx.isolates (G)))

        nx.write_gexf (G, "/tmp/ms.gexf")
