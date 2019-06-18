#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""The API server for Capitularia."""

import argparse
import time

from flask import current_app, Flask
from werkzeug.routing import Map, Rule, Submount

import common
from db_tools import PostgreSQLEngine

from tile_server import tile_app
from geo_server  import geo_app


class Config (object):
    APPLICATION_HOST  = 'localhost'
    APPLICATION_PORT  = 5000
    CONFIG_FILE       = 'server.conf' # default relative to server.py
    USE_RELOADER      = False
    USE_DEBUGGER      = False
    SERVER_START_TIME = str (int (time.time ())) # for cache busting


DROYSEN1886  = 'Droysen, Gustav. Historischer Handatlas. Leipzig, 1886'
VIDAL1898    = 'Vidal-Lablache, Paul. Atlas général. Paris, 1898'
SHEPHERD1911 = 'Shepherd, William. Historical Atlas. New York, 1911'
NATEARTH2019 = '&copy; <a href="http://www.naturalearthdata.com/">Natural Earth</a>'
CAPITULARIA  = 'capitularia.uni-koeln.de'

Config.TILE_LAYERS = [
    {
        'id'          : 'ne',
        'title'       : 'Natural Earth',
        'attribution' : NATEARTH2019,
        'map_style'   : 'mapnik-natural-earth.xml',
        'type'        : 'base',
    },
    {
        'id'          : 'vl',
        'title'       : 'LaBlache - Empire de Charlemagne 843',
        'attribution' : VIDAL1898,
        'map_style'   : 'mapnik-vidal-lablache.xml',
        'type'        : 'overlay',
    },
    {
        'id'          : 'sh',
        'title'       : 'Shepherd - Carolingian Empire 843-888',
        'attribution' : SHEPHERD1911,
        'map_style'   : 'mapnik-shepherd.xml',
        'type'        : 'overlay',
    },
    {
        'id'          : 'dr',
        'title'       : 'Droysen - Deutschland um das Jahr 1000',
        'attribution' : DROYSEN1886,
        'map_style'   : 'mapnik-droysen-1886.xml',
        'type'        : 'overlay',
    },
]

Config.GEO_LAYERS = [
    {
        'id'          : 'countries_843',
        'title'       : 'Empire 843',
        'long_title'  : 'Empire de Charlemagne au Traité de Verdun 843',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_843.geojson',
        'attribution' : VIDAL1898,
        'type'        : 'area',
    },
    {
        'id'          : 'countries_870',
        'title'       : 'Boundaries 870',
        'long_title'  : 'Disruption of the Carolingian Empire, 843-888 (Mersen 870)',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_870.geojson',
        'attribution' : SHEPHERD1911,
        'type'        : 'area',
    },
    {
        'id'          : 'countries_888',
        'title'       : 'Boundaries 888',
        'long_title'  : 'Disruption of the Carolingian Empire, 843-888 (888)',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_888.geojson',
        'attribution' : SHEPHERD1911,
        'type'        : 'area',
    },
    {
        'id'          : 'regions_843',
        'title'       : 'Empire 843 (Pagi)',
        'long_title'  : 'Empire de Charlemagne au Traité de Verdun 843 (Pagi)',
        'classes'     : 'regions',
        'url'         : '/client/geodata/regions_843.geojson',
        'attribution' : VIDAL1898,
        'type'        : 'area',
    },
    {
        'id'          : 'regions_1000',
        'title'       : 'Deutschland um das Jahr 1000',
        'classes'     : 'regions',
        'url'         : '/client/geodata/droysen_1886_22_23.geojson',
        'attribution' : DROYSEN1886,
        'type'        : 'area',
    },
    {
        'id'          : 'countries_modern',
        'title'       : 'Modern Countries',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_modern.geojson',
        'attribution' : NATEARTH2019,
        'type'        : 'area',
    },
    {
        'id'          : 'mss',
        'title'       : 'Manuscripts',
        'classes'     : 'places mss',
        'url'         : 'geo/places/mss.json',
        'attribution' : CAPITULARIA,
        'type'        : 'place',
    },
    {
        'id'          : 'msp',
        'title'       : 'Manuscript Parts',
        'classes'     : 'places msparts',
        'url'         : 'geo/places/msparts.json',
        'attribution' : CAPITULARIA,
        'type'        : 'place',
    },
    {
        'id'          : 'cap',
        'title'       : 'Capitularies',
        'classes'     : 'places capitularies',
        'url'         : 'geo/places/capitularies.json',
        'attribution' : CAPITULARIA,
        'type'        : 'place',
    },
]


def build_parser (default_config_file):
    """ Build the commandline parser. """

    parser = argparse.ArgumentParser (description = __doc__)

    parser.add_argument (
        '-v', '--verbose', dest='verbose', action='count',
        help='increase output verbosity', default=0
    )
    parser.add_argument (
        '-c', '--config-file', dest='config_file',
        default=default_config_file, metavar='CONFIG_FILE',
        help="the config file (default='%s')" % default_config_file
    )
    return parser


def create_app (Config):
    app = Flask (__name__)

    app.config.from_object (Config)
    app.config.from_pyfile (Config.CONFIG_FILE)

    app.logger.setLevel (Config.LOG_LEVEL)

    app.config.dba = PostgreSQLEngine (**app.config)

    app.register_blueprint (tile_app, url_prefix = '/tile')
    tile_app.init_app (app)

    app.register_blueprint (geo_app, url_prefix = '/geo')
    geo_app.init_app (app)

    return app


if __name__ == "__main__":
    from werkzeug.serving import run_simple

    args = build_parser (Config.CONFIG_FILE).parse_args ()
    args = common.init_logging (args)

    Config.LOG_LEVEL   = args.log_level
    Config.CONFIG_FILE = args.config_file

    app = create_app (Config)

    @app.after_request
    def add_headers (response):
        response.headers['Access-Control-Allow-Origin'] = current_app.config['CORS_ALLOW_ORIGIN']
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Server'] = 'Jetty 0.8.15'
        return response

    app.logger.info ("Mounted {name} at {host}:{port} from conf {conf}".format (
        name = app.config['APPLICATION_NAME'],
        host = app.config['APPLICATION_HOST'],
        port = app.config['APPLICATION_PORT'],
        conf = Config.CONFIG_FILE
    ))

    run_simple (
        app.config['APPLICATION_HOST'],
        app.config['APPLICATION_PORT'],
        app,
        use_reloader=app.config['USE_RELOADER'],
        use_debugger=app.config['USE_DEBUGGER'],
        extra_files=[Config.CONFIG_FILE],
    )
