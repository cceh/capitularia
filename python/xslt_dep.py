#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

"""Draw graphs for Capitularia docs.

Draws a graph of XML to HTML data-flow by reading specially-encoded metadata in
the first comment of XSL-Stylesheets.

Draws a dependency graph of XSL-Stylesheets by reading the xsl:include and
xsl:import statements.

Outputs a graphviz .dot file or a HTML table or Makefile dependencies.

Internally uses a triple store for the relations between files.

Implements a 'little language' that reads a list of commands from stdin.
Commands are separated by newlines.

- read filename scans an XSL-Stylesheet.
- recurse follows-up xsl:import and xsl:include statements
- load filename load a triple store
- save filename saves a triple store in turtle format
- io filename adds data-flow predicates to the output graph
- dep filename adds dependency predicates to the output graph
- dot filename outputs a graphviz dot file
- make filename outputs a Makefile dependencies
- html filename outputs a HTML table

.. code::

   read my-style.xsl
   read more-styles-*.xsl
   recurse
   dep *.xsl
   dot my-style-dependencies.dot

.. code::

   read *.xsl
   save styles.ttl

.. code::

   load styles.ttl
   io first.xsl
   io second.xsl
   io third.xsl
   dot styles-dataflow.dot

"""

import argparse
import glob
import html
import os.path
import re
import urllib.parse
import sys

import lxml
from lxml import etree

import rdflib
from rdflib import Literal, URIRef, Namespace, RDF

ARGS = argparse.Namespace ()
PARSER = etree.XMLParser (recover = True)

ROOT = 'http://capitularia.uni-koeln.de/'

# The (completely made up) Capitularia Ontology
#
CAP = Namespace ('http://capitularia.uni-koeln.de/rdf/')
# CAP.version
# CAP.depends
# CAP.inputs
# CAP.outputs
# CAP.urls
# CAP.scrapes
# CAP.xsl       file is an .xsl file
# CAP.xml
# CAP.html

# Some XML Namespaces
NAMESPACES = {
    'cap'  : 'http://cceh.uni-koeln.de/capitularia',
    'fn'   : 'http://www.w3.org/2005/xpath-functions',
    'tei'  : 'http://www.tei-c.org/ns/1.0',
    'xml'  : 'http://www.w3.org/XML/1998/namespace',
    'xs'   : 'http://www.w3.org/2001/XMLSchema',
    'xsl'  : 'http://www.w3.org/1999/XSL/Transform',
}


g = rdflib.Graph ()
g.bind ('cap', CAP)
g.bind ('rdf', RDF)

# rdf:	http://www.w3.org/1999/02/22-rdf-syntax-ns#
# rdfs:	http://www.w3.org/2000/01/rdf-schema#
# xsd:	http://www.w3.org/2001/XMLSchema#
# fn:	http://www.w3.org/2005/xpath-functions#
# sfn:	http://www.w3.org/ns/sparql#

h = rdflib.Graph ()
h.bind ('cap', CAP)
h.bind ('rdf', RDF)


def uri (filename):
    return URIRef (urllib.parse.urljoin (ROOT, filename))

def deuri (uri):
    return uri[len (ROOT):]

def shape (uri):
    return 'box3d' if ('*' in uri) or ('@' in uri) else 'box'

def stdin (filename):
    return '/dev/stdin' if filename in (None, '', '-') else filename

def stdout (filename):
    return '/dev/stdout' if filename in (None, '', '-') else filename

def add_ext (path):
    directory, filename = os.path.split (path)
    filename, ext = os.path.splitext (filename)

    g.add ( (uri (path), RDF.type, CAP[ext[1:]]) )


def read (path, deps = False):
    if (uri (path), None, None) in g:
        return # already scanned

    add_ext (path)

    directory, filename = os.path.split (path)
    filename, ext = os.path.splitext (filename)
    tree = etree.parse (path, PARSER)

    for e in tree.xpath ('/xsl:stylesheet', namespaces = NAMESPACES):
        g.add ( (uri (path), CAP.version, Literal (e.get ('version'))) )

    for e in tree.xpath ('//xsl:include|//xsl:import', namespaces = NAMESPACES):
        dep = os.path.join (directory, e.get ('href'))
        g.add ( (uri (path), CAP.depends, uri (dep)) )
        if deps:
            read (dep) # recurse

    for e in tree.xpath ('//comment ()[1]'):
        for m in re.finditer (r'^\s*Input files?:\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
            for fn in m.group (1).split ():
                dep = os.path.join (directory, fn)
                g.add ( (uri (path), CAP.inputs, uri (dep)) )
                add_ext (dep)
        for m in re.finditer (r'^\s*Output files?:\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
            for fn in m.group (1).split ():
                dep = os.path.join (directory, fn)
                g.add ( (uri (path), CAP.outputs, uri (dep)) )
                add_ext (dep)
        for m in re.finditer (r'^\s*URL:\s+(.*?)\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
            dep = os.path.join (directory, m.group (1))
            url = m.group (2)
            g.add ( (uri (dep), CAP.urls, uri (url)) )
            add_ext (dep)
        for m in re.finditer (r'^\s*Scrape:\s+(.*?)\s+(.*)$', e.text, re.IGNORECASE | re.MULTILINE):
            target = m.group (1)
            dep = os.path.join (directory, m.group (2))
            g.add ( (uri (target), CAP.scrapes, uri (dep)) )
            add_ext (dep)


def load (filename):
    g.parse (stdin (filename), format = 'turtle')


def save (filename):
    g.serialize (stdout (filename), format = 'turtle')


def recurse ():
    """ Pull in dependencies. """

    for s, p, o in g.triples ( (None, CAP.depends, None) ):
        read (deuri (o), deps = True)


def dep (subject):
    """ Only do dependencies. """

    bindings = {}
    if subject:
        bindings['s'] = uri (subject)

    qres = g.query (
        """CONSTRUCT {?s ?p ?o}
        WHERE {
           ?s ?p ?o .
           FILTER (?p IN (cap:depends, cap:version))
        }
        """, initBindings = bindings)

    for t in qres:
        h.add (t)


def io (subject):
    """ Only do input / output. """

    bindings = {}
    if subject:
        bindings['s'] = uri (subject)

    qres = g.query (
        """CONSTRUCT {?s ?p ?o}
        WHERE {
           ?s ?p ?o .
           FILTER (?p IN (cap:inputs, cap:outputs, cap:urls, cap:scrapes))
        }
        """, initBindings = bindings)

    for t in qres:
        h.add (t)


def gfilter (filt):
    """ Apply user-supplied filter. """

    qres = g.query (
        """CONSTRUCT {?s ?p ?o}
        WHERE {
           ?s ?p ?o .
           FILTER (%s)
        }
        """ % filt)

    for t in qres:
        h.add (t)


def render_dot (filename):
    """ Render as dot file. """

    with open (stdout (filename), 'w') as fp:
        fp.write ('strict digraph G {\n')
        fp.write ('  graph [rankdir="LR"];\n')
        fp.write ('  node  [rankdir="LR",fontsize="10.0",fontname="sans"];\n')

        nodes = set ()

        for s, p, o in h.triples ( (None, CAP.version, None ) ):
            nodes.add (s)

        for s, p, o in h.triples ( (None, CAP.depends, None) ):
            fp.write ('  "%s" -> "%s"\n' % (deuri (s), deuri (o)))

        for s, p, o in h.triples ( (None, CAP.inputs, None) ):
            fp.write ('  "%s" [shape=%s,color=green]\n' % (deuri (o), shape (o)))
            fp.write ('  "%s" -> "%s" [color=green]\n' % (deuri (o), deuri (s)))
            nodes.add (s)

        for s, p, o in h.triples ( (None, CAP.outputs, None) ):
            fp.write ('  "%s" [shape=%s,color=red]\n' % (deuri (o), shape (o)))
            fp.write ('  "%s" -> "%s" [color=red]\n' % (deuri (s), deuri (o)))
            nodes.add (s)

        for s, p, o in h.triples ( (None, CAP.urls, None) ):
            fp.write ('  "%s" [shape=note,color=blue]\n' % deuri (o))
            fp.write ('  "%s" -> "%s" [color=blue]\n' % (deuri (s), deuri (o)))
            nodes.add (s)

        for s, p, o in h.triples ( (None, CAP.scrapes, None) ):
            fp.write ('  "import_data.py --%s" [shape=cylinder,color=blue]\n' % deuri (s))
            fp.write ('  "%s" -> "import_data.py --%s" [color=blue]\n' % (deuri (o), deuri (s)))
            nodes.add (o)

        for n in nodes:
            if (n, CAP.version, Literal ('1.0')) in g:
                fp.write ('  "%s" [style=filled,fillcolor=whitesmoke]\n' % deuri (n))
            else:
                fp.write ('  "%s"\n' % deuri (n))

        fp.write ('}\n')


def render_html (filename):
    """ Render as HTML table. """

    with open (stdout (filename), 'w') as fp:

        table = [];
        for s, p, o in h.triples ( (None, CAP.depends, None) ):
            table.append ('<tr><td>%s</td><td>%s</td></tr>' % (s, o))

        if table:
            fp.write ('<table><tbody>\n')
            fp.write ('<tr><th>xsl</th><th>depends on</th></tr>\n')
            fp.write ('\n'.join (table))
            fp.write ('\n</tbody></table>\n')

        table = [];
        qres = h.query (
            """SELECT DISTINCT ?xsl ?ver
            WHERE {
               ?xsl ?p ?o .
               ?xsl cap:version ?ver .
               FILTER (?p IN (cap:inputs, cap:outputs))
            }
            ORDER BY (?xsl)
            """)

        for row in qres:
            xsl = html.escape (deuri (row.xsl))
            ver = html.escape (row.ver)

            table.append ('<tr>')
            table.append ('<td>')
            for s, p, o in h.triples ( (row.xsl, CAP.inputs, None) ):
                table.append ('%s<br/>' % html.escape (deuri (o)))
            table.append ('</td>')
            table.append ('<td>%s (%s)</td>' % (xsl, ver))
            table.append ('<td>')
            for s, p, o in h.triples ( (row.xsl, CAP.outputs, None) ):
                table.append ('%s<br/>' % html.escape (deuri (o)))
            table.append ('</td>')
            table.append ('</tr>')

        if table:
            fp.write ('<table><tbody>\n')
            fp.write ('<tr><th>input</th><th>xsl</th><th>output</th></tr>\n')
            fp.write ('\n'.join (table))
            fp.write ('\n</tbody></table>\n')


def render_makefile (filename):
    """ Render as make dependencies. """

    h = g
    with open (stdout (filename), 'w') as fp:
        for s, p, o in h.triples ( (None, CAP.outputs, None) ):
            qres = h.query (
                """SELECT ?xsl WHERE {
                   ?root cap:depends* ?xsl .
                }
                """, initBindings = { 'root': s })

            fp.write ('%s : %s\n' % (deuri (o), ' '.join ([deuri (row.xsl) for row in qres])))


def main ():
    for command in ARGS.e:
        command = command.strip ()

        cmds = command.split (maxsplit = 1)
        cmd = cmds[0]
        arg = cmds[1] if len (cmds) > 1 else None

        if cmd in ('r', 'read'):
            for fn in glob.glob (arg, recursive=True):
                read (fn)
        if cmd in ('l', 'load'):
            load (arg)
        if cmd in ('s', 'save'):
            save (arg)
        if cmd in ('rec', 'recurse'):
            recurse ()
        if cmd == 'dep':
            dep (arg)
        if cmd == 'io':
            io (arg)
        if cmd in ('f', 'filter'):
            gfilter (arg)
        if cmd == 'dot':
            render_dot (arg)
        if cmd == 'html':
            render_html (arg)
        if cmd in ('make', 'makefile'):
            render_makefile (arg)


if __name__ == '__main__':

    parser = argparse.ArgumentParser (
        formatter_class = argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description = __doc__,
    )

    parser.add_argument ('-e', default=None,
                         help="Commands to be executed, separated by ';'.  "
                         "Default: read commands from stdin, separated by newlines.")

    parser.parse_args (namespace = ARGS)

    if ARGS.e is None:
        ARGS.e = sys.stdin.readlines ()
    else:
        ARGS.e = ARGS.e.split (';')

    main ()
