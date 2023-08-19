"""This module implements the Saxon API for the Capitularia Application Server.

The Saxon commandline is slow because of the overhead of initializing the Java-VM and
parsing the XSLT stylesheet for every conversion. The Saxon server keeps Saxon-C in
memory and caches XSLT stylesheets.

Endpoints
---------

.. http:post:: /saxon/translate

   Translate an XML file

   **Example request**:

   .. sourcecode:: http

      POST /saxon/translate&xslt=stylesheet.xsl HTTP/1.1
      Host: api.capitularia.uni-koeln.de
      Content-Type: application/xml

      <TEI/>

   :param string xslt: The path of the XSLT stylesheet relative to the configured
   STYLESHEET_FOLDER.

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/xml

      <html/>

   :resheader Content-Type: application/xml
   :statuscode 200: No errors.

"""

import os.path

from typing import Optional, Tuple, List, Sequence, Dict
import urllib.parse

import flask
from flask import abort, current_app, request, Blueprint
import werkzeug

from saxonche import PySaxonProcessor, PyXslt30Processor, PyXsltExecutable, PySaxonApiError

import common


class Config(object):
    STYLESHEET_FOLDER = "xslt/"


class SaxonError(werkzeug.exceptions.HTTPException):
    def __init__(self, msg):
        super().__init__(self)
        self.code = 500
        self.description = msg.decode("utf-8")


def handle_saxon_error(e):
    return flask.Response(e.description, e.code, mimetype="text/plain")

SAXON_PROC: PySaxonProcessor = None
XSLT_PROC: PyXslt30Processor = None

class SaxonBlueprint(Blueprint):
    def init_app(self, app):
        global SAXON_PROC, XSLT_PROC

        app.config.from_object(Config)
        app.register_error_handler(SaxonError, handle_saxon_error)
        SAXON_PROC = PySaxonProcessor(license=False)
        XSLT_PROC = SAXON_PROC.new_xslt30_processor()


app = SaxonBlueprint("saxon", __name__)

XSLT_CACHE: dict[str, Tuple[float, PyXsltExecutable]] = dict()

def get_cached_stylesheet(stylesheet_path: str) -> PyXsltExecutable:
    """Compiles and caches a stylesheet

    On retrieval compares the mtime of the cached stylesheet with the mtime of the file
    on disk and re-compiles if necessary.

    :param str stylesheet_path: the stylesheet path relative to the configured STYLESHEET_FOLDER.
    """

    sheet_folder = os.path.expanduser(current_app.config["STYLESHEET_FOLDER"])
    sheet_path = os.path.normpath(os.path.join(sheet_folder, stylesheet_path))
    if not sheet_path.startswith(sheet_folder):
        raise OSError(f"Invalid stylesheet: {stylesheet_path}")

    dt_disk = os.path.getmtime(sheet_path) # throws OSError on missing file
    if sheet_path in XSLT_CACHE:
        dt_cached, executable = XSLT_CACHE[sheet_path]
        if dt_disk <= dt_cached:
            current_app.logger.info(f"Return cached stylesheet: {sheet_path}")
            return executable

    executable = XSLT_PROC.compile_stylesheet(stylesheet_file=sheet_path)
    XSLT_CACHE[sheet_path] = (dt_disk, executable)
    current_app.logger.info(f"Compiled stylesheet: {sheet_path}")

    return executable


@app.route("/translate", methods=["GET", "POST"])
def collate():
    """Implements the /saxon/translate endpoint."""

    xslt = request.args.get("xslt")
    if xslt is None:
        abort(400, "Missing parameter: xslt")

    xml = request.get_data().decode("UTF-8")

    try:
        executable = get_cached_stylesheet(xslt)
        document = SAXON_PROC.parse_xml(xml_text=xml)

        output = executable.transform_to_string(xdm_node=document)
        return flask.make_response(output, 200, { "Content-Type" : "application/xml" })

    except (PySaxonApiError, OSError) as err:
        return flask.make_response(f"Error: {str(err)}", 500, { "Content-Type" : "text/plain" })
