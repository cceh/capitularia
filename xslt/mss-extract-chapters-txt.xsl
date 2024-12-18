<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet generates plain text versions of the chapters generated
by mss-extract-chapters.xsl, for collation and fulltext search.

For each chapter it generates:

  - the original text
  - the corrected text (if any later hands were active)
  - the notes (if any were added)

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
    <div corresp="{@corresp}" cap:hands="{@cap:hands}">
      <xsl:value-of select="normalize-space ($extracted3)"/>
    </div>

    <!-- then extract the notes -->
    <xsl:if test="$extracted2//note">
      <xsl:text>&#x0a;</xsl:text>
      <xsl:apply-templates select="$extracted2//note" mode="notes" />
    </xsl:if>

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

  <!-- Don't normalize V -> U inside <seg type="num"> -->
  <xsl:template match="seg[@type='num']//text ()[matches(., '^[IVXLCDM]+$', 'i')]">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Normalize V -> U -->
  <xsl:template match="text ()">
    <xsl:value-of select="translate (., 'Vv', 'Uu')"/>
  </xsl:template>

  <!-- keep notes out of main text flow -->
  <xsl:template match="note" />

  <xsl:template match="note" mode="notes">
    <xsl:text>&#x0a;</xsl:text>
    <note corresp="{../@corresp}" type="{@type}" >
      <xsl:value-of select="normalize-space()" />
    </note>
  </xsl:template>

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
