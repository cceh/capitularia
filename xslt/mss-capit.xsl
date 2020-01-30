<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL: /mss/capit/
Input file: cap/publ/mss/lists/mss_by_cap.xml cap/publ/cache/lists/corpus.xml
Old name:   tabelle_cap_mss.xsl

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

  <xsl:template match="/list">
    <div class="mss-capit-xsl">
      <div id="content">

        <h4 id="BK">
          [:de]Von Boretius/Krause edierte Kapitularien
          [:en]Capitularies edited by Boretius/Krause
          [:]
        </h4>

        <table class="handschriften">
          <thead valign="top">
            <th class="capit"><h5>[:de]Titel        [:en]Caption    [:]</h5></th>
            <th class="mss"  ><h5>[:de]Handschriften[:en]Manuscripts[:]</h5></th>
          </thead>
          <tbody>
            <xsl:for-each select="item[starts-with (@n, 'BK')]">
              <xsl:call-template name="capitular" />
            </xsl:for-each>
          </tbody>
        </table>

        <h4 id="Mordek">
          [:de]Bei Mordek (Anhang I) gedruckte neue Texte
          [:en]New texts as printed in Mordek appendix I
          [:]
        </h4>

        <table class="handschriften">
          <thead valign="top">
            <th class="capit"><h5>[:de]Titel        [:en]Caption    [:]</h5></th>
            <th class="mss"  ><h5>[:de]Handschriften[:en]Manuscripts[:]</h5></th>
          </thead>
          <tbody>
            <xsl:for-each select="item[starts-with (@n, 'Mordek')]">
              <xsl:call-template name="capitular" />
            </xsl:for-each>
          </tbody>
        </table>

        <h4 id="Rest">
          [:de]Weitere bei Mordek erwähnte Kapitularien und Ansegis
          [:en]Further capitularies mentioned by Mordek and Ansegis
          [:]
        </h4>

        <table class="handschriften">
          <thead valign="top">
            <th class="capit"><h5>[:de]Titel        [:en]Caption    [:]</h5></th>
            <th class="mss"  ><h5>[:de]Handschriften[:en]Manuscripts[:]</h5></th>
          </thead>
          <tbody>
            <xsl:for-each select="item[not (contains (@n, '.'))]">
              <xsl:call-template name="capitular" />
            </xsl:for-each>
          </tbody>
        </table>

      </div>
    </div>
  </xsl:template>

  <xsl:template name="capitular">
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <tr>
      <td class="capit">
        <xsl:call-template name="if-visible">
          <!-- adds link if target is visible to the user -->
          <xsl:with-param name="path" select="concat ('/cap/', @n)" />
          <xsl:with-param name="text">
            <xsl:apply-templates select="title"/>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="contains (@n, '.')">
          <xsl:text> </xsl:text>
          <div class="mss-capit-capitular-siglum">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="cap:human-readable-siglum (@n)"/>
            <xsl:text>]</xsl:text>
          </div>
        </xsl:if>
      </td>

      <xsl:text>&#x0a;&#x0a;</xsl:text>

      <td class="mss">
        <ul class="bare">
          <xsl:for-each select="msIdentifier">
            <li>
              <xsl:call-template name="if-visible">
                <xsl:with-param name="path" select="concat ('/mss/', @xml:id)"/>
                <xsl:with-param name="text">
                  <!-- get the title of the ms out of file corpus.xml -->
                  <xsl:value-of select="$corpus_xml/teiCorpus/TEI[@xml:id=current()/@xml:id]//titleStmt/title[@type='main']" />
                </xsl:with-param>
              </xsl:call-template>
            </li>
            <xsl:text>&#x0a;&#x0a;</xsl:text>
          </xsl:for-each>
        </ul>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="note">
    <div class="note">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="ref[@type='external']">
    <a title="Externer Link" href="{@target}" target="_blank">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="ref[@type='internal']">
    <a title="Interner Link" href="{@target}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

</xsl:stylesheet>
