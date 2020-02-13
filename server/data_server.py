#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Data API server for Capitularia.

REST Interface to perform various database queries

"""

import collections

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug

import intervals as I

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
        SELECT ms_id, title, filename
        FROM manuscripts
        ORDER BY natsort (ms_id)
        """, {})

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, filename')
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


@app.route ('/capitulary/<string:cap_id>/manuscripts.json/')
def capitulary_manuscripts_json (cap_id):
    """ Return all manuscripts containing capitulary cap_id. """

    cap_id = "%s.%s" % common.normalize_bk (cap_id)

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT DISTINCT ms_id
        FROM mss_chapters
        WHERE cap_id = :cap_id
        """, { 'cap_id' : cap_id })

        CM = collections.namedtuple ('Capitulary_Manuscripts', 'ms_id')
        mss = [ CM._make (r)._asdict () for r in res ]

        return cache (make_json_response (mss))


def _chapter_manuscripts (cap_id, chapter):

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT m.ms_id, m.title, mc.mscap_n, mc.locus, m.filename, mct.type
        FROM manuscripts m
          JOIN mss_chapters mc USING (ms_id)
          JOIN mss_chapters_text mct USING (ms_id, cap_id, mscap_n, chapter)
        WHERE (mc.cap_id, mc.chapter) = (:cap_id, :chapter) %s
        ORDER BY natsort (mc.ms_id), mc.mscap_n
        """ % fstat (), { 'cap_id' : cap_id, 'chapter' : chapter })

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, n, locus, filename, type')
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


def highlight (conn, text, fulltext):
    """Snippet and highlight

    Produce snippets out of the text around any of the words in fulltext and
    highlight those words in the snippets.

    """

    WORDS     = 6   # how many words to display on each side of the found word
    SEPARATOR = '[&hellip;]'

    res = execute (conn, """
    SELECT word, word <<% :fulltext AS match
    FROM (
      SELECT REGEXP_SPLIT_TO_TABLE (:text, '\s+') AS word
    ) AS q
    """, { 'text' : text, 'fulltext' : fulltext })

    words       = []
    highlighted = set ()
    interval    = set ()
    for n, r in enumerate (res):
        words.append (r[0])
        if (r[1]):
            highlighted.add (n)
            interval = interval.union (range (n - WORDS, n + WORDS))

    s = []
    for n, w in enumerate (words):
        if n in interval:
            s.append ('<mark>' + w + '</mark>' if n in highlighted else w)
        else:
            if s and s[-1] != SEPARATOR:
                s.append (SEPARATOR)

    return ' '.join (s)


@app.route ('/query_manuscripts.json/')
def query_manuscripts ():
    """ Return manuscripts according to query. """

    status    = request.args.get ('status')
    fulltext  = request.args.get ('fulltext')
    capit     = request.args.get ('capit')
    notbefore = request.args.get ('notbefore')
    notafter  = request.args.get ('notafter')
    places    = request.args.getlist ('places[]')

    with current_app.config.dba.engine.begin () as conn:
        where = []
        params = { 'fulltext' : None }
        if status == 'private':
            where.append ("m.status IN ('private', 'publish')")
        if status == 'publish':
            where.append ("m.status = 'publish'")
        if capit:
            where.append ("cap_id = :cap_id")
            params['cap_id'] = capit
        if notbefore:
            where.append (":after <= upper (msp.date)")
            params['after'] = notbefore
        if notafter:
            where.append ("lower (msp.date) <= :before")
            params['before'] = notafter

        if fulltext:
            where.append ("mct.type = 'original'")
            for n, word in enumerate (fulltext.split ()):
                where.append ("(:word{0})::text <<% mct.text".format (n))
                params['word%d' % n] = word

        if places:
            # current_app.logger.warn ("user selected places = %s" % str (places))

            # First get the geo_ids of all the places that fit the query.
            # Get all children of the place(s) selected by the user.
            res = execute (conn, """
            WITH RECURSIVE parent_places (geo_id, parent_id, geo_name) AS (
              SELECT geo_id, parent_id, geo_name
              FROM geonames
                WHERE geo_id IN :geo_ids AND geo_source = 'geonames'
              UNION
              SELECT p.geo_id, p.parent_id, p.geo_name
              FROM parent_places pp, geonames p
                WHERE p.parent_id = pp.geo_id
            )
            SELECT DISTINCT geo_id FROM parent_places ORDER BY geo_id
            """, { 'geo_ids' : tuple (places) })

            places = [r[0] for r in res]

            # current_app.logger.warn ("resolved places = %s" % str (places))

            # Now get all manuscripts that have any part originated in one of
            # those places.  NOTE: that we use manuscripts instead of manuscript
            # parts because at this stage of software development we don't yet
            # know the relation between parts and capitularies.
            res = execute (conn, """
            SELECT ms_id
            FROM mn_msparts_geonames
              WHERE geo_id IN :geo_ids
            GROUP BY ms_id
            """, { 'geo_ids' : tuple (places) })

            where.append ("m.ms_id IN :ms_ids")
            params['ms_ids'] = tuple ([r[0] for r in res])

            # current_app.logger.warn ("resolved manuscripts for places = %s" % str (params['ms_ids']))

        if where:
            where = 'WHERE ' + (' AND '.join (where))
        else:
            where = ''

        res = execute (conn, """
        SELECT m.ms_id, m.title, mc.cap_id, mc.mscap_n, mc.chapter, mc.locus, mct.text as snippet
        FROM manuscripts m
          JOIN mss_chapters mc USING (ms_id)
          JOIN mss_chapters_text mct USING (ms_id, cap_id, mscap_n, chapter)
          JOIN msparts msp USING (ms_id)
        %s
        GROUP BY m.ms_id, m.title, mc.cap_id, mc.mscap_n, mc.chapter, mc.locus, mct.text
        ORDER BY natsort (m.ms_id), mc.cap_id, mc.mscap_n, mc.chapter
        """ % where, params)

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, cap_id, mscap_n, chapter, locus, snippet')
        manuscripts = [ Manuscripts._make (r)._asdict () for r in res ]

        if fulltext:
            for ms in manuscripts:
                ms['snippet'] = highlight (conn, ms['snippet'], fulltext)
        else:
            for ms in manuscripts:
                ms['snippet'] = ''

        # current_app.logger.warn ("RESULT = %s" % manuscripts)
        return cache (make_json_response (manuscripts))


@app.route ('/places.json/')
def places_json (geo_id = None):
    """ Return hierarchy of known places for the meta-search box. """

    with current_app.config.dba.engine.begin () as conn:
        res = []

        res = execute (conn, """
        WITH RECURSIVE parent_places (geo_id, parent_id, geo_name) AS (
          SELECT geo_id, NULL::text, geo_name
          FROM geonames
            WHERE geo_fcode = 'PCLI'
          UNION
          SELECT p.geo_id, p.parent_id, p.geo_name
          FROM parent_places pp, geonames p
            WHERE p.parent_id = pp.geo_id
        )
        SELECT * FROM parent_places;
        """, {})

        Places = collections.namedtuple ('Places', 'geo_id, parent_id, geo_name')
        places = [ Places._make (r)._asdict () for r in res ]

        return cache (make_json_response (places))
