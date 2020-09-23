<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet generates plain text versions of the chapters generated
by mss-extract-chapters.xsl, for collation and fulltext search.

Transforms: $(CACHE_DIR)/extracted/%.xml -> $(CACHE_DIR)/collation/%.xml

Scrape: fulltext $(CACHE_DIR)/collation/%.xml

Target: collation $(CACHE_DIR)/collation/%.xml

-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xs xsl"
    version="3.0">

  <xsl:import href="mss-transcript-phase-1.xsl" />

  <xsl:template match="/TEI">
    <TEI>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </TEI>
  </xsl:template>

  <xsl:template match="milestone[@unit='capitulare']">
    <!-- copy-of prevents the templates in phase-1 from interfering -->
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="div">

    <!-- add a section -->

    <xsl:variable name="extracted2">
      <!-- apply the templates in mss-transcript-phase-1.xsl -->
      <xsl:apply-templates mode="phase1">
        <xsl:with-param name="include-later-hand" select="false ()" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:variable>

    <!-- then apply the templates in this stylesheet -->
    <xsl:variable name="extracted3">
      <xsl:apply-templates select="$extracted2" />
    </xsl:variable>

    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    <div corresp="{@corresp}" cap:hands="{@cap:hands}">
        <xsl:value-of select="normalize-space ($extracted3)"/>
    </div>

    <!-- maybe add a "later_hands" section -->

    <xsl:if test="translate (@cap:hands, 'XYZ', '') ne @cap:hands">
      <xsl:variable name="extracted4">
        <!-- apply the templates in mss-transcript-phase-1.xsl -->
        <xsl:apply-templates mode="phase1">
          <xsl:with-param name="include-later-hand" select="true ()" tunnel="yes" />
        </xsl:apply-templates>
      </xsl:variable>

      <!-- then apply the templates in this stylesheet -->
      <xsl:variable name="extracted5">
        <xsl:apply-templates select="$extracted4" />
      </xsl:variable>

      <xsl:text>&#x0a;</xsl:text>
      <xsl:text>&#x0a;</xsl:text>
      <div corresp="{@corresp}?later_hands" cap:hands="{@cap:hands}">
        <xsl:value-of select="normalize-space ($extracted5)"/>
      </div>
    </xsl:if>

  </xsl:template>

  <!-- We don't want to normalize V to U inside <seg type="num">
       Replace these characters with true unicode roman numerals. -->
  <xsl:template match="seg[@type='num']//text ()">
    <xsl:value-of select="translate (., 'IVXLCDMivxlcdm', '&#x2160;&#x2164;&#x2169;&#x216c;&#x216d;&#x216e;&#x216f;&#x2170;&#x2174;&#x2179;&#x217c;&#x217d;&#x217e;&#x217f;')"/>
  </xsl:template>

  <xsl:template match="note" />

  <xsl:template match="figure" />

  <!-- override templates in phase 1 -->

  <!-- Don't output "[!]" -->
  <xsl:template match="sic" mode="phase1">
    <xsl:apply-templates mode="phase1" />
  </xsl:template>

  <xsl:template match="gap[@quantity]" mode="phase1">
    <xsl:value-of select="cap:string-pad (xs:integer (@quantity), '·')" />
  </xsl:template>

  <xsl:template name="empty-del" />

</xsl:stylesheet>
