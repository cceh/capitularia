#!/usr/bin/python3

"""Indexes TEI files and Wordpress pages into Solr

This tool can:

  - Connect directly to the Wordpress mysql database and index all pages and posts to
    Solr.
  - Index the header sections of TEI files to Solr.

"""

import datetime
import logging
import logging.handlers
import re
import urllib.parse

from bs4 import BeautifulSoup
from lxml import etree
import requests
import tqdm

import common
from common import mysql_connection, get_de, get_en, fix_id, fix_ws, NS
from config import args, init_logging, config_from_pyfile
import db_tools
from db_tools import log

MYSQL_DEFAULT_FILES = ("/etc/my.cnf", "/etc/mysql/my.cnf", "~/.my.cnf")
MYSQL_DEFAULT_GROUPS = ("mysql", "client", "client-server", "client-mariadb")

RE_QT_DE = re.compile(r"\[:de\]([^[]+)(?:\[:|$)")
RE_QT_EN = re.compile(r"\[:en\]([^[]+)(?:\[:|$)")

QNAME_DIV = etree.QName(NS["tei"], "div")
QNAME_LOCUS = etree.QName(NS["tei"], "locus")
QNAME_MILESTONE = etree.QName(NS["tei"], "milestone")
QNAME_NOTE = etree.QName(NS["tei"], "note")

HIDATE = 10000
LODATE = -10000

CORRESP_EXCEPTIONS = set(
    """
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
""".split()
)

for i in range(1, 21):
    CORRESP_EXCEPTIONS.add("CUE_%d" % i)

MSPART_N_EXCEPTIONS = {
    "Lat. 4761/1": "foll. 1r-102v",
    "Lat. 4761/2": "foll. 103r-128v",
    "foll. 3ra-105ra-rb": "foll. 3ra-105rb",
    "I": "fol. I",
    "IIra-vb": "fol. II",
    "1r-73": "foll. 1r-73v",
}

MSS_WITHOUT_MSDESC = {
    common.BK_ZEUGE: "[1883,1897]",
    "nauclerus-1514": "[1514,1514]",
    "pithou-1588": "[1588,1588]",
}


def ns(ns_name):
    """Convert prefix:tag into normal form {ns}tag"""

    ns, name = ns_name.split(":")
    return "{%s}%s" % (NS[ns], name)


def get_ns(e, ns_name):
    """Get an attribute with namespace prefix.

    :param element e:      The element with the attribute
    :param string ns_name: The attribute name as prefix:name.

    """
    return e.get(ns(ns_name))


def get_date(dates):
    """Read a date range from a sequence of tei:date elements.

    The dates are estimates.  If there is more than one estimate, take the most
    generous span.

    """

    def fix_date(s):
        try:
            return int(s)
        except ValueError:
            try:
                return datetime.datetime.strptime(s, "%Y-%m").year
            except ValueError:
                return datetime.datetime.strptime(s, "%Y-%m-%d").year

    notbefore = HIDATE
    notafter = LODATE

    for date in dates:
        notbefore = min(
            notbefore,
            fix_date(date.get("notBefore", HIDATE)),
            fix_date(date.get("from", HIDATE)),
            fix_date(date.get("when", HIDATE)),
        )
        notafter = max(
            notafter,
            fix_date(date.get("notAfter", LODATE)),
            fix_date(date.get("to", LODATE)),
            fix_date(date.get("when", LODATE)),
        )

    if notbefore > notafter:
        return None

    return "[%d,%d]" % (notbefore, notafter)


def get_width_height(elem):
    """Get the width and height from TEI attributes."""

    w = ""
    h = ""
    for width in elem.xpath("tei:width", namespaces=NS):
        w = width.text or ""
    for height in elem.xpath("tei:height", namespaces=NS):
        h = height.text or ""
    return [w.strip(), h.strip()]


# describe wp_posts;
# +-----------------------+---------------------+------+-----+---------------------+----------------+
# | Field                 | Type                | Null | Key | Default             | Extra          |
# +-----------------------+---------------------+------+-----+---------------------+----------------+
# | ID                    | bigint(20) unsigned | NO   | PRI | NULL                | auto_increment |
# | post_author           | bigint(20) unsigned | NO   | MUL | 0                   |                |
# | post_date             | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
# | post_date_gmt         | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
# | post_content          | longtext            | NO   | MUL | NULL                |                |
# | post_title            | text                | NO   | MUL | NULL                |                |
# | post_excerpt          | text                | NO   | MUL | NULL                |                |
# | post_status           | varchar(20)         | NO   |     | publish             |                |
# | comment_status        | varchar(20)         | NO   |     | open                |                |
# | ping_status           | varchar(20)         | NO   |     | open                |                |
# | post_password         | varchar(255)        | NO   |     |                     |                |
# | post_name             | varchar(200)        | NO   | MUL |                     |                |
# | to_ping               | text                | NO   |     | NULL                |                |
# | pinged                | text                | NO   |     | NULL                |                |
# | post_modified         | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
# | post_modified_gmt     | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
# | post_content_filtered | longtext            | NO   |     | NULL                |                |
# | post_parent           | bigint(20) unsigned | NO   | MUL | 0                   |                |
# | guid                  | varchar(255)        | NO   |     |                     |                |
# | menu_order            | int(11)             | NO   |     | 0                   |                |
# | post_type             | varchar(20)         | NO   | MUL | post                |                |
# | post_mime_type        | varchar(100)        | NO   |     |                     |                |
# | comment_count         | bigint(20)          | NO   |     | 0                   |                |
# +-----------------------+---------------------+------+-----+---------------------+----------------+


def wordpress2solr():
    """Index all Wordpress posts and pages to Solr."""

    url = urllib.parse.urljoin(common.URL_SOLR, "update/json/docs")

    db = mysql_connection(args)
    c = db.cursor()
    query = "SELECT ID, post_status, post_title, post_content FROM wp_posts WHERE post_type in ('post', 'page')"
    c.execute(query)

    for post_id, post_status, post_title, post_content in tqdm.tqdm(
        c.fetchall(), unit="pages", desc="Indexing"
    ):
        soup = BeautifulSoup(post_content, features="lxml").get_text().strip()
        solr = {
            "id": fix_id(f"post-{post_id}"),
            "category": "post",
            "post_id": post_id,
            "post_status": post_status,
            "title_de": get_de(post_title),
            "title_en": get_en(post_title),
            "text_de": get_de(soup),
            "text_en": get_en(soup),
        }
        try:
            r = requests.post(url, json=solr)
            if r.status_code != 200:
                log(logging.ERROR, r.json()["error"]["msg"])
            r.raise_for_status()
        except requests.exceptions.RequestException as e:
            log(logging.ERROR, f"Import fulltext Solr: Error {str(e)}")

    c.close()
    db.close()


def text_content(tei, xpath: str) -> str:
    for e in tei.xpath(xpath, namespaces=NS):
        return fix_ws(" ".join(e.itertext()))
    return ""


def tei2solr():
    """Index the TEI header and front to Solr"""

    url = urllib.parse.urljoin(common.URL_SOLR, "update/json/docs")
    post_status_dict = common.get_post_status(args)

    for fn in tqdm.tqdm(args.mss, unit="files", desc="Indexing"):
        tree = etree.parse(fn, parser=parser)
        for tei in tree.xpath("/tei:TEI", namespaces=NS):
            try:
                solr = []
                if fn.endswith("bk-textzeuge.xml"):
                    ms_id = common.BK_ZEUGE
                    continue  # bk-textzeuge's copyright status is unclear
                else:
                    ms_id = get_ns(tei, "xml:id")
                title = tei.xpath(
                    "normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main'])",
                    namespaces=NS,
                )

                params = dict()
                params["id"] = fix_id(f"{ms_id}-front")
                params["category"] = "front"
                params["ms_id"] = ms_id
                params["title_de"] = title
                params["text_de"] = text_content(
                    tei, "tei:teiHeader | tei:text/tei:front"
                )
                params["post_status"] = post_status_dict[ms_id]
                if params["text_de"]:
                    solr.append(params)

                if solr:
                    r = requests.post(url, json=solr)
                    if r.status_code != 200:
                        log(logging.ERROR, r.json()["error"]["msg"])
                    r.raise_for_status()
            except Exception as e:
                log(logging.ERROR, f"Error: {fn} {str(e)}")


def build_parser(default_config_file):
    """Build the commandline parser."""

    parser = common.build_parser(default_config_file, __doc__)

    parser.add_argument(
        "--wordpress",
        action="store_true",
        help="indexes all Wordpress pages and posts to Solr",
    )
    parser.add_argument(
        "--incremental",
        metavar="TOUCHFILE",
        help="only indexes pages changed after the date of the given file",
    )
    parser.add_argument(
        "--mss", nargs="+", metavar="FILE.TEI", help="the manuscript files to index"
    )
    return parser


if __name__ == "__main__":
    build_parser("server.conf").parse_args(namespace=args)
    args.config = config_from_pyfile(args.config_file)

    handlers = [
        logging.StreamHandler(),
        logging.FileHandler(args.config.get("IMPORT_LOG_FILE", "import.log")),
    ]

    if "MAILTO" in args.config:
        smtp_handler = logging.handlers.SMTPHandler(
            mailhost=(args.config.get("SMTPHOST", "localhost"), 25),
            fromaddr="capitularia import_solr.py <noreply@uni-koeln.de>",
            toaddrs=args.config.get("MAILTO", "root"),
            subject="Capitularia import_solr.py error",
        )
        handlers.append(smtp_handler)

    init_logging(args, *handlers)

    if "MAILTO" in args.config:
        smtp_handler.setLevel(logging.ERROR)

    log(logging.INFO, "Connecting to Postgres database ...")

    dba = db_tools.PostgreSQLEngine(**args.config)

    log(logging.INFO, "using url: %s." % dba.url)

    parser = etree.XMLParser(
        recover=True, resolve_entities=False, remove_blank_text=True
    )

    if args.wordpress:
        log(logging.INFO, "Indexing Wordpress database to Solr ...")
        wordpress2solr()

    if args.mss:
        log(logging.INFO, "Indexing Manuscript headers to Solr ...")
        tei2solr()

    log(logging.INFO, "Done")
