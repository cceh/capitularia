#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""API server for Capitularia.

Georeferencing Maps
-------------------

- Find a suitable map

- Open the Gimp
- Perspective correct the map
- Crop the map

- Open QGIS
- Select Raster | Georeferencer
- Add GCPs
- Settings
- Start Georeferencing

Paris Meridian: 2.337208333333°

"""

import argparse
import logging
import os.path
import time

import flask
from flask import request, current_app
from werkzeug.routing import Map, Rule, Submount

import common
import db_tools
from db_tools import log

from tile_server import tile_app
from geo_server  import geo_app


class Config (object):
    def __init__ (self):
        self.APPLICATION_HOST  = 'localhost'
        self.APPLICATION_PORT  = 5000
        self.LOG_LEVEL         = logging.WARN
        self.USE_RELOADER      = False
        self.USE_DEBUGGER      = False
        self.SERVER_START_TIME = str (time.time ()) # for cache busting

CONFIG = Config ()

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
    app = flask.Flask (__name__)

    app.config.from_object (CONFIG)
    app.config.from_pyfile (config_path)

    app.logger.setLevel (CONFIG.LOG_LEVEL)

    app.config.dba = db_tools.PostgreSQLEngine (**app.config)

    app.register_blueprint (tile_app)
    app.register_blueprint (geo_app)

    app.url_map = Map ([
        Submount ('/tile', [
            Rule ('/<mapid>/<int:zoom>/<int:xtile>/<int:ytile>.png',  endpoint = 'tile.png'),
        ]),
        Submount ('/geo', [
            Rule ('/places/mss.json',          endpoint = 'geo_places_mss.json'),
            Rule ('/places/msparts.json',      endpoint = 'geo_places_msparts.json'),
            Rule ('/places/capitularies.json', endpoint = 'geo_places_capitularies.json'),
            Rule ('/capitularies.json',        endpoint = 'geo_capitularies.json'),
            Rule ('/capitularies.csv',         endpoint = 'geo_capitularies.csv'),
            Rule ('/msparts.json',             endpoint = 'geo_msparts.json'),
            Rule ('/msparts.csv',              endpoint = 'geo_msparts.csv'),
            Rule ('/mss.json',                 endpoint = 'geo_mss.json'),
            Rule ('/mss.csv',                  endpoint = 'geo_mss.csv'),
            Rule ('/extent',                   endpoint = 'geo_extent_all.json'),
        ]),
    ])

    return app


if __name__ == "__main__":
    from werkzeug.serving import run_simple

    args = build_parser ().parse_args ()
    args = common.init_logging (args)

    CONFIG.LOG_LEVEL = args.log_level

    app = create_app (args.config_path)

    log (logging.INFO, "Mounted {name} at {host}:{port} from conf {conf}".format (
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
