<?xml version="1.0" encoding="UTF-8"?>

<!--

Input files: /mss/lists/BibCapitMordek.xml /cache/lists/corpus.xml
Output file: /cache/lists/mss-idno.html
Output URL:  /mss/idno/

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xhtml cap xsl"
    version="3.0">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:include href="common-3.xsl"/>

  <xsl:param name="corpus" select="corpus.xml" />

  <xsl:variable name="corpus_xml" select="document ($corpus)"/>

  <xsl:template match="/TEI">
    <div class="mss-idno-xsl">
      <xsl:apply-templates select=".//div[@type='manuscripts']"/>
    </div>
  </xsl:template>

  <xsl:template match="div[@type='manuscripts']">
    <table>
      <tbody>
        <xsl:apply-templates select="milestone | msDesc/head[@type='shelfmark']"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="milestone">
    <tr>
      <th id="{@n}">
        <xsl:value-of select="@n"/>
      </th>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="msDesc[@xml:id]/head[@type='shelfmark']">
    <tr>
      <td>
        <xsl:call-template name="if-visible">
          <xsl:with-param name="path" select="concat ('/mss/', ../@xml:id)"/>
          <xsl:with-param name="text" select="text()"/>
        </xsl:call-template>

        <xsl:if test="note[@type='siglum' and normalize-space (.)]">
          <xsl:text> [</xsl:text>
          <span class="siglum">
            <xsl:apply-templates select="note[@type='siglum']"/>
          </span>
          <xsl:text>]</xsl:text>
        </xsl:if>

        <!-- some urls are invalid and of the form:
             url="urn:nbn:de:hebis:30:2-45087 http://sammlungen.ub.uni-frankfurt.de/msma/content/titleinfo/4655261"
        -->
        <xsl:variable
            name="urls"
            select="tokenize (normalize-space (string-join ($corpus_xml/teiCorpus/TEI[@xml:id=current()/../@xml:id]/facsimile/graphic/@url[1], ' ')))"
            />

        <xsl:for-each select="$urls">
          <xsl:if test="starts-with (., 'http')">
            <a href="{.}" class="external" title="Zum Digitalisat"></a>
          </xsl:if>
        </xsl:for-each>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
