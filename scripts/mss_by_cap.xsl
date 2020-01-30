<?xml version="1.0" encoding="UTF-8"?>

<!--
  Transforms the old-style mss_by_cap.xml into a more TEI-like format.
-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    exclude-result-prefixes="xsl xs tei cap"
    version="3.0">

  <xsl:output method="xml" indent="yes" />

  <xsl:include href="common-3.xsl" />

  <xsl:template match="/Kapitularien">
    <list>
      <xsl:for-each-group select="Eintrag" group-by="string (Kapitular/@id)">
        <xsl:sort select="cap:natsort (current-grouping-key ())" />

        <item n="{current-grouping-key ()}">
          <title><xsl:value-of select="normalize-space (Kapitular)"/></title>
          <xsl:for-each select="current-group ()">
            <xsl:sort select="cap:natsort (hss/@url)" />
            <xsl:apply-templates />
          </xsl:for-each>
        </item>
      </xsl:for-each-group>
    </list>
  </xsl:template>

  <xsl:template match="hss">
    <msIdentifier>
      <xsl:choose>
        <xsl:when test="normalize-space (@url)">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="@url"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <title>
            <xsl:apply-templates />
          </title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="hss"/>
    </msIdentifier>
  </xsl:template>

  <xsl:template match="Kapitular">
  </xsl:template>

  <xsl:template match="siglum">
  </xsl:template>

  <xsl:template match="note">
    <note>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </note>
  </xsl:template>

  <xsl:template match="ref">
    <ref>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </ref>
  </xsl:template>

</xsl:stylesheet>
