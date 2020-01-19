<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL:  /mss/idno/
Input files: cap/publ/mss/lists/BibCapitMordek.xml cap/publ/cache/lists/corpus.xml
Old name:    handschriften_mordek_signatur.xsl

-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:include href="common-3.xsl"/>

  <xsl:param name="corpus" select="corpus.xml" />

  <xsl:variable name="corpus_xml" select="document ($corpus)"/>

  <xsl:template match="/TEI">
    <div class="mss-idno-xsl">
      <p class="intro">
        [:de]Die folgende, alphabetisch geordnete Liste führt alle bei Mordek 1995 genannten
        Kapitularienhandschriften auf. Weitere, bei Mordek nicht verzeichnete Handschriften mit
        Kapitularien wurden ergänzt.
        [:en]This table lists - in alphabetical order - all manuscripts recorded in Mordek 1995
        which contain capitularies. Further manuscripts containing capitularies which were not
        recorded by Mordek have been added.
        [:]
      </p>

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
