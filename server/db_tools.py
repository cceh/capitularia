# -*- encoding: utf-8 -*-

""" This module contains helper functions for database access, config and logging. """

import collections
import csv
import configparser
import datetime
import io
import logging
import os
import os.path
import types

import sqlalchemy
from sqlalchemy.sql import text

class Args:
    pass

COLORS = {
    logging.CRITICAL : ('\x1B[38;2;255;0;0m', '\x1B[0m'),
    logging.ERROR    : ('\x1B[38;2;255;0;0m', '\x1B[0m'),
    logging.WARN     : ('', ''),
    logging.INFO     : ('', ''),
    logging.DEBUG    : ('', ''),
}

# colorize error log
old_factory = logging.getLogRecordFactory ()

def record_factory (*args, **kwargs):
    record = old_factory (*args, **kwargs)
    record.esc0, record.esc1 = COLORS[record.levelno]
    return record

logging.setLogRecordFactory (record_factory)

logger = logging.getLogger ()

def config_from_pyfile (filename):
    """Mimic Flask config files.

    Emulate the Flask config file parser so we can use the same config files for both,
    the server and this script.

    """

    d = types.ModuleType ('config')
    d.__file__ = filename
    try:
        with open (filename) as config_file:
            exec (compile (config_file.read (), filename, 'exec'), d.__dict__)
    except IOError as e:
        e.strerror = 'Unable to load configuration file (%s)' % e.strerror
        raise

    conf = {}
    for key in dir (d):
        if key.isupper ():
            conf[key] = getattr (d, key)
    return conf


def init_cmdline (parser):
    """ Init the commandline parameter stuff. """

    args = Args ()
    parser.parse_args (namespace = args)

    args.start_time = datetime.datetime.now ()
    LOG_LEVELS = {
        0: logging.CRITICAL,  #
        1: logging.ERROR,     # -v
        2: logging.WARN,      # -vv
        3: logging.INFO,      # -vvv
        4: logging.DEBUG      # -vvvv
    }
    args.log_level = LOG_LEVELS.get (args.verbose, logging.DEBUG)

    logging.getLogger ().setLevel (args.log_level)
    formatter = logging.Formatter (
        fmt = '{esc0}{relativeCreated:6.0f} - {levelname:7} - {message}{esc1}',
        style='{'
    )

    stderr_handler = logging.StreamHandler ()
    stderr_handler.setFormatter (formatter)
    logging.getLogger ().addHandler (stderr_handler)

    file_handler = logging.FileHandler ('server.log')
    file_handler.setFormatter (formatter)
    logging.getLogger ().addHandler (file_handler)

    if args.log_level == logging.INFO:
        # sqlalchemy is way too verbose on level INFO
        sqlalchemy_logger = logging.getLogger ('sqlalchemy.engine')
        sqlalchemy_logger.setLevel (logging.WARN)


    try:
        return args, config_from_pyfile (args.config_path)
    except:
        return args, None

def quote (s):
    if ' ' in s:
        return '"' + s + '"'
    return s


def log (level, msg, *aargs, **kwargs):
    """
    Low level log function
    """

    logger.log (level, msg, *aargs)



# mimics mysql Ver 15.1 Distrib 10.1.29-MariaDB
MYSQL_DEFAULT_FILES  = ( '/etc/my.cnf', '/etc/mysql/my.cnf', '~/.my.cnf' )
MYSQL_DEFAULT_GROUPS = ( 'mysql', 'client', 'client-server', 'client-mariadb' )


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


# def execute_pandas (conn, sql, parameters, debug_level = logging.DEBUG):
#     sql = sql.format (**parameters)
#     log (debug_level, sql.rstrip () + ';')
#     return pd.read_sql_query (text (sql), conn, parameters)

def _debug (conn, msg, sql, parameters, level):
    # print values
    if logging.getLogger ().getLevel () <= level:
        result = execute (conn, sql, parameters)
        if result.rowcount > 0:
            log (level, msg + '\n' + tabulate (result))

def debug (conn, msg, sql, parameters):
    _debug (conn, msg, sql, parameters, logging.DEBUG)

def warn (conn, msg, sql, parameters):
    _debug (conn, msg, sql, parameters, logging.WARNING)


def to_csv (fields, rows):
    fp = io.StringIO ()
    writer = csv.DictWriter (fp, fields, restval='', extrasaction='raise', dialect='excel')
    writer.writeheader ()
    for r in rows:
        writer.writerow (r._asdict ())
    return fp.getvalue ()


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


class MySQLEngine ():
    """ Database Interface """

    def __init__ (self, fn = MYSQL_DEFAULT_FILES, group = MYSQL_DEFAULT_GROUPS):
        # self.params is only needed to configure the MySQL FDW in Postgres
        self.params = self.get_connection_params (fn, group)

        url = sqlalchemy.engine.url.URL (**(dict (self.params, password = 'password')))
        log (logging.DEBUG, 'MySQLEngine: Connecting to URL: {url}'.format (url = url))
        url = sqlalchemy.engine.url.URL (**self.params)
        self.engine = sqlalchemy.create_engine (url)

        self.connection = self.connect ()
        self.url = url


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


class PostgreSQLEngine ():
    """ PostgreSQL Database Interface """

    @staticmethod
    def on_checkout (dbapi_connection, connection_record, connection_proxy):
        """Whenever a new connection is checkd out of the pool. """

        # dbapi_connection.cursor ().execute (" ... ")
        pass

    def __init__ (self, **kwargs):

        args = self.get_connection_params (kwargs)

        self.url = 'postgresql+psycopg2://{user}@{host}:{port}/{database}?server_side_cursors'.format (**args)

        log (logging.DEBUG, "PostgreSQLEngine: Connecting to URL: {url}".format (url = self.url))

        self.engine = sqlalchemy.create_engine (
            self.url,
            use_batch_mode = True
        )

        self.params = args

        sqlalchemy.event.listen (self.engine, 'checkout', self.on_checkout)


    def connect (self):
        return self.engine.connect ()


    def get_connection_params (self, args = {}):
        """Get sqlalchemy connection parameters.

        Try to get the connection parameters in turn from these sources:

        1. get host, port, database, user from args
        2. get PGHOST, PGPORT, PGDATABASE, PGUSER from args
        3. get PGHOST, PGPORT, PGDATABASE, PGUSER from environment
        4. use defaults

        N.B. The postgres client library automatically reads the password from
        the file :file:`~/.pgpass`.  It should be configured there.

        """

        defaults = {
            'host'     : 'localhost',
            'port'     : '5432',
            'user'     : None,
            'database' : None,
        }
        res = {}

        for p in defaults:
            pu = 'PG' + p.upper ()
            res[p] = args.get (p) or args.get (pu) or os.environ.get (pu) or defaults[p]

        return res

    def vacuum (self):
        """Vacuum the database."""

        # turn off auto-transaction because vacuum won't work in a transaction
        connection = self.engine.raw_connection ()
        connection.set_isolation_level (0)
        connection.cursor ().execute ("VACUUM FULL ANALYZE")
        log (logging.INFO, ''.join (connection.notices))
