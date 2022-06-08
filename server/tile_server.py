#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""A tile server for Capitularia.

This is a simple OpenStreetMap-style tile server using mapnik to render the
tiles.

The probability of the client requesting adjacent tiles is very high.  To speed
things up, we ask mapnik to render a bigger "metatile", which we cut into tiles
and then cache the tiles.  We also add some padding around the metatile, which
helps avoiding ugly label placement when a label is near a metatile border.

"""

import math
import os.path

from flask import abort, current_app, make_response, Blueprint
from cachelib import SimpleCache
import mapnik
import cairo

import common


class Config(object):
    TILE_LAYERS = [
        {
            "id": "ne",
            "title": "Natural Earth",
            "attribution": common.NATEARTH2019,
            "map_style": "mapnik-natural-earth.xml",
            "type": "base",
        },
        {
            "id": "vl",
            "title": "LaBlache - Empire de Charlemagne 843",
            "attribution": common.VIDAL1898,
            "map_style": "mapnik-vidal-lablache.xml",
            "type": "overlay",
        },
        {
            "id": "sh",
            "title": "Shepherd - Carolingian Empire 843-888",
            "attribution": common.SHEPHERD1911,
            "map_style": "mapnik-shepherd.xml",
            "type": "overlay",
        },
        {
            "id": "dr",
            "title": "Droysen - Deutschland um das Jahr 1000",
            "attribution": common.DROYSEN1886,
            "map_style": "mapnik-droysen-1886.xml",
            "type": "overlay",
        },
    ]


MIN_ZOOM = 5
MAX_ZOOM = 9

TILE_SIZE = 256  # standard openstreetmap tile size
METATILE_FACTOR = 8  # size of a metatile is N x N tiles
PADDING_FACTOR = 0.25  # padding added around metatile

TILE_CACHE_SIZE = 4096  # how many tiles to cache (as png)
TILE_CACHE_TIMEOUT = 3600  # in seconds

PADDING_SIZE = int(PADDING_FACTOR * TILE_SIZE)
METATILE_SIZE = (METATILE_FACTOR * TILE_SIZE) + (2 * PADDING_SIZE)

epsg3857 = mapnik.Projection("+init=epsg:3857")  # OpenstreetMap  https://epsg.io/3857
# epsg3857 = mapnik.Projection ("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +over")
# epsg4326 = mapnik.Projection ("+init=epsg:4326") # WGS84 / GPS    https://epsg.io/4326


class Render:
    def __init__(self, app, layer):
        self.app = app
        self.mapid = layer["id"]

        self.map = mapnik.Map(METATILE_SIZE, METATILE_SIZE)
        mapnik.load_map(self.map, os.path.join(app.root_path, layer["map_style"]))

    def render_with_agg(self, tile_size):
        """Render tile with Agg renderer."""
        img = mapnik.Image(tile_size, tile_size)
        mapnik.render(self.map, img)
        return img

    def render_with_cairo(self, tile_size):
        """Render tile with cairo renderer."""
        surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, tile_size, tile_size)
        mapnik.render(self.map, surface)
        return mapnik.Image.from_cairo(surface)

    # @staticmethod
    # def deg2num (lat_deg, lon_deg, zoom):
    #     """ Pilfered from: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Python """
    #     lat_rad = math.radians (lat_deg)
    #     n = 2.0 ** zoom
    #     xtile = int ((lon_deg + 180.0) / 360.0 * n)
    #     ytile = int ((1.0 - math.log (math.tan (lat_rad) + (1 / math.cos (lat_rad))) / math.pi) / 2.0 * n)
    #     return (xtile, ytile)

    @staticmethod
    def num2deg(xtile, ytile, zoom):
        """
        Tile coords to epsg 4326
        Pilfered from: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Python
        """
        n = 2.0**zoom  # divide the equator into n tiles
        lon_deg = (xtile / n * 360.0) - 180.0
        lat_rad = math.atan(math.sinh(math.pi * (1 - (2 * ytile / n))))
        lat_deg = math.degrees(lat_rad)
        return (lat_deg, lon_deg)

    def key(self, zoom, xtile, ytile):
        return "T/%s/%d/%d/%d" % (self.mapid, zoom, xtile, ytile)

    def render_metatile(self, zoom, xtile, ytile):
        """Render a tile N times bigger than delivered ones."""

        self.app.logger.info(
            "render_metatile: {mapid}/{zoom}/{x}/{y}".format(
                mapid=self.mapid, zoom=zoom, x=xtile, y=ytile
            )
        )

        s, w = self.num2deg(
            xtile + PADDING_FACTOR, ytile + PADDING_FACTOR + METATILE_FACTOR, zoom
        )
        n, e = self.num2deg(
            xtile - PADDING_FACTOR + METATILE_FACTOR, ytile - PADDING_FACTOR, zoom
        )

        # mapnik bounding box for the tile in lat/lng
        bbox = mapnik.Box2d(w, s, e, n)
        bbox = bbox.forward(epsg3857)

        self.map.zoom_to_box(bbox)

        img = self.render_with_agg(METATILE_SIZE)
        # img = self.render_with_cairo (METATILE_SIZE)

        # cut up the metatile and cache it
        for i in range(0, METATILE_FACTOR):
            for j in range(0, METATILE_FACTOR):
                key = self.key(zoom, xtile + i, ytile + j)
                x = i * TILE_SIZE + PADDING_SIZE
                y = j * TILE_SIZE + PADDING_SIZE
                tile = img.view(x, y, TILE_SIZE, TILE_SIZE)
                current_app.tile_cache.set(key, tile.tostring("png256"))

    def render_tile(self, zoom, xtile, ytile):
        """Render one tile.

        Render a tile N times bigger than the requested one,
        cache it, then cut it up and deliver the requested piece.
        """

        key = self.key(zoom, xtile, ytile)
        tile = current_app.tile_cache.get(key)
        if tile is not None:
            return tile

        self.app.logger.info(
            "render_tile: {mapid}/{zoom}/{x}/{y}".format(
                mapid=self.mapid, zoom=zoom, x=xtile, y=ytile
            )
        )

        # render the metatile and cache its pieces
        meta_xtile = (xtile // METATILE_FACTOR) * METATILE_FACTOR
        meta_ytile = (ytile // METATILE_FACTOR) * METATILE_FACTOR
        self.render_metatile(zoom, meta_xtile, meta_ytile)

        # retrieve the tile
        return current_app.tile_cache.get(key)


renderers = {}


class tileBlueprint(Blueprint):
    def init_app(self, app):
        app.config.from_object(Config)

        for layer in app.config["TILE_LAYERS"]:
            renderers[layer["id"]] = Render(app, layer)

        app.tile_cache = SimpleCache(
            threshold=TILE_CACHE_SIZE, default_timeout=TILE_CACHE_TIMEOUT
        )
        # app.tile_cache = FileSystemCache ('cache' ...)


tile_app = tileBlueprint("tile_server", __name__)


@tile_app.route("/<mapid>/<int:zoom>/<int:xtile>/<int:ytile>.png")
def tile_png(mapid, zoom, xtile, ytile):
    """Tile endpoint: serve a tile as PNG."""

    if zoom < MIN_ZOOM or zoom > MAX_ZOOM:
        abort(400, "Unrealistic zoom")

    if mapid not in renderers:
        abort(400, "No such map")

    tile = renderers[mapid].render_tile(zoom, xtile, ytile)

    return make_response(
        tile,
        200,
        {
            "Content-Type": "image/png",
            "Cache-Control": "public, max-age=3600",
        },
    )


@tile_app.route("/")
def info_json():
    """Info endpoint: send information about server and available layers."""

    i = {
        "title": "Capitularia Tile Server",
        "min_zoom": MIN_ZOOM,
        "max_zoom": MAX_ZOOM,
        "layers": current_app.config["TILE_LAYERS"],
    }
    return common.make_json_response(i, 200)
