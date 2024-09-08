<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xs xsl">

  <key name="zone" match="zone" use="@xml:id"/>

  <template match="/">
    <tei:TEI>
      <!-- INDEX NOMINUM ff. -->
      <apply-templates select=".//div[@type='page'][number (substring (@sameAs, 14)) >= 578]//div[@type='layout']" />
    </tei:TEI>
  </template>

  <template match="div[@type='layout']" >
    <variable name="temp">
      <apply-templates />
    </variable>

    <variable name="min" select="min ($temp/l/@x)" />

    <for-each-group select="$temp/l" group-starting-with="*[@x &lt; $min + 0.8]" >
      <text>&#x0a;</text>
      <tei:p>
        <xsl:for-each select="current-group()">
          <text>&#x0a;</text>
          <copy-of select="node()" />
        </xsl:for-each>
        <text>&#x0a;</text>
      </tei:p>
    </for-each-group>
  </template>

  <template match="l">
    <tei:l>
      <choose>
        <when test="key ('zone', concat (@xml:id, '_001'))/@ulx">
          <attribute name="x" select="key ('zone', concat (@xml:id, '_001'))/@ulx" />
        </when>
        <otherwise>
          <attribute name="x" select="999" />
        </otherwise>
      </choose>
      <apply-templates />
    </tei:l>
  </template>

  <template match="seg">
    <apply-templates />
  </template>

  <template match="seg[@subtype='hyphen']">
  </template>

  <template match="w[@lemma]">
    <value-of select="@lemma" />
  </template>

  <template match="hi[@rendition]|seg[@rendition]">
    <tei:hi rend="{substring (@rendition, 2)}">
      <apply-templates />
    </tei:hi>
  </template>

  <!-- copy everything else -->
  <template match="node()|@*">
    <copy>
      <apply-templates select="node()|@*"/>
    </copy>
  </template>

</xsl:stylesheet>
