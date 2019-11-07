<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:param name="dir" />

  <xsl:template name="main">
    <tei:teiCorpus>
      <tei:teiHeader />
      <xsl:apply-templates select="collection (concat ('file:///', $dir, '?select=*.xml'))" />
    </tei:teiCorpus>
  </xsl:template>

  <xsl:template match="tei:text">
  </xsl:template>

  <xsl:template match="tei:facsimile">
  </xsl:template>

  <!-- get rid of processing instructions too -->
  <xsl:template match="@* | element () | text () | comment ()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
