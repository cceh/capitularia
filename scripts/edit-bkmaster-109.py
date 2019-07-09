#! /usr/bin/python3
#
# /afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/cap/intern/Transkriptionen/BK_Text_Superstruktur/

import re
import sys

import lxml
from lxml import etree
from lxml.builder import ElementMaker

NSMAP = {
    'tei' : 'http://www.tei-c.org/ns/1.0',
    'xml' : 'http://www.w3.org/XML/1998/namespace',
}
XML_ID = '{%s}id' % NSMAP['xml'] # lxml uses Clark notation

RE_NUM = re.compile (r'^(\d+[.])\s+(.*)$', re.DOTALL)

E = ElementMaker (namespace = NSMAP['tei'], nsmap = NSMAP)

# parser = etree.XMLParser (recover = True, remove_blank_text = True)

tree = etree.parse (sys.argv[1])
xml = tree.getroot ()

for e in xml.xpath ('//tei:ab[@type="meta-text"][normalize-space () = ""]', namespaces = NSMAP):
    e.getparent ().remove (e)

for ab in xml.xpath ('//tei:ab[@type="text"]', namespaces = NSMAP):
    m = RE_NUM.search (ab.text)
    if m:
        corresp = ab.get ('corresp')
        xml_id  = ab.get (XML_ID)
        ab.text = m.group (2)
        abmeta = E.ab (m.group (1), {
            'type'    : 'meta-text',
            'corresp' : corresp + '_inscriptio',
            XML_ID    : xml_id  + '_inscriptio',
        })
        abmeta.tail = '\n                        '
        p = ab.getparent ()
        p.insert (p.index (ab), abmeta)

print (etree.tostring (xml, pretty_print = False, encoding = 'unicode', xml_declaration = True))
