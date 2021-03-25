#! /usr/bin/python3
#

import re
import sys

from lxml import etree
import networkx as nx

NSMAP = {
    'tei' : 'http://www.tei-c.org/ns/1.0',
    'xml' : 'http://www.w3.org/XML/1998/namespace',
    'xsl' : 'http://www.w3.org/1999/XSL/Transform',
}

def ns (ns, tag):
    return '{%s}%s' % (NSMAP[ns], tag) # lxml uses Clark notation

XML_ID   = ns ('xml', 'id')
TEMPLATE = ns ('xsl', 'template')
FUNCTION = ns ('xsl', 'function')
CALL     = ns ('xsl', 'call-template')
VARIABLE = ns ('xsl', 'variable')
VALUE    = ns ('xsl', 'value-of')

COLORS = {
    'template' : '#1f77b4',
    'match'    : '#2ca02c',
    'variable' : '#d62728',
    'function' : '#e7ba52',
    'text'     : '#ff7f0e',
}

parser = etree.XMLParser (recover = True)
tree = etree.parse (sys.argv[1], parser=parser)
xml = tree.getroot ()

G = nx.DiGraph ()

context = []

templates = dict ()
functions = dict ()
variables = dict ()

for action, e in etree.iterwalk (xml, events = ('start', 'end')):
    if action == 'start':

        select = e.get ('select')
        if select:
            m = re.search (r'[$]([-\w]+)', select)
            if m:
                name = m.group (1)
                if name in variables:
                    G.add_edge (context[-1], name)
                    variables[name] = 1

            m = re.search (r'([-:\w]+)\s*\(', select)
            if m:
                name = m.group (1)
                if name in functions:
                    G.add_edge (context[-1], name)
                    functions[name] = 1

            m = re.search (r"'([-.\w\d †]+)'", select) # no UTF-8 ?
            if m:
                text = m.group (1)
                G.add_node (text, type = 'text')
                G.add_edge (context[-1], text)

        if e.tag == CALL:
            name = e.get ('name')
            if name in templates and name not in ('generate-note', ):
                G.add_edge (context[-1], name)

        if e.tag == TEMPLATE:
            name = e.get ('name')
            if name:
                context.append (name)
                templates[name] = 0
                G.add_node (name, type = 'template')

            match = e.get ('match')
            if match:
                context.append (match)
                G.add_node (match, type =  'match')

        if e.tag == FUNCTION:
            name = e.get ('name')
            if name:
                context.append (name)
                functions[name] = 0
                G.add_node (name, type = 'function')

        if e.tag == VARIABLE:
            name = e.get ('name')
            if name:
                context.append (name)
                variables[name] = 0
                G.add_node (name, type = 'variable')

        text = e.text
        if text:
            text = text.strip ()
            if text:
                G.add_node (text, type = 'text')
                G.add_edge (context[-1], text)

        tail = e.tail
        if tail:
            tail = tail.strip ()
            if tail:
                G.add_node (tail, type = 'text')
                G.add_edge (context[-1], tail)

    if action == 'end':
        if e.tag in (TEMPLATE, FUNCTION, VARIABLE):
            context.pop ()

# dike out functions and variables from graph
for n in list (G.nodes):
    if G.nodes[n]['type'] in ('function', 'variable'):
        for p in G.predecessors (n):
            for s in G.successors (n):
                G.add_edge (p, s)
        G.remove_node (n)

# remove cruft
for node in '0 tei-add tei-mod tei-del tei-hi tei-mentioned gap-chars'.split ():
    G.remove_node (node)
G.remove_node (' ')
G.remove_node ('ab ab-')
G.remove_node ('tei-seg tei-seg-')

G.remove_nodes_from (list (nx.isolates (G)))

# print .dot
print ('strict digraph G {\ngraph [rankdir="LR",splines="line"];')

for n in G.nodes:
    print ('"%s" [style=filled,color="%s80"]' % (n, COLORS[G.nodes[n]['type']]))

for e in G.edges:
    print ('"%s" -> "%s"' % e)

print ('}')
