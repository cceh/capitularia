<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">
  <!-- libexslt does not support the regexp extension ! -->

  <!-- must also change mss-transcript.xsl !!! -->
  <!-- must also change cap-collation/class-witness.php !!! -->
  <xsl:template match="tei:span[@corresp and @to]">
    <milestone unit="span" corresp="{@corresp}" spanTo="{str:replace (concat ('#', @to), '##', '#')}" />
  </xsl:template>

  <!-- must also change mss-transcript.xsl !!! -->
  <xsl:template match="tei:div[@type='content']/@xml:id">
    <xsl:attribute name="n">divContent</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='mshist']/@xml:id">
    <xsl:attribute name="n">divMsHist</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='scribe']/@xml:id">
    <xsl:attribute name="n">divScribe</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='letters']/@xml:id">
    <xsl:attribute name="n">divLett</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='abbreviations']/@xml:id">
    <xsl:attribute name="n">divAbbr</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='punctuation']/@xml:id">
    <xsl:attribute name="n">divPunct</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='structure']/@xml:id">
    <xsl:attribute name="n">divStruct</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='annotations']/@xml:id">
    <xsl:attribute name="n">divAnnot</xsl:attribute>
  </xsl:template>

  <xsl:template match="tei:div[@type='other']/@xml:id">
    <xsl:attribute name="n">divOther</xsl:attribute>
  </xsl:template>

  <xsl:template match="/tei:TEI">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
