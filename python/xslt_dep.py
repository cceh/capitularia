#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

"""
Build a dependency graph of XSLT and XML files.

Reads xsl:include and xsl:import statements and metadata in the first comment.

Outputs a graphviz .dot file or a HTML table.

"""

import argparse
import glob
import html
import os.path
import re
import sys

import lxml
from lxml import etree

# import networkx as nx

import rdflib
from rdflib import Literal, BNode, Namespace, RDF, URIRef

ARGS = argparse.Namespace ()
PARSER = etree.XMLParser (recover = True)

NAMESPACES = {
    'cap' : 'http://cceh.uni-koeln.de/capitularia',
    'fn'  : 'http://www.w3.org/2005/xpath-functions',
    'tei' : 'http://www.tei-c.org/ns/1.0',
    'xml' : 'http://www.w3.org/XML/1998/namespace',
    'xs'  : 'http://www.w3.org/2001/XMLSchema',
    'xsl' : 'http://www.w3.org/1999/XSL/Transform',
}

g = rdflib.Graph ()

ns_cap = Namespace ('http://capitularia.uni-koeln.de/rdf/')

# invent some terms
isa      = rdflib.term.URIRef ('http://capitularia.uni-koeln.de/rdf/isa')
version  = rdflib.term.URIRef ('http://capitularia.uni-koeln.de/rdf/version')
depends  = rdflib.term.URIRef ('http://capitularia.uni-koeln.de/rdf/depends')
inputs   = rdflib.term.URIRef ('http://capitularia.uni-koeln.de/rdf/inputs')
outputs  = rdflib.term.URIRef ('http://capitularia.uni-koeln.de/rdf/outputs')
urls     = rdflib.term.URIRef ('http://capitularia.uni-koeln.de/rdf/urls')

lit_xsl  = Literal ('xsl')
lit_xml  = Literal ('xml')
lit_html = Literal ('html')


def add_ext (path):
    directory, filename = os.path.split (path)
    filename, ext = os.path.splitext (filename)

    if ext == '.xsl':
        g.add ( (path, isa, lit_xsl) )
    if ext == '.xml':
        g.add ( (path, isa, lit_xml) )
    if ext == '.html':
        g.add ( (path, isa, lit_html) )


def deps (path):
    if (path, None, None) in g:
        return # already scanned

    add_ext (path)

    directory, filename = os.path.split (path)
    filename, ext = os.path.splitext (filename)
    tree = etree.parse (path, PARSER)

    for e in tree.xpath ('/xsl:stylesheet', namespaces = NAMESPACES):
        ver = Literal (e.get ('version'))
        g.add ( (path, version, ver) )

    if ARGS.depends:
        for e in tree.xpath ('//xsl:include|//xsl:import', namespaces = NAMESPACES):
            dep = URIRef (os.path.join (directory, e.get ('href')))
            g.add ( (path, depends, dep) )
            deps (dep) # recurse

    if ARGS.ios:
        for e in tree.xpath ('//comment ()[1]'):
            for m in re.finditer (r'^\s*Input files?:\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
                for fn in m.group (1).split ():
                    dep = Literal (os.path.join (directory, fn))
                    g.add ( (path, inputs, dep) )
                    add_ext (dep)
            for m in re.finditer (r'^\s*Output files?:\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
                for fn in m.group (1).split ():
                    dep = Literal (os.path.join (directory, fn))
                    g.add ( (path, outputs, dep) )
                    add_ext (dep)
            for m in re.finditer (r'^\s*Output URLs?:\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
                for fn in m.group (1).split ():
                    dep = URIRef (os.path.join (directory, fn))
                    g.add ( (path, urls, dep) )
                    add_ext (dep)

def render_dot ():
    with open (ARGS.output, 'w') as fp:
        fp.write ('strict digraph G {\n')
        fp.write ('  graph [rankdir="LR"];\n')
        fp.write ('  node  [rankdir="LR",fontsize="10.0",fontname="sans"];\n')

        if ARGS.depends:
            for s, p, o in g.triples ( (None, depends, None) ):
                fp.write ('  "%s" -> "%s"\n' % (s, o))
            for s, p, o in g.triples ( (None, None, lit_xsl) ):
                fp.write ('  "%s"\n' % s) # output xsls with no dependencies

        if ARGS.ios:
            for s, p, o in g.triples ( (None, inputs, None) ):
                fp.write ('  "%s" [shape=box,color=green]\n' % o)
                fp.write ('  "%s" -> "%s" [color=green]\n' % (o, s))
            for s, p, o in g.triples ( (None, outputs, None) ):
                fp.write ('  "%s" [shape=box,color=red]\n' % o)
                fp.write ('  "%s" -> "%s" [color=red]\n' % (s, o))

        fp.write ('}\n')


def render_html ():
    with open (ARGS.output, 'w') as fp:

        if ARGS.depends:
            fp.write ('<table><tbody>\n')
            fp.write ('<tr><th>xsl</th><th>depends on</th></tr>\n')
            for s, p, o in g.triples ( (None, depends, None) ):
                fp.write ('<tr><td>%s</td><td>%s</td></tr>\n' % (s, o))
            fp.write ('</tbody></table>\n')

        if ARGS.ios:
            fp.write ('<table><tbody>\n')
            fp.write ('<tr><th>input</th><th>xsl</th><th>output</th><th>url</th></tr>\n')

            qres = g.query (
                """SELECT DISTINCT ?xsl ?ver
                WHERE {
                   ?xsl ?p ?o .
                   ?xsl cap:version ?ver .
                   FILTER (?p IN (cap:inputs, cap:outputs, cap:url))
                }
                ORDER BY (?xsl)
                """, initNs = { 'cap': ns_cap })
            for row in qres:
                xsl = html.escape (row.xsl)
                ver = html.escape (row.ver)

                fp.write ('<tr>\n')
                fp.write ('<td>\n')
                for s, p, o in g.triples ( (row.xsl, inputs, None) ):
                    fp.write ('%s<br/>\n' % html.escape (o))
                fp.write ('</td>\n')
                fp.write ('<td>%s (%s)</td>\n' % (xsl, ver))
                fp.write ('<td>\n')
                for s, p, o in g.triples ( (row.xsl, outputs, None) ):
                    fp.write ('%s<br/>\n' % html.escape (o))
                fp.write ('</td>\n')
                fp.write ('<td>\n')
                for s, p, o in g.triples ( (row.xsl, urls, None) ):
                    fp.write ('%s<br/>\n' % html.escape (o))
                fp.write ('</td>\n')
                fp.write ('</tr>\n')

            fp.write ('</tbody></table>\n')


def main ():
    for pathname in ARGS.input:
        for fn in glob.glob (pathname, recursive=True):
            deps (URIRef (fn))

    if ARGS.format == 'dot':
        render_dot ()
    else:
        render_html ()


if __name__ == '__main__':

    parser = argparse.ArgumentParser (
        formatter_class = argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description = __doc__,
        fromfile_prefix_chars = '@',
    )

    parser.add_argument ('-o', '--output', default='-',
                         help="Output file (default: stdout)")
    parser.add_argument ('input', nargs='+', metavar='FILENAME',
                         help="Input file(s)")
    parser.add_argument ('--depends', action='store_true',
                         help="Do a dependency graph")
    parser.add_argument ('--ios', action='store_true',
                         help="Do an input/output graph")
    parser.add_argument ('--format', default="dot",
                         help="Output format (dot, html)")

    parser.parse_args (namespace = ARGS)
    if ARGS.output == '-':
        ARGS.output = '/dev/stdout'
    main ()
