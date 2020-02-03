<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap"
    exclude-result-prefixes="tei">

  <xsl:function name="cap:new-id">
    <xsl:param name="s"/>
    <xsl:sequence select="replace ($s, 'BK.', 'BK_TXT.')"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="/processing-instruction ('xml-model')" />
    <xsl:text>&#x0a;</xsl:text>
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="superstruktur" xml:lang="la">
      <xsl:apply-templates select="tei:teiHeader" />
      <text>
	    <body>
	      <xsl:apply-templates select="/tei:TEI/tei:text/tei:body"/>
	    </body>
      </text>
    </TEI>
  </xsl:template>

  <xsl:template match="processing-instruction ()">
    <xsl:copy />
  </xsl:template>

  <xsl:template match="tei:header">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulare']">
    <ab type="{@type}" xml:id="{@xml:id}">
      <xsl:apply-templates />
    </ab>
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulatio']">
    <ab type="{@type}" xml:id="{@xml:id}">
      <xsl:apply-templates />
    </ab>
  </xsl:template>

  <xsl:template match="tei:div[@type='capitulum']">
    <ab type="{@type}" xml:id="{@xml:id}_cap_">
      <xsl:apply-templates select="tei:head" />
      <ab xml:id="{@xml:id}" type="text">
        <xsl:apply-templates select="tei:p"/>
      </ab>
    </ab>
  </xsl:template>

  <xsl:template match="tei:head[@type='incipit']">
    <ab xml:id="{@xml:id}" type="meta-text">
      <xsl:apply-templates />
    </ab>
  </xsl:template>

  <xsl:template match="tei:head[@type='inscriptio']">
    <ab xml:id="{@xml:id}" type="meta-text">
      <xsl:apply-templates />
    </ab>
  </xsl:template>

  <!-- capitular without <div type=capitulum> -->
  <xsl:template match="tei:div[@type='capitulare']/tei:p">
    <ab xml:id="{../@xml:id}" type="text">
      <xsl:apply-templates />
    </ab>
  </xsl:template>

</xsl:stylesheet>
