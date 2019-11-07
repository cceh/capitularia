#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""XSLT API server for Capitularia.

Call saxon to perform stored XSLT transforms on user-provided XML files.

"""

import os
import subprocess

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug
from werkzeug.utils import secure_filename

import common

class Config (object):
    STYLESHEET_FOLDER  = 'stylesheets/'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024
    PROC_TIMEOUT       = 60


class XSLTError (werkzeug.exceptions.HTTPException):
    def __init__ (self, msg):
        super ().__init__ (self)
        self.code = 500
        self.description = msg.decode ('utf-8')

def handle_xslt_error (e):
    #return e.description, e.code, { 'mimetype' : 'text/plain' }
    return flask.Response (e.description, e.code, mimetype = 'text/plain')

class xsltBlueprint (Blueprint):
    def init_app (self, app):
        app.config.from_object (Config)
        app.register_error_handler (XSLTError, handle_xslt_error)

app  = xsltBlueprint ('xslt', __name__)


@app.route ('/<string:processor>/<path:stylesheet>', methods = ['GET', 'POST'])
def saxon (processor, stylesheet):
    """ Perform XSLT on posted file. """

    if processor not in ('saxon', 'xsltproc'):
        abort (404)

    sheet_folder = os.path.expanduser (current_app.config['STYLESHEET_FOLDER'])

    sheet = os.path.abspath (os.path.join (sheet_folder, stylesheet))
    if os.path.commonprefix ([sheet_folder, sheet]) != sheet_folder:
        current_app.logger.error ("Malicious stylesheet {sheet}".format (sheet = stylesheet))
        abort (404)

    if not os.access (sheet, os.R_OK):
        current_app.logger.error ("Stylesheet {sheet} not found".format (sheet = sheet))
        raise werkzeug.exceptions.BadRequest ('Stylesheet %s not found' % stylesheet)

    if request.method == 'POST':
        current_app.logger.info ("Stylesheet {sheet}".format (sheet = sheet))
        # current_app.logger.info (request.headers)

        if processor == 'saxon':
            cmdline = ['saxon', '-s:-', sheet]
            for key, val in request.args.items ():
                cmdline.append ('%s=%s' % (key, val))

        if processor == 'xsltproc':
            cmdline = ['xsltproc', '--nonet', '--nowrite', '--nomkdir', sheet, '-']
            for key, val in request.args.items ():
                cmdline.extend (['--stringparam', key, val])

        file_ = request.files['file']
        # current_app.logger.info (file_.read ())
        # file_.seek (0)

        proc = subprocess.Popen (
            cmdline,
            stdin     = file_,
            stdout    = subprocess.PIPE,
            stderr    = subprocess.PIPE,
            close_fds = True
        )
        try:
            outs, errs = proc.communicate (timeout = current_app.config['PROC_TIMEOUT'])
            if errs:
                current_app.logger.error (errs)
                raise XSLTError (errs)
        except subprocess.TimeoutExpired:
            proc.kill ()
            outs, errs = proc.communicate ()
            # return errs, 500
            raise XSLTError (errs)

        return flask.Response (outs)

    return '''
    <!doctype html>
    <title>XSLT file</title>
    <h1>XSLT file</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''
