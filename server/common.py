#!/usr/bin/python3
# -*- encoding: utf-8 -*-

""" Repository for common tools. """

import collections
import csv
import io
import logging
import re
import requests
import types

import flask
from flask import abort, current_app, request

RE_WS              = re.compile ('(\s+)')
RE_PUNCT           = re.compile (r'[-.,:;!?*/]')
RE_BRACKETS        = re.compile (r'\[\s*|\s*\]')
RE_NORMALIZE_SPACE = re.compile (r'\s+')

# See: https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

REGEX_BK      = r'(bk|mordek|ansegis|benedictus\.levita|dtr_66\.§)[-nr._]+0*(\d+)([a-z]?)'
REGEX_N       = r'(?:_(\d))?'
REGEX_CHAPTER = r'(?:_(.+))?'

RE_BK         = re.compile ('^' + REGEX_BK +                 '$', re.IGNORECASE)
RE_BK_N       = re.compile ('^' + REGEX_BK + REGEX_N +       '$', re.IGNORECASE)
RE_CORRESP    = re.compile ('^' + REGEX_BK + REGEX_CHAPTER + '$', re.IGNORECASE)

RE_LOCUS      = re.compile (r'(\d*)([rv]?[ab]?)(?:-(\d*)([rv]?))?')
RE_LOCUS_N    = re.compile (r'(\d*[rv]?[ab]?)-(\d+)')

RE_MSPART_N   = re.compile (r'foll?\.\s+(.*)$')
RE_INTRANGE   = re.compile (r'(\d+)(?:-(\d+))')


RE_BK_GUESS   = re.compile (r'^(b|bk|m|mordek)?[._ ]?(\d+)', re.IGNORECASE)
""" Regex for guessing a BK while parsing the commandline.
Allows for various shortcuts.  Should never be used on texts. """

LAST_BK      = 307
""" The highest BK number.  Used for open ranges in commandline parsing. """

LAST_MORDEK  = 27
""" The highest Mordek number. Used for open ranges in commandline parsing. """

# geographic map attributions, used by geo_server *and* tile_server
DROYSEN1886  = 'Droysen, Gustav. Historischer Handatlas. Leipzig, 1886'
VIDAL1898    = 'Vidal-Lablache, Paul. Atlas général. Paris, 1898'
SHEPHERD1911 = 'Shepherd, William. Historical Atlas. New York, 1911'
NATEARTH2019 = '&copy; <a href="http://www.naturalearthdata.com/">Natural Earth</a>'
CAPITULARIA  = 'capitularia.uni-koeln.de'


def make_json_response (json = None, status = 200):
    return flask.make_response (flask.json.jsonify (json), status, {
        'Content-Type' : 'application/json;charset=utf-8',
    })


def make_geojson_response (rows, fields, geometry_field_name = 'geom', id_field_name = 'geo_id'):
    """Make a geoJSON response.

    All fields except the id and geometry fields become properties.

    GeoJSON specs: https://tools.ietf.org/html/rfc7946

    """

    fields = collections.namedtuple ('GeoJSONFields', fields)

    features = []
    for row in rows:
        d = fields._make (row)
        properties = d._asdict ()
        feature = {
            'type'       : 'Feature',
            'id'         : properties[id_field_name],
            'geometry'   : properties[geometry_field_name],
            'properties' : properties,
        }
        del properties[geometry_field_name]
        # del properties[id_field_name]
        features.append (feature)

    response = flask.make_response (flask.json.jsonify ({
        'type'     : 'FeatureCollection',
        'features' : features,
    }), 200, {
        'Content-Type' : 'application/geo+json;charset=utf-8',
    })
    return response


def make_csv_response (rows, fields):
    """ Send a HTTP response in CSV format. """

    fields = collections.namedtuple ('CSVFields', fields)
    rows = list (map (fields._make, rows))

    return flask.make_response (to_csv (fields._fields, rows), 200, {
        'Content-Type' : 'text/csv;charset=utf-8',
    })


def to_csv (fields, rows):
    fp = io.StringIO ()
    writer = csv.DictWriter (fp, fields, restval='', extrasaction='raise', dialect='excel')
    writer.writeheader ()
    for r in rows:
        writer.writerow (r._asdict ())
    return fp.getvalue ()


def fix_ws (s):
    return RE_WS.sub (' ', s)


def text_content (e):
    return fix_ws (''.join (e.itertext ()))


def _parse_locus (m):
    """ Parse a RE_LOCUS match

    Normalize Nr and Nv to modern page numbering.
    """

    start, start_rv = int (m.group (1) or 0), m.group (2)
    end,   end_rv   = int (m.group (3) or 0), m.group (4)
    start   = start   or 1      # eg. xml:id=newhaven-bl-808-r-2
    end     = end     or start
    end_rv  = end_rv  or start_rv

    if (start_rv):
        start = 2 * start + (start_rv == 'v') - 1
    if (end_rv):
        end   = 2 * end   + (end_rv   == 'v') - 1

    if start > end:
        raise ValueError ("Bogus locus range: '%d-%d'" % (start, end))

    return start, end


def parse_locus (s):
    """ Parse a <locus> element

    Normalize Nr and Nv to modern page numbering.
    """

    m = RE_LOCUS.search (s)
    if m is None:
        raise ValueError ("Bogus locus: '%s'" % s)

    return _parse_locus (m)


def parse_mspart_n (s):
    """ Parse a n="foll. 7-27, 44-51 (Teil-Hs. B)"

    Normalize to modern page numbering.
    """

    m = RE_MSPART_N.search (s)
    if m is None:
        raise ValueError ("Bogus msPart @n: '%s'" % s)

    loci = m.group (1)
    return [_parse_locus (m) for m in RE_LOCUS.finditer (loci)]


def parse_xml_id_locus (s, ms_id):
    m = RE_LOCUS_N.search (s[len (ms_id) + 1:])
    if m is None:
        raise ValueError ("Bogus locus + n: '%s'" % s)

    return m.group (1), int (m.group (2))


BK_NORM = {
    'bk'                : "BK",
    'mordek'            : "Mordek",
    'ansegis'           : "Ansegis",
    'benedictus.levita' : "Benedictus.Levita",
    'dtr_66.§'          : "DTR.66.§",
}
""" The format(s) of a normalized BK. """


def _normalize_bk (m):
    """ Normalize a BK number.

    Return (BK, 20a)
    Throw on malformed BKs.
    """

    return BK_NORM[m.group (1).lower ()], m.group (2) + m.group (3).lower ()


def normalize_bk (s):
    """Normalize a capitulary id.

    :return: (BK, 20a)
    :type:   list
    :raises: ValueError if the input is malformed

    """

    m = RE_BK.search (s)
    if m is None:
        raise ValueError ("Bogus BK: '%s'" % s)

    return (*_normalize_bk (m), )


def normalize_bk_n (s):
    """Normalize a capitulary id.  Use on milestone @n.

    N.B. There may be one or more copies of a capitulary in any manuscript.
    The last element in the returned list is the index, starting with 1.

    :return: (BK, 20a, 1)
    :type:   list
    :raises: ValueError if the input is malformed

    """

    m = RE_BK_N.search (s)
    if m is None:
        raise ValueError ("Bogus BK: '%s'" % s)

    return (*_normalize_bk (m), int (m.group (4) or '1'))


def normalize_corresp (corresp):
    """ Normalize a corresp attribute.

    :param str corresp: The corresp to normalize

    :return: (BK, 20a, 12)
    :rtype:  list
    :raises: ValueError if the corresp is malformed
    """

    m = RE_CORRESP.search (corresp)
    if m is None:
        raise ValueError ("Bogus @corresp: '%s'" % corresp)

    return (*_normalize_bk (m), m.group (4))


def guess_bk (s, default_prefix = 'bk'):
    """ Guess a BK from user input. Throw if hopeless. """

    m = RE_BK_GUESS.search (s)
    if m is None:
        raise ValueError ("Cannot guess BK from: '%s'" % s)

    prefix = (m.group (1) or default_prefix).lower ()
    if prefix[0] == 'm':
        return "Mordek_{0:02d}".format (int (m.group (2)))
    return "BK_{0:03d}".format (int (m.group (2)))


def guess_bk_range (s, default_prefix = 'bk'):
    """ Convert a range from user input into list of bk or mordek nos. """

    if not s:
        return

    res = []

    try:
        for value in s.split ():
            r = value.split ('-')
            if len (r) == 2:
                # a range eg. BK39-BK41, BK139-140, or M5-10
                if r[0] == '':
                    prefix0 = default_prefix.lower ()
                    suffix0 = 1
                else:
                    m = RE_BK.search (r[0])
                    prefix0 = (m.group (1) or default_prefix).lower ()
                    suffix0 = int (m.group (2))

                if r[1] == '':
                    prefix1 = prefix0
                    suffix1 = LAST_MORDEK if prefix0 == 'm' else LAST_BK
                else:
                    m = RE_BK.search (r[1])
                    prefix1 = (m.group (1) or prefix0).lower ()
                    suffix1 = int (m.group (2))

                if prefix0 != prefix1:
                    raise ValueError
                if suffix0 > suffix1:
                    raise ValueError

                for suffix in range (suffix0, suffix1 + 1):
                    res.append (guess_bk ("%s%d" % (prefix0, suffix)))

            elif len (r) == 1:
                res.append (guess_bk (value))

            else:
                raise ValueError

    except ValueError:
        raise ValueError ("error in range parameter")

    return res


def config_from_pyfile (filename):
    """Mimic Flask config files.

    Emulate the Flask config file parser so we can use the same config files for both,
    the Flask server and non-server scripts.

    """

    d = types.ModuleType ('config')
    d.__file__ = filename
    try:
        with open (filename) as config_file:
            exec (compile (config_file.read (), filename, 'exec'), d.__dict__)
    except IOError as e:
        e.strerror = 'Unable to load configuration file (%s)' % e.strerror
        raise

    conf = {}
    for key in dir (d):
        if key.isupper ():
            conf[key] = getattr (d, key)
    return conf


def init_logging (args):
    """ Init the logging stuff. """

    LOG_LEVELS = {
        0: logging.CRITICAL,  #
        1: logging.ERROR,     # -v
        2: logging.WARN,      # -vv
        3: logging.INFO,      # -vvv
        4: logging.DEBUG      # -vvvv
    }
    args.log_level = LOG_LEVELS.get (args.verbose, logging.DEBUG)

    logging.getLogger ().setLevel (args.log_level)
    formatter = logging.Formatter (
        fmt = '{esc0}{relativeCreated:6.0f} - {levelname:7} - {message}{esc1}',
        style='{'
    )

    stderr_handler = logging.StreamHandler ()
    stderr_handler.setFormatter (formatter)
    logging.getLogger ().addHandler (stderr_handler)

    file_handler = logging.FileHandler ('server.log')
    file_handler.setFormatter (formatter)
    logging.getLogger ().addHandler (file_handler)

    if args.log_level == logging.INFO:
        # sqlalchemy is way too verbose on level INFO
        sqlalchemy_logger = logging.getLogger ('sqlalchemy.engine')
        sqlalchemy_logger.setLevel (logging.WARN)

    return args


def get_user_info_from_wp ():
    current_app.logger.info (request.cookies)
    r = requests.get (current_app.config['USER_INFO_ENDPOINT'], cookies = request.cookies)
    current_app.logger.info (r.text)

    if r.json ()['success']:
        return r.json ()['data']
    return {}


def assert_map ():
    info = get_user_info_from_wp ()
    if 'allcaps' in info and 'edit_pages' in info['allcaps']:
        return
    #abort (401, 'You have no "edit_pages" capability.')

    # FIXME: put this on the session


ROMANS = dict (zip (
    'M CM D CD C XC L XL X IX U V IU IV I'.split (),
    map (int, '1000 900 500 400 100 90 50 40 10 9 5 5 4 4 1'.split ()),
))

RE_ROMANS    = re.compile ('|'.join (ROMANS.keys ()))
RE_ROMAN     = re.compile (r'\b([MDCLXVI]+)\b')

NORMALIZATION_DICTS = [
    {
        # string is already lowercased
        'j'     : 'i',
        'v'     : 'u',
        'ę'     : 'e',
        '_'     : ' ',
        'ae'    : 'e',
        'oe'    : 'e',
    },
    {
        # string is already lowercased
        'duodecim'    : '12',
        'viginti'     : '20',
        'triginta'    : '30',
        'quadraginta' : '40',
        'sexaginta'   : '60',
        'sexcentos'   : '600',
        'ecles'       : 'eccles',
    },
]
""" The normalizations to apply. First dictionary first. """

NORMALIZATIONS = list (zip (
    [re.compile ('|'.join (d.keys ())) for d in NORMALIZATION_DICTS],
    NORMALIZATION_DICTS
))

def convert (m):
    return CONVERSIONS[m.group (0)]

def roman_to_decimal (m):
    return str (sum ([ROMANS[x] for x in RE_ROMANS.findall (m.group (0).upper ())]))

def normalize_space (s):
    return RE_NORMALIZE_SPACE.sub (' ', s)

def normalize_latin (s):
    s = RE_ROMAN.sub (roman_to_decimal, s)
    s = s.lower ()
    s = RE_PUNCT.sub ('', s)
    s = RE_BRACKETS.sub ('', s)

    for regex, d in NORMALIZATIONS:
        s = regex.sub (lambda m: d[m.group (0)], s)

    return normalize_space (s)
