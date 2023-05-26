#!/usr/bin/python3

"""Merges multiple CTE index files into one

"""

# FIXME: Leerzeichen nach vorne sortieren?
# Warnung wenn zwei Dateien die gleiche Seite referenzieren

import argparse
import collections
import datetime
import itertools
import locale
import logging
import re

from lxml import etree
import lxml.builder

SEPARATOR = ";"
""" Separator of occurence (ref) entries. """

#LINENO = {"rendition" : "#rd-lineno"}
#ITALIC = {"rendition" : "#rd-italic"}
LINENO = {"rend" : "font-size: 9pt"}
ITALIC = {"rend" : "font-family: Stempel Garamond LT Pro Italic"}


NS_TEI = "http://www.tei-c.org/ns/1.0"
NS_XML = "http://www.w3.org/XML/1998/namespace"

NS = {
    None: NS_TEI,
    "xml": NS_XML,
}

E = lxml.builder.ElementMaker(namespace=NS_TEI, nsmap=NS)

re_make_italic = re.compile(r"^(.*)\s+(\(.*\)|=\s.+)$")

class Args:
    pass

args = Args()
""" Globally accessible arguments from command line. """

def ns(ns_name):
    """Convert prefix:tag into normal form {ns}tag"""

    ns, name = ns_name.split(":")
    return "{%s}%s" % (NS[ns], name)

lemmas : dict[tuple, list] = collections.defaultdict(list)
locale.setlocale(locale.LC_ALL, 'de_DE.UTF-8')

def make_italic(s):
    m = re_make_italic.match(s)
    if (m):
        return m.group(1), " ", E.hi(m.group(2), ITALIC)
    return s, "", ""

def parse_occurrences(occurrences: str):
    """ Parse an occurrence, and unroll it if necessary """
    res = []
    for occurrence in occurrences.split(SEPARATOR):
        occurrence = occurrence.strip()
        m = re.fullmatch("(\d+),(\d+)(?: – (\d+))?", occurrence)
        if m:
            page = int(m.group(1))
            line = int(m.group(2))
            if m.group(3):
                line2 = int(m.group(3))
                for i in range(line, line2 + 1):
                    res.append((page, i))
            else:
                res.append((page, line))
        else:
            logging.error(f"Cannot parse occurrence: {occurrence}")
    return res

def scan_index_file(fp):
    current_lemma = None
    current_sublemma = None

    for line in fp.readlines():
        tokens = line.rstrip().split("\t")
        if len(tokens) == 3:
            lemma, sublemma, occurrences = tokens
            subsublemma = ""
        elif len(tokens) == 4:
            lemma, sublemma, subsublemma, occurrences = tokens
        else:
            logging.error(f"Wrong number of TABs in line: {line}")
            continue
        if subsublemma and not sublemma:
            sublemma = current_sublemma
        if sublemma and not lemma:
            lemma = current_lemma
        current_lemma = lemma
        current_sublemma = sublemma

        lemmas[(lemma, sublemma, subsublemma)].extend(parse_occurrences(occurrences))

def output():
    body = E.body()
    tei = E.TEI(
        E.teiHeader(
            E.fileDesc(
                E.titleStmt(
                    E.title("Index XML Import Test"),
                    E.author("hiwi")
                ),
                E.publicationStmt(E.p()),
                E.notesStmt(E.note()),
                E.sourceDesc(E.ab()),
            ),
            E.encodingDesc(
                E.variantEncoding(method="double-end-point", location="internal"),
                E.tagsDecl(
                    E.rendition("""
padding-left:0mm;padding-right:0mm;text-indent:0mm;line-height:14pt;-cte-line-height:fixed;margin-top:0pt;margin-bottom:0pt;text-align:justify;font-family:Stempel Garamond LT Pro;
font-size:11pt;color:#000000;font-style:normal;font-weight:normal;text-decoration:none;text-underline-position:0pt;text-decoration:none;text-transform:none;font-variant:normal;
vertical-align:baseline;display:block;letter-spacing:0pt;direction:ltr;-cte-diacritics:yes;position:relative;top:0pt;
""",
                        {ns("xml:id"): "rd-text", "scheme": "css"}),
                    E.rendition("font-family:Stempel Garamond LT Pro Italic", {ns("xml:id"): "rd-italic", "scheme": "css"}),
                    E.rendition("font-size:9pt", {ns("xml:id"): "rd-lineno", "scheme": "css"}),
                )
            )
        ),
        E.text(body)
    )
    # group by lemma
    for key, group in itertools.groupby(sorted(lemmas, key=lambda x: (locale.strxfrm(x[0]), x[1], x[2])), lambda key: key[0]):
        a = list()
        for n, g in enumerate(sorted(group)):
            lemma, sublemma, subsublemma = g
            occurrences = lemmas[g]
            if n == 0:
                italic = make_italic(lemma)
                a.append(E.milestone(unit="chapter", n=italic[0]))
                a.append(E.emph(italic[0], n=italic[0]))
                a.append(italic[1])
                a.append(italic[2])
                if sublemma:
                    a.append(". ")
            else:
                a.append(". ")
            a.extend(make_italic(sublemma))
            if subsublemma:
                a.append(". ")
                a.extend(make_italic(subsublemma))
            a.append(" ")
            # occurrence = tuple(page, line)
            # group by page
            for m, [key, page_group] in enumerate(itertools.groupby(sorted(set(occurrences)), lambda x : x[0])):
                if m > 0:
                    a.append(". ")
                page_group = list(page_group)
                a.append(f"{page_group[0][0]},")
                if args.group_lines:
                    # group by spans of consecutive lines
                    for n, [key, lines_group] in enumerate(itertools.groupby(enumerate(page_group), lambda x: x[0] - x[1][1])): # x[0] = enum, x[1][1] = line
                        if n > 0:
                            a.append(".")
                        lines_group = list(lines_group)
                        if len(lines_group) == 1:
                            a.append(E.hi(str(lines_group[0][1][1]), LINENO))
                        elif len(lines_group) == 2:
                            a.append(E.hi(f"{lines_group[0][1][1]}f", LINENO))
                        else:
                            a.append(E.hi(f"{lines_group[0][1][1]}–{lines_group[-1][1][1]}", LINENO))
                else:
                    # no grouping
                    for n, page in enumerate(page_group):
                        if n > 0:
                            a.append(".")
                        a.append(E.hi(str(page[1]), LINENO))
        a.append(".")
        body.append(E.p(*a, rendition="#rd-text"))

    print("<?xml version='1.0' encoding='UTF-8'?>")
    print(etree.tostring(tei, encoding="unicode", pretty_print=True))

def build_parser():
    """Build the commandline parser."""

    parser = argparse.ArgumentParser(description=__doc__, fromfile_prefix_chars="@")

    parser.add_argument(
        "-v",
        "--verbose",
        dest="verbose",
        action="count",
        help="increase output verbosity",
        default=0,
    )
    parser.add_argument(
        "--group-lines",
        action="store_true",
        help="group lines, eg. 42,3f. 69,4-7.",
    )
    parser.add_argument(
        "files",
        metavar='FILE',
        type=str,
        nargs='+',
        help="the index files",
    )
    return parser


if __name__ == "__main__":
    build_parser().parse_args(namespace=args)

    for filename in args.files:
        with open(filename, "r") as fp:
            scan_index_file(fp)

    output()

    logging.log(logging.INFO, "Done")
