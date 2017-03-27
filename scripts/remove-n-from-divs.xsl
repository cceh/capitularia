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

  <xsl:template match="tei:div[@type='content']/@n" />
  <xsl:template match="tei:div[@type='mshist']/@n" />
  <xsl:template match="tei:div[@type='scribe']/@n" />
  <xsl:template match="tei:div[@type='letters']/@n" />
  <xsl:template match="tei:div[@type='abbreviations']/@n" />
  <xsl:template match="tei:div[@type='punctuation']/@n" />
  <xsl:template match="tei:div[@type='structure']/@n" />
  <xsl:template match="tei:div[@type='annotations']/@n" />
  <xsl:template match="tei:div[@type='other']/@n" />

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
