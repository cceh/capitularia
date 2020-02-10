<?xml version="1.0" encoding="UTF-8"?>

<!--

Transforms:  $(BIB_DIR)/Bibliographie_Capitularia.xml -> $(CACHE_DIR)/lists/bib.html

URL: $(CACHE_DIR)/lists/bib.html /resources/biblio/

Target: lists $(CACHE_DIR)/lists/bib.html

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
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">

  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <!-- allgemeine Parameter -->

  <!-- use values: all/published/unpublished -->
  <xsl:param name="pShow">all</xsl:param>

  <!-- y/n: start with the outermost <div> tag or with <html> -->
  <xsl:param name="pEmbedded">y</xsl:param>

  <!-- shortcode/url/none: how to output urls to private content -->
  <xsl:param name="pPrivateUrlsAs">shortcode</xsl:param>

  <!-- one or more of: edi lit cat: which sections to output -->
  <xsl:param name="pCategories">edi lit cat</xsl:param>

  <!-- y/n Do not use str:encode-uri because oxygen/Saxon doesn't like it -->
  <xsl:param name="pOxygen">n</xsl:param>

  <xsl:variable name="vDigitalisatePfad">https://capitularia.uni-koeln.de/cap/publ/bibl</xsl:variable>

  <xsl:variable name="config">
    <section rel_text="Edition">
      <caption>[:de]Editionen und Übersetzungen[:en]Editions and translations[:]</caption>
      <id>edi</id>
      <path>q</path>
    </section>
    <section rel_text="Literatur">
      <caption>[:de]Literatur[:en]Literature[:]</caption>
      <id>lit</id>
      <path>lit</path>
    </section>
    <section rel_text="Katalog">
      <caption>[:de]Handschriften&#xad;kataloge[:en]Manuscript catalogues[:]</caption>
      <id>cat</id>
      <path>kat</path>
    </section>
    <section rel_text="Sonstige">
      <caption>[:de]Sonstige[:en]Other[:]</caption>
      <id>other</id>
      <path>Sonstige</path>
    </section>
  </xsl:variable>

  <func:function name="cap:has-text">
    <xsl:param name="n" select="." />

    <func:result select="boolean (normalize-space ($n) and normalize-space ($n) != '-')" />
  </func:function>

  <func:function name="cap:is-known">
    <xsl:param name="n" select="." />

    <func:result select="boolean (normalize-space ($n) and normalize-space ($n) != 'Unbekannt')" />
  </func:function>

  <xsl:variable name="apos">&apos;"</xsl:variable>
  <xsl:variable name="quotes">&apos;"</xsl:variable>
  <xsl:variable name="punct">.,:;!?</xsl:variable>

  <func:function name="cap:ends-with-punctuation">
    <xsl:param name="s" select="string (.)" />

    <xsl:variable name="s1" select="substring ($s, string-length ($s),     1)" />
    <xsl:variable name="s2" select="substring ($s, string-length ($s) - 1, 1)" />

    <func:result select="not (translate ($s1, $punct, '')) or not (translate ($s1, $quotes, '') or translate ($s2, $punct, ''))"/>
  </func:function>

  <func:function name="cap:join">
    <!--
        Join a node-set with a glue string, eg. <a><b><c> => <a>, <b>, <c>

        - glue is applied between nodes

        - glue2 is applied between nodes if the first node ends with punctuation

        Nodes with class=no-glue-after will get no glue applied after them.
        Nodes with class=no-glue-before will get no glue applied before them.
    -->
    <xsl:param name="nodes" />
    <xsl:param name="glue" select="', '" />
    <xsl:param name="glue2" select="', '" />

    <func:result>
      <xsl:for-each select="$nodes">
        <xsl:if test="normalize-space (.)">
          <xsl:copy-of select="."/>
          <xsl:if test="position () &lt; last ()">
            <xsl:if test="not (contains (concat (' ', @class, ' '), ' no-glue-after '))">
              <xsl:if test="not (contains (concat (' ', following-sibling::*[1]/@class, ' '), ' no-glue-before '))">
                <xsl:choose>
                  <xsl:when test="cap:ends-with-punctuation (.)">
                    <xsl:value-of select="$glue2" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$glue" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:if>
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
        <div id="bibliography">
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
            <div id="bibliography">
              <xsl:apply-templates select="//tei:listBibl" />
            </div>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:listBibl">
    <xsl:variable name="n" select="." />

    <xsl:for-each select="exsl:node-set ($config)/section">
      <xsl:if test="contains ($pCategories, id)">
        <xsl:variable name="rel_text">
          <xsl:value-of select="@rel_text"/>
        </xsl:variable>

        <xsl:variable name="bibls_in_section">
          <xsl:for-each select="$n/tei:biblStruct[tei:note[@type = 'rel_text'][string() = $rel_text]]">
            <xsl:sort select="tei:*/tei:idno[@short_title]"/>

            <xsl:choose>
              <xsl:when test="$pShow = 'published' and @status = 'published'">
                <xsl:copy-of select="."/>
              </xsl:when>
              <xsl:when test="$pShow = 'unpublished' and not (@status = 'published')">
                <xsl:copy-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="normalize-space ($bibls_in_section)">
          <div id="bib-section-{id}" class="bib-section">
            <h4 id="{id}"><xsl:copy-of select="caption/node()"/></h4>
            <table>
              <tbody>
                <!-- the /* avoids matching the root node of the node-set -->
                <xsl:apply-templates select="exsl:node-set ($bibls_in_section)/*" />
              </tbody>
            </table>
          </div>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
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
      <span class="tei-series no-glue-before">
        <xsl:text> (</xsl:text>
        <xsl:variable name="res">
          <xsl:apply-templates select="tei:title[@type='main']"/>
          <xsl:apply-templates select="tei:biblScope[@unit='volume']"/>
          <xsl:apply-templates select="tei:biblScope[@unit='issue']"/>
          <xsl:apply-templates select="tei:title[@type='sub']"/>
        </xsl:variable>
        <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' ', ' ')"/>
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
    <a class="tei-idno tei-idno-url external ssdone" target="_blank" href="{.}" title="{.}"></a>
  </xsl:template>

  <xsl:template match="tei:persName">
    <xsl:variable name="forenames">
      <xsl:apply-templates select="tei:forename"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="ancestor::tei:monogr and ancestor::tei:biblStruct[@type = 'bookSection']">
        <!-- Johann Wolfgang Goethe -->
        <xsl:if test="normalize-space (tei:forename)">
          <xsl:copy-of select="cap:join (exsl:node-set ($forenames)/*, ' ', ' ')"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <span class="tei-surname">
          <xsl:apply-templates select="tei:surname"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <!-- Goethe, Johann Wolfgang -->
        <span class="tei-surname">
          <xsl:apply-templates select="tei:surname"/>
        </span>
        <xsl:if test="normalize-space (tei:forename)">
          <xsl:text>, </xsl:text>
          <xsl:copy-of select="cap:join (exsl:node-set ($forenames)/*, ' ', ' ')"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:forename">
    <span class="tei-forename">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:author|tei:editor">
    <xsl:if test="cap:is-known ()">
      <span class="tei-{local-name ()}">
        <xsl:apply-templates select="tei:persName"/>
        <xsl:apply-templates select="tei:note[@type='role']"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:author|tei:editor" mode="no-role">
    <xsl:if test="cap:is-known ()">
      <span class="tei-{local-name ()}">
        <xsl:apply-templates select="tei:persName"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:idno[@type='short_title']">
    <xsl:variable name="vNoUnderlineIDNO" select="translate (., '_', ' ')" />

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

    <div id="{translate (., $apos, '_')}" class="bib-short-title">
      <xsl:choose>
        <xsl:when test="$pPrivateUrlsAs = 'shortcode' and ../../tei:note/@target">
          <!-- SHORTCODE Inhalt nur an eingeloggte User gezeigt. -->
          <xsl:text>[logged_in]</xsl:text>
          <a href="{$url}" target="_blank"><xsl:value-of select="$vNoUnderlineIDNO" /></a>
          <xsl:text>[/logged_in]</xsl:text>
          <!-- SHORTCODE Inhalt nur an nicht eingeloggte User gezeigt. -->
          <xsl:text>[logged_out]</xsl:text>
          <xsl:value-of select="$vNoUnderlineIDNO" />
          <xsl:text>[/logged_out]</xsl:text>
        </xsl:when>

        <xsl:when test="$pPrivateUrlsAs = 'url' and ../../tei:note/@target">
          <a href="{$url}" target="_blank" ><xsl:value-of select="$vNoUnderlineIDNO"/></a>
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of select="$vNoUnderlineIDNO"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="../tei:idno[@type='URL']"/>
    </div>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template name="header">
    <xsl:param name="n" />

    <!-- Kurztitel -->
    <xsl:apply-templates select="$n/tei:idno[@type='short_title']"/>
  </xsl:template>

  <xsl:template name="editors">
    <xsl:param name="n" />
    <xsl:param name="with-roles" select="true ()"/>

    <!-- Editoren et al. -->
    <xsl:variable name="res">
      <xsl:choose>
        <xsl:when test="count ($n/tei:editor[cap:is-known ()]) &gt;= 4">
          <span>
            <xsl:apply-templates select="$n/tei:editor[cap:is-known ()][1]"/>
            <xsl:text> et al.</xsl:text>
            <xsl:if test="$with-roles">
              <xsl:apply-templates select="$n/tei:editor[tei:note[@type='role'] and cap:is-known ()][last()]/tei:note[@type='role']"/>
            </xsl:if>
          </span>
        </xsl:when>
        <xsl:when test="$with-roles">
          <xsl:apply-templates select="$n/tei:editor"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$n/tei:editor" mode="no-role" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <span>
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' / ', ' / ')"/>
    </span>
  </xsl:template>

  <xsl:template name="authors">
    <xsl:param name="n" />

    <xsl:variable name="res">
      <xsl:apply-templates select="$n/tei:author"/>
    </xsl:variable>

    <span>
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' / ', ' / ')"/>
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
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, '. ', ' ')"/>
    </span>
  </xsl:template>

  <xsl:template name="journal-titles">
    <xsl:variable name="res">
      <span>in:</span>
      <xsl:apply-templates select="tei:monogr/tei:title[@type='main']" />
      <xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']" />
      <xsl:apply-templates select="tei:monogr/tei:title[@type='sub']" />

      <span class="imprint">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="tei:monogr/tei:edition" />
        <!-- do not print acces date (found in analytic web publications) -->
        <xsl:apply-templates select="tei:monogr/tei:imprint/tei:date[not (@type='access')]" />
        <xsl:text>) </xsl:text>
      </span>
    </xsl:variable>

    <span class="no-glue-after">
      <xsl:copy-of select="cap:join (exsl:node-set ($res)/*, ' ', ' ')"/>
    </span>
  </xsl:template>

  <xsl:template name="imprint">
    <span class="imprint">
      <xsl:apply-templates select="tei:monogr/tei:imprint/tei:pubPlace" />
      <xsl:apply-templates select="tei:monogr/tei:edition" />
      <xsl:apply-templates select="tei:monogr/tei:imprint/tei:date" />
    </span>
  </xsl:template>

  <xsl:template name="pages">
    <xsl:param name="n" />

    <xsl:apply-templates select="$n/tei:imprint/tei:biblScope[@unit='chapter']" />
    <xsl:apply-templates select="$n/tei:imprint/tei:biblScope[@unit='page']" />
  </xsl:template>

  <xsl:template name="notes">
    <xsl:param name="n" />
    <xsl:apply-templates select="tei:note[@type='reprint']"/>
    <xsl:apply-templates select="tei:note[@type='notes']"/>
  </xsl:template>

  <!-- biblStruct -->

  <xsl:template match="tei:biblStruct">
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
      <xsl:text>&#x0a;&#x0a;</xsl:text>
    </xsl:if>
    <tr class="bib-{@type}">
      <td>
        <xsl:choose>
          <xsl:when test="@type = 'book'">
            <xsl:call-template name="bib-book"/>
          </xsl:when>
          <xsl:when test="@type = 'bookSection'">
            <xsl:call-template name="bib-booksection"/>
          </xsl:when>
          <xsl:when test="@type = 'journalArticle'">
            <xsl:call-template name="bib-article"/>
          </xsl:when>
          <xsl:when test="@type = 'webPublication'">
            <xsl:choose>
              <xsl:when test="tei:analytic">
                <xsl:call-template name="bib-web-analytic"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="bib-web-monograph"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>ERROR: biblStruct @type = <xsl:value-of select="@type"/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <!-- book -->

  <xsl:template name="bib-book">
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

      <xsl:apply-templates select="tei:series" />

      <xsl:call-template name="imprint" />
    </xsl:variable>

    <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

    <xsl:call-template name="notes">
      <xsl:with-param name="n" select="tei:monogr" />
    </xsl:call-template>
  </xsl:template>

  <!-- book section -->

  <xsl:template name="bib-booksection">
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

      <span class="no-glue-after">in: </span>

      <!-- Namengruppe 2 -->
      <xsl:variable name="authors">
        <xsl:choose>
          <xsl:when test="cap:is-known (tei:monogr/tei:author) and cap:is-known (tei:monogr/tei:editor)">
            <!-- author & editor gemischt => Namensgruppe 2 nur author, Namensgruppe 3 nur editor -->
            <xsl:apply-templates select="tei:monogr/tei:author"/>
          </xsl:when>
          <xsl:when test="cap:is-known (tei:monogr/tei:author)">
            <xsl:apply-templates select="tei:monogr/tei:author"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="editors">
              <xsl:with-param name="n" select="tei:monogr" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="normalize-space ($authors)">
        <xsl:copy-of select="cap:join (exsl:node-set ($authors)/span, ' / ', ' / ')"/>
        <xsl:text>, </xsl:text>
      </xsl:if>

      <!-- Titelgruppe 2 -->
      <xsl:call-template name="titles">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>

      <!-- Namengruppe 3 -->
      <xsl:if test="cap:is-known (tei:monogr/tei:author) and cap:is-known (tei:monogr/tei:editor)">
        <span class="no-glue-after">hg. v. </span>
        <xsl:call-template name="editors">
          <xsl:with-param name="n" select="tei:monogr" />
          <xsl:with-param name="with-roles" select="false ()" />
        </xsl:call-template>
      </xsl:if>

      <!-- Reihenangabe -->
      <xsl:apply-templates select="tei:series" />

      <xsl:call-template name="imprint" />

      <xsl:call-template name="pages">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

    <xsl:call-template name="notes">
      <xsl:with-param name="n" select="tei:analytic" />
    </xsl:call-template>
  </xsl:template>

  <!-- article -->

  <xsl:template name="bib-article">
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

      <xsl:call-template name="journal-titles" />

      <xsl:call-template name="pages">
        <xsl:with-param name="n" select="tei:monogr" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

    <xsl:call-template name="notes">
      <xsl:with-param name="n" select="tei:analytic" />
    </xsl:call-template>
  </xsl:template>

  <!-- web pub (monograph) -->

  <xsl:template name="bib-web-monograph">
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

      <xsl:apply-templates select="tei:series" />
    </xsl:variable>

    <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

    <xsl:call-template name="notes">
      <xsl:with-param name="n" select="tei:monogr" />
    </xsl:call-template>
  </xsl:template>

  <!-- web pub (analytic) -->

  <xsl:template name="bib-web-analytic">
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

      <xsl:call-template name="journal-titles" />

      <xsl:apply-templates select="tei:series" />
    </xsl:variable>

    <xsl:copy-of select="cap:join (exsl:node-set ($res)/*)"/>

    <xsl:call-template name="notes">
      <xsl:with-param name="n" select="tei:analytic" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
