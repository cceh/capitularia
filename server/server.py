#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""API server for Capitularia."""

import argparse
import collections
import io
import re
import os
import os.path
import math
import urllib.parse

import flask
from flask import request, current_app
import flask_sqlalchemy

import mapnik
import requests
import cairo

from . import db_tools
from .db_tools import execute, log
from . import db

MAX_ZOOM = 18
TILE_SIZE = 256
METATILE_SIZE = 8

app  = flask.Flask (__name__)
map_ = mapnik.Map (TILE_SIZE, TILE_SIZE)
mapnik.load_map (map_, os.path.join (os.path.dirname (os.path.abspath (__file__)), "mapnik-style.xml"))

epsg3857 = mapnik.Projection ("+init=epsg:3857") # OpenstreetMap  https://epsg.io/3857
epsg4326 = mapnik.Projection ("+init=epsg:4326") # WGS84 / GPS    https://epsg.io/4326


def make_json_response (json = None, status = 200, message = None):
    d = dict (status = status)
    if json:
        d['data'] = json
    if message:
        d['message'] = message
    return flask.make_response (flask.json.jsonify (d), status, {
        'Content-Type' : 'application/json;charset=utf-8',
        'Access-Control-Allow-Origin' : '*',
    })


def make_geojson_response (rows, fields):
    """Make a geoJSON response.

    The geometry must be in the first field.  All other fields become
    properties.

    GeoJSON specs: https://tools.ietf.org/html/rfc7946

    """

    fields = collections.namedtuple ('GeoJSONFields', fields)
    geo_field_name = fields._fields[0]

    features = []
    for row in rows:
        d = fields._make (row)
        properties = d._asdict ()
        del properties[geo_field_name]
        feature = {
            'type'       : 'Feature',
            'geometry'   : d[0],
            'properties' : properties,
        }
        features.append (feature)

    response = flask.make_response (flask.json.jsonify ({
        'type'     : 'FeatureCollection',
        'features' : features,
    }), 200)
    response.headers['Content-Type'] = 'application/geo+json;charset=utf-8'
    response.headers['Access-Control-Allow-Origin'] =  '*'
    return response


def openstreetmap_zoom (level, lat = 0.0):
    """ return the size of one pixel in the real world in meters at the selected zoom level """
    return (2.0 * math.pi * 6372798.2) * math.cos (lat) / (2 ** (level + 8))


@app.endpoint ('index')
def index ():
    """ Return a greeting. """

    return flask.Response ('hello, world!', mimetype = 'text/plain')


class Render:
    def __init__ (self, map_):
        self.map = map_

    def render_with_agg (self, tile_size):
        # Render image with default Agg renderer
        img = mapnik.Image (tile_size, tile_size)
        mapnik.render (self.map, img)
        return img

    def render_with_cairo (self, tile_size):
        # Render image with cairo renderer
        surface = cairo.ImageSurface (cairo.FORMAT_ARGB32, tile_size, tile_size)
        mapnik.render (self.map, surface)
        return mapnik.Image.from_cairo (surface)

    @staticmethod
    def deg2num (lat_deg, lon_deg, zoom):
        """ Pilfered from: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Python """
        lat_rad = math.radians(lat_deg)
        n = 2.0 ** zoom
        xtile = int((lon_deg + 180.0) / 360.0 * n)
        ytile = int((1.0 - math.log(math.tan(lat_rad) + (1 / math.cos(lat_rad))) / math.pi) / 2.0 * n)
        return (xtile, ytile)

    @staticmethod
    def num2deg (xtile, ytile, zoom):
        """
        Tile number to epsg 4326
        Pilfered from: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Python
        """
        n = 2.0 ** zoom
        lon_deg = xtile / n * 360.0 - 180.0
        lat_rad = math.atan(math.sinh(math.pi * (1 - 2 * ytile / n)))
        lat_deg = math.degrees(lat_rad)
        return (lat_deg, lon_deg)

    def render_tile (self, xtile, ytile, zoom, tile_size = TILE_SIZE):
        """

        """
        s, w = self.num2deg (xtile,     ytile + 1, zoom)
        n, e = self.num2deg (xtile + 1, ytile,     zoom)

        # log (logging.INFO, "NE: {0:.6f}/{1:.6f}".format (n, e))
        # log (logging.INFO, "SW: {0:.6f}/{1:.6f}".format (s, w))

        # mapnik bounding box for the tile in lat/lng
        bbox = mapnik.Box2d (w, s, e, n)
        bbox = bbox.forward (epsg3857)

        # log (logging.INFO, str (bbox))

        self.map.zoom_to_box (bbox)
        #self.map.zoom_all ()

        img = self.render_with_agg (tile_size)
        #img = self.render_with_cairo (tile_size)

        view = img.view (0, 0, tile_size, tile_size)
        return view.tostring ('png256')


@app.endpoint ('tile.png')
def tile_png (zoom, xtile, ytile, type_='png'):
    """ Return a png tile. """

    rd  = Render (map_)
    png = rd.render_tile (xtile, ytile, zoom)

    return flask.Response (png, mimetype = 'image/png')


@app.endpoint ('places.json')
def places_json ():
    """ Return all places. """

    FIELDS = 'geo, name, geo_id'

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT %s
        FROM geonames_view
        ORDER BY name
        """ % FIELDS, {})

        return make_geojson_response (res, FIELDS)


@app.endpoint ('msparts.json')
def msparts_json ():
    """ Return location of all manuscript parts. """

    FIELDS = 'geo, ms_id, title, ms_part, notbefore, notafter, geo_id, name, fcode'

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT %s
        FROM msparts_view
        ORDER BY ms_id, ms_part
        """ % FIELDS, {})

        return make_geojson_response (res, FIELDS)


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


class DefaultConfig (object):
    APPLICATION_HOST = 'localhost'
    APPLICATION_PORT = 5000


if __name__ == "__main__":
    from werkzeug.routing import Map, Rule
    from werkzeug.wsgi import DispatcherMiddleware
    from werkzeug.serving import run_simple
    import logging

    args, dummy = db_tools.init_cmdline (build_parser ())

    app.logger.setLevel (args.log_level)

    app.config.from_object (DefaultConfig)
    app.config.from_pyfile (args.config_path)

    app.config['server_start_time'] = str (int (args.start_time.timestamp ()))
    app.config.dba = db_tools.PostgreSQLEngine (**app.config)

    app.url_map = Map ([
        Rule ('/',                                             endpoint = 'index'),
        Rule ('/tile/<int:zoom>/<int:xtile>/<int:ytile>.png',  endpoint = 'tile.png'),
        Rule ('/places.json',                                  endpoint = 'places.json'),
        Rule ('/msparts.json',                                 endpoint = 'msparts.json'),
    ])

    log (logging.INFO, "Mounted {name} at {host}:{port} from conf {conf}".format (
        name = app.config['APPLICATION_NAME'],
        host = app.config['APPLICATION_HOST'],
        port = app.config['APPLICATION_PORT'],
        conf = args.config_path)
    )

    run_simple (app.config['APPLICATION_HOST'], app.config['APPLICATION_PORT'], app)
