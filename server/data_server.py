#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Data API server for Capitularia.

REST Interface to perform various database queries.


Endpoints
---------

.. http:get:: /data/manuscripts.json/

   Return all manuscripts.

   **Example request**:

   .. sourcecode:: http

      GET /data/manuscripts.json/?status=publish HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      [
        {
          "filename": "file:/var/www/.../cap/publ/mss/avranches-bm-145.xml",
          "ms_id": "avranches-bm-145",
          "title": "Avranches, Biblioth\u00e8que municipale, 145"
        },
        {
          "filename": "file:/var/www/.../cap/publ/mss/bamberg-sb-can-12.xml",
          "ms_id": "bamberg-sb-can-12",
          "title": "Bamberg, Staatsbibliothek, Can. 12"
        },
        {
          "filename": "file:/var/www/.../cap/publ/mss/barcelona-aca-ripoll-40.xml",
          "ms_id": "barcelona-aca-ripoll-40",
          "title": "Barcelona, Arxiu de la Corona d'Arag\u00f3, Ripoll 40"
        }
      ]

   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.
   :resheader Content-Type: application/json
   :statuscode 200: no error
   :resjsonobj string ms_id: the id of the manuscript.
   :resjsonobj string title: the title of the manuscript.
   :resjsonobj string filename: the absolute path to the file.


.. http:get:: /data/capitularies.json/

   Return all capitularies that have a transcription.

   **Example request**:

   .. sourcecode:: http

      GET /data/capitularies.json/?status=private HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      [
        {
          "cap_id": "BK.138",
          "title": "Capitulare ecclesiasticum",
          "transcriptions": 17
        },
        {
          "cap_id": "BK.139",
          "title": "Capitula legibus addenda",
          "transcriptions": 29
        },
        {
          "cap_id": "BK.140",
          "title": "Capitula per se scribenda",
          "transcriptions": 24
        }
      ]

   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.
   :resheader Content-Type: application/json
   :statuscode 200: no error
   :resjsonobj string cap_id: the id of the capitulary.
   :resjsonobj string title: the title of the capitulary.
   :resjsonobj integer transcriptions: How many transcriptions
                                       of this capitulary do we have?


.. http:get:: /data/capitulary/<cap_id>/chapters.json/

   Return all chapters in capitulary cap_id.

   **Example request**:

   .. sourcecode:: http

      GET /data/capitulary/BK.168/chapters.json/ HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      [
        {
          "cap_id": "BK.168",
          "chapter": "1",
          "transcriptions": 7
        },
        {
          "cap_id": "BK.168",
          "chapter": "1_inscriptio",
          "transcriptions": 1
        },
        {
          "cap_id": "BK.168",
          "chapter": "2",
          "transcriptions": 8
        }
      ]

   :query cap_id: The capitulary id, eg. 'BK.123' or 'Mordek.4'
   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.
   :resheader Content-Type: application/json
   :statuscode 200: no error
   :statuscode 400: Bad Request
   :resjsonobj string cap_id: the id of the capitulary.
   :resjsonobj string chapter: the chapter.
   :resjsonobj integer transcriptions: How many transcriptions
                                       of this chapter do we have?


.. http:get:: /data/capitulary/<cap_id>/manuscripts.json/

   Return all manuscripts containing capitulary cap_id.

   **Example request**:

   .. sourcecode:: http

      GET /data/capitulary/BK.40/manuscripts.json/ HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      [
        {"ms_id":"bk-textzeuge"},
        {"ms_id":"vatikan-bav-chigi-f-iv-75"}
      ]

   :query cap_id: The capitulary id, eg. 'BK.123' or 'Mordek.4'
   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.
   :resheader Content-Type: application/json
   :statuscode 200: no error
   :statuscode 400: Bad Request
   :resjsonobj string ms_id: the id of the manuscript.


.. http:get:: /data/corresp/<corresp>/manuscripts.json/

   Return all manuscripts containing corresp.

   **Example request**:

   .. sourcecode:: http

      GET /data/corresp/BK.40_1/manuscripts.json/ HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      [
        {
          "filename": "file:/var/www/.../cap/publ/mss/cava-dei-tirreni-bdb-4.xml",
          "locus": "cava-dei-tirreni-bdb-4-243v-1",
          "ms_id": "cava-dei-tirreni-bdb-4",
          "n": 1,
          "title": "Cava de' Tirreni, Biblioteca Statale del Monumento Nazionale Badia di Cava, 4",
          "type": "original"
        },
        {
          "filename": "file:/var/www/.../cap/publ/mss/ivrea-bc-xxxiv.xml",
          "locus": "ivrea-bc-xxxiv-53v-8",
          "ms_id": "ivrea-bc-xxxiv",
          "n": 1,
          "title": "Ivrea, Biblioteca Capitolare, XXXIV",
          "type": "original"
        },
        {
          "filename": "file:/var/www/.../cap/publ/mss/vatikan-bav-chigi-f-iv-75.xml",
          "locus": "vatikan-bav-chigi-f-iv-75-94r-6",
          "ms_id": "vatikan-bav-chigi-f-iv-75",
          "n": 1,
          "title": "Vatikan, Biblioteca Apostolica Vaticana, Chigi F. IV. 75",
          "type": "original"
        }
      ]

   :query string corresp:  The @corresp, eg. 'BK.123_4'
   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.
   :resheader Content-Type: application/json
   :statuscode 200: no error
   :statuscode 400: Bad Request
   :resjsonobj string ms_id: the id of the manuscript.
   :resjsonobj string title: the title of the manuscript.
   :resjsonobj string locus: the locus of the chapter in the manuscript.
   :resjsonobj string filename: the absolute path of the manuscript file.
   :resjsonobj int n: This chapter is part of the n_th occurence of the capitulary in the
                      manuscript.  Default is 1.  See :ref:`MssChapters.mscap_n`.
   :resjsonobj string type: Either 'original' or 'later_hands'.  The type of preprocessing applied.
                            Whether the original hand was followed or a later corrector.


.. http:get:: /data/capitulary/<cap_id>/chapter/<chapter>/manuscripts.json/

   Return all manuscripts containing chapter.

   **Example request**:

   .. sourcecode:: http

      GET /data/capitulary/BK.40/chapter/1/manuscripts.json/ HTTP/1.1
      Host: api.capitularia.uni-koeln.de

   :query string cap_id:  The capitulary id, eg. 'BK.123' or 'Mordek.4'
   :query string chapter: The chapter, eg. '1' or '1_inscriptio'
   :query string status: Optional.  'private' or 'publish'.  Default 'publish'.
                         Consider all manuscripts or just the published ones.

   Response format see above.


"""

import collections

from flask import abort, current_app, request, Blueprint

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


def get_status_param ():
    status = request.args.get ('status') or 'publish'
    if status not in ('private', 'publish'):
        raise ValueError ('Unknown status.')
    return status


def stat ():
    """ Create a filter on page status. """

    if get_status_param () == 'private':
        return ("m.status IN ('private', 'publish')")
    return ("m.status = 'publish'")


def fstat ():
    """ Create a filter on page status. """

    status = get_status_param ()
    if status == 'private':
        return "m.status IN ('private', 'publish') AND mc.chapter !~ '_incipit|_explicit'"
    return "m.status = 'publish' AND mc.chapter !~ '_inscriptio|_incipit|_explicit'"


@app.route ('/manuscripts.json/')
def manuscripts ():
    """ Return all manuscripts """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT ms_id, title, filename
        FROM manuscripts m
        WHERE %s
        ORDER BY natsort (ms_id)
        """ % stat (), {})

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, filename')
        mss = [ Manuscripts._make (r)._asdict () for r in res ]

        return cache (make_json_response (mss))


@app.route ('/capitularies.json/')
def capitularies ():
    """ Return all capitularies with transcriptions. """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """

        SELECT c.cap_id, c.title, MAX (b.transcriptions) AS transcriptions
        FROM (
          SELECT mc.cap_id, mc.chapter, COUNT (m.ms_id) AS transcriptions
          FROM mss_chapters mc
            JOIN manuscripts m USING (ms_id)
          WHERE %s
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
        WHERE cap_id = :cap_id AND %s
        GROUP BY cap_id, chapter
        ORDER BY natsort (chapter)
        """ % fstat (), { 'cap_id' : cap_id })

        Chapters = collections.namedtuple ('Chapters', 'cap_id, chapter, transcriptions')
        chapters = [ Chapters._make (r)._asdict () for r in res ]

        return cache (make_json_response (chapters))


@app.route ('/capitulary/<string:cap_id>/manuscripts.json/')
def capitulary_manuscripts_json (cap_id):
    try:
        cap_id = "%s.%s" % common.normalize_bk (cap_id)
    except ValueError:
        abort (400, str (e))

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
    """
    """

    with current_app.config.dba.engine.begin () as conn:
        res = execute (conn, """
        SELECT m.ms_id, m.title, mc.mscap_n, mc.locus, m.filename, mct.type
        FROM manuscripts m
          JOIN mss_chapters mc USING (ms_id)
          JOIN mss_chapters_text mct USING (ms_id, cap_id, mscap_n, chapter)
        WHERE (mc.cap_id, mc.chapter) = (:cap_id, :chapter) AND %s
        ORDER BY natsort (mc.ms_id), mc.mscap_n
        """ % fstat (), { 'cap_id' : cap_id, 'chapter' : chapter })

        Manuscripts = collections.namedtuple ('Manuscripts', 'ms_id, title, n, locus, filename, type')
        manuscripts = [ Manuscripts._make (r)._asdict () for r in res ]

        return cache (make_json_response (manuscripts))


@app.route ('/capitulary/<string:cap_id>/chapter/<string:chapter>/manuscripts.json/')
def chapter_manuscripts (cap_id, chapter):
    """
    """

    try:
        cap_id = "%s.%s" % common.normalize_bk (cap_id)
    except ValueError:
        abort (400, str (e))

    return _chapter_manuscripts (cap_id, chapter)


@app.route ('/corresp/<string:corresp>/manuscripts.json/')
def corresp_manuscripts (corresp):
    try:
        catalog, no, chapter = common.normalize_corresp (corresp)
    except ValueError:
        abort (400, str (e))

    return _chapter_manuscripts ("%s.%s" % (catalog, no), chapter or '')


def highlight (conn, text, fulltext):
    """Snippet and highlight

    Produce snippets out of the text around any of the words in fulltext and
    highlight those words in the snippets.

    """

    WORDS     = 6   # how many words to display on each side of the found word
    SEPARATOR = '[&hellip;]'

    res = execute (conn, r"""
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
        if r[1]:
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
            WITH RECURSIVE parent_places (geo_id, parent_id) AS (
              SELECT geo_id, parent_id
              FROM geoplaces
                WHERE geo_id IN :geo_ids
              UNION
              SELECT p.geo_id, p.parent_id
              FROM parent_places pp, geoplaces p
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
            FROM mn_mss_geoplaces
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
def places_json ():
    """ Return hierarchy of known places for the meta-search box. """

    lang = request.args.get ('lang') or 'de'

    with current_app.config.dba.engine.begin () as conn:

        # this mess is needed to sort the parent nodes first
        res = execute (conn, """
        WITH RECURSIVE parent_places (geo_id, parent_id) AS (
          SELECT geo_id, parent_id
          FROM geoplaces
            WHERE parent_id IS NULL
          UNION
          SELECT p.geo_id, p.parent_id
          FROM parent_places pp, geoplaces p
            WHERE p.parent_id = pp.geo_id
        )
        SELECT geo_id, parent_id, geo_name
        FROM parent_places
            JOIN geoplaces_names USING (geo_id)
            WHERE geo_lang = :geo_lang
        """, {'geo_lang' : lang})

        Places = collections.namedtuple ('Places', 'geo_id, parent_id, geo_name')
        places = [ Places._make (r)._asdict () for r in res ]

        return cache (make_json_response (places))
