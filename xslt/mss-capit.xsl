<?xml version="1.0" encoding="UTF-8"?>

<!--

Transforms: $(MSS_DIR)/lists/mss_by_cap.xml $(MSS_DIR)/lists/manuscripts.xml -> $(CACHE_DIR)/lists/mss-capit.html : manuscripts=$(MSS_DIR)/lists/manuscripts.xml make=false

URL: $(CACHE_DIR)/lists/mss-capit.html /mss/capit/

Target: lists $(CACHE_DIR)/lists/mss-capit.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <xsl:include href="common-3.xsl"/>
  <xsl:include href="common-html.xsl"/>

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:param name="manuscripts" select="manuscripts.xml" />

  <xsl:variable name="manuscripts_xml" select="document ($manuscripts)"/>

  <xsl:template match="/lists/list[@type='capitularies']">
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
              <xsl:sort select="title"
                        collation="http://www.w3.org/2013/collation/UCA?lang=de;fallback=yes" />
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
          <xsl:with-param name="path" select="concat ('/capit/', @n)" />
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

        <xsl:apply-templates select="note"/>
      </td>

      <xsl:text>&#x0a;&#x0a;</xsl:text>

      <td class="mss">
        <ul class="bare">
          <xsl:for-each select="msIdentifier">
            <li>
              <xsl:variable name="title">
                <xsl:choose>
                  <xsl:when test="title">
                    <!-- an explicitly set title overrides -->
                    <xsl:apply-templates select="title" />
                  </xsl:when>
                  <xsl:when test="$manuscripts_xml//item[@xml:id=current ()/@target]">
                    <!-- look for title in manuscript list -->
                    <xsl:apply-templates
                        select="$manuscripts_xml//item[@xml:id=current ()/@target]/title" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@target" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:choose>
                <xsl:when test="@target">
                  <xsl:call-template name="if-visible">
                    <xsl:with-param name="path" select="concat ('/mss/', @target, '/')"/>
                    <xsl:with-param name="text">
                      <xsl:copy-of select="$title"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$title"/>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:apply-templates select="note" />
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

</xsl:stylesheet>
