<?xml version="1.0" encoding="UTF-8"?>

<!--

Input File: cap/publ/mss/lists/ueberblick_mordek.xml
Output URL: /mss/table/
Old name:   tabelle_ueberblick.xsl

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

  <xsl:template match="/MSS">

    <!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <item> -->
    <div class="mss-table-xsl">
      <p class="intro">
        [:de]Die Übersicht listet alle bekannten Handschriften auf, die Kapitularien
        enthalten. Die in Mordek 1995 vergebenen Handschriftensiglen stehen in Klammern hinter
        der jeweiligen Signatur. Hier finden Sie eine <a
        href="http://capitularia.uni-koeln.de/mss/key/" title="Konkordanz nach
        Mordek-Siglen">Konkordanz der Mordek-Siglen</a>.

        [:en]This table lists all known manuscripts containing capitularies. Shelfmarks are
        usually followed by the siglum assigned by Mordek 1995 in square brackets. Here is a
        <a href="http://capitularia.uni-koeln.de/mss/key/" title="concordance Mordek"
           >concordance of all these sigla</a>.

        [:]
      </p>

      <p class="intro">
        [:de]Hinter den enthaltenen Kapitularien (in der 2. Spalte) steht entweder die Nummer
        der Edition von Boretius/Krause (BK) oder die Nummer im Anhang I von Mordek
        1995.

        [:en]The second column lists all capitularies in the respective manuscript. In square
        brackets you find either the number assigned to that capitulary in the edition by
        Boretius/Krause (“BK”) or its number in Mordek 1995, appendix I (“Mordek”).

        [:]
      </p>

      <p class="intro">
        [:de]Hier finden Sie eine <a href="http://capitularia.uni-koeln.de/capit/list/"
        title="Gesamtüberblick über die Kapitularien">Liste mit allen Kapitularien</a>.

        [:en]Here is a <a href="http://capitularia.uni-koeln.de/capit/list/" title="table of
        capitularies">listing of all capitularies</a>.

        [:]
      </p>

      <table align="center" class="handschriften" rules="all">
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
    <xsl:call-template name="if-published">
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

    <xsl:variable name="path">
      <xsl:text>/capit</xsl:text>
      <xsl:choose>
        <xsl:when test="@list='pre814'">
          <xsl:value-of select="'/pre814'"/>
        </xsl:when>
        <xsl:when test="@list='post840'">
          <xsl:value-of select="'/post840'"/>
        </xsl:when>
        <xsl:when test="@list='undated'">
          <xsl:value-of select="'/undated'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'/ldf'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="contains(@n, 'BK')">
        <xsl:text>/bk-nr-</xsl:text>
      </xsl:if>
      <xsl:if test="contains(@n, 'Mordek')">
        <xsl:text>/mordek-nr-</xsl:text>
      </xsl:if>
      <xsl:value-of select="substring-after (@n, '.')"/>
    </xsl:variable>

    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>

    <span class="term">
      <xsl:text> [</xsl:text>

      <xsl:call-template name="if-published">
        <xsl:with-param name="path" select="$path"/>

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
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="note">
    <br/>
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="ref[@type = 'external' and @subtype = 'Bl']">
    <a href="{$Bl}{@target}" target="_blank" title="Bibliotheca legum">
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
