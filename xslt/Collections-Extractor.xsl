<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei xhtml exslt">

  <xsl:output indent="yes"/>

  <xsl:template match="/tei:TEI">
    <tei:TEI xml:id="{@xml:id}">
      <xsl:text>&#x0a;</xsl:text>
      <tei:list>
        <xsl:text>&#x0a;</xsl:text>
        <xsl:apply-templates/>
      </tei:list>
      <xsl:text>&#x0a;</xsl:text>
    </tei:TEI>
  </xsl:template>

  <xsl:template match="tei:msItem">
    <xsl:text>  </xsl:text>
    <tei:item type="capitulare" corresp="{@corresp}">
    </tei:item>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="text()" />

</xsl:stylesheet>
