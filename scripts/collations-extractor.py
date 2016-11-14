#! /usr/bin/python3
#

import collections
import sys

import lxml
from lxml import etree
from lxml.builder import E

parser = etree.XMLParser (recover = True, remove_blank_text = True)
namespaces = { 'tei': 'http://www.tei-c.org/ns/1.0' }

def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

xslt_root = etree.XML ("""
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei xhtml exslt xs">

  <xsl:output indent="yes"/>

  <xsl:template match="/tei:TEI">
    <tei:list type="ms" xml:id="{@xml:id}">
      <xsl:apply-templates/>
    </tei:list>
  </xsl:template>

  <xsl:template match="tei:msItem[@corresp]">
    <tei:item n="{@n}" type="capitulare" corresp="{@corresp}" />
  </xsl:template>

  <xsl:template match="tei:msItem">
    <tei:item n="{@n}"/>
  </xsl:template>

  <xsl:template match="text()" />

</xsl:stylesheet>
""", parser = parser);

transform = etree.XSLT (xslt_root)

tei_root = etree.XML ("""
<TEI xmlns="http://www.tei-c.org/ns/1.0">
</TEI>
""");

# get a map of BK => BK chapters

supertree = etree.parse ("/home/highlander/uni/capitularia/http/docs/cap/intern/InArbeit/Boretius/BK_Text_Superstruktur.xml", parser = parser)

BK = collections.defaultdict (list)

for div in supertree.xpath ("//tei:div[@type='capitulare' or @type='capitulatio']", namespaces = namespaces):
    for divhead in div.xpath ("./tei:div[@xml:id] | ./tei:head[@xml:id]", namespaces = namespaces):
        BK[div.get ('{http://www.w3.org/XML/1998/namespace}id')].append (
            divhead.get ('{http://www.w3.org/XML/1998/namespace}id'))

for filename in sys.argv[1:]:
    doc = etree.parse (filename, parser = parser)
    tei_root.append (transform (doc).getroot ())

for item in tei_root.xpath ("//tei:item[@corresp]", namespaces = namespaces):
    corresp = item.get ("corresp")
    if corresp in BK:
        list_ = etree.SubElement (item, "list")
        for BKchapter in BK[corresp]:
            i = etree.SubElement (list_, "item")
            i.set ("type", "capitulum")
            i.text = BKchapter

indent (tei_root)

print (etree.tostring (tei_root, pretty_print = True).decode ('utf-8'))
