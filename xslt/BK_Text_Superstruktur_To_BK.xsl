<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">

  <func:function name="cap:new-id">
    <xsl:param name="s"/>
    <func:result select="str:replace ($s, 'BK.', 'BK_TXT.')"/>
  </func:function>

  <xsl:template match="/">
    <?xml-model
      href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"
      type="application/xml"
	  schematypens="http://purl.oclc.org/dsdl/schematron"?>
    <tei:TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="superstruktur" xml:lang="la">
      <xsl:apply-templates select="tei:teiHeader" />
      <tei:text>
	    <tei:body>
	      <xsl:apply-templates select="/tei:TEI/tei:text/tei:body"/>
	    </tei:body>
      </tei:text>
    </tei:TEI>
  </xsl:template>

  <xsl:template match="tei:header">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulatio']">
    <tei:milestone n="{@xml:id}" unit="{@type}" />
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulare']">
    <tei:milestone n="{@xml:id}" unit="{@type}" />
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulum']">
    <xsl:apply-templates select="tei:head" />
    <tei:ab xml:id="{cap:new-id (@xml:id)}" corresp="{@xml:id}" type="text">
      <xsl:apply-templates select="tei:p"/>
    </tei:ab>
  </xsl:template>

  <xsl:template match="tei:head[@type='incipit']">
    <tei:ab xml:id="{cap:new-id (@xml:id)}" corresp="{@xml:id}" type="meta-text">
      <xsl:apply-templates />
    </tei:ab>
  </xsl:template>

  <xsl:template match="tei:head[@type='inscriptio']">
    <tei:ab xml:id="{cap:new-id (@xml:id)}" corresp="{@xml:id}" type="meta-text">
      <xsl:apply-templates />
    </tei:ab>
  </xsl:template>

  <!-- capitular without <div type=capitulum> -->
  <xsl:template match="tei:div[@type='capitulare']/tei:p">
    <tei:ab xml:id="{cap:new-id (../@xml:id)}" corresp="{../@xml:id}" type="text">
      <xsl:apply-templates />
    </tei:ab>
  </xsl:template>

</xsl:stylesheet>
