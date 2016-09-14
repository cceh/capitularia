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
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">

  <!-- allgemeine Parameter -->
  <xsl:variable name="vParams" select="document('biblioParams.xml')"/>

  <!-- use values: all/published/unpublished -->
  <xsl:param name="pShow">all</xsl:param>

  <!-- use values: y/n -->
  <xsl:param name="pEmbedded">y</xsl:param>

  <!-- use values: shortcode/url/none -->
  <xsl:param name="pPrivateUrlsAs">shortcode</xsl:param>

  <!-- use values: all/edi/lit/cat -->
  <xsl:param name="pCategory">all</xsl:param>

  <!-- use values: [chunk number].[chunk size] default: 0.0 (=show all) -->
  <xsl:param name="pSplit">0.0</xsl:param>

  <!-- y/n Do not use str:encode-uri because oxygen doesn't like it -->
  <xsl:param name="pOxygen">n</xsl:param>

  <xsl:variable name="config">
    <section rel_text="Edition">
      <h4>[:de]Editionen und Übersetzungen[:en]Editions and translations[:]</h4>
      <id>edition</id>
      <path>q</path>
    </section>
    <section rel_text="Literatur">
      <h4>[:de]Literatur[:en]Literature[:]</h4>
      <id>lit</id>
      <path>lit</path>
    </section>
    <section rel_text="Katalog">
      <h4>[:de]Handschriftenkataloge[:en]Manuscript catalogues[:]</h4>
      <id>cat</id>
      <path>kat</path>
    </section>
    <section rel_text="Sonstige">
      <h4>[:de]Sonstige[:en]Other[:]</h4>
      <id>other</id>
      <path>Sonstige</path>
    </section>
  </xsl:variable>

  <xsl:variable name="vDigitalisatePfad">
    <!--<xsl:text>../hss-scans</xsl:text>-->
    <xsl:value-of select="$vParams/list[@xml:id='paths']/item[title = 'Digitalisate']/path" />
  </xsl:variable>

  <xsl:variable name="vTransformationenPfad">
    <!--<xsl:text>../hss-scans</xsl:text>-->
    <xsl:value-of select="$vParams/list[@xml:id='paths']/item[title = 'Transformationen']/path" />
  </xsl:variable>

  <!-- BAUSTELLEN/ToDO:
       * xsl:key einbauen?! notwendig??
       * ...
  -->

  <func:function name="cap:has-text">
    <xsl:param name="n" select="." />

    <func:result select="boolean (normalize-space ($n) and normalize-space ($n) != '-')" />
  </func:function>

  <func:function name="cap:is-known">
    <xsl:param name="n" select="." />

    <func:result select="boolean (normalize-space ($n) and normalize-space ($n) != 'Unbekannt')" />
  </func:function>

  <func:function name="cap:join">
    <xsl:param name="nodes" />
    <xsl:param name="sep"   select="', '" />

    <func:result>
      <xsl:for-each select="$nodes">
	<xsl:if test="normalize-space (.)">
          <xsl:copy-of select="."/>
          <xsl:if test="not (contains (concat (' ', @class, ' '), ' joiner ')) and position () &lt; last ()">
            <xsl:value-of select="$sep" />
          </xsl:if>
	</xsl:if>
      </xsl:for-each>
    </func:result>
  </func:function>

  <func:function name="cap:first-letter">
    <!--
        Get the first letter where to file the biblStruct
    -->
    <xsl:param name="b"/>

    <xsl:variable name="r">
      <xsl:choose>
        <xsl:when test="$b//tei:idno[@type='short_title']">
          <xsl:value-of select="substring ($b//tei:idno[@type='short_title'], 1, 1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>_</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <func:result select="translate ($r,
                         'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžš‌​œ',
                         'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠ‌​Œ'
                         )"/>
  </func:function>

  <func:function name="cap:config">
    <!--
        Get the first letter where to file the biblStruct
    -->
    <xsl:param name="section"/>
    <xsl:param name="option"/>

    <func:result>
      <xsl:copy-of select="exsl:node-set ($config)/section[@rel_text = $section]/*[local-name () = $option]"/>
    </func:result>
  </func:function>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$pEmbedded='y'">
        <div id="bibliographie">
          <xsl:apply-templates select="//tei:listBibl" />
        </div>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <title>Bibliographie Capitularia</title>
            <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            <meta content="Bibliographie" name="Eintraege"/>
          </head>
          <body>
            <xsl:apply-templates select="//tei:listBibl" />
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:listBibl">
    <xsl:variable name="n" select="." />

    <xsl:for-each select="exsl:node-set ($config)/section">
      <xsl:variable name="rel_text">
	<xsl:value-of select="@rel_text"/>
      </xsl:variable>

      <xsl:variable name="bibls_in_section" select="$n/tei:biblStruct[tei:note[@type = 'rel_text'][string() = $rel_text]]"/>

      <xsl:if test="normalize-space ($bibls_in_section)">
	<div>
	  <h4 id="{id}"><xsl:copy-of select="h4/node()"/></h4>
	  <table>
	    <tbody>

              <xsl:choose>
		<xsl:when test="$pShow = 'published'">
		  <xsl:apply-templates select="$bibls_in_section[@status = 'published']">
		    <xsl:sort select="tei:*/tei:idno[@short_title]"/>
		  </xsl:apply-templates>
		</xsl:when>

		<xsl:when test="$pShow = 'unpublished'">
		  <xsl:apply-templates select="$bibls_in_section[not (@status = 'published')]">
		    <xsl:sort select="tei:*/tei:idno[@short_title]"/>
		  </xsl:apply-templates>
		</xsl:when>

		<xsl:otherwise>
		  <!-- published & unpublished anzeigen -->
		  <xsl:apply-templates select="$bibls_in_section">
		    <xsl:sort select="tei:*/tei:idno[@short_title]"/>
		  </xsl:apply-templates>
		</xsl:otherwise>
              </xsl:choose>
	    </tbody>
	  </table>
	</div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:biblStruct">
    <xsl:call-template name="preamble" />
    <tr>
      <td>
	<xsl:message>ERROR: biblStruct @type = <xsl:value-of select="@type"/></xsl:message>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="preamble">
    <xsl:variable name="rel_text">
      <xsl:value-of select="tei:note[@type='rel_text']"/>
    </xsl:variable>
    <xsl:variable name="first_letter">
      <xsl:value-of select="cap:first-letter (.)" />
    </xsl:variable>

    <xsl:if test="$first_letter != cap:first-letter (preceding-sibling::tei:biblStruct[1])">
      <tr class="alpha">
	<th id="{$first_letter}_{$rel_text}">
          <h5><xsl:value-of select="$first_letter" /></h5>
	</th>
      </tr>
    </xsl:if>

  </xsl:template>

  <xsl:template match="tei:p">
    <p class="tei-p">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="tei:hi[@rend]">
    <span class="tei-hi rend-{@rend}">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:title">
    <xsl:if test="cap:has-text ()">
      <span class="tei-title tei-title-{@type} tei-title-level-{@level}">
        <xsl:apply-templates />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:series">
    <xsl:if test="cap:has-text (.)">
      <span class="tei-series">
        <xsl:text> (</xsl:text>
        <xsl:variable name="res">
          <xsl:apply-templates select="tei:title"/>
          <xsl:apply-templates select="tei:biblScope[@unit='volume']"/>
          <xsl:apply-templates select="tei:biblScope[@unit='issue']"/>
        </xsl:variable>
        <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' ')"/>
        <xsl:text>)</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:biblScope">
    <xsl:if test="cap:has-text ()">
      <span class="tei-biblscope tei-biblscope-{@unit}">
        <xsl:choose>
          <xsl:when test="@unit = 'page'">
            <xsl:text>S. </xsl:text>
          </xsl:when>
          <xsl:when test="@unit = 'chapter'">
            <xsl:text>Kap. </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:monogr/tei:imprint/tei:pubPlace">
    <xsl:if test="cap:has-text ()">
      <xsl:if test="preceding-sibling::tei:pubPlace">
        <xsl:text> - </xsl:text>
      </xsl:if>
      <span class="tei-pubPlace">
	<xsl:apply-templates />
      </span>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:monogr/tei:edition">
    <xsl:if test="number (@n) > 1">
      <sup class="tei-edition">
        <xsl:value-of select="@n"/>
      </sup>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:monogr/tei:imprint/tei:date">
    <span class="tei-date">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <xsl:template match="tei:note[@type='role']">
    <xsl:if test="cap:has-text ()">
      <span class="tei-note tei-note-{@type}">
	<xsl:text> (</xsl:text>
	<xsl:apply-templates />
	<xsl:text>)</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:note[@type = 'notes' or @type = 'reprint']">
    <xsl:if test="cap:has-text ()">
      <span class="tei-note tei-note-{@type}">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>]</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:idno[@type='URL']">
    <div class="tei-idno tei-idno-url">
      <xsl:text>URL: </xsl:text>
      <a target="_blank" href="{.}">
        <xsl:value-of select="."/>
      </a>
    </div>
  </xsl:template>

  <xsl:template match="tei:persName" mode="forenameFirst">
    <!-- "[forename] [surname]" -->
    <xsl:if test="tei:forename">
      <span class="tei-forename">
        <xsl:apply-templates select="tei:forename"/>
      </span>
    </xsl:if>
    <xsl:text> </xsl:text>
    <span class="tei-surname">
      <xsl:apply-templates select="tei:surname"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:persName" mode="surnameFirst">
    <!-- "[surname], [forename]" -->
    <span class="tei-surname">
      <xsl:apply-templates select="tei:surname"/>
    </span>
    <xsl:if test="tei:forename">
      <xsl:text>, </xsl:text>
      <span class="tei-forename">
        <xsl:apply-templates select="tei:forename"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:forename[preceding-sibling::tei:forename]">
    <!-- middlename / second forename -->
    <span class="tei-forename">
      <xsl:text> </xsl:text>
      <xsl:value-of select="substring (., 1, 1)"/>
      <xsl:text>.</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:author|tei:editor" mode="forenameFirst">
    <xsl:if test="cap:is-known ()">
      <span class="tei-{local-name ()}">
        <xsl:apply-templates select="tei:persName" mode="forenameFirst"/>
        <xsl:apply-templates select="tei:note[@type='role']"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:author|tei:editor" mode="surnameFirst">
    <xsl:if test="cap:is-known ()">
      <span class="tei-{local-name ()}">
        <xsl:apply-templates select="tei:persName" mode="surnameFirst"/>
	<xsl:choose>
	  <xsl:when test="local-name () = 'editor' and count (../tei:editor[cap:is-known ()]) &gt;= 4">
	    <xsl:text> et. al. (</xsl:text>
            <xsl:value-of select="following-sibling::tei:editor[last()]/tei:note[@type='role']"/>
	    <xsl:text>)</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
            <xsl:apply-templates select="tei:note[@type='role']"/>
	  </xsl:otherwise>
	</xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:author|tei:editor" mode="forenameFirst_noRole">
    <xsl:if test="cap:is-known ()">
      <span class="tei-{local-name ()}">
        <xsl:apply-templates select="tei:persName" mode="forenameFirst"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:idno[@type='short_title']">
    <xsl:variable name="vNoUnderlineIDNO" select="str:replace (., '_', ' ')" />

    <xsl:variable name="url">
      <xsl:value-of select="$vDigitalisatePfad"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="cap:config (../../tei:note[@type='rel_text'], 'path')"/>
      <xsl:text>/</xsl:text>
      <xsl:if test="$pOxygen != 'y'">
        <!-- => beim lokalen Testen auskommentieren => !FINDMICH! -->
        <xsl:value-of select="str:encode-uri(../../tei:note/@target, true())"/>
      </xsl:if>
    </xsl:variable>

    <div id="{string(.)}">
      <xsl:choose>
        <xsl:when test="$pPrivateUrlsAs = 'shortcode' and ../../tei:note/@target">
          <!-- SHORTCODE Inhalt nur an eingeloggte User gezeigt. -->
          <xsl:text>[logged_in]</xsl:text>
          <a href="{$url}" target="_blank"><xsl:value-of select="$vNoUnderlineIDNO" /></a>
          <xsl:text>[/logged_in]</xsl:text>
          <!-- SHORTCODE Inhalt nur an nicht eingeloggte User gezeigt. -->
          <xsl:text>[logged_out]</xsl:text>
          <span class="semibold"><xsl:value-of select="$vNoUnderlineIDNO" /></span>
          <xsl:text>[/logged_out]</xsl:text>
        </xsl:when>

        <xsl:when test="$pPrivateUrlsAs = 'url' and ../../tei:note/@target">
          <a href="{$url}" target="_blank" ><xsl:value-of select="$vNoUnderlineIDNO"/></a>
        </xsl:when>

        <xsl:otherwise>
          <span class="semibold"><xsl:value-of select="$vNoUnderlineIDNO"/></span>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="header">
    <xsl:param name="n" />

    <!-- Kurztitel -->
    <xsl:apply-templates select="$n/tei:idno[@type='short_title']"/>
  </xsl:template>

  <xsl:template name="editors">
    <xsl:param name="n" />

    <!-- Editoren et. al. -->
    <xsl:variable name="res">
      <xsl:choose>
	<xsl:when test="count ($n/tei:editor[cap:is-known ()]) &gt;= 4">
	  <xsl:apply-templates select="$n/tei:editor[cap:is-known ()][1]" mode="surnameFirst"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="$n/tei:editor" mode="surnameFirst"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <span>
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' / ')"/>
    </span>
  </xsl:template>

  <xsl:template name="authors">
    <xsl:param name="n" />

    <xsl:variable name="res">
      <xsl:apply-templates select="$n/tei:author" mode="surnameFirst"/>
    </xsl:variable>

    <span>
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' / ')"/>
    </span>
  </xsl:template>

  <xsl:template name="titles">
    <xsl:param name="n" />

    <xsl:variable name="res">
      <xsl:apply-templates select="$n/tei:title[@type='main']" />
      <xsl:apply-templates select="$n/tei:imprint/tei:biblScope[@unit='volume']" />
      <xsl:apply-templates select="$n/tei:title[@type='sub']" />
    </xsl:variable>

    <span>
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, '. ')"/>
    </span>
  </xsl:template>

  <xsl:template name="journal-titles">
    <xsl:param name="n" />

    <xsl:variable name="res">
      <span>in:</span>
      <xsl:apply-templates select="$n/tei:title[@type='main']" />
      <xsl:apply-templates select="$n/tei:imprint/tei:biblScope[@unit='volume']" />
      <xsl:apply-templates select="$n/tei:title[@type='sub']" />

      <span class="imprint">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="tei:monogr/tei:edition" />
        <xsl:apply-templates select="tei:monogr/tei:imprint/tei:date" />
        <xsl:text>) </xsl:text>
      </span>
    </xsl:variable>

    <span class="joiner">
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' ')"/>
    </span>
  </xsl:template>

  <xsl:template name="imprint">
    <xsl:param name="n" />

    <span class="imprint">
      <!-- Verlagsort -->
      <xsl:apply-templates select="$n/tei:imprint/tei:pubPlace" />

      <!-- Edition/Bandnummer -->
      <xsl:apply-templates select="$n/tei:edition" />

      <!-- Erscheinungsdatum -->
      <xsl:apply-templates select="$n/tei:imprint/tei:date" />
    </span>
  </xsl:template>

  <xsl:template name="pages">
    <xsl:param name="n" />

    <xsl:apply-templates select="$n/tei:imprint/tei:biblScope[@unit='chapter']" />
    <xsl:apply-templates select="$n/tei:imprint/tei:biblScope[@unit='page']" />
  </xsl:template>

  <xsl:template name="notes">
    <xsl:param name="n" />

    <!-- Anmerkungen -->
    <xsl:apply-templates select="tei:note[@type='reprint']"/>
    <xsl:apply-templates select="tei:note[@type='notes']"/>

    <!-- URL -->
    <xsl:apply-templates select="$n/tei:idno[@type='URL']"/>
  </xsl:template>

  <!-- book -->

  <xsl:template match="tei:biblStruct[@type='book']">
    <xsl:call-template name="preamble" />
    <tr class="bib-book">
      <td>
      <xsl:call-template name="header">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>

      <xsl:variable name="res">
        <xsl:call-template name="authors">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>

        <xsl:call-template name="titles">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>

        <!-- Reihenangabe -->
        <xsl:apply-templates select="tei:series" />

        <xsl:call-template name="imprint">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

      <xsl:call-template name="notes">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>
      </td>
    </tr>
  </xsl:template>

  <!-- book section -->

  <xsl:template match="tei:biblStruct[@type='bookSection']">
    <xsl:call-template name="preamble" />
    <tr class="bib-booksection">
      <td>
      <xsl:call-template name="header">
        <xsl:with-param name="n" select="tei:analytic" />
      </xsl:call-template>

      <xsl:variable name="res">
        <xsl:call-template name="authors">
          <xsl:with-param name="n" select="tei:analytic" />
        </xsl:call-template>

        <xsl:call-template name="titles">
          <xsl:with-param name="n" select="tei:analytic" />
        </xsl:call-template>

        <span class="joiner">in: </span>

        <!-- Namengruppe 2 -->
        <xsl:variable name="authors">
          <xsl:choose>
            <xsl:when test="cap:is-known (tei:monogr/tei:author) and cap:is-known (tei:monogr/tei:editor)">
              <!-- author & editor gemischt => Namensgruppe 2 nur author, Namensgruppe 3 nur editor -->
              <xsl:apply-templates select="tei:monogr/tei:author" mode="forenameFirst" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="editors">
		<xsl:with-param name="n" select="tei:monogr" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space ($authors)">
          <xsl:copy-of select="cap:join (exsl:node-set ($authors)/span, ' / ')"/>
          <xsl:text>, </xsl:text>
        </xsl:if>

        <!-- Titelgruppe 2 -->
        <xsl:call-template name="titles">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>

        <!-- Namengruppe 3 -->
        <xsl:if test="cap:is-known (tei:monogr/tei:author) and cap:is-known (tei:monogr/tei:editor)">
          <span class="joiner">hg. v. </span>
          <xsl:apply-templates select="tei:monogr/tei:editor" mode="forenameFirst_noRole" />
        </xsl:if>

        <!-- Reihenangabe -->
        <xsl:apply-templates select="tei:series" />

        <xsl:call-template name="imprint">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>

        <xsl:call-template name="pages">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

      <xsl:call-template name="notes">
        <xsl:with-param name="n" select="tei:analytic" />
      </xsl:call-template>
      </td>
    </tr>
  </xsl:template>

  <!-- article -->

  <xsl:template match="tei:biblStruct[@type='journalArticle']">
    <xsl:call-template name="preamble" />
    <tr class="bib-article">
      <td>
      <xsl:call-template name="header">
        <xsl:with-param name="n" select="tei:analytic" />
      </xsl:call-template>

      <xsl:variable name="res">
        <xsl:call-template name="authors">
          <xsl:with-param name="n" select="tei:analytic" />
        </xsl:call-template>

        <xsl:call-template name="titles">
          <xsl:with-param name="n" select="tei:analytic" />
        </xsl:call-template>

        <xsl:call-template name="journal-titles">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>

        <xsl:call-template name="pages">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

      <xsl:call-template name="notes">
        <xsl:with-param name="n" select="tei:analytic" />
      </xsl:call-template>
      </td>
    </tr>
  </xsl:template>

  <!-- web pub -->

  <xsl:template match="tei:biblStruct[@type='webPublication']">
    <xsl:call-template name="preamble" />
    <tr class="bib-webpub">
      <td>
      <xsl:call-template name="header">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>

      <xsl:variable name="res">
        <xsl:call-template name="authors">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>

        <xsl:call-template name="titles">
          <xsl:with-param name="n" select="tei:monogr" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

      <xsl:call-template name="notes">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
