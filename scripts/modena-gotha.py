import os
import textwrap

from lxml import etree
from lxml.sax import saxify
from xml.sax.handler import ContentHandler
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import xlsxwriter

import tabview as tv

import server.common as common
from super_collator.aligner import Aligner

XML = "http://www.w3.org/XML/1998/namespace"
TEI = "http://www.tei-c.org/ns/1.0"

NAMESPACES = {"tei": TEI, "xml": XML}

XML_PATH = os.path.join(os.getenv("CAPITULARIA_REMOTE_FS"), "cap/publ/mss/")

XLSX_FILE = "modena-gotha.xlsx"


def xp(e, p):
    return e.xpath(p, namespaces=NAMESPACES)


def xp_first(e, p):
    e = e.xpath(p, namespaces=NAMESPACES)
    if e:
        return e[0]
    return None


def text(e):
    return " ".join("".join(e.itertext()).split())


def normalize(t):
    return (" ".join(t.split())).strip().strip("-").strip()


def if_print(e, p):
    e = xp(e, p)
    if e:
        print("\n".join(textwrap.wrap(text(e[0]))))
    else:
        print()


def if_print_attr(e, p, a):
    e = xp(e, p)
    if e:
        print(e[0].get(a))
    else:
        print()


def fix(s):
    return s.lower().replace("v", "u")


class MyContentHandler(ContentHandler):
    def __init__(self, doc_index, item_index, n):
        self.doc_index = doc_index
        """index into handlers[]"""
        self.item_index = item_index
        """index into handlers[][]"""
        self.n = n
        """ msItem @n """
        self.mode = None
        self.locus = ""
        self.chapters = ""
        self.text = ""
        self.corresp = ""
        self.partner = None
        self.sim = None

    def startElementNS(self, name, qname, attributes):
        uri, localname = name
        if localname == "locus":
            self.mode = "locus"
        if localname == "title":
            self.corresp = attributes.get((None, "corresp")) + " "
            self.chapters = self.text
            self.text = ""
            self.mode = "text"

    def endElementNS(self, name, qname):
        uri, localname = name
        if localname == "locus":
            self.mode = "text"

    def characters(self, data):
        if self.mode == "locus":
            self.locus += data
        if self.mode == "text":
            self.text += data

    def endDocument(self):
        self.locus = normalize(self.locus)
        self.chapters = normalize(self.chapters)
        self.text = normalize(self.text)


### scrape the files

handlers = ([], [])

for doc_index, (xmlfile, ranges) in enumerate(
    (
        ("modena-bc-o-i-2.xml", None),
        (
            "gotha-flb-memb-i-84.xml",
            list(common.parse_mspart_n("foll. 148ra-225va, 396rb-414va")),
        ),
    )
):

    tree = etree.parse(XML_PATH + xmlfile)

    for msItem in xp(tree, "//tei:msContents/tei:msItem"):
        for p in xp(msItem, "tei:p"):
            locus = xp_first(p, "tei:locus")
            if locus is None:
                continue

            loci_cooked = list(common.parse_msitem_locus(locus.text))

            if ranges is not None:
                in_range = False
                for locus_cooked in loci_cooked:
                    for r in ranges:
                        if locus_cooked[0] >= r[0] and locus_cooked[1] <= r[1]:
                            in_range = True
                if not in_range:
                    continue

            handler = MyContentHandler(
                doc_index, len(handlers[doc_index]), msItem.get("n")
            )
            saxify(p, handler)
            handlers[doc_index].append(handler)

### pair the texts using tf-idf and cosine similarity

vectorizer = TfidfVectorizer(
    max_df=0.5,
    min_df=2,
    # max_features=50,
    # stop_words="english",
)

X_tfidf = vectorizer.fit_transform([fix(h.text) for h in (handlers[0] + handlers[1])])
print(f"n_samples: {X_tfidf.shape[0]}, n_features: {X_tfidf.shape[1]}")
print(f"{X_tfidf.nnz / np.prod(X_tfidf.shape):.3f}")

A = X_tfidf[: len(handlers[0])]
B = X_tfidf[len(handlers[0]) :]

similarity = cosine_similarity(A, B)


def get_similarity(a, b):
    if a.item_index is not None and b.item_index is not None:
        return 2 * similarity[a.item_index, b.item_index] - 1
    return 0


aligner = Aligner(0.0, -0.5, -0.25)
a, b, score = aligner.align(
    handlers[0], handlers[1], get_similarity, lambda: MyContentHandler(None, None, "")
)

### output the excel worksheet

DEFAULT = {"align": "left", "valign": "top", "text_wrap": True}
TITLE = {**DEFAULT, "bold": True, "font_size": 16, "align": "center"}
HEADER = {**DEFAULT, "bold": True}
TEXT = {**DEFAULT}

workbook = xlsxwriter.Workbook(XLSX_FILE)
worksheet = workbook.add_worksheet()

default_format = workbook.add_format(DEFAULT)
title_format = workbook.add_format(TITLE)
header_format = workbook.add_format(HEADER)
text_format = workbook.add_format(TEXT)

worksheet.set_column(0, 0, 12, text_format)
worksheet.set_column(1, 1, 15, text_format)
worksheet.set_column(2, 2, 60, text_format)
worksheet.set_column(3, 3, 12, text_format)
worksheet.set_column(4, 4, 15, text_format)
worksheet.set_column(5, 5, 60, text_format)

worksheet.merge_range("A1:C1", "Modena", title_format)
worksheet.merge_range("D1:F1", "Gotha", title_format)

row = 1
for col, header in enumerate("locus corresp text locus corresp text".split()):
    worksheet.write(row, col, header, header_format)

for h1, h2 in zip(a, b):
    row += 1
    worksheet.write(row, 0, h1.locus)
    worksheet.write(row, 1, h1.corresp + h1.chapters)
    worksheet.write(row, 2, h1.text)
    worksheet.write(row, 3, h2.locus)
    worksheet.write(row, 4, h2.corresp + h2.chapters)
    worksheet.write(row, 5, h2.text)

workbook.close()
