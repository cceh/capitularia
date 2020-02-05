<?xml version="1.0" encoding="UTF-8"?>

<!--

Input files: /mss/lists/manuscripts.xml
Output file: /cache/lists/mss-key.html

URL: /cache/lists/mss-key.html /mss/key/

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

  <xsl:template match="/lists">
    <div class="mss-key-xsl">
      <div>
        <table>
          <thead>
            <tr>
              <th class="siglum">[:de]Sigle      [:en]Sigla     [:]</th>
              <th class="mss"   >[:de]Handschrift[:en]Manuscript[:]</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="list/item/siglum">
              <xsl:sort select="cap:natsort (.)"/>
            </xsl:apply-templates>
          </tbody>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="siglum">
    <tr>
      <td class="siglum">
        <div>
          <xsl:apply-templates />
          <xsl:if test="@type = 'new'">
            <xsl:text> [:de](NEU)[:en](NEW)[:]</xsl:text>
          </xsl:if>
          <xsl:if test="@type = 'old'">
            <xsl:text> (olim)</xsl:text>
          </xsl:if>
        </div>
      </td>
      <td>
        <xsl:apply-templates select="../title"/>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="title">
    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/mss/', ../@xml:id)"/>
      <xsl:with-param name="text" select="text ()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
