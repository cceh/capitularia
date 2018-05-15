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

  <!-- fix these external refs -->
  <xsl:template match="tei:ref[@type='external']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="@subtype = 'Baluze1'">
          <xsl:text>Baluze 1780</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'Baluze2'">
          <xsl:text>Baluze 1780a</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'BK1'">
          <xsl:text>Boretius 1883</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'BK2'">
          <xsl:text>Boretius 1897</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'Pertz1'">
          <xsl:text>Pertz G 1835</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'Pertz2'">
          <xsl:text>Pertz G 1837</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'Pertz3'">
          <xsl:text>Pertz G 1837a</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'Werminghoff1'">
          <xsl:text>Werminghoff 1906</xsl:text>
        </xsl:when>
        <xsl:when test="@subtype = 'Werminghoff2'">
          <xsl:text>Werminghoff 1908</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
