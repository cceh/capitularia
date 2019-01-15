#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Initialize the Geonames table."""

import argparse
import collections
import io
import json
import re
import os
import os.path
import urllib.parse

import requests
import lxml
from lxml import etree

import db_tools
from db_tools import execute, executemany, log
import db

NS_TEI  = 'http://www.tei-c.org/ns/1.0'
NS_XML  = 'http://www.w3.org/XML/1998/namespace'
NS_HTML = 'http://www.w3.org/1999/xhtml'

NS = { 'tei': NS_TEI, 'xml' : NS_XML }

RE_GEONAMES = re.compile ('//www.geonames.org/(\d+)/')

def lookup_coords (conn):
    GEONAMES_API_ENDPOINT = 'http://api.geonames.org/hierarchyJSON'
    GEONAMES_USER         = 'highlander'  # FIXME get an institutional user

    res = execute (conn, """
    SELECT geo_id
    FROM geonames
    WHERE blob IS NULL
    """, {})

    for geo_id in [ r[0] for r in res ]:
        print ("Looking up %d" % geo_id)
        try:
            r = requests.get (GEONAMES_API_ENDPOINT,
                              params = { 'geonameId' : geo_id, 'username' : GEONAMES_USER },
                              timeout = 5)

            rec = json.loads (r.text)['geonames'][-1]
            data = {
                'geo_id' : geo_id,
                'lat'    : float (rec['lat']),
                'lng'    : float (rec['lng']),
                'name'   : rec['name'],
                'fcode'  : rec['fcode'],
                'blob'   : r.text
            }

            execute (conn, """
            UPDATE geonames
            SET geo = 'SRID=4326;POINT (:lng :lat)',
                name = :name,
                fcode = :fcode,
                blob = :blob
            WHERE geo_id = :geo_id
            """, data)

            execute (conn, "COMMIT", {});
        except:
            log (logging.WARNING, "Error looking up geonames id: %s" % geo_id)
            pass


def get_width_height (elem):
    w = ''
    h = ''
    for width in elem.xpath ('tei:width', namespaces = NS):
        w = width.text
    for height in elem.xpath ('tei:height', namespaces = NS):
        h = height.text
    return [ w, h ]


def extract (conn, root, ms_id, ms_part) :
    row = {
        'ms_id'     : ms_id,
        'ms_part'   : ms_part,
        'geo_id'    : None,
        'notbefore' : None,
        'notafter'  : None,
        'leaf'      : None,
        'written'   : None,
    }

    for origplace in root.xpath ("tei:head/tei:origPlace[@ref]", namespaces = NS):
        m = RE_GEONAMES.search (origplace.get ('ref'))
        if m:
            row['geo_id'] = m.group (1)
            execute (conn, """
            INSERT INTO geonames (geo_id)
            VALUES (:geo_id)
            ON CONFLICT (geo_id) DO NOTHING
            """, row)

    for origdate in root.xpath ("tei:head/tei:origDate[@notBefore and @notAfter]", namespaces = NS):
        row['notbefore'] = int (origdate.get ('notBefore'))
        row['notafter']  = int (origdate.get ('notAfter'))
        if row['notbefore'] > row['notafter']:
            row['notbefore'] = None
            row['notafter'] = None

    for leaf in root.xpath (".//tei:dimensions[@type='leaf']", namespaces = NS):
        row['leaf'] = get_width_height (leaf)

    for written in root.xpath (".//tei:dimensions[@type='written']", namespaces = NS):
        row['written'] =  get_width_height (written)

    execute (conn, """
    INSERT INTO msparts (ms_id, ms_part, geo_id, date, leaf, written)
      VALUES (:ms_id, :ms_part, :geo_id, int4range (:notbefore, :notafter), :leaf, :written)
    ON CONFLICT (ms_id, ms_part) DO NOTHING
    """, row)


def build_parser ():
    """ Build the commandline parser. """

    parser = argparse.ArgumentParser (description = __doc__)
    config_path = os.path.abspath (os.path.dirname (__file__) + '/server.conf')

    parser.add_argument (
        '-v', '--verbose', dest='verbose', action='count',
        help='increase output verbosity', default=0
    )
    parser.add_argument (
        '-c', '--config-path', dest='config_path',
        default=config_path, metavar='CONFIG_PATH',
        help="the config file (default='./server.conf')"
    )
    parser.add_argument (
        '-i', '--init', action='store_true',
        help='initialize the Postgres database.', default=False
    )
    parser.add_argument (
        'files', nargs="*",
        help='the xml files to import'
    )
    return parser


if __name__ == "__main__":
    import logging

    args, config = db_tools.init_cmdline (build_parser ())

    log (logging.INFO, "Connecting to Postgres Database ...")

    dba = db_tools.PostgreSQLEngine (**config)

    log (logging.INFO, "using url: %s." % dba.url)

    if args.init:
        log (logging.INFO, "Creating Postgres Database Schema ...")

        db.Base.metadata.drop_all   (dba.engine)
        db.Base.metadata.create_all (dba.engine)

    parser = etree.XMLParser (recover = True, remove_blank_text = True)

    mss = []
    msparts = []
    geo_ids = set ()

    log (logging.INFO, "Parsing TEI files ...")

    with dba.engine.begin () as conn:
        for fn in args.files:
            log (logging.INFO, "Parsing %s ..." % fn)
            tree = etree.parse (fn, parser = parser)
            ms_id = tree.xpath ("/tei:TEI/@xml:id", namespaces = NS)[0]
            row = {
                'ms_id' : ms_id,
                'title' : tree.xpath ("//tei:titleStmt/tei:title[@type='main']/text()", namespaces = NS)[0],
            }
            execute (conn, """
            INSERT INTO manuscripts (ms_id, title)
              VALUES (:ms_id, :title)
            ON CONFLICT (ms_id) DO NOTHING
            """, row)

            for msdesc in tree.xpath ("//tei:sourceDesc/tei:msDesc", namespaces = NS):
                extract (conn, msdesc, ms_id, '')

            for mspart in tree.xpath ("//tei:sourceDesc/tei:msDesc/tei:msPart", namespaces = NS):
                extract (conn, mspart, ms_id, mspart.get ('n'))

            execute (conn, "COMMIT", {});


    with dba.engine.begin () as conn:
        log (logging.INFO, "Looking up in geonames.org ...")

        lookup_coords (conn)

    log (logging.INFO, "Done")
