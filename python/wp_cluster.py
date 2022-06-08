#! /usr/bin/python3 -*- encoding: utf-8 -*-
#

import collections
import configparser
import datetime
import logging
import os
import os.path

import numpy as np
import sqlalchemy
from sqlalchemy.sql import text

import cluster

# mimics mysql Ver 15.1 Distrib 10.1.29-MariaDB
MYSQL_DEFAULT_FILES = ("/etc/my.cnf", "/etc/mysql/my.cnf", "~/.my.cnf")
MYSQL_DEFAULT_GROUPS = ("mysql", "client", "client-server", "client-mariadb")

LOG_HILITE = {logging.ERROR: ("\x1B[1m", "\x1B[0m")}

logger = logging.getLogger()


def log(level, msg, *aargs, **kwargs):
    """
    Low level log function
    """

    d = {"hilite": LOG_HILITE.get(level, ("", ""))}
    logger.log(level, msg, *aargs, extra=d)


def execute(conn, sql, parameters, debug_level=logging.DEBUG):
    sql = sql.strip().format(**parameters)
    start_time = datetime.datetime.now()
    result = conn.execute(text(sql), parameters)
    log(
        debug_level,
        "%d rows in %.3fs",
        result.rowcount,
        (datetime.datetime.now() - start_time).total_seconds(),
    )
    return result


def executemany(conn, sql, parameters, param_array, debug_level=logging.DEBUG):
    sql = sql.strip().format(**parameters)
    start_time = datetime.datetime.now()
    result = conn.execute(text(sql), param_array)
    log(
        debug_level,
        "%d rows in %.3fs",
        result.rowcount,
        (datetime.datetime.now() - start_time).total_seconds(),
    )
    return result


def executemany_raw(conn, sql, parameters, param_array, debug_level=logging.DEBUG):
    sql = sql.strip().format(**parameters)
    start_time = datetime.datetime.now()
    result = conn.execute(sql, param_array)
    log(
        debug_level,
        "%d rows in %.3fs",
        result.rowcount,
        (datetime.datetime.now() - start_time).total_seconds(),
    )
    return result


def tabulate(res):
    """Format and output a rowset

    Uses an output format similar to the one produced by the mysql commandline
    utility.

    """
    cols = range(0, len(res.keys()))
    rowlen = dict()
    a = []

    def line():
        for i in cols:
            a.append("+")
            a.append("-" * (rowlen[i] + 2))
        a.append("+\n")

    # convert database types to strings
    rows = []
    for row in res.fetchall():
        newrow = []
        for i in cols:
            if row[i] is None:
                newrow.append("NULL")
            else:
                newrow.append(str(row[i]))
        rows.append(newrow)

    # calculate column widths
    for i in cols:
        rowlen[i] = len(res.keys()[i])

    for row in rows:
        for i in cols:
            rowlen[i] = max(rowlen[i], len(row[i]))

    # output header
    line()
    for i in cols:
        a.append("| {:<{align}} ".format(res.keys()[i], align=rowlen[i]))
    a.append("|\n")
    line()

    # output rows
    for row in rows:
        for i in cols:
            a.append("| {:<{align}} ".format(row[i], align=rowlen[i]))
        a.append("|\n")
    line()
    a.append("%d rows\n" % len(rows))

    return "".join(a)


class MySQLEngine(object):
    """Database Interface"""

    def __init__(self, fn=MYSQL_DEFAULT_FILES, group=MYSQL_DEFAULT_GROUPS, db=""):
        # self.params is only needed to configure the MySQL FDW in Postgres
        self.params = self.get_connection_params(fn, group)
        self.params["database"] = db

        url = sqlalchemy.engine.url.URL(**(dict(self.params, password="secret")))
        log(logging.INFO, "MySQLEngine: Connecting to URL: {url}".format(url=url))
        url = sqlalchemy.engine.url.URL(**self.params)
        self.engine = sqlalchemy.create_engine(url)

        self.connection = self.connect()

    @staticmethod
    def get_connection_params(filenames, groups):
        if isinstance(filenames, str):
            filenames = [filenames]
        if isinstance(groups, str):
            groups = [groups]

        filenames = map(os.path.expanduser, filenames)
        config = configparser.ConfigParser()
        config.read(filenames)
        parameters = {
            "drivername": "drivername",
            "host": "host",
            "port": "port",
            "database": "database",
            "user": "username",
            "password": "password",
        }
        options = {
            "default-character-set": "charset",
        }
        params = {
            "drivername": "mysql",
            "host": "localhost",
            "port": "3306",
            "query": {
                "charset": "utf8mb4",
            },
        }

        for group in groups:
            if group in config:
                section = config[group]
                for key, alias in parameters.items():
                    if key in section:
                        params[alias] = section[key].strip('"')
                for key, alias in options.items():
                    if key in section:
                        params["query"][alias] = section[key].strip('"')
        return params

    def connect(self):
        connection = self.engine.connect()
        # Make MySQL more compatible with other SQL databases
        connection.execute("SET sql_mode='ANSI'")
        return connection


def load_feature_matrix(conn):
    res = execute(
        conn,
        """
    SELECT pm2.meta_value, pm1.meta_value
    FROM wp_posts p
    JOIN wp_postmeta pm1 ON (p.ID = pm1.post_id)
    JOIN wp_postmeta pm2 ON (p.ID = pm2.post_id)
    WHERE p.post_parent = 58
      AND pm1.meta_key = 'msitem-corresp' AND pm1.meta_value REGEXP '^(BK|Mordek)'
      AND pm2.meta_key = 'tei-xml-id'
    GROUP BY 1, 2
    ORDER BY 1, 2
    """,
        dict(),
    )

    mss_bks = list(map(collections.namedtuple("MSS_BKS", "ms bk")._make, res))

    mss = set()
    bks = set()
    for t in mss_bks:
        mss.add(t.ms)
        bks.add(t.bk)

    mss = sorted(mss, key=cluster.natural_sort_key)
    bks = sorted(bks, key=cluster.natural_sort_key)

    inv_mss = {ms: n for n, ms in enumerate(mss)}
    inv_bks = {bk: n for n, bk in enumerate(bks)}

    print("mss: %d" % len(mss))
    print("bks: %d" % len(bks))
    print("mss_bks: %d" % len(mss_bks))

    feature_matrix = np.zeros((len(bks), len(mss)), dtype=bool)
    for t in mss_bks:
        feature_matrix[inv_bks[t.bk], inv_mss[t.ms]] = True

    return feature_matrix, bks, mss


if __name__ == "__main__":

    db = MySQLEngine("~/.my.cnf.capitularia", "mysql", "capitularia")
    with db.engine.begin() as conn:
        tf_kd, bklabels, mslabels = load_feature_matrix(conn)

        cluster.process(tf_kd, bklabels, mslabels)
