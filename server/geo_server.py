#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Geo queries API server for Capitularia."""

from flask import abort, current_app, request, Blueprint

import common
from db_tools import execute


class geoBlueprint (Blueprint):
    def init_app (self, app):
        pass

geo_app  = geoBlueprint ('geo',  __name__)


def init_geo_query_params (conn):
    try:
        params = {
            'notbefore' : request.args.get ('notbefore') or 0,
            'notafter'  : request.args.get ('notafter')  or 3000,
            'where'     : " AND msp_date && int4range (:notbefore, :notafter, '[]') ",
        }

        capitularies = request.args.get ('capitularies')
        if capitularies:
            params['capitularies'] = tuple (common.fix_cap_range (capitularies))
            params['where'] += 'AND cap_id IN :capitularies '

    except ValueError:
        abort (400)

    return params


def init_geo_query_params_layer (conn):

    params = init_geo_query_params (conn)

    params['geo_source'] = request.args.get ('geo_source')
    params['geo_id']     = request.args.get ('geo_id')
    params['table']      = 'geonames' if params['geo_source'] == 'geonames' else 'geoareas'

    return params


@geo_app.route ('/places/mss.json')
def places_mss_json ():
    """ Return all places along with mss count. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT ST_AsGeoJSON (geom)::json AS geom, geo_id, geo_source, geo_name, geo_fcode, count (distinct ms_id) as count
        FROM msparts_view
          JOIN mn_msparts_capitularies USING (ms_id, ms_part)
        WHERE geo_source = 'geonames'
              {where}
        GROUP BY geom, geo_id, geo_source, geo_name, geo_fcode
        ORDER BY count DESC
        """, init_geo_query_params (conn))

        return common.make_geojson_response (res, 'geom, geo_id, geo_source, geo_name, geo_fcode, count')


@geo_app.route ('/places/msparts.json')
def places_msparts_json ():
    """ Return all places along with ms_part count. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT ST_AsGeoJSON (geom)::json AS geom, geo_id, geo_source, geo_name, geo_fcode, count (distinct ms_id || ms_part) as count
        FROM msparts_view
          JOIN mn_msparts_capitularies USING (ms_id, ms_part)
        WHERE geo_source = 'geonames'
              {where}
        GROUP BY geom, geo_id, geo_source, geo_name, geo_fcode
        ORDER BY count DESC
        """, init_geo_query_params (conn))

        return common.make_geojson_response (res, 'geom, geo_id, geo_source, geo_name, geo_fcode, count')


@geo_app.route ('/places/capitularies.json')
def places_capitularies_json ():
    """ Return all places along with capitularies count. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT ST_AsGeoJSON (geom)::json AS geom, geo_id, geo_source, geo_name, geo_fcode, count (distinct cap_id) as count
        FROM msparts_view msp
          JOIN mn_msparts_capitularies USING (ms_id, ms_part)
        WHERE geo_source = 'geonames'
              {where}
        GROUP BY geom, geo_id, geo_source, geo_name, geo_fcode
        ORDER BY count DESC
        """, init_geo_query_params (conn))

        return common.make_geojson_response (res, 'geom, geo_id, geo_source, geo_name, geo_fcode, count')


def _mss ():
    """ Return manuscripts with any part originated in some geolocation. """

    with current_app.config.dba.engine.begin () as conn:

        params = init_geo_query_params_layer (conn)

        # if no layer is specified get all mss
        if params['geo_source'] is None or params['geo_id'] is None:
            res = execute (conn, """
            SELECT ms_id, ms_title, min (msp_notbefore) as ms_notbefore, max (msp_notafter) - 1 as ms_notafter
            FROM msparts_view msp
              JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
            WHERE geo_source = 'geonames'
              {where}
            GROUP BY ms_id, ms_title
            ORDER BY ms_id
            """, params)

            return res

        # get all msparts contained in the geometry of layer:geo_id
        res = execute (conn, """
        SELECT ms_id, ms_title, min (msp_notbefore) as ms_notbefore, max (msp_notafter) - 1 as ms_notafter
        FROM msparts_view msp
          JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
          JOIN {table} ly ON (ST_contains (ly.geom, msp.geom))
        WHERE ly.geo_id = :geo_id AND ly.geo_source = :geo_source AND msp.geo_source = 'geonames'
          {where}
        GROUP BY ms_id, ms_title
        ORDER BY ms_id
        """, params)

        return res


@geo_app.route ('/mss.json')
def mss_json ():
    """ Return location of manuscripts as geojson response. """

    FIELDS = 'ms_id, ms_title, notbefore, notafter'

    return common.make_geojson_response (_mss (), FIELDS)


@geo_app.route ('/mss.csv')
def mss_csv ():
    """ Return location of manuscripts as CSV response. """

    FIELDS = 'ms_id, ms_title, notbefore, notafter'

    return common.make_csv_response (_mss (), FIELDS)


def _msparts ():
    """ Return manuscript parts originated in some geolocation. """

    with current_app.config.dba.engine.begin () as conn:

        params = init_geo_query_params_layer (conn)

        # if no layer is specified get all msparts
        if params['geo_source'] is None or params['geo_id'] is None:
            res = execute (conn, """
            SELECT ms_id, ms_part, ms_title, msp_head,
                   min (msp_notbefore) as ms_notbefore, max (msp_notafter) - 1 as ms_notafter
            FROM msparts_view msp
              JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
            WHERE geo_source = 'geonames'
              {where}
            ORDER BY ms_id, ms_part, ms_title, msp_head
            """, params)

            return res

        # get all msparts contained in the geometry of layer:geo_id
        res = execute (conn, """
        SELECT ms_id, ms_part, ms_title, msp_head,
               min (msp_notbefore) as ms_notbefore, max (msp_notafter) - 1 as ms_notafter
        FROM msparts_view msp
          JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
          JOIN {table} ly ON (ST_contains (ly.geom, msp.geom))
        WHERE ly.geo_id = :geo_id AND ly.geo_source = :geo_source AND msp.geo_source = 'geonames'
          {where}
        GROUP BY ms_id, ms_part, ms_title, msp_head
        ORDER BY ms_id, ms_part
        """, params)

        return res


@geo_app.route ('/msparts.json')
def msparts_json ():
    """ Return location of manuscript parts as geojson response. """

    FIELDS = 'ms_id, ms_part, ms_title, msp_head, notbefore, notafter'

    return common.make_geojson_response (_msparts (), FIELDS)


@geo_app.route ('/msparts.csv')
def msparts_csv ():
    """ Return location of manuscript parts as CSV response. """

    FIELDS = 'ms_id, ms_part, ms_title, msp_head, notbefore, notafter'

    return common.make_csv_response (_msparts (), FIELDS)


def _capitularies ():
    """ Return capitularies in manuscript parts originated in some geolocation. """

    with current_app.config.dba.engine.begin () as conn:

        params = init_geo_query_params_layer (conn)

        # if no layer is specified get all capitularies
        if params['geo_source'] is None or params['geo_id'] is None:
            res = execute (conn, """
            SELECT cap.cap_id, cap_title, lower (cap_date) as cap_notbefore, upper (cap_date) - 1as cap_notafter, count
            FROM capitularies cap
            JOIN (
              SELECT cap_id, count (*) as count
              FROM msparts_view msp
                JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
              WHERE geo_source = 'geonames'
                {where}
              GROUP BY cap_id
            ) AS foo USING (cap_id)
            """, params)

            return res

        # get all capitularies contained in any mss. originated in the geometry of layer:geo_id
        res = execute (conn, """
        SELECT cap.cap_id, cap_title, lower (cap_date) as cap_notbefore, upper (cap_date) - 1 as cap_notafter, count
        FROM capitularies cap
        JOIN (
          SELECT cap_id, count (*) as count
          FROM msparts_view msp
            JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
            JOIN {table} ly ON (ST_contains (ly.geom, msp.geom))
          WHERE ly.geo_id = :geo_id AND ly.geo_source = :geo_source AND msp.geo_source = 'geonames'
            {where}
          GROUP BY cap_id
        ) AS foo USING (cap_id)
        """, params)

        return res


@geo_app.route ('/capitularies.json')
def capitularies_json ():
    """ Return capitularies in geometry as geojson response. """

    FIELDS = 'geom, geo_id, geo_name, geo_fcode, cap_id, cap_title, notbefore, notafter, count'

    return common.make_geojson_response (_capitularies (), FIELDS)


@geo_app.route ('/capitularies.csv')
def capitularies_csv ():
    """ Return capitularies in geometry as CSV response. """

    FIELDS = 'cap_id, cap_title, notbefore, notafter, count'

    return common.make_csv_response (_capitularies (), FIELDS)


@geo_app.route ('/extent.json')
def extent_json ():
    """ Return the max. extent of all data points. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT ST_AsGeoJSON(ST_Extent(geom))::json AS geom, 1 as geo_id
        FROM msparts_view
        WHERE geo_source = 'geonames'
        """, {})

        return common.make_geojson_response (res, 'geom, geo_id')


@geo_app.route ('/', methods = ['GET', 'OPTIONS'])
def info_json ():
    """ Info endpoint: send information about server and available layers. """

    # FIXME: common.assert_map ()

    i = {
        'title'    : 'Capitularia Geo Server',
        'layers'   : current_app.config['GEO_LAYERS'],
    }
    return common.make_json_response (i, 200)
