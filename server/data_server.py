#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Data API server for Capitularia.

REST Interface to perform various database queries

"""

import collections

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug

import common
from db_tools import execute
from common import make_json_response

class Config (object):
    pass


class dataBlueprint (Blueprint):
    def init_app (self, app):
        app.config.from_object (Config)


app  = dataBlueprint ('data', __name__)


def cache (response):
    response.headers['Cache-Control'] = 'private, max-age=3600'
    return response


@app.route ('/manuscripts.json/')
def manuscripts ():
    """ Return all manuscripts """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT ms_id, title, filename, hands
        FROM manuscripts
        ORDER BY natsort (ms_id)
        """, {})

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, filename, hands')
        manuscripts = [ Manuscripts._make (r)._asdict () for r in res ]

        return cache (make_json_response (manuscripts))


def fstat ():
    """ Create a filter on page status. """

    status = request.args.get ('status')
    where = ''
    if status == 'private':
        where = "AND m.status IN ('private', 'publish') AND mc.chapter !~ '_incipit|_explicit'"
    if status == 'publish':
        where = "AND m.status = 'publish' AND mc.chapter !~ '_inscriptio|_incipit|_explicit'"
    return where


@app.route ('/capitularies.json/')
def capitularies ():
    """ Return all capitularies. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """

        SELECT c.cap_id, c.title, MAX (b.transcriptions) AS transcriptions
        FROM (
          SELECT mc.cap_id, mc.chapter, COUNT (m.ms_id) AS transcriptions
          FROM mss_chapters mc
            JOIN manuscripts m USING (ms_id)
          WHERE true %s
          GROUP BY (cap_id, chapter)
          ) b
          JOIN capitularies c USING (cap_id)
        GROUP BY c.cap_id, c.title
        ORDER BY natsort (c.cap_id)
        """ % fstat (), {})

        Capitularies = collections.namedtuple ('Capitularies', 'cap_id, title, transcriptions')
        capitularies = [ Capitularies._make (r)._asdict () for r in res ]

        return cache (make_json_response (capitularies))


@app.route ('/capitulary/<string:cap_id>/chapters.json/')
def chapters (cap_id):
    """ Return all chapters in capitulary cap_id. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT cap_id, chapter, COUNT (ms_id) AS transcriptions
        FROM mss_chapters mc
          JOIN manuscripts m USING (ms_id)
        WHERE cap_id = :cap_id %s
        GROUP BY cap_id, chapter
        ORDER BY natsort (chapter)
        """ % fstat (), { 'cap_id' : cap_id })

        Chapters = collections.namedtuple ('Chapters', 'cap_id, chapter, transcriptions')
        chapters = [ Chapters._make (r)._asdict () for r in res ]

        return cache (make_json_response (chapters))


def _chapter_manuscripts (cap_id, chapter):

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT m.ms_id, m.title, mc.mscap_n, mc.locus, m.filename, mc.hands
        FROM manuscripts m
          JOIN mss_chapters mc USING (ms_id)
        WHERE (mc.cap_id, mc.chapter) = (:cap_id, :chapter) %s
        ORDER BY natsort (mc.ms_id), mc.mscap_n
        """ % fstat (), { 'cap_id' : cap_id, 'chapter' : chapter })

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, n, locus, filename, hands')
        manuscripts = [ Manuscripts._make (r)._asdict () for r in res ]

        return cache (make_json_response (manuscripts))


@app.route ('/capitulary/<string:cap_id>/chapter/<string:chapter>/manuscripts.json/')
def chapter_manuscripts (cap_id, chapter):
    """ Return all manuscripts with chapter """

    return _chapter_manuscripts (cap_id, chapter)


@app.route ('/corresp/<string:corresp>/manuscripts.json/')
def corresp_manuscripts (corresp):
    """ Return all manuscripts with corresp.  """

    catalog, no, chapter = common.normalize_corresp (corresp)

    return _chapter_manuscripts ("%s.%s" % (catalog, no), chapter or '')
