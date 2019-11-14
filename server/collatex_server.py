#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""CollateX API server for Capitularia.

Call CollateX and return results.

"""

import json
import os
import re
import subprocess

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug
import lxml.html

import common

class Config (object):
    COLLATEX                    = '/usr/bin/java -jar /usr/local/share/java/collatex-tools-1.8-SNAPSHOT.jar'
    COLLATEX_STYLESHEET         = 'xslt/mss-transcript-collation.xsl'
    COLLATEX_MAX_CONTENT_LENGTH = 1024 * 1024
    COLLATEX_TIMEOUT            = 120
    CACHE_DIR                   = 'cache/'
    XSLTPROC                    = '/usr/bin/xsltproc'


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


RE_PUNCT           = re.compile (r'[-.,:;!?*/]')
RE_BRACKETS        = re.compile (r'\[\s*|\s*\]')
RE_NORMALIZE_SPACE = re.compile (r'\s+')


def to_collatex (id_, text, normalizations = None):
    """
    Build the input to Collate-X

    Builds the JSON for one witness.  Returns an array that must be combined
    into the witness array and then json_encode()d.

    Example of Collate-X input file:

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

    :return Object: The json representation of one witness.
    """

    text = text.strip ()

    for n in 'ę=e Ę=E ae=e Ae=E AE=E'.split ():
        s, r = n.split ('=')
        text = text.replace (s, r)

    text = RE_PUNCT.sub ('', text)
    text = text.replace (' ', ' ')

    patterns = [n.split ('=') for n in normalizations if n]

    # tokenize
    tokens = []
    for token in text.split ():
        normalized = token
        for p in patterns:
            s, r = p
            normalized = normalized.replace (s, r)
        normalized = normalized.lower ()
        normalized = RE_BRACKETS.sub ('', normalized)
        if normalized:
            tokens.append ({ 't' : token, 'n' : normalized })

    return { 'id' : id_, 'tokens' : tokens }


@app.route ('/collate', methods = ['POST'])
def collate ():
    """ Collate witnesses. """

    current_app.logger.info (request.get_data (as_text = True))

    # get files and pass them through xsltproc
    # then remove html tags

    json_in = request.get_json ()
    json_out = []

    corresp        = json_in['corresp']
    normalizations = json_in['normalizations']
    for w in json_in['witnesses']:
        m = re.match (r'^([^?#]+)(\?hands=XYZ)?(?:#(\d+))?$', w)
        xml_id = m.group (1)
        hands  = m.group (2)
        n      = int (m.group (3) or '1')

        cache_dir = current_app.config['CACHE_DIR']
        filename = "%s/%s_%s.xml" % (xml_id, corresp, n)
        stylesheet = current_app.config['COLLATEX_STYLESHEET']

        cmdline = current_app.config['XSLTPROC'].split () + [stylesheet, '-']
        with open (os.path.join (cache_dir, 'collation/', filename), 'r') as fp:
            proc = subprocess.Popen (
                cmdline,
                stdin     = fp,
                stdout    = subprocess.PIPE,
                stderr    = subprocess.PIPE,
                close_fds = True,
                encoding  = 'utf-8'
            )
            try:
                stdout, stderr = proc.communicate (
                    timeout = current_app.config['COLLATEX_TIMEOUT']
                )
            except subprocess.TimeoutExpired:
                proc.kill ()
                stdout, stderr = proc.communicate ()
                abort (504)

            json_out.append (
                to_collatex (
                    w,
                    RE_NORMALIZE_SPACE.sub (
                        ' ',
                        lxml.html.document_fromstring (stdout).text_content ()
                    ),
                    normalizations
                )
            )

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

    # current_app.logger.info (json_in)

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

    # current_app.logger.info (stdout)

    try:
        stdout = json.loads (stdout)
        return flask.make_response (flask.json.jsonify ({
            'status' : status,
            'stdout' : stdout,
            'stderr' : stderr,
        }), status, {
            'Content-Type' : 'application/json;charset=utf-8',
        })
    except json.decoder.JSONDecodeError as e:
        current_app.logger.error (stdout)
        return flask.make_response (flask.json.jsonify ({
            'status' : 500,
            'stdout' : '',
            'stderr' : stderr,
        }), status, {
            'Content-Type' : 'application/json;charset=utf-8',
        })
