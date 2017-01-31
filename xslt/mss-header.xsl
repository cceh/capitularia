<?xml version="1.0" encoding="UTF-8"?>

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

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- For aestetical purposes only. -->
  <xsl:strip-space elements="tei:msContents tei:listBibl"/>

  <func:function name="cap:part-id">
    <!-- Get the msPart part number as id. -->
    <xsl:variable name="pn">
      <xsl:if test="ancestor-or-self::tei:msPart">
        <xsl:value-of select="cap:make-id (concat ('id_', ancestor-or-self::tei:msPart[1]/@n))"/>
      </xsl:if>
    </xsl:variable>

    <func:result select="$pn"/>
  </func:function>

  <xsl:variable name="captions">
    <item key="origin"             value="[:de]Entstehung:[:en]Origin:[:]"/>
    <item key="provenance"         value="[:de]Provenienz:[:en]Provenance:[:]"/>
    <item key="summary"            value="[:de]Anmerkung:[:en]Note:[:]"/>
    <item key="support"            value="[:de]Material:[:en]Material:[:]"/>
    <item key="extent"             value="[:de]Umfang:[:en]Number:[:]"/>
    <item key="dimensions-leaf"    value="[:de]Maße:[:en]Size:[:]"/>
    <item key="dimensions-written" value="[:de]Schriftraum:[:en]Body text:[:]"/>
    <item key="collation"          value="[:de]Lagen:[:en]Quires:[:]"/>
    <item key="condition"          value="[:de]Zustand:[:en]Condition:[:]"/>
    <item key="layout"             value="[:de]Zeilen:[:en]Lines:[:]"/>
    <item key="layout-columns"     value="[:de]Spalten:[:en]Columns:[:]"/>
    <item key="scriptDesc"         value="[:de]Schrift:[:en]Script:[:]"/>
    <item key="handDesc"           value="[:de]Schreiber:[:en]Scribe(s):[:]"/>
    <item key="decoDesc"           value="[:de]Ausstattung:[:en]Decoration:[:]"/>
    <item key="binding"            value="[:de]Einband:[:en]Binding:[:]"/>
  </xsl:variable>

  <xsl:template match="/tei:TEI">
    <div class="tei-TEI mss-header-xsl transkription-header">
      <script language="javascript">
        function toggle (control) {
          var elem = document.getElementById(control);
          if (elem.style.display == "none") {
            elem.style.display = "block";
          } else {
            elem.style.display = "none";
          }
        }
      </script>

      <xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
      <xsl:call-template name="page-break"/>
    </div>
  </xsl:template>

  <!-- Ausgabe des Titels, Informationen zur haltenden Institution, Entstehungsgeschichte,
       allgemeine Anmerkungen, Bibliographie -->

  <xsl:template match="tei:fileDesc">
    <div class="tei-fileDesc">
      <!-- The main title is already supplied by Wordpress.  Eventually add filiation here. -->
      <xsl:apply-templates select="tei:titleStmt//tei:note[@type='filiation']"/>

      <!-- "Beschreibung nach Mordek" -->
      <h4 id="description-mordek" class="tei-titleStmt">
        <xsl:text>[:de]Beschreibung[:en]Description</xsl:text>
        <xsl:if test="tei:sourceDesc//tei:listBibl[@type='cap']/tei:bibl[starts-with (., 'Mordek 1995')]">
          <xsl:text>[:de] nach Mordek[:en] according to Mordek</xsl:text>
        </xsl:if>
        <xsl:text>[:]</xsl:text>
      </h4>

      <xsl:apply-templates select="tei:sourceDesc"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:msDesc">
    <div class="tei-msDesc">

      <div id="identification">
        <!-- Aufbewahrungsort -->
        <xsl:apply-templates select="tei:msIdentifier"/>
        <!-- Digitalisat verfügbar bei -->
        <xsl:apply-templates select="/tei:TEI/tei:facsimile"/>
      </div>

      <div>
        <xsl:apply-templates select=".//tei:filiation"/>
        <xsl:apply-templates select=".//tei:adminInfo/tei:note[@resp='KU']"/>
        <xsl:apply-templates select=".//tei:msItem/tei:note[@type='annotation']"/>
        <!-- Handschrift des Monats -->
        <xsl:apply-templates select=".//tei:ref[@subtype='mom']"/>
      </div>

      <xsl:call-template name="page-break"/>
      <xsl:call-template name="ms-part"/>
      <xsl:apply-templates select="tei:msPart"/>

    </div>
  </xsl:template>

  <xsl:template match="tei:msPart">
    <xsl:call-template name="page-break"/> <!-- Duplicated page-breaks are removed by css! -->

    <div class="tei-msPart">
      <h4 id="{cap:part-id ()}">
        <xsl:value-of select="@n"/>
      </h4>
      <xsl:call-template name="ms-part"/>
    </div>
  </xsl:template>

  <xsl:template name="ms-part">
    <!-- Entstehung und Überlieferung -->
    <xsl:apply-templates select="tei:history[normalize-space()]"/>
    <!-- Äußere Beschreibung -->
    <xsl:apply-templates select="tei:physDesc[normalize-space()]"/>
    <!-- Inhalte -->
    <xsl:apply-templates select="tei:msContents[normalize-space()]"/>
    <!-- Bibliographie -->
    <xsl:apply-templates select="tei:additional/tei:listBibl"/>
  </xsl:template>

  <!-- Aufbewahrungsort -->

  <xsl:template match="tei:msIdentifier">
    <div class="tei-msIdentifier">
      <h5>[:de]Aufbewahrungsort:[:en]Repository:[:]</h5>

      <xsl:value-of select="tei:settlement"/>
      <br/>
      <xsl:value-of select="tei:repository"/>
      <br/>
      <xsl:value-of select="tei:collection"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="tei:idno"/>

      <div>
        <xsl:if test="normalize-space (tei:msName)">
          <div class="tei-msNames">
            <u>[:de]Name[:en]Name[:]:</u>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="tei:msName"/>
          </div>
        </xsl:if>
        <xsl:apply-templates select="tei:altIdentifier"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="tei:msName">
    <xsl:if test="preceding-sibling::tei:msName">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:altIdentifier"/>

  <xsl:template match="tei:altIdentifier[@type='siglum']">
    <div class="tei-altIdentifier">
      <u>[:de]Sigle:[:en]Siglum[:]</u>
      <xsl:text> </xsl:text>
      <span class="italic">
        <xsl:value-of select="tei:idno"/>
        <xsl:if test="normalize-space (tei:note)">
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="tei:note"/>
        </xsl:if>
      </span>
    </div>
  </xsl:template>

  <!-- Entstehung und Überlieferung -->

  <xsl:template match="tei:history">
    <div class="tei-history">
      <h5 id="{cap:part-id ()}_origin">
        <xsl:text>[:de]Entstehung und Überlieferung[:en]Origin and history[:]</xsl:text>
      </h5>
      <!-- Entstehung -->
      <xsl:apply-templates select="tei:origin[normalize-space()]"/>
      <!-- Provenienz -->
      <xsl:apply-templates select="tei:provenance[normalize-space()]"/>
      <!-- Anmerkung -->
      <xsl:apply-templates select="tei:summary[normalize-space()]"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:origin|tei:provenance|tei:summary">
    <div class="tei-{local-name ()}">
      <h6><xsl:value-of select="cap:lookup-value ($captions, local-name ())"/></h6>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Äußere Beschreibung (Die Tabelle) -->

  <xsl:template match="tei:physDesc">
    <xsl:call-template name="page-break"/>

    <div class="tei-physDesc">
      <h5 id="{cap:part-id ()}_description">
        <xsl:text>[:de]Äußere Beschreibung[:en]Physical description[:]</xsl:text>
      </h5>

      <table class="tei-physDesc-table">
        <tbody>
          <!-- Material -->
          <xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:support"/>
          <!-- Umfang -->
          <xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:extent"/>
          <!-- Maße + Schriftraum -->
          <xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:extent/tei:dimensions" mode="dimensions"/>
          <!-- Lagen -->
          <xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:collation[normalize-space()]"/>
          <!-- Zustand -->
          <xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:condition[normalize-space()]"/>
          <!-- Zeilen -->
          <xsl:apply-templates select="tei:objectDesc/tei:layoutDesc/tei:layout[@writtenLines]"/>
          <!-- Spalten -->
          <xsl:apply-templates select="tei:objectDesc/tei:layoutDesc/tei:layout[@columns]"/>
          <!-- Schrift -->
          <xsl:apply-templates select="tei:scriptDesc[normalize-space()]"/>
          <!-- Schreiber -->
          <xsl:apply-templates select="tei:handDesc[normalize-space()]"/>
          <!-- Ausstattung -->
          <xsl:apply-templates select="tei:decoDesc[normalize-space()]"/>
          <!-- Einband -->
          <xsl:apply-templates select="tei:bindingDesc[normalize-space()]"/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="tei:support|tei:condition|tei:layout[@writtenLines]|tei:scriptDesc|tei:handDesc|tei:decoDesc|tei:binding">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, concat (local-name (), @type))"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:extent">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, 'extent')"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:dimensions"/>

  <xsl:template match="tei:dimensions" mode="dimensions">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, concat ('dimensions-', @type))"/>
      </th>
      <td class="text">
        <xsl:if test="@precision">
          <xsl:text>ca. </xsl:text>
        </xsl:if>
        <xsl:value-of select="concat (tei:height, ' × ', tei:width, ' mm')"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:collation">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, 'collation')"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
        <xsl:apply-templates select="tei:formula"    mode="formula"/>
        <xsl:apply-templates select="tei:catchwords" mode="formula"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:layout[@columns]">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, 'layout-columns')"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
        <xsl:if test="not (normalize-space ())">
          <xsl:value-of select="@columns"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:formula|tei:catchwords"/>

  <xsl:template match="tei:formula|tei:catchwords" mode="formula">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Inhalte -->

  <xsl:template match="tei:msContents">
    <xsl:call-template name="page-break"/>

    <div class="tei-msContents">
      <h5 id="{cap:part-id ()}_content">
        <xsl:text>[:de]Inhalte[:en]Contents[:]</xsl:text>
      </h5>

      <xsl:apply-templates select="tei:summary[normalize-space()]"/>

      <ul class="bare">
        <xsl:apply-templates select="tei:msItem"/>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="tei:msItem">
    <xsl:if test="@prev">
      <li class="tei-msItem">
        <a class="internal" target="_blank" href="{$mss}{str:replace (@prev, '_', '#')}"
          title="[:de]Zum zugehörigen Teil (in einer anderen Handschrift)[:en]To the corresponding part in another manuscript[:]">
        </a>
      </li>
    </xsl:if>

    <li class="tei-msItem">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id">
          <xsl:value-of select="substring-after (@xml:id, '_')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </li>

    <xsl:if test="@next">
      <li class="tei-msItem">
        <a class="internal" target="_blank" href="{$mss}{str:replace (@next, '_', '#')}"
          title="[:de]Zum zugehörigen Teil (in einer anderen Handschrift)[:en]To the corresponding part in another manuscript[:]">
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:msItem//tei:title">
    <span class="semibold">
      <xsl:if test="contains (ancestor::tei:msItem/@corresp, '.')">
        <xsl:attribute name="title">
          <xsl:text>= </xsl:text>
          <xsl:value-of select="str:replace (ancestor::tei:msItem/@corresp, '.', ' ')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:msItem//tei:locus">
    <span class="semibold">
      <xsl:if test="@target">
        <a class="internal" href="{$mss}{str:replace (@target, '_', '#')}"
           target="_blank"
           title="[:de]Zur korrespondierenden Handschrift[:en]To the corresponding manuscript[:]">
          <xsl:apply-templates/>
        </a>
      </xsl:if>
      <xsl:if test="not (@target)">
        <xsl:apply-templates/>
      </xsl:if>
      <xsl:if test="normalize-space (following-sibling::tei:*[1][self::tei:locus])">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </span>
    <xsl:if test="not (following-sibling::tei:locus)">
      <br />
    </xsl:if>
  </xsl:template>

  <!-- Bibliographie -->

  <xsl:variable name="bib-sections">
    <section type="lit" caption="[:de]Literatur:[:en]References:[:]"/>
    <section type="cat" caption="[:de]Kataloge:[:en]Catalogues:[:]"/>
    <section type="abb" caption="[:de]Abbildungen:[:en]Images:[:]"/>
    <section type="cap" caption="[:de]Projektspezifische Referenzen:[:en]Project-specific references:[:]"/>
  </xsl:variable>

  <xsl:template match="tei:additional/tei:listBibl">
    <xsl:call-template name="page-break"/>

    <xsl:variable name="this" select="."/>

    <div class="tei-listBibl tei-listBibl-not-type">
      <h5 id="{cap:part-id ()}_bibliography">
        <xsl:text>[:de]Bibliographie[:en]Bibliography[:]</xsl:text>
      </h5>
      <xsl:for-each select="exsl:node-set ($bib-sections)/*">
        <xsl:if test="normalize-space ($this/tei:listBibl[@type=current()/@type])">
          <xsl:text>&#x0a;&#x0a;</xsl:text>
          <div class="tei-listBibl tei-listBibl-{./@type}">
            <h6><xsl:value-of select="./@caption"/></h6>
            <ul>
              <xsl:apply-templates select="$this/tei:listBibl[@type=current()/@type]"/>
            </ul>
          </div>
        </xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="tei:listBibl">
    <xsl:apply-templates select="tei:bibl[not (@resp='capit')]"/>
  </xsl:template>

  <xsl:template name="bibl-a">
    <xsl:choose>
      <xsl:when test="@corresp">
        <a class="internal bib" href="{$biblio}{@corresp}"
           title="[:de]Zum bibliographischen Eintrag[:en]To the bibliographic entry[:]">
          <xsl:apply-templates />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:bibl">
    <xsl:choose>
      <xsl:when test="parent::tei:listBibl">
        <li class="tei-bibl">
          <xsl:call-template name="bibl-a"/>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="bibl-a"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Sonstige Elemente -->

  <xsl:template match="tei:facsimile">
    <xsl:if test="starts-with (tei:graphic/@url, 'http')">
      <div class="tei-facsimile">
        <xsl:text>[:de]Digitalisat verfügbar bei[:en]Digital image available at[:] </xsl:text>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:graphic">
    <xsl:if test="starts-with (@url, 'http')">
      <xsl:variable name="url" select="substring-after (@url, '://')"/>
      <xsl:variable name="target" select="exsl:node-set ($tei-graphic-targets)/item[contains ($url, @key)]"/>
      <a class="external" href="{@url}" title="{string ($target/title)}" target="_blank">
        <xsl:value-of select="$target/caption"/>
      </a>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:note[not(@type)]"> [<xsl:apply-templates/>] </xsl:template>

  <xsl:template match="tei:note[@type='filiation']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:adminInfo/tei:note[@resp='KU']">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:msItem/tei:note[@type='annotation']">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:note[@type='corr']">
    <img onclick="javascript:toggle('{generate-id()}')"
         src="/cap/publ/material/attention.png"
         title="Bitte klicken Sie hier, um die Anmerkung bzw. Korrektur anzuzeigen."/>
    <span id="{generate-id()}" class="tei-note-corr" style="display: none">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:list">
    <ul class="tei-list dash">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="tei:item">
    <li class="tei-item">
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="tei:anchor">
    <a id="{@xml:id}" />
  </xsl:template>

  <xsl:template match="tei:lb">
    <br/>
  </xsl:template>

  <xsl:template match="tei:emph">
    <span class="tei-emph italic">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:hi">
    <xsl:choose>
      <xsl:when test="@rend='italic'">
        <span class="tei-hi rend-italic italic">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@rend='smallcaps'">
        <span class="tei-hi rend-smallcaps smallcaps">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@rend='super' and (ancestor::tei:bibl or ancestor::tei:formula)">
        <sup class="tei-hi rend-super">
          <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <span class="tei-hi">
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
