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
import sqlalchemy

import common
from common import fix_ws
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

QNAME_DIV       = etree.QName (NS['tei'], 'div')
QNAME_LOCUS     = etree.QName (NS['tei'], 'locus')
QNAME_MILESTONE = etree.QName (NS['tei'], 'milestone')

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
_explicit
explicit
""".split ())

for i in range (1, 21):
    CORRESP_EXCEPTIONS.add ("CUE_%d" % i)

MSPART_N_EXCEPTIONS = {
    'Lat. 4761/1'          : 'foll. 1r-102v',
    'Lat. 4761/2'          : 'foll. 103r-128v',
    'foll. 3ra-105ra-rb'   : 'foll. 3ra-105rb',
    'I'                    : 'fol. I',
    'IIra-vb'              : 'fol. II',
    '1r-73'                : 'foll. 1r-73v',
}

MSS_WITHOUT_MSDESC = {
    common.BK_ZEUGE  : '[1883,1897]',
    'nauclerus-1514' : '[1514,1514]',
    'pithou-1588'    : '[1588,1588]',
}

def ns (ns_name):
    ns, name = ns_name.split (':')
    return '{%s}%s' % (NS[ns], name)

def get_ns (e, ns_name):
    return e.get (ns (ns_name))


def get_date (dates):
    """Read a date range from a sequence of tei:date elements.

    The dates are estimates.  If there is more than one estimate, take the most
    generous span.

    """

    def fix_date (s):
        try:
            return int (s)
        except ValueError:
            try:
                return datetime.datetime.strptime (s, '%Y-%m').year
            except ValueError:
                return datetime.datetime.strptime (s, '%Y-%m-%d').year

    notbefore = HIDATE
    notafter  = LODATE

    for date in dates:
        notbefore = min (
            notbefore,
            fix_date (date.get ('notBefore', HIDATE)),
            fix_date (date.get ('from',      HIDATE)),
            fix_date (date.get ('when',      HIDATE))
        )
        notafter = max (
            notafter,
            fix_date (date.get ('notAfter',  LODATE)),
            fix_date (date.get ('to',        LODATE)),
            fix_date (date.get ('when',      LODATE))
        )

    if notbefore > notafter:
        return None

    return "[%d,%d]" % (notbefore, notafter)


def lookup_geonames (conn, geo_source):
    """ Lookup the GEO APIs.

    Cached:  Lookup only entities we don't already know.
    """

    data = GEO_APIS[geo_source]

    while True:

        # get a row we didn't yet look up
        res = execute (conn, """
        SELECT geo_id
        FROM geonames
        WHERE geo_source = :geo_source AND blob IS NULL
        LIMIT 1
        """, { 'geo_source' : geo_source})

        try:
            row = res.fetchone ()
            if row is None:
                break

            geo_id = row[0]
            print ("Looking up api: %s, id: %s" % (geo_source, geo_id))

            url = data['endpoint'].format (id = geo_id)
            r = requests.get (url, timeout = 5)

            row = {
                'geo_source' : geo_source,
                'geo_id'     : geo_id,
                'parent_id'  : None,
                'geo_name'   : None,
                'geo_fcode'  : None,
                'geom'       : None,
                'blob'       : r.text,
            }

            if geo_source == 'geonames':
                records = json.loads (r.text)['geonames']
                place = records[-1]
                row.update ({
                    'geo_name'  : place['name'],
                    'geo_fcode' : place['fcode'],
                    'geom'      : 'SRID=4326;POINT (%f %f)' % (float (place['lng']), float (place['lat'])),
                })
                if len (records) > 1:
                    row['parent_id'] = records[-2]['geonameId']

                    execute (conn, """
                    INSERT INTO geonames (geo_id, geo_source)
                    VALUES (:geo_id, :geo_source)
                    ON CONFLICT (geo_id, geo_source) DO NOTHING
                    """, { 'geo_id' : row['parent_id'], 'geo_source' : geo_source })

            if geo_source == 'dnb':
                rec = json.loads (r.text)
                row['geo_name'] = rec['preferredName']

            if geo_source == 'viaf':
                rec = json.loads (r.text)
                # geo_id = rec['GeoNames'] # == ["http://www.geonames.org/3017382"],
                raise NotImplementedError

            execute (conn, """
            UPDATE geonames
            SET geom      = :geom,
                parent_id = :parent_id,
                geo_name  = :geo_name,
                geo_fcode = :geo_fcode,
                blob      = :blob
            WHERE (geo_id, geo_source) = (:geo_id, :geo_source)
            """, row)

            execute (conn, "COMMIT", {})

        except IndexError:
            break

        except:
            log (logging.WARNING, "Error looking up %s" % url)
            raise


def get_width_height (elem):
    w = ''
    h = ''
    for width in elem.xpath ('tei:width', namespaces = NS):
        w = width.text or ''
    for height in elem.xpath ('tei:height', namespaces = NS):
        h = height.text or ''
    return [ w.strip (), h.strip () ]


def process_msdesc (conn, root, ms_id, msp_part = ''):
    """Process an <msDesc> or an <msPart>.

    Note: <msPart>s of a document may have originated in different times and
    places.

    Insert all known documents and parts in their relative tables.

    Extract the geo ids and add yet unknown geo ids to the geonames table for
    later lookup.

    :param instance conn:  database connection
    :param element root:   <msDesc> or <msPart>
    :param str ms_id:      the manuscript id
    :param str msp_part:   part id if it is a <msPart>

    """

    row = {
        'ms_id'        : ms_id,
        'msp_part'     : msp_part,
        'date'         : None,
        'locus_cooked' : None,
        'leaf'         : None,
        'written'      : None,
    }

    for api, data in GEO_APIS.items ():
        data['geo_ids'] = set ()

    for origplace in root.xpath ("tei:head/tei:origPlace[@ref]", namespaces = NS):
        for api, data in GEO_APIS.items ():
            m = data['re'].search (origplace.get ('ref'))
            if m:
                data['geo_ids'].add (m.group (1))

    # if we find more than one estimate, take the most generous span
    row['date'] = get_date (root.xpath ("tei:head/tei:origDate", namespaces = NS))

    for leaf in root.xpath (".//tei:dimensions[@type='leaf']", namespaces = NS):
        row['leaf'] = get_width_height (leaf)

    for written in root.xpath (".//tei:dimensions[@type='written']", namespaces = NS):
        row['written'] = get_width_height (written)

    if msp_part:
        try:
            mspart_n = root.get ('n')
            mspart_n = MSPART_N_EXCEPTIONS.get (mspart_n, mspart_n)
            locus_cooked = common.parse_mspart_n (mspart_n)
            row['locus_cooked'] = ["[%d, %d]" % l for l in locus_cooked]
        except ValueError:
            pass

    execute (conn, """
    INSERT INTO msparts (ms_id, msp_part, date, locus_cooked, leaf, written)
      VALUES (:ms_id, :msp_part, :date,
              CAST (:locus_cooked AS INT4RANGE[]), :leaf, :written)
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

        execute (conn, "COMMIT", {})

    # do the capitularies mentioned in the msItems, these may not yet be
    # transcribed

    rows = []

    # count the loci at which the capitular was found
    cap_loci = collections.defaultdict (set)

    locus        = None
    locus_cooked = None
    for msitem in root.xpath (".//tei:msItem", namespaces = NS):
        msitem_n = msitem.get ('n')
        for tl in msitem.xpath (".//tei:title[@corresp]|.//tei:locus", namespaces = NS):
            if tl.tag == QNAME_LOCUS:
                try:
                    locus        = tl.text.lstrip ('-').strip ()
                    locus_cooked = ["[%d, %d]" % l for l in common.parse_msitem_locus (locus)]
                except ValueError as e:
                    log (logging.WARNING, "%s: %s in msItem %s" % (ms_id, str (e), msitem_n))
            else:
                for corresp in tl.get ('corresp').split ():
                    try:
                        catalog, no = common.normalize_bk (corresp)
                        cap_id = "%s.%s" % (catalog, no)
                        cap_loci[cap_id].add (locus)
                        # there is no mscap_n in the msItem, must infer from locus
                        rows.append ({
                            'ms_id'        : ms_id,
                            'cap_id'       : cap_id,
                            'mscap_n'      : len (cap_loci[cap_id]),
                            'msp_part'     : msp_part,
                            'locus'        : locus,
                            'locus_cooked' : locus_cooked,
                        })
                    except ValueError as e:
                        if corresp not in CORRESP_EXCEPTIONS:
                            log (logging.WARNING, "%s: %s in msItem %s" % (ms_id, str (e), msitem_n))

    if rows:
        # first make sure the capitulary is in the database
        executemany (conn, """
        INSERT INTO capitularies (cap_id)
        VALUES (:cap_id)
        ON CONFLICT (cap_id) DO NOTHING
        """, {}, rows)

        executemany (conn, """
        INSERT INTO mss_capitularies (ms_id, cap_id, mscap_n, msp_part, locus, locus_cooked)
        VALUES (:ms_id, :cap_id, :mscap_n, :msp_part, :locus, CAST (:locus_cooked AS INT4RANGE[]))
        ON CONFLICT (ms_id, cap_id, mscap_n)
        DO NOTHING
        """, {}, rows)


def process_cap (conn, filename):
    """ Process one item from the capitularies list. """

    tree = etree.parse (filename, parser = parser)

    for tei in tree.xpath ("/tei:TEI[@corresp]", namespaces = NS):
        try:
            # corresp="ldf/bk-nr-139"
            catalog, no = common.normalize_bk (tei.get ('corresp').split ('/')[1])
            cap_id = "%s.%s" % (catalog, no)
        except ValueError as e:
            log (logging.WARNING, "%s: %s" % (filename, str (e)))
            return

        log (logging.INFO, "Parsing %s ..." %  cap_id)

        for body in tei.xpath (".//tei:body", namespaces = NS):
            row = {
                'cap_id' : cap_id,
                'title'  : fix_ws (body.xpath (".//tei:head", namespaces = NS)[0].text.split (':')[1].strip ()),
                'date'   : get_date (body.xpath (".//tei:note[@type='date']/tei:date", namespaces = NS)),
            }

            execute (conn, """
            INSERT INTO capitularies (cap_id, title, date)
            VALUES (:cap_id, :title, :date)
            ON CONFLICT (cap_id) DO
            UPDATE
            SET title = EXCLUDED.title,
                date  = EXCLUDED.date
            """, row)


def lookup_published (conn, ajax_endpoint):

    for status in ('publish', 'private'):
        params = {
            'action' : 'on_cap_lib_get_published_ids',
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
    WHERE ms_id = :bkzeuge
    """, { 'bkzeuge' : common.BK_ZEUGE })


def import_geoplaces (conn, args):
    """ Import a geoplaces.xml file. """

    if args.truncate:
        execute (conn, "TRUNCATE TABLE gis.geoplaces CASCADE", {})

    fn = args.geoplaces
    log (logging.INFO, "Parsing %s ..." % fn)
    tree = etree.parse (fn, parser = parser)

    for place in tree.xpath ("/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id]", namespaces = NS):
        params = {
            'geo_id'    : get_ns (place, "xml:id"),
            'parent_id' : None,
        }
        for parent in place.xpath ("tei:*[@corresp]", namespaces = NS):
            params['parent_id'] = parent.get ('corresp')[1:]

        execute (conn, """
        INSERT INTO gis.geoplaces (geo_id, parent_id)
        VALUES (:geo_id, :parent_id)
        ON CONFLICT (geo_id)
        DO UPDATE SET parent_id = EXCLUDED.parent_id
        """, params)

        for lang in place.xpath ("tei:*[@xml:lang]", namespaces = NS):
            params['geo_lang'] = get_ns (lang, "xml:lang").lower ()
            params['geo_name'] = lang.text,

            execute (conn, """
            INSERT INTO gis.geoplaces_names (geo_id, geo_lang, geo_name)
              VALUES (:geo_id, :geo_lang, :geo_name)
            ON CONFLICT (geo_id, geo_lang)
            DO UPDATE SET geo_name  = EXCLUDED.geo_name
            """, params)

        execute (conn, "COMMIT", {})

        for link in place.xpath ("tei:linkGrp[@type='mss']/tei:link", namespaces = NS):
            params['ms_id'] = link.get ("target")

            try:
                execute (conn, "BEGIN", {})

                execute (conn, """
                INSERT INTO gis.mn_mss_geoplaces (ms_id, geo_id)
                  VALUES (:ms_id, :geo_id)
                ON CONFLICT
                DO NOTHING
                """, params)

                execute (conn, "COMMIT", {})

            except sqlalchemy.exc.IntegrityError as e:
                log (logging.ERROR, e)
                execute (conn, "ROLLBACK", {})


    execute (conn, "COMMIT", {})


def import_corpus (conn, args):
    """ Import a corpus file (or lots of manuscript files). """

    if args.truncate:
        execute (conn, "TRUNCATE TABLE manuscripts CASCADE", {})

    processed_ms_ids = dict ()
    fn_corpus = args.mss
    for fn in fn_corpus:
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
                msparts = msdesc.xpath ("tei:msPart", namespaces = NS)
                if msparts:
                    for mspart in msparts:
                        process_msdesc (conn, mspart, ms_id, mspart.get ('n'))
                else:
                    process_msdesc (conn, msdesc, ms_id)

            if ms_id in MSS_WITHOUT_MSDESC:
                log (logging.INFO, "Patching %s" % ms_id)
                execute (conn, """
                INSERT INTO msparts (ms_id, msp_part, date)
                VALUES (:ms_id, :msp_part, :date)
                ON CONFLICT (ms_id, msp_part) DO NOTHING
                """, { 'ms_id' : ms_id, 'msp_part' : '', 'date' : MSS_WITHOUT_MSDESC[ms_id] })

            for body in TEI.xpath ("tei:text/tei:body", namespaces = NS):
                process_body (conn, body, ms_id)

            execute (conn, "COMMIT", {})


def process_body (conn, root, ms_id):
    """Process a manuscript <body>.

    """

    # Documentation:
    # https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

    chapters = []
    mscap_n  = 1

    # in corpus.xml we have <milestone unit="chapter" corresp="..." locus="..." /> !!!
    for milestone in root.xpath (".//tei:milestone", namespaces = NS):
        unit = milestone.get ('unit')
        if unit == 'capitulare':
            try:
                n = milestone.get ('n')
                catalog, no, mscap_n = common.normalize_bk_capitulare (n)
            except ValueError as e:
                log (logging.WARNING, "%s: %s" % (ms_id, str (e)))
            continue

        if unit == 'chapter':
            locus        = None
            locus_index  = None
            locus_cooked = None
            if ms_id != common.BK_ZEUGE: # there are no loci in bk-textzeuge
                try:
                    locus = milestone.get ('locus') # added by corpus.xsl from xml:id
                    if not locus:
                        raise ValueError ()
                    if not locus.startswith (ms_id):
                        raise ValueError ()

                    loc = locus[len (ms_id) + 1:]
                    loc = loc.replace ('pertz_', '')
                    locus_cooked, locus_index = common.parse_xml_id_locus (loc)

                except ValueError as e:
                    log (logging.WARNING, "%s: Invalid xml:id: %s" % (ms_id, locus))

            for corresp in milestone.get ('corresp').split ():
                try:
                    catalog, no, chapter = common.normalize_corresp (corresp)
                    chapters.append ({
                        'ms_id'        : ms_id,
                        'cap_id'       : "%s.%s" % (catalog, no),
                        'chapter'      : chapter,
                        'mscap_n'      : mscap_n,
                        'locus'        : locus,
                        'locus_index'  : locus_index,
                        'locus_cooked' : locus_cooked,
                        'transcribed'  : 0,
                    })
                except ValueError as e:
                    if corresp not in CORRESP_EXCEPTIONS:
                        log (logging.WARNING, "%s: %s" % (ms_id, str (e)))

    if chapters:
        # make sure the capitulary is in the database
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

        # insert relation chapter -> capitulary, mspart
        executemany (conn, """
        INSERT INTO mss_chapters (ms_id, cap_id, mscap_n, chapter,
                                  locus, locus_index, locus_cooked, transcribed, msp_part)
        SELECT :ms_id, :cap_id, :mscap_n, :chapter,
               :locus, :locus_index, :locus_cooked, :transcribed, msp_part
          FROM msparts
          WHERE ms_id = :ms_id
            AND (:locus_cooked <@ ANY (msparts.locus_cooked) OR msparts.locus_cooked IS NULL)
        ON CONFLICT (ms_id, cap_id, mscap_n, chapter)
        DO NOTHING
        """, {}, chapters)


def import_fulltext (conn, filenames, mode):
    """ Import the xml or plain text of the chapter transcriptions """

    for fn in filenames:
        log (logging.INFO, "Parsing %s ..." % fn)
        tree = etree.parse (fn, parser = parser)
        for TEI in tree.xpath ("/tei:TEI", namespaces = NS):
            ms_id = get_ns (TEI, "xml:id")
            mscap_catalog = ''
            mscap_no = ''
            mscap_n = 1

            for item in TEI.xpath (".//tei:div[@corresp]|.//tei:milestone[@unit]", namespaces = NS):
                if item.tag == QNAME_MILESTONE:
                    unit = item.get ('unit')
                    if unit == 'capitulare':
                        try:
                            n = item.get ('n')
                            mscap_catalog, mscap_no, mscap_n = common.normalize_bk_capitulare (n)
                        except ValueError as e:
                            log (logging.WARNING, "%s: %s" % (ms_id, str (e)))
                    continue

                corresp = item.get ("corresp")
                hand = 'original'
                if '?later_hands' in corresp:
                    hand = 'later_hands'
                    corresp = corresp.replace ('?later_hands', '')

                try:
                    catalog, no, chapter = common.normalize_corresp (corresp)

                    if (catalog, no) != (mscap_catalog, mscap_no):
                        log (logging.DEBUG, "%s: Missing milestone capitulare for: %s" % (ms_id, corresp))

                    params = {
                        'ms_id'   : ms_id,
                        'cap_id'  : "%s.%s" % (catalog, no),
                        'mscap_n' : mscap_n,
                        'chapter' : chapter,
                        'type'    : hand,
                    }

                    if mode == 'xml':
                        # we assume the chapters are already there from a corpus scrap
                        res = execute (conn, """
                        UPDATE mss_chapters
                        SET xml = :text
                        WHERE (ms_id, cap_id, mscap_n, chapter) =
                              (:ms_id, :cap_id, :mscap_n, :chapter)
                        """, dict (params, text = etree.tostring (item, encoding='unicode')))
                        if res.rowcount != 1:
                            log (logging.ERROR,
                                 "Import fulltext did not match row {ms_id} {cap_id} {mscap_n} {chapter}".format (**params))

                    if mode == 'txt':
                        execute (conn, """
                        INSERT INTO mss_chapters_text (ms_id, cap_id, mscap_n, chapter, type, text)
                        VALUES (:ms_id, :cap_id, :mscap_n, :chapter, :type, :text)
                        ON CONFLICT (ms_id, cap_id, mscap_n, chapter, type) DO UPDATE
                        SET text = EXCLUDED.text
                        """, dict (params, text = item.text))

                except ValueError as e:
                    if corresp not in CORRESP_EXCEPTIONS:
                        log (logging.WARNING, "%s: %s" % (ms_id, str (e)))

            execute (conn, "COMMIT", {})


def build_parser (default_config_file):
    """ Build the commandline parser. """

    parser = argparse.ArgumentParser (
        description = __doc__,
        fromfile_prefix_chars = '@'
    )
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
        help='initialize the Postgres database', default=False
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
        '--extracted', nargs="*",
        help='import per-chapter extracted XML from files'
    )
    parser.add_argument (
        '--fulltext', nargs="*",
        help='import per-chapter extracted fulltext from files'
    )
    parser.add_argument (
        '--publish', action='store_true',
        help='get the publish status from Wordpress Ajax API'
    )
    parser.add_argument (
        '--geoplaces', action='store',
        help='import geoplaces XML', default=False
    )
    parser.add_argument (
        '--geonames', action='store_true',
        help='lookup geonames.org', default=False
    )
    parser.add_argument (
        '--dnb', action='store_true',
        help='lookup dnb.de', default=False
    )
    parser.add_argument (
        '--viaf', action='store_true',
        help='lookup viaf.org', default=False
    )
    parser.add_argument (
        '--truncate', action='store_true',
        help='truncate the relative Postgres table before importing into it', default=False
    )
    return parser


if __name__ == "__main__":
    import logging

    build_parser ('server.conf').parse_args (namespace = args)
    args.config = config_from_pyfile (args.config_file)

    init_logging (
        args,
        logging.StreamHandler (),
        logging.FileHandler ('import.log')
    )

    log (logging.INFO, "Connecting to Postgres database ...")

    dba = db_tools.PostgreSQLEngine (**args.config)

    log (logging.INFO, "using url: %s." % dba.url)

    parser = etree.XMLParser (recover = True, remove_blank_text = True)

    if args.init:
        log (logging.INFO, "Creating Postgres database schema ...")

        db.Base.metadata.drop_all   (dba.engine)
        db.Base.metadata.create_all (dba.engine)

    if args.mss:
        log (logging.INFO, "Parsing TEI Manuscript files ...")
        with dba.engine.begin () as conn:
            import_corpus (conn, args)

    if args.cap_list:
        log (logging.INFO, "Parsing TEI Capitulary List ...")

        with dba.engine.begin () as conn:
            for fn in args.cap_list:
                log (logging.INFO, "Parsing %s ..." % fn)
                process_cap (conn, fn)
                execute (conn, "COMMIT", {})

    if args.geoplaces:
        log (logging.INFO, "Importing geoplaces XML ...")
        with dba.engine.begin () as conn:
            import_geoplaces (conn, args)

    if args.publish:
        log (logging.INFO, "Looking up published manuscripts ...")
        with dba.engine.begin () as conn:
            lookup_published (conn, args.config['WP_ADMIN_AJAX'])

    if args.geonames:
        log (logging.INFO, "Looking up in geonames.org ...")
        with dba.engine.begin () as conn:
            lookup_geonames (conn, 'geonames')

    if args.dnb:
        log (logging.INFO, "Looking up in DNB ...")
        with dba.engine.begin () as conn:
            lookup_geonames (conn, 'dnb')

    if args.viaf:
        log (logging.INFO, "Looking up in viaf.org ...")
        with dba.engine.begin () as conn:
            lookup_geonames (conn, 'viaf')

    if args.extracted:
        log (logging.INFO, "Importing extracted @corresp XML ...")
        with dba.engine.begin () as conn:
            import_fulltext (conn, args.extracted, 'xml')

    if args.fulltext:
        log (logging.INFO, "Importing extracted @corresp fulltext ...")
        with dba.engine.begin () as conn:
            import_fulltext (conn, args.fulltext, 'txt')

    log (logging.INFO, "Done")
