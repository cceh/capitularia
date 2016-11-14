<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL: /capit/list/
Input file: cap/publ/capit/lists/capit_all.xml
Old name:   list_capit_all.xsl

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

  <xsl:param name="type" select="'all'"/>

  <xsl:template match="/tei:TEI">

    <xsl:variable name="BK">
      <xsl:apply-templates select=".//tei:item[starts-with (@xml:id, 'BK_')]"/>
    </xsl:variable>
    <xsl:variable name="Mordek">
      <xsl:apply-templates select=".//tei:item[starts-with (@xml:id, 'Mordek_')]"/>
    </xsl:variable>
    <xsl:variable name="Other">
      <xsl:apply-templates select=".//tei:item[not(@xml:id)][not(parent::tei:list[@type='transmission'])]"/>
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

  <xsl:template match="tei:list/tei:item">
    <xsl:if test="../@type=$type or $type='all'">
      <xsl:text>&#x0a;&#x0a;</xsl:text>
      <tr>
        <td class="siglum">
          <xsl:value-of select="cap:human-readable-siglum (@xml:id)"/>
        </td>
        <td class="title">
          <xsl:apply-templates select="tei:name"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:item/tei:name">
    <xsl:call-template name="if-published">
      <xsl:with-param name="path" select="concat ('/capit/', @ref)"/>
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
        <th class="siglum"  >[:de]Nummer                     [:en]No.                 [:]</th>
        <th class="title"   >[:de]Titel                      [:en]Caption             [:]</th>
      </tr>
    </thead>
  </xsl:template>

</xsl:stylesheet>
