<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    default-mode="phase1"
    exclude-result-prefixes="cap tei xs xsl">

  <xsl:output method="text" encoding="UTF-8" />

  <xsl:function name="cap:quote">
    <xsl:param name="s" />
    <xsl:value-of select="concat ('&quot;', $s, '&quot;')"/>
  </xsl:function>

  <!-- 9467bd8c564be377c217becfaec7e8ffbb7898df8aff9896c5b0d5c49c94f7b6d2dbdb8d9edae57f7f7f -->

  <xsl:variable name="style" as="map(xs:string, xs:string)" select="map {
    'country'    : '#1f77b4',
    'region_c'   : '#2ca02c',
    'region_a'   : '#d62728',
    'historical' : '#e7ba52',
    'settlement' : '#ff7f0e'
  }" />

  <xsl:template match="/TEI/text/body">
    <xsl:text>strict digraph G {&#x0a;graph [rankdir="LR"];&#x0a;</xsl:text>
    <xsl:apply-templates select="listPlace" />
    <xsl:text>}&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="listPlace[@type]">
    <xsl:for-each select="place">
      <xsl:value-of select="cap:quote (@xml:id)" />
      <xsl:text> [style=filled,color="</xsl:text>
      <xsl:value-of select="$style(../@type)"/>
      <xsl:text>80"];&#x0a;</xsl:text>
    </xsl:for-each>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*[@xml:id]">
    <xsl:for-each select="./*[@corresp]">
      <xsl:value-of select="cap:quote (substring (@corresp, 2))" />
      <xsl:text> -&gt; </xsl:text>
      <xsl:value-of select="cap:quote (../@xml:id)" />
      <xsl:text>&#x0a;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="linkGrp[@type='mss']" />

  <xsl:template match="text()" />

</xsl:stylesheet>
