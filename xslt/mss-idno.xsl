<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL: /mss/idno/
Input file: cap/publ/mss/lists/BibCapitMordek.xml
Old name:   handschriften_mordek_signatur.xsl

-->

<xsl:stylesheet
    version="1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">
  <!-- libexslt does not support the regexp extension ! -->

  <xsl:include href="common.xsl"/>

  <xsl:template match="/tei:TEI">
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

      <xsl:apply-templates select=".//tei:div[@type='manuscripts']"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:div[@type='manuscripts']">
    <table>
      <tbody>
        <xsl:apply-templates select="tei:milestone | tei:msDesc/tei:head[@type='shelfmark']"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="tei:milestone">
    <tr>
      <th id="{@n}">
        <xsl:value-of select="@n"/>
      </th>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:msDesc[@xml:id]/tei:head[@type='shelfmark']">
    <tr>
      <td>
        <xsl:call-template name="if-visible">
          <xsl:with-param name="path" select="concat ('/mss/', ../@xml:id)"/>
          <xsl:with-param name="text" select="text()"/>
        </xsl:call-template>

        <xsl:if test="tei:note[@type='siglum' and normalize-space (.)]">
          <xsl:text> [</xsl:text>
          <span class="siglum">
            <xsl:apply-templates select="tei:note[@type='siglum']"/>
          </span>
          <xsl:text>]</xsl:text>
        </xsl:if>

        <xsl:variable name="doc" select="document (concat ('../mss/', ../@xml:id, '.xml'))"/>
        <!-- some urls are invalid and of the form:
             url="urn:nbn:de:hebis:30:2-45087 http://sammlungen.ub.uni-frankfurt.de/msma/content/titleinfo/4655261"
        -->
        <xsl:variable name="urls" select="str:split (normalize-space ($doc/tei:TEI/tei:facsimile/tei:graphic/@url))"/>
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
