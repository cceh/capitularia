#!/usr/bin/python3
# -*- encoding: utf-8 -*-

""" Repository for common tools. """

import collections
import csv
import io
import logging
import re
import requests
import types

import flask
from flask import abort, current_app, request

RE_WS    = re.compile ('(\s+)')
RE_CAP   = re.compile ('^([bkmorde]*)[._ ]*(\d+)', re.IGNORECASE)

LAST_BK      = 307
LAST_MORDEK  = 27


def make_json_response (json = None, status = 200):
    return flask.make_response (flask.json.jsonify (json), status, {
        'Content-Type' : 'application/json;charset=utf-8',
    })


def make_geojson_response (rows, fields, geometry_field_name = 'geom', id_field_name='geo_id'):
    """Make a geoJSON response.

    All fields except the id and geometry fields become properties.

    GeoJSON specs: https://tools.ietf.org/html/rfc7946

    """

    fields = collections.namedtuple ('GeoJSONFields', fields)

    features = []
    for row in rows:
        d = fields._make (row)
        properties = d._asdict ()
        feature = {
            'type'       : 'Feature',
            'id'         : properties[id_field_name],
            'geometry'   : properties[geometry_field_name],
            'properties' : properties,
        }
        del properties[geometry_field_name]
        # del properties[id_field_name]
        features.append (feature)

    response = flask.make_response (flask.json.jsonify ({
        'type'     : 'FeatureCollection',
        'features' : features,
    }), 200, {
        'Content-Type' : 'application/geo+json;charset=utf-8',
    })
    return response


def make_csv_response (rows, fields):
    """ Send a HTTP response in CSV format. """

    fields = collections.namedtuple ('CSVFields', fields)
    rows = list (map (fields._make, rows))

    return flask.make_response (to_csv (fields._fields, rows), 200, {
        'Content-Type' : 'text/csv;charset=utf-8',
    })


def to_csv (fields, rows):
    fp = io.StringIO ()
    writer = csv.DictWriter (fp, fields, restval='', extrasaction='raise', dialect='excel')
    writer.writeheader ()
    for r in rows:
        writer.writerow (r._asdict ())
    return fp.getvalue ()


def fix_ws (s):
    return RE_WS.sub (' ', s)

def text_content (e):
    return fix_ws (' '.join (e.xpath ('//text()')))

def fix_cap (s, default_prefix = 'b'):
    m = RE_CAP.match (s)
    if m:
        prefix = (m.group (1) or default_prefix).lower ()
        if prefix in ('b', 'bk'):
            return "BK_{0:03d}".format (int (m.group (2)))
        if prefix in ('m', 'mordek'):
            return "Mordek_{0:02d}".format (int (m.group (2)))
    return s

def fix_cap_range (s, default_prefix = 'bk'):
    """ Convert a range from user input into list of bk or mordek nos. """

    if not s:
        return

    res = []

    try:
        for value in s.split ():
            r = value.split ('-')
            if len (r) == 2:
                # a range eg. BK39-BK41, BK139-140, or M5-10
                if r[0] == '':
                    prefix0 = default_prefix.lower ()
                    suffix0 = 1
                else:
                    m = RE_CAP.match (r[0])
                    prefix0 = (m.group (1) or default_prefix).lower ()
                    suffix0 = int (m.group (2))

                if r[1] == '':
                    prefix1 = prefix0
                    suffix1 = LAST_MORDEK if prefix0 == 'm' else LAST_BK
                else:
                    m = RE_CAP.match (r[1])
                    prefix1 = (m.group (1) or prefix0).lower ()
                    suffix1 = int (m.group (2))

                if prefix0 != prefix1:
                    raise ValueError
                if suffix0 > suffix1:
                    raise ValueError

                for suffix in range (suffix0, suffix1 + 1):
                    res.append (fix_cap ("%s%d" % (prefix0, suffix)))

            elif len (r) == 1:
                res.append (fix_cap (value))

            else:
                raise ValueError

    except ValueError:
        raise ValueError ("error in range parameter")

    return res


def config_from_pyfile (filename):
    """Mimic Flask config files.

    Emulate the Flask config file parser so we can use the same config files for both,
    the Flask server and non-server scripts.

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


def init_logging (args):
    """ Init the logging stuff. """

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

    return args


def get_user_info_from_wp ():
    current_app.logger.info (request.cookies)
    r = requests.get (current_app.config['USER_INFO_ENDPOINT'], cookies = request.cookies)
    current_app.logger.info (r.text)

    if r.json ()['success']:
        return r.json ()['data']
    return {}


def assert_map ():
    info = get_user_info_from_wp ()
    if 'allcaps' in info and 'edit_pages' in info['allcaps']:
        return
    #abort (401, 'You have no "edit_pages" capability.')

    # FIXME: put this on the session
