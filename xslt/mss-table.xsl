<?xml version="1.0" encoding="UTF-8"?>

<!--

Input Files: /mss/lists/ueberblick_mordek.xml
Output File: /cache/lists/mss-table.html
Output URL:  /mss/table/

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

  <xsl:template match="/MSS">
    <div class="mss-table-xsl">
      <table align="center" class="handschriften break-word" rules="all">
        <thead>
          <tr>
            <th class="shelfmark">[:de]Signatur [Siglum]       [:en]Shelfmark [siglum]     [:]</th>
            <th class="capit"    >[:de]Enthaltene Kapitularien [:en]Capitularies contained [:]</th>
            <th class="origin"   >[:de]Datierung, Herkunft     [:en]Origin                 [:]</th>
          </tr>
        </thead>
        <tbody>
          <xsl:apply-templates select="text/list/*"/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="milestone">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <tr>
      <th class="dyn-menu-h4" colspan="3" id="{@n}">
        <xsl:value-of select="@n"/>
      </th>
    </tr>
  </xsl:template>

  <xsl:template match="item[@xml:id]">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <tr>
      <td class="shelfmark">
        <span>
          <xsl:apply-templates select="idno[@type = 'main']"/>
        </span>
        <span title="[:de]Sigle bei Mordek[:en]Siglum (Mordek)[:]">
          <xsl:apply-templates select="idno[@type = 'siglum']"/>
        </span>
        <xsl:apply-templates select="note[@type = 'filiation']"/>
      </td>

      <td class="capit">
        <ul class="bare">
          <xsl:apply-templates select="content"/>
        </ul>
      </td>

      <td class="origin">
        <span>
          <xsl:apply-templates select="origin"/>
        </span>
        <xsl:apply-templates select="note[@type = 'annotation']"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="idno[@type = 'main']">
    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/mss/', ../@xml:id)"/>
      <xsl:with-param name="title">[:de]Zur Handschrift[:en]Go to the manuscript[:]</xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="idno[@type = 'siglum']">
    <xsl:text> [</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="origin">
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::origin">
      <br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="origDate">
    <xsl:if test="preceding-sibling::locus">
      <xsl:apply-templates select="locus"/>
      <xsl:text>: </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::origPlace">
      <xsl:if test="not(following-sibling::origDate)">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="following-sibling::origDate">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="origPlace">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="locus">
    <xsl:choose>
      <xsl:when test="parent::origDate">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="content/capit">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="term[@n]">

    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>

    <span class="term">
      <xsl:text> [</xsl:text>

      <xsl:call-template name="if-visible">
        <xsl:with-param name="path" select="concat ('/cap/', @n)"/>

        <xsl:with-param name="title">
          <xsl:text>[:de]Informationen zum Kapitular[:en]Information on capitulary[:] </xsl:text>
          <xsl:value-of select="cap:human-readable-siglum (@n)"/>
        </xsl:with-param>

        <xsl:with-param name="text">
          <xsl:value-of select="cap:human-readable-siglum (@n)"/>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:text>]</xsl:text>
    </span>

  </xsl:template>

  <xsl:template match="term">
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="hi">
    <xsl:if test="@rend = 'super'">
      <sup>
        <xsl:apply-templates/>
      </sup>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note[@type = 'filiation' or @type = 'annotation']">
    <span>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="note">
    <br/>
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="ref[@type='external']">
    <xsl:variable name="target" select="cap:lookup-element ($tei-ref-external-targets, @subtype)"/>
    <a class="external" href="{string ($target/prefix)}{@target}" target="_blank" title="{string ($target/caption)}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="ref[@type = 'internal' and @subtype = 'mss']">
    <a href="{$mss}{@target}" title="Zur Handschriftenbeschreibung">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="ref" />

</xsl:stylesheet>
