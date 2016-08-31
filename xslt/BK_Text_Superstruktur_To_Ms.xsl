<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei xhtml exslt">

  <xsl:template match="/">
    <tei:TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="_bk-text-superstruktur" xml:lang="la">
      <tei:teiHeader>
	<tei:fileDesc>
	  <tei:titleStmt>
	    <tei:title type="main" xml:lang="ger">
	      Boretius Krause Superstruktur
	    </tei:title>
	  </tei:titleStmt>
	  <tei:publicationStmt>
	    <tei:p/>
	  </tei:publicationStmt>
	  <tei:sourceDesc>
	    <tei:p/>
	  </tei:sourceDesc>
	</tei:fileDesc>
      </tei:teiHeader>
      <tei:text>
	<tei:body>
	  <xsl:apply-templates select="/tei:TEI/tei:text/tei:body"/>
	</tei:body>
      </tei:text>
    </tei:TEI>
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulare']">
    <tei:milestone n="{@xml:id}" unit="{@type}" />
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulum']">
    <xsl:apply-templates select="tei:head" />
    <tei:ab corresp="{@xml:id}" type="text">
      <xsl:apply-templates select="tei:p"/>
    </tei:ab>
  </xsl:template>

  <xsl:template match="tei:head[@type='incipit']">
    <tei:ab corresp="{@xml:id}" type="meta-text">
      <xsl:apply-templates />
    </tei:ab>
  </xsl:template>

  <xsl:template match="tei:head[@type='inscriptio']">
    <tei:ab corresp="{@xml:id}" type="meta-text">
      <xsl:apply-templates />
    </tei:ab>
  </xsl:template>

  <!-- capitular without <div type=capitulum> -->
  <xsl:template match="tei:div[@type='capitulare']/tei:p">
    <tei:ab corresp="{../@xml:id}" type="text">
      <xsl:apply-templates />
    </tei:ab>
  </xsl:template>

</xsl:stylesheet>
