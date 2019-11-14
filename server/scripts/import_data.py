#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""Insert and update data from TEI files into Postgres.

Call this tool from cron to keep the postgres database in sync with the data in
the TEI file collection.

Includes the geographic information tables.

"""

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

from sqlalchemy_utils import IntRangeType
from sqlalchemy.dialects.postgresql.json import JSONB
from sqlalchemy.dialects.postgresql import ARRAY, INT4RANGE

import common
from common import text_content, fix_ws
from config import args, init_logging, config_from_pyfile
import db_tools
from db_tools import execute, executemany, log
import db

NS_TEI  = 'http://www.tei-c.org/ns/1.0'
NS_XML  = 'http://www.w3.org/XML/1998/namespace'
NS_HTML = 'http://www.w3.org/1999/xhtml'
NS_CAP  = 'http://cceh.uni-koeln.de/capitularia'

NS = {
    'tei'  : NS_TEI,
    'xml'  : NS_XML,
    'html' : NS_HTML,
    'cap'  : NS_CAP,
}

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

CORRESP_EXCEPTIONS = set ("""
ActaKvA
Ansegis
Benedictus.Levita
Capit.episc.
CapitulaRemedii
CollectioMartialisLemovicensis
ConcilioGermanico
DTR_66
Hieronymus.Eusebius.praef
Isidor.CMA.praef
KMexpeditioneRomana
KonzilNeuching
KonzilDingolfing
StatutaCapitularia
""".split ())

for i in range (1, 21):
    CORRESP_EXCEPTIONS.add ("CUE_%d" % i)

def ns (ns_name):
    ns, name = ns_name.split (':')
    return '{%s}%s' % (NS[ns], name)

def get_ns (e, ns_name):
    return e.get (ns (ns_name))


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


def norm (corresp, f):
    """ Normalize a @corresp

    :param str corresp: space-separated list of bks
    :param function f: the normalization function to apply

    :returns list: a list of normalized bks

    :raises ValueError: if the corresp cannot be parsed
    """

    res = []
    for cap_id in corresp.split ():
        try:
            res.append (f (cap_id))
        except ValueError as e:
            if not cap_id in CORRESP_EXCEPTIONS:
                log (logging.WARNING, str (e))
    return res


def process_msdesc (conn, root, ms_id, msp_part):
    """Process an <msDesc> or an <msPart>.

    Note: <msPart>s of a document may have originated in different times and
    places.

    Insert all known documents and parts in their relative tables.

    Extract the geo ids and add yet unknown geo ids to the geonames table for
    later lookup.

    :param instance conn:  database connection
    :param element root:   <msDesc> or <msPart>
    :param str ms_id:      the manuscript id
    :param str msp_part:    part id if it is a <msPart>

    """

    row = {
        'ms_id'       : ms_id,
        'msp_part'    : msp_part,
        'notbefore'   : HIDATE,
        'notafter'    : LODATE,
        'loci'    : None,
        'leaf'    : None,
        'written' : None,
    }

    for api, data in GEO_APIS.items ():
        data['geo_ids'] = set ()

    for origplace in root.xpath ("tei:head/tei:origPlace[@ref]", namespaces = NS):
        for api, data in GEO_APIS.items ():
            m = data['re'].search (origplace.get ('ref'))
            if m:
                data['geo_ids'].add (m.group (1))

    for origdate in root.xpath ("tei:head/tei:origDate", namespaces = NS):
        # if we find more than one estimate, take the most generous span
        get_date (row, origdate)

    for leaf in root.xpath (".//tei:dimensions[@type='leaf']", namespaces = NS):
        row['leaf'] = get_width_height (leaf)

    for written in root.xpath (".//tei:dimensions[@type='written']", namespaces = NS):
        row['written'] = get_width_height (written)

    if msp_part:
        try:
            loci = common.parse_mspart_n (root.get ('n'))
            row['loci'] = ["[%d, %d]" % l for l in loci]
        except ValueError:
            pass

    fix_date (row)

    execute (conn, """
    INSERT INTO msparts (ms_id, msp_part, date, loci, leaf, written)
      VALUES (:ms_id, :msp_part, int4range (:notbefore, :notafter, '[]'),
              CAST (:loci AS INT4RANGE[]), :leaf, :written)
    ON CONFLICT (ms_id, msp_part) DO NOTHING
    """, row)

    rows = []
    for api, data in GEO_APIS.items ():
        for geo_id in data['geo_ids']:
            rows.append ({
                'ms_id'      : ms_id,
                'msp_part'   : msp_part,
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
        INSERT INTO mn_msparts_geonames (ms_id, msp_part, geo_source, geo_id)
        VALUES (:ms_id, :msp_part, :geo_source, :geo_id)
        ON CONFLICT (ms_id, msp_part, geo_source, geo_id) DO NOTHING
        """, {}, rows)

        execute (conn, "COMMIT", {});

    # do the capitularies, these may not yet be transcribed

    cap_ids = set ()
    rows = []

    for msitem in root.xpath (".//tei:msItem", namespaces = NS):
        for title in msitem.xpath (".//tei:title[@corresp]", namespaces = NS):
            try:
                locus = msitem.xpath ('.//tei:locus', namespaces = NS)[0]
                locus = '[%s, %s]' % common.parse_locus (locus.text)
            except:
                log (logging.WARNING, "No locus for %s ..." % title.get ('corresp'))
                locus = '[0, 0]'

            for catalog, no, dummy_n in norm (title.get ('corresp'), common.normalize_bk_n):
                rows.append ({
                    'ms_id'       : ms_id,
                    'cap_id'      : "%s.%s" % (catalog, no),
                    'locus'       : locus,
                })

    if rows:
        # first make sure the capitulary is in the database
        executemany (conn, """
        INSERT INTO capitularies (cap_id)
        VALUES (:cap_id)
        ON CONFLICT (cap_id) DO NOTHING
        """, {}, rows)

        executemany (conn, """
        INSERT INTO mn_mss_capitularies (ms_id, cap_id, mscap_n)
        VALUES (:ms_id, :cap_id, 1)
        ON CONFLICT (ms_id, cap_id, mscap_n)
        DO NOTHING
        """, {}, rows)


def parse_corresp (el, params):
    """ Parse a @corresp attribute. """

    cap_id = params['cap_id']
    locus = None
    n = None
    try:
        locus = el.get ('locus')
        if (locus):
            locus, n = common.parse_xml_id_locus (locus, ms_id)
    except ValueError as e:
        log (logging.WARNING, str (e))

    rows = []
    for catalog, no, chapter in norm (el.get ('corresp'), common.normalize_corresp):
        corresp = "%s.%s_%s" % (catalog, no, chapter) if chapter else "%s.%s" % (catalog, no)

        if cap_id and not corresp.startswith (cap_id) and not (catalog in CORRESP_EXCEPTIONS):
            log (logging.WARNING, '@corresp %s following milestone %s' % (corresp, cap_id))

        p = params.copy ()
        p.update ({
            'cap_id'      : "%s.%s" % (catalog, no),
            'chapter'     : chapter or '',
            'mschap_n'    : 1,
            'locus'       : locus,
            'transcribed' : 0,
        })
        if cap_id != p['cap_id']:
            p['mscap_n'] = 0

        rows.append (p)

    return rows


def process_body (conn, root, ms_id):
    """Process a manuscript <body>.

    """

    capits   = []
    chapters = []

    # Documentation:
    # https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

    params = {
        'ms_id'   : ms_id,
        'cap_id'  : None,
        'mscap_n' : 0,
        'hands'   : '',
    }
    for e in root.xpath (".//tei:milestone[@unit]", namespaces = NS):
        unit = e.get ('unit')

        if unit == 'capitulatio':
            params['cap_id']  = None
            params['mscap_n'] = 0
        if unit == 'capitulare':
            try:
                catalog, no, mscap_n = common.normalize_bk_n (e.get ('n'))
                cap_id = "%s.%s" % (catalog, no)
                capits.append ({ 'cap_id' : cap_id })
                params['cap_id']  = cap_id
                params['mscap_n'] = mscap_n
            except ValueError as exc:
                log (logging.WARNING, str (exc))
        if unit == 'chapter':
            params['hands'] = get_ns (e, "cap:hands") or '';
            chapters += parse_corresp (e, params)


    if capits:
        # make sure the capitulary is in the database
        executemany (conn, """
        INSERT INTO capitularies (cap_id)
        VALUES (:cap_id)
        ON CONFLICT (cap_id) DO NOTHING
        """, {}, capits)

        execute (conn, "COMMIT", {});

    if chapters:
        # make sure the capitulary is in the database
        # again because some capitularies are without milestone
        executemany (conn, """
        INSERT INTO capitularies (cap_id)
        VALUES (:cap_id)
        ON CONFLICT (cap_id) DO NOTHING
        """, {}, chapters)

        # make sure the chapter is in the database
        executemany (conn, """
        INSERT INTO chapters (cap_id, chapter)
        VALUES (:cap_id, :chapter)
        ON CONFLICT (cap_id, chapter) DO NOTHING
        """, {}, chapters)

        # insert relation capitulary -> ms
        executemany (conn, """
        INSERT INTO mn_mss_capitularies (ms_id, cap_id, mscap_n)
        VALUES (:ms_id, :cap_id, :mscap_n)
        ON CONFLICT (ms_id, cap_id, mscap_n)
        DO NOTHING
        """, {}, chapters)

        # insert relation chapter -> capitulary
        executemany (conn, """
        INSERT INTO mss_chapters (ms_id, cap_id, mscap_n, chapter, mschap_n, locus, hands, transcribed)
        VALUES (:ms_id, :cap_id, :mscap_n, :chapter, :mschap_n, :locus, :hands, :transcribed)
        ON CONFLICT (ms_id, cap_id, mscap_n, chapter, mschap_n)
        DO NOTHING
        """, {}, chapters)



def process_cap (conn, item):
    """ Process one item from the capitularies list. """

    try:
        catalog, no, dummy_n = common.normalize_bk_n (get_ns (item, 'xml:id'))
        cap_id = "%s.%s" % (catalog, no)
    except ValueError as exc:
        log (logging.WARNING, str (exc))
        return

    log (logging.INFO, "Parsing %s ..." %  cap_id)

    row = {
        'cap_id'    : cap_id,
        'title'     : fix_ws (item.xpath ("tei:name", namespaces = NS)[0].text),
        'notbefore' : HIDATE,
        'notafter'  : LODATE,
    }

    for date in item.xpath ("tei:note[@type='date']/tei:date", namespaces = NS):
        get_date (row, date)

    fix_date (row)

    execute (conn, """
    INSERT INTO capitularies (cap_id, title, date)
    VALUES (:cap_id, :title, int4range (:notbefore, :notafter, '[]'))
    ON CONFLICT (cap_id) DO
    UPDATE
    SET title = EXCLUDED.title,
        date  = EXCLUDED.date
    """, row)


def lookup_published (conn, ajax_endpoint):

    for status in ('publish', 'private'):
        params = {
            'action' : 'on_cap_collation_user_get_published_ids',
            'status' : status,
        }
        r = requests.get (ajax_endpoint, params=params, timeout = 5)

        execute (conn, """
        UPDATE manuscripts
        SET status = :status
        WHERE ms_id IN :mss
        """, { 'status' : status, 'mss' : tuple (r.json ()['ids']) })

    execute (conn, """
    UPDATE manuscripts
    SET status = 'publish'
    WHERE ms_id = 'bk-textzeuge';
    """, {})


def build_parser (default_config_file):
    """ Build the commandline parser. """

    parser = argparse.ArgumentParser (description = __doc__)
    config_path = os.path.abspath (os.path.dirname (__file__) + '/server.conf')

    parser.add_argument (
        '-v', '--verbose', dest='verbose', action='count',
        help='increase output verbosity', default=0
    )
    parser.add_argument (
        '-c', '--config-file', dest='config_file',
        default=default_config_file, metavar='CONFIG_FILE',
        help="the config file (default='%s')" % default_config_file
    )
    parser.add_argument (
        '--init', action='store_true',
        help='initialize the Postgres database.', default=False
    )
    parser.add_argument (
        '--mss', nargs="+",
        help='the manuscript files (or the corpus file) to import'
    )
    parser.add_argument (
        '--cap-list', nargs="+",
        help='the capitularies lists to import'
    )
    parser.add_argument (
        '--publish', action='store_true',
        help='get the publish status from Wordpress Ajax API'
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

    build_parser ('server.conf').parse_args (namespace = args)
    config = config_from_pyfile (args.config_file)

    init_logging (
        args,
        logging.StreamHandler (),
        logging.FileHandler ('import.log')
    )

    log (logging.INFO, "Connecting to Postgres database ...")

    dba = db_tools.PostgreSQLEngine (**config)

    log (logging.INFO, "using url: %s." % dba.url)

    parser = etree.XMLParser (recover = True, remove_blank_text = True)

    if args.init:
        log (logging.INFO, "Creating Postgres database schema ...")

        db.Base.metadata.drop_all   (dba.engine)
        db.Base.metadata.create_all (dba.engine)

    if args.mss:
        log (logging.INFO, "Parsing TEI Manuscript files ...")

        with dba.engine.begin () as conn:
            execute (conn, "TRUNCATE TABLE manuscripts CASCADE", {});
            processed_ms_ids = dict ()
            for fn in args.mss:
                log (logging.INFO, "Parsing %s ..." % fn)
                tree = etree.parse (fn, parser = parser)
                for TEI in tree.xpath ("//tei:TEI", namespaces = NS):
                    ms_id    = get_ns (TEI, "xml:id")
                    filename = get_ns (TEI, "cap:file")
                    if ms_id in processed_ms_ids:
                        log (logging.ERROR, "xml:id %s (in %s) already seen in %s" %
                             (ms_id, filename or fn, processed_ms_ids[ms_id]))
                        continue
                    processed_ms_ids[ms_id] = filename or fn
                    log (logging.INFO, "Parsing Manuscript %s" % ms_id)
                    row = {
                        'ms_id' : ms_id,
                        'title' : fix_ws (
                            TEI.xpath ("tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']/text()",
                                       namespaces = NS)[0]
                        ),
                        'filename' : filename,
                    }
                    execute (conn, """
                    INSERT INTO manuscripts (ms_id, title, filename)
                      VALUES (:ms_id, :title, :filename)
                    ON CONFLICT (ms_id)
                    DO UPDATE SET title = EXCLUDED.title,
                                  filename = EXCLUDED.filename
                    """, row)

                    for msdesc in TEI.xpath ("tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc", namespaces = NS):
                        process_msdesc (conn, msdesc, ms_id, '')

                    for mspart in TEI.xpath ("tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msPart", namespaces = NS):
                        process_msdesc (conn, mspart, ms_id, mspart.get ('n'))

                    for body in TEI.xpath ("tei:text/tei:body", namespaces = NS):
                        process_body (conn, body, ms_id)

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

    if args.publish:
        with dba.engine.begin () as conn:
            log (logging.INFO, "Looking up published manuscripts ...")
            lookup_published (conn, config['WP_ADMIN_AJAX'])

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
