#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""The API server for Capitularia."""

import argparse
import os.path
import time

from flask import current_app, Flask
from werkzeug.routing import Map, Rule, Submount

import common
from db_tools import PostgreSQLEngine

from tile_server import tile_app
from geo_server  import geo_app


class Config (object):
    def __init__ (self):
        self.APPLICATION_HOST  = 'localhost'
        self.APPLICATION_PORT  = 5000
        self.USE_RELOADER      = False
        self.USE_DEBUGGER      = False
        self.SERVER_START_TIME = str (time.time ()) # for cache busting

CONFIG = Config ()

SHEPHERD1911 = 'Shepherd, William. Historical Atlas. New York, 1911'
VIDAL1898    = 'Vidal-Lablache, Paul. Atlas général. Paris, 1898'
NATEARTH2019 = '&copy; <a href="http://www.naturalearthdata.com/">Natural Earth</a>'

CONFIG.TILE_LAYERS = [
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
    }
]

CONFIG.GEO_LAYERS = [
    {
        'id'          : 'countries_843',
        'title'       : 'Countries Anno 843',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_843.geojson',
        'attribution' : VIDAL1898,
        'type'        : 'overlay',
    },
    {
        'id'          : 'regions_843',
        'title'       : 'Regions Anno 843',
        'classes'     : 'regions',
        'url'         : '/client/geodata/regions_843.geojson',
        'attribution' : VIDAL1898,
        'type'        : 'overlay',
    },
    {
        'id'          : 'countries_870',
        'title'       : 'Countries Anno 870',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_870.geojson',
        'attribution' : SHEPHERD1911,
        'type'        : 'overlay',
    },
    {
        'id'          : 'countries_888',
        'title'       : 'Countries Anno 888',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_888.geojson',
        'attribution' : SHEPHERD1911,
        'type'        : 'overlay',
    },
    {
        'id'          : 'countries_modern',
        'title'       : 'Countries Modern',
        'classes'     : 'countries',
        'url'         : '/client/geodata/countries_modern.geojson',
        'attribution' : NATEARTH2019,
        'type'        : 'overlay',
    },
]


def build_parser ():
    """ Build the commandline parser. """

    parser = argparse.ArgumentParser (description = __doc__)
    config_path = os.path.abspath (os.path.dirname (__file__) + '/server.conf')

    parser.add_argument (
        '-v', '--verbose', dest='verbose', action='count',
        help='increase output verbosity', default=0
    )
    parser.add_argument (
        '-c', '--config-path', dest='config_path',
        default=config_path, metavar='CONFIG_PATH',
        help="the config file (default='./server.conf')"
    )
    return parser


def create_app (config_path):
    app = Flask (__name__)

    app.config.from_object (CONFIG)
    app.config.from_pyfile (config_path)

    app.logger.setLevel (CONFIG.LOG_LEVEL)

    app.config.dba = PostgreSQLEngine (**app.config)

    app.register_blueprint (tile_app, url_prefix = '/tile')
    tile_app.init_app (app)

    app.register_blueprint (geo_app, url_prefix = '/geo')
    geo_app.init_app (app)

    return app


if __name__ == "__main__":
    from werkzeug.serving import run_simple

    args = build_parser ().parse_args ()
    args = common.init_logging (args)

    CONFIG.LOG_LEVEL = args.log_level

    app = create_app (args.config_path)

    @app.after_request
    def add_headers (response):
        response.headers['Access-Control-Allow-Origin'] = current_app.config['CORS_ALLOW_ORIGIN']
        response.headers['Server'] = 'Jetty 0.8.15'
        return response

    app.logger.info ("Mounted {name} at {host}:{port} from conf {conf}".format (
        name = app.config['APPLICATION_NAME'],
        host = app.config['APPLICATION_HOST'],
        port = app.config['APPLICATION_PORT'],
        conf = args.config_path
    ))

    run_simple (
        app.config['APPLICATION_HOST'],
        app.config['APPLICATION_PORT'],
        app,
        use_reloader=app.config['USE_RELOADER'],
        use_debugger=app.config['USE_DEBUGGER']
    )
