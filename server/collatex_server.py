#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""CollateX API server for Capitularia.

Call CollateX and return results.

"""

import json
import os
import subprocess

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug

import common

class Config (object):
    COLLATEX                    = '/usr/bin/java -jar /usr/local/share/java/collatex-tools-1.8-SNAPSHOT.jar'
    COLLATEX_MAX_CONTENT_LENGTH = 1024 * 1024
    COLLATEX_TIMEOUT            = 120


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


@app.route ('/collate', methods = ['POST'])
def collate ():
    """ Collate posted JSON data. """

    if request.content_length > current_app.config['COLLATEX_MAX_CONTENT_LENGTH']:
        abort (400)

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

    # current_app.logger.info (request.get_data (as_text = True))

    try:
        stdout, stderr = proc.communicate (
            input = request.get_data (as_text = True),
            timeout = current_app.config['COLLATEX_TIMEOUT']
        )
    except subprocess.TimeoutExpired:
        proc.kill ()
        stdout, stderr = proc.communicate ()
        status = 504

    # current_app.logger.info (stdout)

    return flask.make_response (flask.json.jsonify ({
        'status' : status,
        'stdout' : json.loads (stdout),
        'stderr' : stderr,
    }), status, {
        'Content-Type' : 'application/json;charset=utf-8',
    })
