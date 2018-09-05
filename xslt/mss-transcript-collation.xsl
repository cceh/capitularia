<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#default tei"
    extension-element-prefixes="cap exsl func set str">
  <!-- libexslt does not support the regexp extension ! -->

  <!-- This transformation produces HTML better suited for collation. -->

  <xsl:import href="mss-transcript.xsl" />

  <!-- Don't output the front for collation. Go directly to the body. -->
  <xsl:template match="/">
    <xsl:apply-templates select="/tei:TEI/tei:text/tei:body"/>
  </xsl:template>

  <!-- Normalize V to U except in <tei:seg type="num"> -->
  <xsl:template match="text ()">
    <xsl:value-of select="translate (., 'Vv', 'Uu')"/>
  </xsl:template>

  <xsl:template match="tei:seg[@type='num']//text ()">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Don't output folio number etc. -->
  <xsl:template match="tei:cb" />

  <xsl:template match="tei:milestone[not (@unit='span')]" />

  <!-- Don't output footnotes -->
  <xsl:template name="footnotes-wrapper" />

  <xsl:template match="tei:note" />

  <xsl:template match="tei:figure" />

  <!-- Don't output "[!]" -->
  <xsl:template match="tei:sic">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:gap">
    <xsl:value-of select="str:padding (number (@quantity), '·')" />
  </xsl:template>

  <xsl:template name="empty-del" />

  <xsl:template name="page-break" />

  <!-- don't output special markup for wordpress sidebar menu -->
  <xsl:template name="make-chapter-mark" />

  <xsl:template name="make-sidebar-bk" />

  <xsl:template name="make-sidebar-bk-chapter" />

</xsl:stylesheet>
