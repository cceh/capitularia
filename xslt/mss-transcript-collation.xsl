<?xml version="1.0" encoding="UTF-8"?>

<!--
This transformation produces the transcription section of a manuscript as TXT
output suited for collation.  Some text normalizations are applied.
-->

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    default-mode="collation"
    exclude-result-prefixes="cap tei xs xsl">

  <xsl:import href="mss-transcript-phase-1.xsl" />

  <xsl:output method="text" encoding="UTF-8" />

  <!-- Don't output the front for collation. Go directly to the body. -->
  <xsl:template match="/">
    <xsl:apply-templates select="/TEI/text/body" />
  </xsl:template>

  <xsl:template match="/TEI/text/body">
    <!-- apply templates in phase-1 stylesheet -->
    <xsl:variable name="phase1">
      <root>
        <xsl:apply-templates mode="phase1" />
      </root>
    </xsl:variable>

    <!-- apply templates in this stylesheet -->
    <xsl:variable name="s">
      <xsl:apply-templates select="$phase1/root" />
    </xsl:variable>

    <xsl:value-of select="normalize-space (translate (replace (lower-case ($s), 'ae', 'e'), 'ję.,:;!?-_*/', 'ie          '))"/>
  </xsl:template>

  <!-- Normalize V to U -->
  <xsl:template match="text ()">
    <xsl:value-of select="translate (., 'Vv', 'Uu')"/>
  </xsl:template>

  <!-- Don't normalize V to U inside <seg type="num"> -->
  <xsl:template match="seg[@type='num']//text ()">
    <xsl:value-of select="."/>
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
