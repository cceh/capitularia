<?xml version="1.0" encoding="UTF-8"?>

<!--

Transforms: $(CAPIT_DIR)/lists/capit_all.xml -> $(CACHE_DIR)/lists/capit-all.html     : type=all
Transforms: $(CAPIT_DIR)/lists/capit_all.xml -> $(CACHE_DIR)/lists/capit-pre814.html  : type=pre814
Transforms: $(CAPIT_DIR)/lists/capit_all.xml -> $(CACHE_DIR)/lists/capit-ldf.html     : type=ldf
Transforms: $(CAPIT_DIR)/lists/capit_all.xml -> $(CACHE_DIR)/lists/capit-post840.html : type=post840
Transforms: $(CAPIT_DIR)/lists/capit_all.xml -> $(CACHE_DIR)/lists/capit-undated.html : type=undated

URL: $(CACHE_DIR)/lists/capit-all.html     /capit/list/
URL: $(CACHE_DIR)/lists/capit-pre814.html  /capit/pre814/
URL: $(CACHE_DIR)/lists/capit-ldf.html     /capit/ldf/
URL: $(CACHE_DIR)/lists/capit-post840.html /capit/post840/
URL: $(CACHE_DIR)/lists/capit-undated.html /capit/undated/

Target: lists $(CACHE_DIR)/lists/capit-all.html
Target: lists $(CACHE_DIR)/lists/capit-pre814.html
Target: lists $(CACHE_DIR)/lists/capit-ldf.html
Target: lists $(CACHE_DIR)/lists/capit-post840.html
Target: lists $(CACHE_DIR)/lists/capit-undated.html

Scrape: cap-list $(CAPIT_DIR)/lists/capit_all.xml

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

  <xsl:include href="common-3.xsl" />
  <xsl:include href="common-html.xsl" />

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:param name="type" select="'all'"/>

  <xsl:template match="/TEI">

    <xsl:variable name="BK">
      <xsl:apply-templates select=".//item[starts-with (@xml:id, 'BK_')]"/>
    </xsl:variable>
    <xsl:variable name="Mordek">
      <xsl:apply-templates select=".//item[starts-with (@xml:id, 'Mordek_')]"/>
    </xsl:variable>
    <xsl:variable name="Other">
      <xsl:apply-templates select=".//item[not(@xml:id)][not(parent::list[@type='transmission'])]"/>
    </xsl:variable>

    <div class="capit-list-xsl">
      <div class="handschriften">

        <xsl:if test="normalize-space ($BK)">
          <h4 id="BK">
            [:de]Bei Boretius/Krause (BK) verzeichnete Kapitularien
            [:en]Capitularies mentioned by Boretius/Krause (BK)
            [:]
          </h4>

          <table>
            <xsl:call-template name="thead"/>
            <xsl:copy-of select="$BK"/>
          </table>
        </xsl:if>

        <xsl:if test="normalize-space ($Other)">
          <h4 id="Other">
            [:de]Weitere Kapitularien und Ansegis
            [:en]Further capitularies and Ansegis
            [:]
          </h4>

          <table>
            <xsl:call-template name="thead"/>
            <xsl:copy-of select="$Other"/>
          </table>
        </xsl:if>

        <xsl:if test="normalize-space ($Mordek)">
          <h4 id="Mordek">
            [:de]Neuentdeckte Kapitularien (Mordek Anhang I)
            [:en]Newly discovered capitularies (Mordek appendix I)
            [:]
          </h4>

          <table>
            <xsl:call-template name="thead"/>
            <xsl:copy-of select="$Mordek"/>
          </table>
        </xsl:if>

      </div>
    </div>
  </xsl:template>

  <xsl:template match="list/item">
    <xsl:if test="../@type=$type or $type='all'">
      <xsl:text>&#x0a;&#x0a;</xsl:text>
      <tr>
        <td class="siglum">
          <xsl:value-of select="cap:human-readable-siglum (@xml:id)"/>
        </td>
        <td class="title">
          <xsl:apply-templates select="name"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item/name">
    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/capit/', @ref, '/')"/>
      <xsl:with-param  name="title">
        <xsl:text>[:de]Zu[:en]Go to[:] </xsl:text>
        <xsl:value-of select="cap:human-readable-siglum (../@xml:id)"/>
      </xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="thead">
    <thead>
      <xsl:text>&#x0a;&#x0a;</xsl:text>
      <tr>
        <th class="siglum">[:de]Nummer[:en]No.    [:]</th>
        <th class="title" >[:de]Titel [:en]Caption[:]</th>
      </tr>
    </thead>
  </xsl:template>

</xsl:stylesheet>
