#!/usr/bin/python3
# -*- encoding: utf-8 -*-

""" Repository for common tools. """

import argparse
import collections
import csv
import io
import logging
import os.path
import re
import types

import MySQLdb  # apt-get libmariadb-dev && pip install mysqlclient
import requests
import roman as rom

import flask
from flask import current_app, request

NS_TEI = "http://www.tei-c.org/ns/1.0"
NS_XML = "http://www.w3.org/XML/1998/namespace"
NS_HTML = "http://www.w3.org/1999/xhtml"
NS_CAP = "http://cceh.uni-koeln.de/capitularia"

NS = {
    "tei": NS_TEI,
    "xml": NS_XML,
    "html": NS_HTML,
    "cap": NS_CAP,
}

# fmt: off
RE_WS              = re.compile(r"(\s+)")
RE_PUNCT           = re.compile(r"[-_.,:;!?*/]")
RE_BRACES          = re.compile(r"\([^\)]*\)")
RE_BRACKETS        = re.compile(r"\[\s*|\s*\]")
RE_NORMALIZE_SPACE = re.compile(r"\s+")

# See: https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

# regexes to match the milestone/@n and the */@corresp attributes
# @n:       the first group is the catalog name, the second the catalog number, the third the copy index
# @corresp: the first group is the catalog name, the second the catalog number, the third the chapter
REGEX_BK_N               = r"(bk|mordek|dtr_66\.§)[-nr._]+0*(\d+[a-z]?)(?:_(\d))?"
REGEX_BK_CORRESP         = r"(bk|mordek|dtr_66\.§)[-nr._]+0*(\d+[a-z]?)(?:_(.+))?"
REGEX_BENEDICTUS_N       = r"(benedictus\.levita)"
REGEX_BENEDICTUS_CORRESP = r"(benedictus\.levita)\.([1-2])((?:_\d+)?(?:_inscriptio(?:_c)?)?)"
REGEX_ANSEGIS_N          = r"(ansegis)\.([1-4])"
REGEX_ANSEGIS_CORRESP    = r"(ansegis)\.([1-4])(_\d+(?:_inscriptio)?)?"

REGEX_LOCUS = (
    r"<?([0-9]*)([IVXL]*)\s*\(?((?:bis|ter)?)\)?\s*((?:recto|verso|r|v)?)\s*([abc]?)>?"
)

RE_BK_N               = re.compile(REGEX_BK_N,               re.IGNORECASE)
RE_BK_CORRESP         = re.compile(REGEX_BK_CORRESP,         re.IGNORECASE)
RE_BENEDICTUS_N       = re.compile(REGEX_BENEDICTUS_N,       re.IGNORECASE)
RE_BENEDICTUS_CORRESP = re.compile(REGEX_BENEDICTUS_CORRESP, re.IGNORECASE)
RE_ANSEGIS_N          = re.compile(REGEX_ANSEGIS_N,          re.IGNORECASE)
RE_ANSEGIS_CORRESP    = re.compile(REGEX_ANSEGIS_CORRESP,    re.IGNORECASE)

RE_LOCUS        = re.compile(REGEX_LOCUS)
RE_LOCUS_RANGE  = re.compile(r"\b%s(?:\s*-\s*%s)?\b" % (REGEX_LOCUS, REGEX_LOCUS))
RE_LOCUS_N      = re.compile(r"-(\d+)")
RE_LOCUS_PITHOU = re.compile(r"\d-(\d+)")

RE_MSPART_N     = re.compile(r"(foll|fol|pp|p)\.\s+(.*)")
RE_INTRANGE     = re.compile(r"(\d+)-(\d+)")
# fmt: on

RE_BK_GUESS = re.compile(r"(bk|b|mordek|m)?[._ ]?(\d+)", re.IGNORECASE)
""" Regex for guessing a BK while parsing the commandline.
Allows for various shortcuts.  Should never be used on texts. """

LAST_BK = 307
""" The highest BK number.  Used for open ranges in commandline parsing. """

LAST_MORDEK = 27
""" The highest Mordek number. Used for open ranges in commandline parsing. """

BK_ZEUGE = "bk-textzeuge"

# geographic map attributions, used by geo_server *and* tile_server
DROYSEN1886 = "Droysen, Gustav. Historischer Handatlas. Leipzig, 1886"
VIDAL1898 = "Vidal-Lablache, Paul. Atlas général. Paris, 1898"
SHEPHERD1911 = "Shepherd, William. Historical Atlas. New York, 1911"
NATEARTH2019 = '&copy; <a href="http://www.naturalearthdata.com/">Natural Earth</a>'
CAPITULARIA = "capitularia.uni-koeln.de"

URL_SOLR = "http://localhost:8983/solr/capitularia/"


def make_json_response(json=None, status=200):
    return flask.make_response(
        flask.json.jsonify(json),
        status,
        {
            "Content-Type": "application/json;charset=utf-8",
        },
    )


def make_geojson_response(
    rows, fields, geometry_field_name="geom", id_field_name="geo_id"
):
    """Make a geoJSON response.

    All fields except the id and geometry fields become properties.

    GeoJSON specs: https://tools.ietf.org/html/rfc7946

    """

    fields = collections.namedtuple("GeoJSONFields", fields)

    features = []
    for row in rows:
        d = fields._make(row)
        properties = d._asdict()
        feature = {
            "type": "Feature",
            "id": properties[id_field_name],
            "geometry": properties[geometry_field_name],
            "properties": properties,
        }
        del properties[geometry_field_name]
        # del properties[id_field_name]
        features.append(feature)

    response = flask.make_response(
        flask.json.jsonify(
            {
                "type": "FeatureCollection",
                "features": features,
            }
        ),
        200,
        {
            "Content-Type": "application/geo+json;charset=utf-8",
        },
    )
    return response


def make_csv_response(rows, fields):
    """Send a HTTP response in CSV format."""

    fields = collections.namedtuple("CSVFields", fields)
    rows = list(map(fields._make, rows))

    return flask.make_response(
        to_csv(fields._fields, rows),
        200,
        {
            "Content-Type": "text/csv;charset=utf-8",
        },
    )


def to_csv(fields, rows):
    fp = io.StringIO()
    writer = csv.DictWriter(
        fp, fields, restval="", extrasaction="raise", dialect="excel"
    )
    writer.writeheader()
    for r in rows:
        writer.writerow(r._asdict())
    return fp.getvalue()


def fix_id(s: str) -> str:
    """Lowercases and replaces all punctuation with a hyphen."""
    return RE_PUNCT.sub("-", s).lower()


def fix_ws(s: str) -> str:
    """Replaces multiple whitespace characters with one space."""
    return RE_WS.sub(" ", s)


def text_content(e):
    return fix_ws("".join(e.itertext()))


def _parse_locus(locus, carry=0, is_end=False):
    """Parse a RE_LOCUS match into something sortable.

    I   => 00001000
    II  => 00002000
    1   => 10001000
    2   => 10002000
    bis => 00000100
    ter => 00000200
    r   => 00000000
    v   => 00000010
    a   => 00000000
    b   => 00000001
    c   => 00000002

    """

    locus = locus.strip()
    m = RE_LOCUS.fullmatch(locus)
    if not m:
        raise ValueError("Invalid locus: %s" % locus)

    folio = m.group(1) or ""
    roman = m.group(2) or ""
    bis = m.group(3) or ""
    rv = m.group(4) or ("v" if is_end else "r")
    ab = m.group(5) or ("b" if is_end else "a")

    if folio and roman:
        raise ValueError("Invalid locus: %s" % locus)

    res = 0
    if not (folio or roman):
        res = carry if carry else 10001000

    if folio:
        res += 1000 * int(folio) + 10000000
    if roman:
        res += 1000 * rom.fromRoman(roman)
    if bis:
        if bis == "bis":
            res += 100
        if bis == "ter":
            res += 200
    carry = res
    if rv[0] == "v":
        res += 10
    if ab:
        if ab == "b":
            res += 1
        if ab == "c":
            res += 2

    # logging.log (logging.WARNING, "Matched: %s => (%s)(%s)(%s)(%s)(%s) => %d" % (
    #     locus,
    #     m.group (1),
    #     m.group (2),
    #     m.group (3),
    #     m.group (4),
    #     m.group (5),
    #     res
    # ))

    return res, carry


def _parse_locus_range(m):
    """Parse a RE_LOCUS_RANGE match

    You have to parse these beauties:

      fol. 262
      foll. 33-86
      foll. 1r-6r
      foll. 24ra-52vb
      fol. 106r-v
      foll. 1v-2v, 57-168
      foll. 69-76, 76bis, 77-93, 99-147
      foll. 27-<82>
      fol. I, 1
      pp. 177-220
      IIra-vb
      foll. b-g
      foll. 1-85 und 94-153

    """

    if not m.group(0):
        # regex matched nothing
        raise ValueError("Invalid locus range: empty")

    if "-" in m.group(0):
        s, e = m.group(0).split("-")
    else:
        s = e = m.group(0)
    start, carry = _parse_locus(s, 0, False)
    end, carry = _parse_locus(e, carry, True)
    if start > end:
        raise ValueError("Invalid locus range: '%d-%d'" % (start, end))
    return start, end


def parse_msitem_locus(s):
    """Parse a <locus> element.

    May contain multiple ranges.
    """

    # FIXME: ad hoc fixes
    s = s.replace("(bis)", "bis")
    s = s.replace("Einzelblatt", "")
    s = s.replace("—", "-")
    s = s.replace("Ab fol. 86v", "86v")
    s = RE_BRACES.sub("", s)

    for m in RE_LOCUS_RANGE.finditer(s):
        if m:
            try:
                yield _parse_locus_range(m)
            except ValueError:
                pass


def parse_mspart_n(s):
    """Parse a @n="foll. 7-27, 44-51 (Teil-Hs. B)"

    May contain multiple ranges.
    """

    s = s.strip()
    m = RE_MSPART_N.search(s)
    if m is None or not m.group(2):
        raise ValueError("Invalid msPart @n: '%s'" % s)

    for m in RE_LOCUS_RANGE.finditer(m.group(2)):
        if m:
            try:
                yield _parse_locus_range(m)
            except ValueError:
                pass


def parse_xml_id_locus(locus):
    m = RE_LOCUS_PITHOU.match(locus) or RE_LOCUS.match(locus)
    if m is None:
        raise ValueError("Invalid locus: %s" % locus)

    m2 = RE_LOCUS_N.fullmatch(locus, m.end(0))
    if m2 is None:
        raise ValueError("Invalid locus: %s" % locus)

    return _parse_locus(m.group(1))[0], int(m2.group(1))


BK_NORM = {
    "bk": "BK",
    "mordek": "Mordek",
    "ansegis": "Ansegis",
    "benedictus.levita": "Benedictus.Levita",
    "dtr_66.§": "DTR.66.§",
}
""" Normalized catalog names. """


def _normalize_bk(m):
    """Normalize a BK number.

    :return: (BK, 20a)
    :type:   list
    :raises: ValueError if the input is malformed.
    """

    return BK_NORM[m[1].lower()], m[2] if m.lastindex >= 2 else ""


def normalize_bk(s):
    """Normalize a capitulary id.

    Normalize capitulary ids, eg. 'BK.20a', ' Mordek.25', or 'Ansegis.3_57'.

    :param str s: The capitulary id to normalize

    :return: ('BK', '20a')
    :type:   list
    :raises: ValueError if the input is malformed

    """

    m = (
        RE_BK_CORRESP.fullmatch(s)
        or RE_BENEDICTUS_CORRESP.fullmatch(s)
        or RE_ANSEGIS_CORRESP.fullmatch(s)
    )
    if m is None:
        raise ValueError("Invalid BK: '%s'" % s)

    return (*_normalize_bk(m),)


def normalize_milestone_n(n):
    """Normalize the @n attribute on a milestone unit capitulare.

    Examples:

       <milestone unit='capitulare' n='BK.139' />
       <milestone unit='capitulare' n='Benedictus.Levita' />
       <milestone unit='capitulare' n='Ansegis.3_57' />

    There may be more than one copy of any capitulary in a manuscript.
    The copies are marked by milestones:

       <milestone unit='capitulare' n='BK.139' />
       <milestone unit='capitulare' n='BK.139_1' />

    The last element in the returned list is the index, starting with 1.

    :param str n: The @n attribute to normalize

    :return: ('BK', '139', 2)
    :type:   list
    :raises: ValueError if the input is malformed

    """

    if n is None:
        raise ValueError("No @n found on milestone capitulare")

    m = RE_BK_N.match(n) or RE_BENEDICTUS_N.match(n) or RE_ANSEGIS_N.match(n)
    if m is None:
        raise ValueError("Invalid milestone capitulare @n: '%s'" % n)

    if m.lastindex == 3:
        return (*_normalize_bk(m), int(m[3]) + 1)

    # no copy index
    return (*_normalize_bk(m), 1)


def normalize_corresp(corresp):
    """Normalize a corresp attribute.

    Examples:

        <ab corresp='BK_16'>
        <ab corresp='BK_20a_12'>
        <ab corresp="Mordek.27">
        <ab corresp="Benedictus.Levita.1_279">
        <ab corresp="Ansegis.4_72_inscriptio_c">

    :param str corresp: The corresp to normalize

    :return: ('BK', '16', '') or ('BK', '20a', '12')
    :rtype:  list
    :raises: ValueError if the corresp is malformed
    """

    m = (
        RE_BK_CORRESP.match(corresp)
        or RE_BENEDICTUS_CORRESP.match(corresp)
        or RE_ANSEGIS_CORRESP.match(corresp)
    )
    if m is None:
        raise ValueError("Invalid @corresp: '%s'" % corresp)

    if m.lastindex == 3:
        return (*_normalize_bk(m), m[3])

    # no chapter
    return (*_normalize_bk(m), "")


def guess_bk(s, default_prefix="bk"):
    """Guess a BK from user input. Throw if hopeless."""

    m = RE_BK_GUESS.fullmatch(s)
    if m is None:
        raise ValueError("Cannot guess BK from: '%s'" % s)

    prefix = (m.group(1) or default_prefix).lower()
    if prefix[0] == "m":
        return "Mordek.{0:d}".format(int(m.group(2)))
    return "BK.{0:d}".format(int(m.group(2)))


def guess_bk_range(s, default_prefix="bk"):
    """Convert a range from user input into list of bk or mordek nos."""

    if not s:
        return

    res = []

    try:
        for value in s.split():
            r = value.split("-")
            if len(r) == 2:
                # a range eg. BK39-BK41, BK139-140, or M5-10
                if r[0] == "":
                    prefix0 = default_prefix.lower()
                    suffix0 = 1
                else:
                    m = RE_BK_GUESS.fullmatch(r[0])
                    prefix0 = (m.group(1) or default_prefix).lower()
                    suffix0 = int(m.group(2))

                if r[1] == "":
                    prefix1 = prefix0
                    suffix1 = LAST_MORDEK if prefix0 == "m" else LAST_BK
                else:
                    m = RE_BK_GUESS.fullmatch(r[1])
                    prefix1 = (m.group(1) or prefix0).lower()
                    suffix1 = int(m.group(2))

                if prefix0 != prefix1:
                    raise ValueError
                if suffix0 > suffix1:
                    raise ValueError

                for suffix in range(suffix0, suffix1 + 1):
                    res.append(guess_bk("%s%d" % (prefix0, suffix)))

            elif len(r) == 1:
                res.append(guess_bk(value))

            else:
                raise ValueError

    except ValueError:
        raise ValueError("error in range parameter")

    return res


def config_from_pyfile(filename):
    """Mimic Flask config files.

    Emulate the Flask config file parser so we can use the same config files for both,
    the Flask server and non-server scripts.

    """

    d = types.ModuleType("config")
    d.__file__ = filename
    try:
        with open(filename) as config_file:
            exec(compile(config_file.read(), filename, "exec"), d.__dict__)
    except IOError as e:
        e.strerror = "Unable to load configuration file (%s)" % e.strerror
        raise

    conf = {}
    for key in dir(d):
        if key.isupper():
            conf[key] = getattr(d, key)
    return conf


def init_logging(args):
    """Init the logging stuff."""

    LOG_LEVELS = {
        0: logging.CRITICAL,  #
        1: logging.ERROR,  # -v
        2: logging.WARN,  # -vv
        3: logging.INFO,  # -vvv
        4: logging.DEBUG,  # -vvvv
    }
    args.log_level = LOG_LEVELS.get(args.verbose, logging.DEBUG)

    logging.getLogger().setLevel(args.log_level)
    formatter = logging.Formatter(
        fmt="{esc0}{relativeCreated:6.0f} - {levelname:7} - {message}{esc1}", style="{"
    )

    stderr_handler = logging.StreamHandler()
    stderr_handler.setFormatter(formatter)
    logging.getLogger().addHandler(stderr_handler)

    file_handler = logging.FileHandler("server.log")
    file_handler.setFormatter(formatter)
    logging.getLogger().addHandler(file_handler)

    if args.log_level == logging.INFO:
        # sqlalchemy is way too verbose on level INFO
        sqlalchemy_logger = logging.getLogger("sqlalchemy.engine")
        sqlalchemy_logger.setLevel(logging.WARN)

    return args


def get_user_info_from_wp():
    current_app.logger.info(request.cookies)
    r = requests.get(current_app.config["USER_INFO_ENDPOINT"], cookies=request.cookies)
    current_app.logger.info(r.text)

    if r.json()["success"]:
        return r.json()["data"]
    return {}


def assert_map():
    info = get_user_info_from_wp()
    if "allcaps" in info and "edit_pages" in info["allcaps"]:
        return
    # abort (401, 'You have no "edit_pages" capability.')

    # FIXME: put this on the session


ROMANS = dict(
    zip(
        "M CM D CD C XC L XL X IX U V IU IV I".split(),
        map(int, "1000 900 500 400 100 90 50 40 10 9 5 5 4 4 1".split()),
    )
)

RE_ROMANS = re.compile("|".join(ROMANS.keys()))
RE_ROMAN = re.compile(r"\b([MDCLXVI]+)\b")

NORMALIZATION_DICTS = [
    {
        # string is already lowercased
        "j": "i",
        "v": "u",
        "ę": "e",
        "_": " ",
        "ae": "e",
        "oe": "e",
    },
    {
        # string is already lowercased
        "duodecim": "12",
        "uiginti": "20",
        "triginta": "30",
        "quadraginta": "40",
        "sexaginta": "60",
        "sexcentos": "600",
        "ecles": "eccles",
    },
]
""" The normalizations to apply. First dictionary first. """

NORMALIZATIONS = list(
    zip(
        [re.compile("|".join(d.keys())) for d in NORMALIZATION_DICTS],
        NORMALIZATION_DICTS,
    )
)


def roman_to_decimal(m):
    return str(sum([ROMANS[x] for x in RE_ROMANS.findall(m.group(0).upper())]))


def normalize_space(s):
    return RE_NORMALIZE_SPACE.sub(" ", s)


def normalize_latin(s):
    s = RE_ROMAN.sub(roman_to_decimal, s)
    s = s.lower()
    s = RE_PUNCT.sub("", s)
    s = RE_BRACKETS.sub("", s)

    for regex, d in NORMALIZATIONS:
        s = regex.sub(lambda m: d[m.group(0)], s)  # NOSONAR

    return normalize_space(s)


def un_qtranslate(text: str, lang: str) -> str:
    """Extract a language from a qTranslate multi-language text"""

    default_lang = "de"
    mode = default_lang
    result = ""

    for s in re.split(r"(\[:\w*\])", text):
        if s.startswith("[:"):
            if len(s) == 5:
                mode = s[2:4]
            if s == "[:]":
                mode = default_lang
            continue
        if lang == mode:
            result += s

    return result.strip()


def get_de(text: str) -> str:
    """Extract the German text from a qTranslate multi-language text"""
    return un_qtranslate(text, "de")


def get_en(text: str) -> str:
    """Extract the English text from a qTranslate multi-language text"""
    return un_qtranslate(text, "en")


def mysql_connection(args):
    """Connect to the mysql database."""
    cnf = os.path.expanduser(args.mysql_config_file)
    logging.log(logging.INFO, f"Connecting to mysql using config file: {cnf}")
    return MySQLdb.connect(read_default_file=cnf, read_default_group="mysql")


def get_post_status(args) -> dict[str, str]:
    """Get a dict of all xml:ids -> publish status"""

    mysql = mysql_connection(args)
    c = mysql.cursor()

    # get the parent page of all manuscripts: /mss
    query = """
        SELECT ID, post_name, post_parent, post_type
        FROM wp_posts
        WHERE post_name = 'mss'
            AND post_type = 'page'
        """
    c.execute(query)
    parent_page_id = int(c.fetchone()[0])

    # get the post_status of all manuscripts
    query = """
        SELECT pm.meta_value, p.post_status
        FROM wp_posts p
           INNER JOIN wp_postmeta pm ON p.ID = pm.post_id
        WHERE p.post_parent = %s
            AND pm.meta_key = 'tei-xml-id'
        """
    c.execute(query, (parent_page_id,))

    d = {"bk-textzeuge": "publish"}
    d.update(c.fetchall())
    return d


def build_parser(default_config_file, doc):
    """Build the commandline parser."""

    parser = argparse.ArgumentParser(description=doc, fromfile_prefix_chars="@")

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
    parser.add_argument(
        "--my-cnf",
        metavar=".MY.CNF.FILE",
        default="~/.my.cnf",
        dest="mysql_config_file",
        help="the mysql .my.cnf file to use (default:~/.my.cnf) (reads client and mysql sections)",
    )
    return parser
