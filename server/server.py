#!/usr/bin/python3

"""The API server for Capitularia."""

import argparse
import logging
import time

import flask
from flask import Flask

from config import args, init_logging

from db_tools import PostgreSQLEngine

from collator_server import app as collator_app
from data_server import app as data_app
from geo_server import geo_app
from saxon_server import app as saxon_app
from solr_server import app as solr_app
from tile_server import tile_app


class Config(object):
    APPLICATION_HOST = "localhost"
    APPLICATION_PORT = 5000
    CONFIG_FILE = "server.conf"  # default relative to server.py
    LOG_FILE = "server.log"  # default relative to server.py
    USE_RELOADER = False
    USE_DEBUGGER = False
    SERVER_START_TIME = str(int(time.time()))  # for cache busting


def build_parser(default_config_file):
    """Build the commandline parser."""

    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        "-v",
        "--verbose",
        dest="verbose",
        action="count",
        help="increase output verbosity",
        default=0,
    )
    parser.add_argument(
        "-c",
        "--config-file",
        dest="config_file",
        default=default_config_file,
        metavar="CONFIG_FILE",
        help="the config file (default='%s')" % default_config_file,
    )
    return parser


def create_app(Config):
    app = Flask(__name__)

    app.config.from_object(Config)

    # load the config file only to get the log file destination
    app.config.from_pyfile(Config.CONFIG_FILE)
    init_logging(
        args, flask.logging.default_handler, logging.FileHandler(app.config["LOG_FILE"])
    )
    Config.LOG_LEVEL = args.log_level
    app.logger.setLevel(Config.LOG_LEVEL)

    app.register_blueprint(data_app, url_prefix="/data")
    data_app.init_app(app)

    app.register_blueprint(tile_app, url_prefix="/tile")
    tile_app.init_app(app)

    app.register_blueprint(geo_app, url_prefix="/geo")
    geo_app.init_app(app)

    app.register_blueprint(saxon_app, url_prefix="/saxon")
    saxon_app.init_app(app)

    app.register_blueprint(solr_app, url_prefix="/solr")
    solr_app.init_app(app)

    app.register_blueprint(collator_app, url_prefix="/collator")
    collator_app.init_app(app)

    # reload the config file to overwrite default values
    app.config.from_pyfile(Config.CONFIG_FILE)

    app.config.dba = PostgreSQLEngine(**app.config)

    return app


if __name__ == "__main__":
    from werkzeug.serving import run_simple

    build_parser("server.conf").parse_args(namespace=args)
    Config.CONFIG_FILE = args.config_file

    app = create_app(Config)

    @app.after_request
    def add_headers(response):
        response.headers["Access-Control-Allow-Origin"] = app.config[
            "CORS_ALLOW_ORIGIN"
        ]
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Allow-Headers"] = (
            "Content-Type"  # allow application/json
        )
        response.headers["Server"] = "Jetty 0.8.15"
        return response

    app.logger.info(
        "Mounted {name} at {host}:{port} from conf {conf}".format(
            name=app.config["APPLICATION_NAME"],
            host=app.config["APPLICATION_HOST"],
            port=app.config["APPLICATION_PORT"],
            conf=Config.CONFIG_FILE,
        )
    )

    run_simple(
        app.config["APPLICATION_HOST"],
        app.config["APPLICATION_PORT"],
        app,
        use_reloader=app.config["USE_RELOADER"],
        use_debugger=app.config["USE_DEBUGGER"],
        extra_files=[Config.CONFIG_FILE],
    )
