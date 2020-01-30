<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL: /mss/key/
Input file: cap/publ/mss/lists/sigle.xml
Old name:   IdnoSynopse.xsl

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
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
            <xsl:apply-templates select="list[@id='sigla']/item|list[@id='newsigla']/item">
              <xsl:sort select="cap:natsort (sigle)"/>
              <xsl:sort select="mss"/>
            </xsl:apply-templates>
          </tbody>
        </table>
      </div>

      <!--
      <div>
        <h4 id="no_sigla">
          [:de]Handschriften ohne Sigle
          [:en]Manuscripts without sigla
          [:]
        </h4>
        <p>
          [:de]Bei den folgenden Codices handelt es sich entweder um Neufunde oder um
          Handschriften, die Mordek zwar erwähnt, ihnen aber keine Sigle zuwies.
          [:en]Listed below are manuscripts that were either newly discovered or that were
          mentioned by Mordek, but with no sigla attributed to them.
          [:]
        </p>
        <table>
          <tbody>
	        <xsl:apply-templates select="list[@id='nosigla']/item" />
          </tbody>
        </table>
      </div>
      -->

    </div>
  </xsl:template>

  <xsl:template match="item">
    <tr>
      <xsl:choose>
        <xsl:when test="parent::list[@id='sigla']">
          <td class="siglum">
            <xsl:apply-templates select="sigle"/>
          </td>
        </xsl:when>
        <xsl:when test="parent::list[@id='newsigla']">
          <td class="siglum">
            <xsl:apply-templates select="sigle"/>
            <xsl:text> [:de](NEU)[:en](NEW)[:]</xsl:text>
          </td>
        </xsl:when>
      </xsl:choose>
      <td>
        <xsl:apply-templates select="mss"/>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="mss">
    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/mss/', ../url)"/>
      <xsl:with-param name="text" select="text ()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
