#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Initialize the geographic information tables."""

import argparse
import collections
import datetime
import io
import json
import re
import os
import os.path
import urllib.parse

import requests
import lxml
from lxml import etree

from common import text_content, fix_ws, fix_cap
import db_tools
from db_tools import execute, executemany, log
import db

NS_TEI  = 'http://www.tei-c.org/ns/1.0'
NS_XML  = 'http://www.w3.org/XML/1998/namespace'
NS_HTML = 'http://www.w3.org/1999/xhtml'

NS = { 'tei': NS_TEI, 'xml' : NS_XML }

GEO_APIS = {
    'geonames' : {
        're'       : re.compile ('//www.geonames.org/(\d+)/'),
        # FIXME get an institutional user
        'endpoint' : 'http://api.geonames.org/hierarchyJSON?geonameId={id}&username=highlander',
    },
    'dnb' : {
        're'       : re.compile ('http://d-nb.info/gnd/([-X\d]+)'),
        'endpoint' : 'https://hub.culturegraph.org/entityfacts/{id}',
    },
    'viaf' : {
        're'       : re.compile ('http://viaf.org/viaf/(\d+)'),
        'endpoint' : 'https://viaf.org/viaf/{id}/justlinks.json',
    },
}

HIDATE =  10000
LODATE = -10000

def get_date (row, origdate):
    """ Read a date range from a TEI element. """

    def fix_date (s):
        try:
            return int (s)
        except ValueError:
            try:
                return datetime.datetime.strptime (s, '%Y-%m').year
            except ValueError:
                return datetime.datetime.strptime (s, '%Y-%m-%d').year

    # if we find more than one estimate, take the most generous span
    row['notbefore'] = min (
        row['notbefore'],
        fix_date (origdate.get ('notBefore', HIDATE)),
        fix_date (origdate.get ('from',      HIDATE)),
        fix_date (origdate.get ('when',      HIDATE))
    )
    row['notafter']  = max (
        row['notafter'],
        fix_date (origdate.get ('notAfter',  LODATE)),
        fix_date (origdate.get ('to',        LODATE)),
        fix_date (origdate.get ('when',      LODATE))
    )

def fix_date (row):
    if row['notbefore'] == HIDATE:
        row['notbefore'] = None
    if row['notafter'] == LODATE:
        row['notafter'] = None
    if row['notbefore'] and row['notafter'] and row['notbefore'] > row['notafter']:
        row['notbefore'] = None
        row['notafter'] = None


def lookup_geonames (conn, geo_source):
    """ Lookup the GEO APIs.

    Cached:  Lookup only entities we don't already know.
    """

    res = execute (conn, """
    SELECT geo_id
    FROM geonames
    WHERE geo_source = :geo_source AND blob IS NULL
    """, { 'geo_source' : geo_source})

    data = GEO_APIS[geo_source]

    for geo_id in [ r[0] for r in res ]:
        print ("Looking up api: %s id: %s" % (geo_source, geo_id))
        try:
            url = data['endpoint'].format (id = geo_id)
            r = requests.get (url, timeout = 5)

            row = {
                'geo_source' : geo_source,
                'geo_id'     : geo_id,
                'geo_name'   : None,
                'geo_fcode'  : None,
                'geom'       : None,
                'blob'       : r.text,
            }

            if geo_source == 'geonames':
                rec = json.loads (r.text)['geonames'][-1]
                row.update ({
                    'geo_name'  : rec['name'],
                    'geo_fcode' : rec['fcode'],
                    'geom'      : 'SRID=4326;POINT (%f %f)' % (float (rec['lng']), float (rec['lat'])),
                })

            if geo_source == 'dnb':
                rec = json.loads (r.text)
                row.update ({
                    'geo_name' : rec['preferredName'],
                })

            if geo_source == 'viaf':
                rec = json.loads (r.text)
                # geo_id = rec['GeoNames'] # == ["http://www.geonames.org/3017382"],
                raise NotImplementedError

            execute (conn, """
            UPDATE geonames
            SET geom = :geom,
                geo_name = :geo_name,
                geo_fcode = :geo_fcode,
                blob = :blob
            WHERE geo_source = :geo_source AND geo_id = :geo_id
            """, row)

            execute (conn, "COMMIT", {});
        except:
            log (logging.WARNING, "Error looking up %s" % url)
            raise


def get_width_height (elem):
    w = ''
    h = ''
    for width in elem.xpath ('tei:width', namespaces = NS):
        w = width.text
    for height in elem.xpath ('tei:height', namespaces = NS):
        h = height.text
    return [ w, h ]


def process_mss (conn, root, ms_id, ms_part):
    """Process a full TEI document or <mspart> of it.

    Note: <msparts> of a document may have originated in different times and
    places.

    Insert all known documents and parts in their relative tables.

    Extract the geo ids and add yet unknown geo ids to the geonames table for
    later lookup.

    """

    row = {
        'ms_id'       : ms_id,
        'ms_part'     : ms_part,
        'notbefore'   : HIDATE,
        'notafter'    : LODATE,
        'msp_head'    : None,
        'msp_leaf'    : None,
        'msp_written' : None,
    }

    cap_ids = set ()
    for api, data in GEO_APIS.items ():
        data['geo_ids'] = set ()

    for head in root.xpath ("tei:head", namespaces = NS):
        row['msp_head'] = text_content (head)

    for origplace in root.xpath ("tei:head/tei:origPlace[@ref]", namespaces = NS):
        for api, data in GEO_APIS.items ():
            m = data['re'].search (origplace.get ('ref'))
            if m:
                data['geo_ids'].add (m.group (1))

    for origdate in root.xpath ("tei:head/tei:origDate", namespaces = NS):
        # if we find more than one estimate, take the most generous span
        get_date (row, origdate)

    for leaf in root.xpath (".//tei:dimensions[@type='leaf']", namespaces = NS):
        row['msp_leaf'] = get_width_height (leaf)

    for written in root.xpath (".//tei:dimensions[@type='written']", namespaces = NS):
        row['msp_written'] =  get_width_height (written)

    for title in root.xpath (".//tei:msItem//tei:title[@corresp]", namespaces = NS):
        corresp= title.get ('corresp') # BK_123
        if corresp:
            for cap_id in corresp.split ():
                cap_ids.add (fix_cap (cap_id))
        else:
            log (logging.ERROR, "Title with no corresp: %s" % text_content (title))

    fix_date (row)

    execute (conn, """
    INSERT INTO msparts (ms_id, ms_part, msp_date, msp_head, msp_leaf, msp_written)
      VALUES (:ms_id, :ms_part, int4range (:notbefore, :notafter, '[]'), :msp_head, :msp_leaf, :msp_written)
    ON CONFLICT (ms_id, ms_part) DO NOTHING
    """, row)

    rows = []
    for api, data in GEO_APIS.items ():
        for geo_id in data['geo_ids']:
            rows.append ({
                'ms_id'      : ms_id,
                'ms_part'    : ms_part,
                'geo_source' : api,
                'geo_id'     : geo_id,
            })

    if rows:
        executemany (conn, """
        INSERT INTO geonames (geo_source, geo_id)
        VALUES (:geo_source, :geo_id)
        ON CONFLICT (geo_source, geo_id) DO NOTHING
        """, {}, rows)

        executemany (conn, """
        INSERT INTO mn_msparts_geonames (ms_id, ms_part, geo_source, geo_id)
        VALUES (:ms_id, :ms_part, :geo_source, :geo_id)
        ON CONFLICT (ms_id, ms_part, geo_source, geo_id) DO NOTHING
        """, {}, rows)

        execute (conn, "COMMIT", {});

    rows = []
    for cap_id in cap_ids:
        rows.append ({
            'ms_id'   : ms_id,
            'ms_part' : ms_part,
            'cap_id'  : cap_id,
        })

    if rows:
        # need this to exist as foreign reference
        executemany (conn, """
        INSERT INTO capitularies (cap_id)
        VALUES (:cap_id)
        ON CONFLICT (cap_id) DO NOTHING
        """, {}, rows)

        executemany (conn, """
        INSERT INTO mn_msparts_capitularies (ms_id, ms_part, cap_id)
        VALUES (:ms_id, :ms_part, :cap_id)
        ON CONFLICT (ms_id, ms_part, cap_id) DO NOTHING
        """, {}, rows)


def process_cap (conn, item):
    """ Process one item from the capitularies list. """

    cap_id = fix_cap (item.get ('{%s}id' % NS_XML))

    if cap_id:
        log (logging.INFO, "Parsing %s ..." %  cap_id)
    else:
        log (logging.ERROR, "Item with no id")

    row = {
        'cap_id'    : cap_id,
        'cap_title' : fix_ws (item.xpath ("tei:name", namespaces = NS)[0].text),
        'notbefore' : HIDATE,
        'notafter'  : LODATE,
    }

    for date in item.xpath ("tei:note[@type='date']/tei:date", namespaces = NS):
        get_date (row, date)

    fix_date (row)

    execute (conn, """
    INSERT INTO capitularies (cap_id, cap_title, cap_date)
    VALUES (:cap_id, :cap_title, int4range (:notbefore, :notafter, '[]'))
    ON CONFLICT (cap_id) DO
    UPDATE
    SET cap_title = EXCLUDED.cap_title,
        cap_date  = EXCLUDED.cap_date
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
        '--init', action='store_true',
        help='initialize the Postgres database.', default=False
    )
    parser.add_argument (
        '--init-geolayers', action='store_true',
        help='initialize the Postgres geo layer tables.', default=False
    )
    parser.add_argument (
        '--mss', nargs="+",
        help='the manuscript files to import'
    )
    parser.add_argument (
        '--cap-list', nargs="+",
        help='the capitularies lists to import'
    )
    parser.add_argument (
        '--geonames', action='store_true',
        help='lookup geonames.org.', default=False
    )
    parser.add_argument (
        '--dnb', action='store_true',
        help='lookup dnb.de.', default=False
    )
    parser.add_argument (
        '--viaf', action='store_true',
        help='lookup viaf.org.', default=False
    )
    return parser


if __name__ == "__main__":
    import logging

    args, config = db_tools.init_cmdline (build_parser ())

    log (logging.INFO, "Connecting to Postgres database ...")

    dba = db_tools.PostgreSQLEngine (**config)

    log (logging.INFO, "using url: %s." % dba.url)

    parser = etree.XMLParser (recover = True, remove_blank_text = True)

    if args.init:
        log (logging.INFO, "Creating Postgres database schema ...")

        db.Base.metadata.drop_all   (dba.engine)
        db.Base.metadata.create_all (dba.engine)

    if args.init_geolayers:
        log (logging.INFO, "Creating Postgres geo layer tables ...")

        db.Base_geolayers.metadata.drop_all   (dba.engine)
        db.Base_geolayers.metadata.create_all (dba.engine)

    if args.mss:
        log (logging.INFO, "Parsing TEI Manuscript files ...")

        with dba.engine.begin () as conn:
            for fn in args.mss:
                log (logging.INFO, "Parsing %s ..." % fn)
                tree = etree.parse (fn, parser = parser)
                ms_id = tree.xpath ("/tei:TEI/@xml:id", namespaces = NS)[0]
                row = {
                    'ms_id'    : ms_id,
                    'ms_title' : fix_ws (tree.xpath ("//tei:titleStmt/tei:title[@type='main']/text()", namespaces = NS)[0]),
                }
                execute (conn, """
                INSERT INTO manuscripts (ms_id, ms_title)
                  VALUES (:ms_id, :ms_title)
                ON CONFLICT (ms_id) DO NOTHING
                """, row)

                for msdesc in tree.xpath ("//tei:sourceDesc/tei:msDesc", namespaces = NS):
                    process_mss (conn, msdesc, ms_id, '')

                for mspart in tree.xpath ("//tei:sourceDesc/tei:msDesc/tei:msPart", namespaces = NS):
                    process_mss (conn, mspart, ms_id, mspart.get ('n'))

                execute (conn, "COMMIT", {});

    if args.cap_list:
        log (logging.INFO, "Parsing TEI Capitulary List ...")

        with dba.engine.begin () as conn:
            for fn in args.cap_list:
                log (logging.INFO, "Parsing %s ..." % fn)
                tree = etree.parse (fn, parser = parser)
                for item in tree.xpath ("//tei:item[@xml:id]", namespaces = NS):
                    process_cap (conn, item)
                execute (conn, "COMMIT", {});

    if args.geonames:
        with dba.engine.begin () as conn:
            log (logging.INFO, "Looking up in geonames.org ...")
            lookup_geonames (conn, 'geonames')

    if args.dnb:
        with dba.engine.begin () as conn:
            log (logging.INFO, "Looking up in DNB ...")
            lookup_geonames (conn, 'dnb')

    if args.viaf:
        with dba.engine.begin () as conn:
            log (logging.INFO, "Looking up in viaf.org ...")
            lookup_geonames (conn, 'viaf')

    log (logging.INFO, "Done")
