#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Tile server API for Capitularia. """

import math
import os.path

import flask
# from flask import request, current_app, Blueprint

import mapnik
import cairo

MAP_STYLES = {
    'ne' : 'mapnik-natural-earth.xml',
    'vl' : 'mapnik-vidal-lablache.xml',
    'sh' : 'mapnik-shepherd.xml',
}

MAX_ZOOM = 18
TILE_SIZE = 256
METATILE_SIZE = 8
DIR = os.path.dirname (os.path.abspath (__file__))

epsg3857 = mapnik.Projection ("+init=epsg:3857") # OpenstreetMap  https://epsg.io/3857
epsg4326 = mapnik.Projection ("+init=epsg:4326") # WGS84 / GPS    https://epsg.io/4326

tile_app = flask.Blueprint ('tile_server', __name__)

MAPS = {}

for mapid in MAP_STYLES:
    map_ = mapnik.Map (TILE_SIZE, TILE_SIZE)
    mapnik.load_map (map_, os.path.join (DIR, MAP_STYLES[mapid]))
    MAPS[mapid] = map_


def openstreetmap_zoom (level, lat = 0.0):
    """ return the size of one pixel in the real world in meters at the selected zoom level """
    return (2.0 * math.pi * 6372798.2) * math.cos (lat) / (2 ** (level + 8))


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


@tile_app.endpoint ('tile.png')
def tile_png (mapid, zoom, xtile, ytile, type_='png'):
    """ Return a png tile. """

    rd  = Render (MAPS[mapid])
    png = rd.render_tile (xtile, ytile, zoom)

    return flask.Response (png, mimetype = 'image/png')
