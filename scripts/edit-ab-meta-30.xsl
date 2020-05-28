<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xs xsl">

  <xsl:template match="ab[@type='meta-text' and not (@corresp) and (seg[@type='num' or @type='numDenom'])]">
    <xsl:variable name="corresp" select="concat (tokenize (following::ab[@type='text'][1]/@corresp)[1], '_inscriptio')" />
    <ab>
      <xsl:if test="$corresp != '_inscriptio'">
        <xsl:attribute name="corresp" select="$corresp" />
      </xsl:if>

      <xsl:apply-templates select="node()|@*"/>
    </ab>
  </xsl:template>

  <!-- copy everything else -->

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
