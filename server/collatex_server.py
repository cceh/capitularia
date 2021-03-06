#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""This module implements the CollateX API for the Capitularia Application Server.

Endpoints
---------

.. http:post:: /collatex/collate

   Collate sections of witnesses.

   **Example request**:

   .. sourcecode:: http

      POST /collatex/collate HTTP/1.1
      Host: api.capitularia.uni-koeln.de
      Content-Type: application/json;charset=utf-8

      {
          "collate": [
              "BK.20a_3/bk-textzeuge",
              "BK.20b_3/bk-textzeuge",
              "BK.20b_3/vatikan-bav-reg-lat-263"
          ]
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json;charset=utf-8

      {
        "witnesses": [
          "BK.20a_3/bk-textzeuge",
          "BK.20b_3/bk-textzeuge",
          "BK.20b_3/vatikan-bav-reg-lat-263"
        ],
        "table":[
          [ [ {"t": "A",     "n": "a" } ],     [ {"t": "A",      "n": "a" } ] ],
          [ [ {"t": "black", "n": "black" } ], [ {"t": "white",  "n": "white" } ] ],
          [ [ {"t": "cat",   "n": "cat" } ],   [ {"t": "kitten", "n": "kitten" } ] ]
        ]
      }

   :resheader Content-Type: application/json;charset=utf-8
   :statuscode 200: No errors.
   :statuscode 500: CollateX reported errors.
                    A report was logged in the server logfile.
   :statuscode 504: The CollateX process took too long.
                    Retry later or with less witnesses.
   :resjsonobj string[] witnesses: List of manuscript ids.
   :resjsonobj array table: The collateX response.

"""

import json
import os
import re
import subprocess

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug

import lxml.html
from lxml import etree

import common
from db_tools import execute

class Config (object):
    COLLATEX         = '/usr/bin/java -jar /usr/local/share/java/collatex-tools-1.8-SNAPSHOT.jar'
    CACHE_DIR        = 'cache/'
    COLLATEX_TIMEOUT = 120


class CollatexError (werkzeug.exceptions.HTTPException):
    def __init__ (self, msg):
        super ().__init__ (self)
        self.code = 500
        self.description = msg.decode ('utf-8')


def handle_collatex_error (e):
    return flask.Response (e.description, e.code, mimetype = 'text/plain')


class collatexBlueprint (Blueprint):
    def init_app (self, app):
        app.config.from_object (Config)
        app.register_error_handler (CollatexError, handle_collatex_error)


app  = collatexBlueprint ('collatex', __name__)

WHOLE_TEXT_PATTERNS = [n.split ('=') for n in """
ae=e
ę=e
j=i
v=u
""".split () if n]

RE_WHITESPACE_EQUIV_CHARS = re.compile ("[.,:;!?-_*/]")

def normalize_with_patterns (patterns, text, whole_words = False):
    """Normalize text using a list of patterns"""

    normalized = text
    if whole_words:
        for p in patterns:
            search, replace = p
            normalized = re.sub (r'\b' + search + r'\b', replace, normalized)
    else:
        for p in patterns:
            search, replace = p
            normalized = normalized.replace (search, replace)
    return normalized

def to_collatex (id_, text, normalizations = None):
    """Build the input to Collate-X

    Builds the representation for one witness.  Returns an object that must be
    combined into the witnesses array.

    Example of Collate-X input:

    .. code:: json

       {
         "witnesses" : [
           {
             "id" : "A",
             "tokens" : [
                 { "t" : "A ",      "n" : "a"     },
                 { "t" : "black " , "n" : "black" },
                 { "t" : "cat.",    "n" : "cat"   }
             ]
           },
           {
             "id" : "B",
             "tokens" : [
                 { "t" : "A ",      "n" : "a"     },
                 { "t" : "white " , "n" : "white" },
                 { "t" : "kitten.", "n" : "cat"   }
             ]
           }
         ]
       }

    :param string[] normalizations: List of string in the form: oldstring=newstring
                                    Normalizations applied to each word.

    :return Object: The representation of one witness.

    """

    text = text.strip ().lower ()
    text = common.RE_BRACKETS.sub ('', text)
    text = RE_WHITESPACE_EQUIV_CHARS.sub ('', text)

    norm = normalize_with_patterns (WHOLE_TEXT_PATTERNS, text)

    normalizations = normalizations or []
    patterns = [n.split ('=') for n in normalizations if n]
    if patterns:
        norm = normalize_with_patterns (patterns, norm, True)

    tsplit = text.split ()
    nsplit = norm.split ()
    assert (len (tsplit) == len (nsplit))

    tokens = [{ 't' : s[0], 'n' : s[1] } for s in zip (tsplit, nsplit)]

    return { 'id' : id_, 'tokens' : tokens }


@app.route ('/collate', methods = ['POST'])
def collate ():
    """Implements the /collatex/collate endpoint."""

    json_in = {
        "levenshtein_distance" : 0,
        "levenshtein_ratio"    : 1,
        "joined"               : False,
        "segmentation"         : False,
        "transpositions"       : False,
        "algorithm"            : "needleman-wunsch-gotoh",
        "normalizations"       : [],
        "collate"              : [],
    }
    json_in.update (request.get_json ())
    json_out = []

    current_app.logger.info (json.dumps (json_in, indent = 4))

    normalizations = json_in['normalizations']

    with current_app.config.dba.engine.begin () as conn:
        for w in json_in['collate']:
            m       = re.match (r'^([^/]+)/([^?#]+)(\?hands=XYZ)?(?:#(\d+))?$', w)
            corresp = m.group (1)
            ms_id   = m.group (2)
            hands   = m.group (3)

            catalog, no, chapter = common.normalize_corresp (corresp)

            params = {
                'ms_id'   : ms_id,
                'cap_id'  : "%s.%s" % (catalog, no),
                'mscap_n' : int (m.group (4) or '1'),
                'chapter' : chapter or '',
                'type'    : 'later_hands' if hands else 'original',
            }

            # current_app.logger.info (params)

            res = execute (conn, """
            SELECT text
            FROM mss_chapters_text
            WHERE (ms_id, cap_id, mscap_n, chapter, type) = (:ms_id, :cap_id, :mscap_n, :chapter, :type)
            """, params)

            doc = res.fetchone()[0]
            json_out.append (to_collatex (w, doc, normalizations))

    json_in['witnesses'] = json_out

    cmdline = current_app.config['COLLATEX'].split () + ['-f', 'json', '-']
    status = 200

    proc = subprocess.Popen (
        cmdline,
        stdin     = subprocess.PIPE,
        stdout    = subprocess.PIPE,
        stderr    = subprocess.PIPE,
        close_fds = True,
        encoding  = 'utf-8'
    )

    # current_app.logger.info (json.dumps (json_in, indent = 4))

    try:
        stdout, stderr = proc.communicate (
            input   = json.dumps (json_in),
            timeout = current_app.config['COLLATEX_TIMEOUT']
        )
    except subprocess.TimeoutExpired:
        proc.kill ()
        stdout, stderr = proc.communicate ()
        abort (504)

    # The Collate-X response
    #
    # {
    #   "witnesses":["A","B"],
    #   "table":[
    #     [ [ {"t":"A","ref":123 } ],      [ {"t":"A" } ] ],
    #     [ [ {"t":"black","adj":true } ], [ {"t":"white","adj":true } ] ],
    #     [ [ {"t":"cat","id":"xyz" } ],   [ {"t":"kitten.","n":"cat" } ] ]
    #   ]
    # }

    stderr = stderr.splitlines ()

    # current_app.logger.info (stdout)

    try:
        stdout = json.loads (stdout)
    except json.decoder.JSONDecodeError as e:
        stderr.append ('Error: %s decoding JSON response from CollateX' % str (e))

    for line in stderr:
        if line.startswith ('Error: '):
            current_app.logger.error (line[7:])
            status = 500
        elif line.startswith ('Warning: '):
            current_app.logger.warning (line[9:])
        else:
            current_app.logger.info (line)
    current_app.logger.info ("Done the CollateX")

    return flask.make_response (flask.json.jsonify (stdout), status, {
        'Content-Type' : 'application/json;charset=utf-8',
    })
