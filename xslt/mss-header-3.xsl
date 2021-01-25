<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs the header section of a single manuscript page.

Transforms: $(MSS_DIR)/%.xml      -> $(CACHE_DIR)/mss/%.header.html
Transforms: $(MSS_PRIV_DIR)/%.xml -> $(CACHE_DIR)/internal/mss/%.header.html

URL: $(CACHE_DIR)/mss/%.header.html          /mss/%/
URL: $(CACHE_DIR)/internal/mss/%.header.html /internal/mss/%/

Target: mss      $(CACHE_DIR)/mss/%.header.html
Target: mss_priv $(CACHE_DIR)/internal/mss/%.header.html

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

  <!-- For aestetical purposes only. -->
  <xsl:strip-space elements="msContents listBibl"/>

  <xsl:function name="cap:part-id">
    <xsl:param name="context" />
    <!-- Get the msPart part number as id. -->
    <xsl:variable name="pn">
      <xsl:if test="$context/ancestor-or-self::msPart">
        <xsl:value-of select="cap:make-id (concat ('id_', $context/ancestor-or-self::msPart[1]/@n))"/>
      </xsl:if>
    </xsl:variable>

    <xsl:sequence select="$pn"/>
  </xsl:function>

  <xsl:variable name="captions">
    <root xmlns="http://www.tei-c.org/ns/1.0">
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
    </root>
  </xsl:variable>

  <xsl:template match="/TEI">
    <div class="tei-TEI mss-header-xsl transkription-header">
      <xsl:apply-templates select="teiHeader/fileDesc"/>
      <xsl:call-template name="page-break"/>
    </div>
  </xsl:template>

  <!-- Ausgabe des Titels, Informationen zur haltenden Institution, Entstehungsgeschichte,
       allgemeine Anmerkungen, Bibliographie -->

  <xsl:template match="fileDesc">
    <div class="tei-fileDesc">
      <!-- The main title is already supplied by Wordpress.  Eventually add filiation here. -->
      <xsl:apply-templates select="titleStmt//note[@type='filiation']"/>

      <!-- "Beschreibung nach ..." -->
      <h4 id="description" class="tei-titleStmt">
        <xsl:text>[:de]</xsl:text>
        <xsl:value-of select="substring-before (concat (normalize-space (titleStmt/title[@type='sub' and @xml:lang='ger']), ' und Trans'), ' und Trans')"/>
        <xsl:text>[:en]</xsl:text>
        <xsl:value-of select="substring-before (concat (normalize-space (titleStmt/title[@type='sub' and @xml:lang='eng']), ' and trans'), ' and trans')"/>
        <xsl:text>[:]</xsl:text>
      </h4>

      <xsl:apply-templates select="sourceDesc"/>
    </div>
  </xsl:template>

  <xsl:template match="sourceDesc">
    <xsl:apply-templates select="msDesc"/>
    <xsl:apply-templates select="msDesc" mode="move-notes" />
  </xsl:template>

  <xsl:template match="msDesc">
    <div class="tei-msDesc">

      <div id="identification">
        <!-- Aufbewahrungsort -->
        <xsl:apply-templates select="msIdentifier"/>
        <!-- Digitalisat verfügbar bei -->
        <xsl:apply-templates select="/TEI/facsimile"/>
      </div>

      <xsl:call-template name="ms-desc"/>
      <xsl:call-template name="page-break"/>
      <xsl:call-template name="ms-part"/>

      <xsl:apply-templates select="msPart" />
      <xsl:apply-templates select="msPart" mode="move-notes" />

    </div>
  </xsl:template>

  <xsl:template match="msPart">
    <xsl:call-template name="page-break"/> <!-- Duplicated page-breaks are removed by css! -->

    <div class="tei-msPart">
      <h4 id="{cap:part-id (.)}">
        <xsl:value-of select="@n"/>
      </h4>

      <xsl:call-template name="ms-part"/>
    </div>
  </xsl:template>

  <xsl:template match="msDesc" mode="move-notes">
    <div class="footnotes-wrapper">
      <xsl:call-template name="ms-desc" />
      <xsl:call-template name="ms-part"/>
    </div>
  </xsl:template>

  <xsl:template match="msPart" mode="move-notes">
    <div class="footnotes-wrapper">
      <xsl:call-template name="ms-part" />
    </div>
  </xsl:template>

  <xsl:template name="ms-desc">
    <xsl:apply-templates select=".//filiation"                       mode="#current" />
    <xsl:apply-templates select=".//adminInfo/note[@resp='KU']"      mode="#current" />
    <xsl:apply-templates select=".//msItem/note[@type='annotation']" mode="#current" />
    <!-- Handschrift des Monats -->
    <xsl:apply-templates select=".//ref[@subtype='mom']" mode="#current" />
    <!-- Kapitular des Monats -->
    <xsl:apply-templates select=".//ref[@subtype='com']" mode="#current" />
  </xsl:template>

  <xsl:template name="ms-part">
    <!-- Entstehung und Überlieferung -->
    <xsl:apply-templates select="history[cap:non-empty (.)]" mode="#current" />
    <!-- Äußere Beschreibung -->
    <xsl:apply-templates select="physDesc[cap:non-empty (.)]" mode="#current" />
    <!-- Inhalte -->
    <xsl:apply-templates select="msContents[cap:non-empty (.)]" mode="#current" />
    <!-- Bibliographie -->
    <xsl:apply-templates select="additional/listBibl" mode="#current" />
  </xsl:template>

  <!-- Aufbewahrungsort -->

  <xsl:template match="msIdentifier">
    <div class="tei-msIdentifier">
      <h5>[:de]Aufbewahrungsort:[:en]Repository:[:]</h5>

      <xsl:value-of select="settlement"/>
      <br/>
      <xsl:value-of select="repository"/>
      <br/>
      <xsl:value-of select="collection"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="idno"/>

      <div>
        <xsl:if test="cap:non-empty (msName)">
          <div class="tei-msNames">
            <u>[:de]Name[:en]Name[:]:</u>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="msName"/>
          </div>
        </xsl:if>
        <xsl:apply-templates select="altIdentifier"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="msName">
    <xsl:if test="preceding-sibling::msName">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="altIdentifier"/>

  <xsl:template match="altIdentifier[@type='siglum']">
    <div class="tei-altIdentifier">
      <u>[:de]Sigle:[:en]Siglum[:]</u>
      <xsl:text> </xsl:text>
      <span class="italic">
        <xsl:value-of select="idno"/>
        <xsl:if test="cap:non-empty (note)">
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="note"/>
        </xsl:if>
      </span>
    </div>
  </xsl:template>

  <!-- Entstehung und Überlieferung -->

  <xsl:template match="history">
    <div class="tei-history">
      <h5 id="{cap:part-id (.)}_origin">
        <xsl:text>[:de]Entstehung und Überlieferung[:en]Origin and history[:]</xsl:text>
      </h5>
      <!-- Entstehung -->
      <xsl:apply-templates select="origin[normalize-space (.)]"/>
      <!-- Provenienz -->
      <xsl:apply-templates select="provenance[normalize-space (.)]"/>
      <!-- Anmerkung -->
      <xsl:apply-templates select="summary[normalize-space (.)]"/>
    </div>
  </xsl:template>

  <xsl:template match="origin|provenance|summary">
    <div class="tei-{local-name ()}">
      <h6><xsl:value-of select="cap:lookup-value ($captions, local-name ())"/></h6>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Äußere Beschreibung (Die Tabelle) -->

  <xsl:template match="physDesc">
    <xsl:call-template name="page-break"/>

    <div class="tei-physDesc">
      <h5 id="{cap:part-id (.)}_description">
        <xsl:text>[:de]Äußere Beschreibung[:en]Physical description[:]</xsl:text>
      </h5>

      <table class="tei-physDesc-table">
        <tbody>
          <!-- Material -->
          <xsl:apply-templates select="objectDesc/supportDesc/support"/>
          <!-- Umfang -->
          <xsl:apply-templates select="objectDesc/supportDesc/extent"/>
          <!-- Maße und Schriftraum -->
          <xsl:apply-templates select="objectDesc/supportDesc/extent/dimensions" mode="dimensions"/>
          <!-- Lagen -->
          <xsl:apply-templates select="objectDesc/supportDesc/collation[normalize-space (.)]"/>
          <!-- Zustand -->
          <xsl:apply-templates select="objectDesc/supportDesc/condition[normalize-space (.)]"/>
          <!-- Zeilen -->
          <xsl:apply-templates select="objectDesc/layoutDesc/layout[@writtenLines]"/>
          <!-- Spalten -->
          <xsl:apply-templates select="objectDesc/layoutDesc/layout[@columns]"/>
          <!-- Schrift -->
          <xsl:apply-templates select="scriptDesc[normalize-space (.)]"/>
          <!-- Schreiber -->
          <xsl:apply-templates select="handDesc[normalize-space (.)]"/>
          <!-- Ausstattung -->
          <xsl:apply-templates select="decoDesc[normalize-space (.)]"/>
          <!-- Einband -->
          <xsl:apply-templates select="bindingDesc[normalize-space (.)]"/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="support|condition|layout[@writtenLines]|scriptDesc|handDesc|decoDesc|binding">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, concat (local-name (), @type))"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="extent">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, 'extent')"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="dimensions"/>

  <xsl:template match="dimensions" mode="dimensions">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, concat ('dimensions-', @type))"/>
      </th>
      <td class="text">
        <xsl:if test="@precision">
          <xsl:text>ca. </xsl:text>
        </xsl:if>
        <xsl:value-of select="concat (height, ' × ', width, ' mm')"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="collation">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, 'collation')"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
        <xsl:apply-templates select="formula"    mode="formula"/>
        <xsl:apply-templates select="catchwords" mode="formula"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="layout[@columns]">
    <tr>
      <th class="value">
        <xsl:value-of select="cap:lookup-value ($captions, 'layout-columns')"/>
      </th>
      <td class="text">
        <xsl:apply-templates/>
        <xsl:if test="not (cap:non-empty (.))">
          <xsl:value-of select="@columns"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="formula|catchwords"/>

  <xsl:template match="formula|catchwords" mode="formula">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Inhalte -->

  <xsl:template match="msContents">
    <xsl:call-template name="page-break"/>

    <div class="tei-msContents">
      <h5 id="{cap:part-id (.)}_content">
        <xsl:text>[:de]Inhalte[:en]Contents[:]</xsl:text>
      </h5>

      <xsl:apply-templates select="summary[normalize-space (.)]"/>

      <ul class="bare">
        <xsl:apply-templates select="msItem"/>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="msItem">
    <xsl:if test="@prev">
      <li class="tei-msItem">
        <a class="internal" target="_blank" href="{$mss}{replace (@prev, '_', '#')}"
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
        <a class="internal" target="_blank" href="{$mss}{replace (@next, '_', '#')}"
          title="[:de]Zum zugehörigen Teil (in einer anderen Handschrift)[:en]To the corresponding part in another manuscript[:]">
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="msItem[@corresp]//title" priority="2.0">
    <!-- get the first of multiple corresp
         FIXME: how should we handle multiple corresps? -->
    <xsl:variable name="corresp"
                  select="substring-before (concat (ancestor::msItem/@corresp, ' '), ' ')" />

    <xsl:variable name="path">
      <xsl:choose>
        <xsl:when test="starts-with ($corresp, 'BK.')">
          <xsl:value-of select="concat ('/bk/', $corresp)" />
        </xsl:when>
        <xsl:when test="starts-with ($corresp, 'Mordek.')">
          <xsl:value-of select="concat ('/mordek/', $corresp)" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="if-visible-then-else">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="then">
        <a class="rend-semibold" href="{$path}" title="{cap:human-readable-siglum ($corresp)}">
          <xsl:apply-templates/>
        </a>
      </xsl:with-param>
      <xsl:with-param name="else">
        <span class="rend-semibold" title="{cap:human-readable-siglum ($corresp)}">
          <xsl:apply-templates/>
        </span>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="msItem//title[@corresp]" priority="3.0">
    <!-- New version to handle explicit @corresp on title -->

    <xsl:variable name="path">
      <xsl:choose>
        <xsl:when test="starts-with (@corresp, 'BK.')">
          <xsl:value-of select="concat ('/bk/', @corresp)" />
        </xsl:when>
        <xsl:when test="starts-with (@corresp, 'Mordek.')">
          <xsl:value-of select="concat ('/mordek/', @corresp)" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="if-visible-then-else">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="then">
        <a class="rend-semibold" href="{$path}" title="{cap:human-readable-siglum (@corresp)}">
          <xsl:apply-templates/>
        </a>
      </xsl:with-param>
      <xsl:with-param name="else">
        <span class="rend-semibold" title="{cap:human-readable-siglum (@corresp)}">
          <xsl:apply-templates/>
        </span>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="msItem//title">
    <span class="rend-semibold">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="msItem//locus">
    <span class="rend-semibold">
      <xsl:if test="@target">
        <a class="internal" href="{$mss}{replace (@target, '_', '#')}"
           target="_blank"
           title="[:de]Zur korrespondierenden Handschrift[:en]To the corresponding manuscript[:]">
          <xsl:apply-templates/>
        </a>
      </xsl:if>
      <xsl:if test="not (@target)">
        <xsl:apply-templates/>
      </xsl:if>
      <xsl:if test="cap:non-empty (following-sibling::*[1][self::locus])">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </span>
    <xsl:if test="not (following-sibling::locus)">
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

  <xsl:template match="additional/listBibl">
    <xsl:call-template name="page-break"/>

    <xsl:variable name="this" select="."/>

    <div class="tei-listBibl tei-listBibl-not-type">
      <h5 id="{cap:part-id (.)}_bibliography">
        <xsl:text>[:de]Bibliographie[:en]Bibliography[:]</xsl:text>
      </h5>
      <xsl:for-each select="$bib-sections/*">
        <xsl:if test="cap:non-empty ($this/listBibl[@type=current()/@type])">
          <xsl:text>&#x0a;&#x0a;</xsl:text>
          <div class="tei-listBibl tei-listBibl-{./@type}">
            <h6><xsl:value-of select="./@caption"/></h6>
            <ul>
              <xsl:apply-templates select="$this/listBibl[@type=current()/@type]"/>
            </ul>
          </div>
        </xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="listBibl">
    <xsl:apply-templates select="bibl[not (@resp='capit')]"/>
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

  <xsl:template match="bibl">
    <xsl:choose>
      <xsl:when test="parent::listBibl">
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

  <xsl:template match="facsimile">
    <xsl:if test="graphic[starts-with (@url, 'http')]">
      <div class="tei-facsimile">
        <xsl:text>[:de]Digitalisat verfügbar bei[:en]Digital image available at[:] </xsl:text>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="graphic">
    <xsl:if test="starts-with (@url, 'http')">
      <xsl:variable name="url" select="substring-after (@url, '://')"/>
      <xsl:variable name="target" select="$tei-graphic-targets/root/item[contains ($url, @key)]"/>
      <a class="external" href="{@url}" title="{string ($target/title)}" target="_blank">
        <xsl:value-of select="$target/caption"/>
      </a>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note[not(@type)]"> [<xsl:apply-templates/>] </xsl:template>

  <xsl:template match="note[@type='filiation']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="adminInfo/note[@resp='KU']">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="msItem/note[@type='annotation']">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="note[@type='corr']">
    <span class="tei-note annotation annotation-editorial annotation-corr" data-shortcuts="0"
          data-note-id="{generate-id()}" />
  </xsl:template>

  <xsl:template match="note[@type='corr']" mode="move-notes">
    <div id="{generate-id()}-content" class="annotation-content">
      <div class="annotation-text">
        <xsl:apply-templates/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="text ()" mode="move-notes">
  </xsl:template>

  <xsl:template match="p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="list">
    <ul class="tei-list dash">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="item">
    <li class="tei-item">
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="anchor">
    <a id="{@xml:id}" />
  </xsl:template>

  <xsl:template match="lb">
    <br/>
  </xsl:template>

  <xsl:template match="emph">
    <span class="tei-emph italic">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="hi">
    <span>
      <xsl:call-template name="handle-rend">
        <xsl:with-param name="extra-class" select="'tei-hi'"/>
      </xsl:call-template>
      <xsl:apply-templates />
    </span>
  </xsl:template>

</xsl:stylesheet>
