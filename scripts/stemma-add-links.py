#! /usr/bin/python3

""" This script processes a stemma SVG created with Inkscape.

  - it removes all xml:space attributes, and

  - adds links to the corresponding manuscript page around text
    elements with class = siglum.

Usage: stemma-add-links.py stemma.inkscape.svg > stemma.svg

"""

import re
import sys

import lxml
from lxml import etree
from lxml.builder import ElementMaker

NSMAP = {
    'xml'   : 'http://www.w3.org/XML/1998/namespace',
    'svg'   : 'http://www.w3.org/2000/svg',
    'xlink' : 'http://www.w3.org/1999/xlink',
}

XML_SPACE  = '{%s}space' % NSMAP['xml'] # lxml uses Clark notation
XLINK_HREF = '{%s}href' % NSMAP['xlink']

RE_SIGLUM = re.compile(r'^\w+\d*$')
RE_NOT_SIGLUM = re.compile(r'^(AACHEN|Ansegis|Versio α|Herold|Lupus|X)$')

E = ElementMaker (namespace = NSMAP['svg'], nsmap = NSMAP)

tree = etree.parse (sys.argv[1])
xml = tree.getroot ()

# remove xml:space because it is deprecated and it messes up the layout when the SVG is
# included in a HTML page
for e in xml.xpath ('//svg:*[@xml:space]', namespaces = NSMAP):
    e.attrib.pop (XML_SPACE, None)

for e in xml.xpath ('//svg:text[contains(@class,"siglum")][not(parent::svg:a)]', namespaces = NSMAP):
    siglum = ''.join(e.itertext()) # text may be inside tspan
    if RE_SIGLUM.match(siglum) and not RE_NOT_SIGLUM.match(siglum):
        a = E.a({ XLINK_HREF : "/siglum/" + siglum })

        e.getparent().replace(e, a)
        a.append(e)

print (etree.tostring (xml, pretty_print = False, encoding = 'unicode', xml_declaration = False))
