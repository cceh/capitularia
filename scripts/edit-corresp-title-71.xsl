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

  <xsl:output method="xml" indent="no" encoding="UTF-8" />

  <!-- if @corresp contains no spaces, add corresp to all titles within -->
  <xsl:template match="tei:msItem[not (contains (@corresp, ' '))]//tei:title[not (@corresp)]">
    <xsl:copy>
      <xsl:attribute name="corresp">
        <xsl:value-of select="ancestor::tei:msItem/@corresp"/>
      </xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- remove attribute from msItem -->
  <xsl:template match="tei:msItem[.//tei:title]/@corresp[not (contains (., ' '))]">
  </xsl:template>

  <!-- copy everything else -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
