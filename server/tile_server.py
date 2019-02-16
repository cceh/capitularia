#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""A tile server for Capitularia.

This is a simple OpenStreetMap-style tile server using mapnik to render the
tiles.  The server has 2 levels of caching.

The probability of the client requesting adjacent tiles is very high.  To speed
things up, we ask mapnik to render a bigger "metatile", which we cache.  To make
a tile we find the cached metatile and cut the requested tile out.  We also add
some padding around the metatile, which helps avoiding broken labels when a
label is placed at a metatile border.

"""

import functools
import math
import os.path

from flask import abort, current_app, make_response, Blueprint
from werkzeug.routing import Map, Rule, Submount
import mapnik
import cairo

import common

MIN_ZOOM = 5
MAX_ZOOM = 9

TILE_SIZE       = 256     # standard openstreetmap tile size
METATILE_FACTOR =   4     # size of a metatile is N x N tiles
PADDING_FACTOR  =   0.25  # padding added around metatile

METATILE_CACHE_SIZE =   32  # how many metatiles to cache (as raw images)
TILE_CACHE_SIZE     = 4096  # how many tiles to cache (as png)

PADDING_SIZE  = int (PADDING_FACTOR * TILE_SIZE)
METATILE_SIZE = (METATILE_FACTOR * TILE_SIZE) + (2 * PADDING_SIZE)

epsg3857 = mapnik.Projection ("+init=epsg:3857") # OpenstreetMap  https://epsg.io/3857
#epsg4326 = mapnik.Projection ("+init=epsg:4326") # WGS84 / GPS    https://epsg.io/4326

class Render:
    def __init__ (self, app, layer):
        self.app   = app
        self.mapid = layer ['id']

        map_style_dir = os.path.dirname (os.path.abspath (__file__))
        self.map = mapnik.Map (METATILE_SIZE, METATILE_SIZE)
        mapnik.load_map (self.map, os.path.join (map_style_dir, layer['map_style']))


    def __hash__ (self):
        """ Make class usable with lru_cache. """
        return hash (self.mapid)

    def render_with_agg (self, tile_size):
        """ Render tile with Agg renderer. """
        img = mapnik.Image (tile_size, tile_size)
        mapnik.render (self.map, img)
        return img

    def render_with_cairo (self, tile_size):
        """ Render tile with cairo renderer. """
        surface = cairo.ImageSurface (cairo.FORMAT_ARGB32, tile_size, tile_size)
        mapnik.render (self.map, surface)
        return mapnik.Image.from_cairo (surface)

    # @staticmethod
    # def deg2num (lat_deg, lon_deg, zoom):
    #     """ Pilfered from: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Python """
    #     lat_rad = math.radians (lat_deg)
    #     n = 2.0 ** zoom
    #     xtile = int ((lon_deg + 180.0) / 360.0 * n)
    #     ytile = int ((1.0 - math.log (math.tan (lat_rad) + (1 / math.cos (lat_rad))) / math.pi) / 2.0 * n)
    #     return (xtile, ytile)

    @staticmethod
    def num2deg (xtile, ytile, zoom):
        """
        Tile coords to epsg 4326
        Pilfered from: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Python
        """
        n = 2.0 ** zoom    # divide the equator into n tiles
        lon_deg = (xtile / n * 360.0) - 180.0
        lat_rad = math.atan (math.sinh (math.pi * (1 - (2 * ytile / n))))
        lat_deg = math.degrees (lat_rad)
        return (lat_deg, lon_deg)

    @functools.lru_cache (maxsize = METATILE_CACHE_SIZE)
    def render_metatile (self, zoom, xtile, ytile):
        """Render a tile N times bigger than delivered ones."""

        self.app.logger.info ("render_metatile: {mapid}/{zoom}/{x}/{y}".format (
            mapid = self.mapid, zoom = zoom, x = xtile, y = ytile))

        s, w = self.num2deg (xtile + PADDING_FACTOR,                   ytile + PADDING_FACTOR + METATILE_FACTOR, zoom)
        n, e = self.num2deg (xtile - PADDING_FACTOR + METATILE_FACTOR, ytile - PADDING_FACTOR,                   zoom)

        # mapnik bounding box for the tile in lat/lng
        bbox = mapnik.Box2d (w, s, e, n)
        bbox = bbox.forward (epsg3857)

        self.map.zoom_to_box (bbox)

        img = self.render_with_agg (METATILE_SIZE)
        #img = self.render_with_cairo (METATILE_SIZE)

        return img


    @functools.lru_cache (maxsize = TILE_CACHE_SIZE)
    def render_tile (self, zoom, xtile, ytile):
        """ Render one tile.

        Render a tile N times bigger than the requested one,
        cache it, then cut it up and deliver the requested piece.
        """

        self.app.logger.info ("render_tile: {mapid}/{zoom}/{x}/{y}".format (
             mapid = self.mapid, zoom = zoom, x = xtile, y = ytile))

        meta_xtile = (xtile // METATILE_FACTOR) * METATILE_FACTOR
        meta_ytile = (ytile // METATILE_FACTOR) * METATILE_FACTOR

        # get eventually cached metatile
        metatile_img = self.render_metatile (zoom, meta_xtile, meta_ytile)

        x = (xtile - meta_xtile) * TILE_SIZE + PADDING_SIZE
        y = (ytile - meta_ytile) * TILE_SIZE + PADDING_SIZE

        # cut the metatile up
        tile = metatile_img.view (x, y, TILE_SIZE, TILE_SIZE)
        return tile.tostring ('png256')


renderers = {}

class tileBlueprint (Blueprint):
    def init_app (self, app):
        for layer in app.config['TILE_LAYERS']:
            renderers[layer['id']] = Render (app, layer)

tile_app = tileBlueprint ('tile_server', __name__)


@tile_app.route ('/<mapid>/<int:zoom>/<int:xtile>/<int:ytile>.png')
def tile_png (mapid, zoom, xtile, ytile):
    """ Tile endpoint: serve a tile as PNG. """

    if zoom < MIN_ZOOM or zoom > MAX_ZOOM:
        abort (400, "Unrealistic zoom")

    if mapid not in renderers:
        abort (400, "No such map")

    png = renderers[mapid].render_tile (zoom, xtile, ytile)

    return make_response (png, 200, {
        'Content-Type'  : 'image/png',
        'Cache-Control' : 'public, max-age=3600',
    })


@tile_app.route ('/')
def info_json ():
    """ Info endpoint: send information about server and available layers. """

    i = {
        'title'    : 'Capitularia Tile Server',
        'min_zoom' : MIN_ZOOM,
        'max_zoom' : MAX_ZOOM,
        'layers'   : current_app.config['TILE_LAYERS'],
    }
    return common.make_json_response (i, 200)
