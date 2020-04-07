<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs the transcription section of a single manuscript page.
TEI -> HTML processing.

Transforms: $(CACHE_DIR)/mss/%.transcript.phase-1.xml          -> $(CACHE_DIR)/mss/%.transcript.html
Transforms: $(CACHE_DIR)/internal/mss/%.transcript.phase-1.xml -> $(CACHE_DIR)/internal/mss/%.transcript.html

URL: $(CACHE_DIR)/mss/%.transcript.html          /mss/%/
URL: $(CACHE_DIR)/internal/mss/%.transcript.html /internal/mss/%/

Target: mss      $(CACHE_DIR)/mss/%.transcript.html
Target: mss_priv $(CACHE_DIR)/internal/mss/%.transcript.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <!--
      This is the new series of stylesheets that generate the transcription
      section of the manuscript pages on the wordpress site.  It replaces the
      transkription_PublWP* series of stylesheets.

      @author: MP
  -->
  <xsl:param name="title" select="'[:de]Transkription[:en]Transcription[:]'"/>

  <xsl:include href="common-3.xsl"/>      <!-- common templates and functions -->
  <xsl:include href="common-html.xsl"/>   <!-- common templates and functions -->

  <!-- Needed for the correct determination of the word around an editorial
       intervention. -->
  <xsl:strip-space elements="tei:subst tei:choice"/>

  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <xsl:template match="/TEI">
    <!-- transkription-body is a flag for the post-processor -->
    <div class="tei-TEI mss-transcript-xsl transkription-body">
      <xsl:apply-templates select="text"/>
    </div>
  </xsl:template>

  <xsl:template match="text">
    <div class="tei-text">
      <h4 id="transcription"><xsl:value-of select="$title"/></h4>

      <xsl:apply-templates select="front"/>
      <xsl:apply-templates select="/TEI/teiHeader/fileDesc/sourceDesc"/>

      <!-- This is for automatically generating the sidebar menu,
           not for users' eyes. -->
      <div id="inhaltsverzeichnis" style="display: none">
        <!-- The following id will not function as target since display: none.
             The real id we jump to is down below. -->
        <a data-level="5" href="#start-of-text">
          [:de]Inhalt (Rubriken)[:en]Contents (Rubrics)[:]
        </a>
        <xsl:apply-templates select="front/div[@type='content']" mode="toc"/>
        <a data-level="5" href="#start-of-text">
          [:de]Inhalt (BK-Nummern)[:en]Contents (BK-Nos.)[:]
        </a>
      </div>

      <xsl:call-template name="page-break" />
      <xsl:apply-templates select="body"/>
    </div>
  </xsl:template>

  <xsl:template match="encodingDesc">
    <div class="italic tei-encodingDesc">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="front">
    <div class="tei-front">
      <h5 id="editorial-preface"
          data-cap-dyn-menu-caption="[:de]Editorische Vorbemerkung[:en]Editorial Preface[:]">
        [:de]Editorische Vorbemerkung zur Transkription[:en]Editorial Preface to the Transcription[:]
      </h5>
      <xsl:apply-templates select="/TEI/teiHeader/encodingDesc"/>
      <xsl:apply-templates select="./div[normalize-space (.) and not (@type='content')]" />
    </div>
  </xsl:template>

  <xsl:template match="body">
    <!-- This is the target for the "Contents *" links in the sidebar. -->
    <div class="tei-body" id="start-of-text">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="sourceDesc" /><!-- overridden in transkription_CTE.xsl -->
  <xsl:template match="projectDesc"/>
  <xsl:template match="editorialDecl"/>
  <xsl:template match="revisionDesc"/>

  <xsl:template match="front/div">
    <div class="tei-front-div">
      <h6>
        <xsl:choose>
          <xsl:when test="@type='mshist'">       Zur Handschrift</xsl:when>
          <xsl:when test="@type='scribe'">       Schreiber</xsl:when>
          <xsl:when test="@type='letters'">      Buchstabenformen</xsl:when>
          <xsl:when test="@type='abbreviations'">Abkürzungen</xsl:when>
          <xsl:when test="@type='punctuation'">  Interpunktion</xsl:when>
          <xsl:when test="@type='structure'">    Gliederungsmerkmale</xsl:when>
          <xsl:when test="@type='annotations'">  Benutzungsspuren</xsl:when>
          <xsl:when test="@type='other'">        Sonstiges</xsl:when>
        </xsl:choose>
      </h6>

      <xsl:apply-templates select="p"/>
    </div>
  </xsl:template>

  <!-- Das strukturierte Inhaltsverzeichnis in der Sidebar wird
       vorläufig aus einem nur zu diesem Zwecke angelegten div
       erzeugt.  TODO: Struktur irgendwie aus dem Haupttext
       ableiten. -->

  <xsl:template match="list" mode="toc">
    <ul>
      <xsl:apply-templates select="item" mode="toc"/>
    </ul>
  </xsl:template>

  <xsl:template match="item" mode="toc">
    <li class="toc">
      <a href="{ptr/@target}" data-level="{count (ancestor::item) + 6}">
        <xsl:apply-templates select="text ()"/>
      </a>
      <xsl:apply-templates select="list" mode="toc"/>
    </li>
  </xsl:template>

  <!--
      #############################################################################################
  -->

  <xsl:template match="p">
    <p class="tei-p">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="mentioned">
    <span class="tei-mentioned"><xsl:apply-templates /></span>
  </xsl:template>

  <xsl:template name="make-chapter-mark">
    <!-- Insert the [BK 42 c. 69] at the top of each chapter. -->
    <xsl:variable name="corresp">
      <xsl:value-of select="cap:make-human-readable-bk (cap:strip-ignored-corresp (@corresp))" />
    </xsl:variable>

    <xsl:if test="normalize-space ($corresp)"> <!-- is filtered by inscriptio incipit explicit etc. -->
      <div class="corresp">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$corresp"/>
        <xsl:text>]</xsl:text>
      </div>
      <xsl:text>&#x0a;&#x0a;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-sidebar-bk">
    <!-- Insert invisible markers for the sidebar generation algorithm.
    -->

    <xsl:param name="corresp" select="@corresp" />

    <xsl:variable name="id" select="generate-id ()" />

    <xsl:for-each select="tokenize ($corresp, '\s+')">
      <xsl:variable name="hr" select="cap:make-human-readable-bk (cap:strip-ignored-corresp (substring-before (concat (., '_'), '_')))" />
      <a id="{cap:make-id (.)}" class="milestone"></a>
      <xsl:if test="normalize-space ($hr) and not (contains (., 'Ansegis'))">
        <!-- an anchor for the exclusive use of the dynamic menu in the sidebar -->
        <a id="x-menu-{$id}" class="milestone"
           data-shortcuts="0" data-level="6"
           data-cap-dyn-menu-caption="{$hr}">
        </a>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="make-sidebar-bk-chapter">
    <!-- Insert invisible markers for the sidebar generation algorithm.
    -->

    <xsl:param name="corresp" select="@corresp" />

    <xsl:variable name="id" select="generate-id ()" />

    <xsl:for-each select="tokenize ($corresp, '\s+')">
      <xsl:variable name="hr" select="cap:make-human-readable-bk (cap:strip-ignored-corresp (.))" />
      <a id="{cap:make-id (.)}" class="milestone milestone-chapter"></a>
      <xsl:if test="normalize-space ($hr) and not (contains (., 'Ansegis'))">
        <!-- an anchor for the exclusive use of the dynamic menu in the sidebar -->
        <a id="x-menu-{$id}" class="milestone milestone-chapter"
           data-shortcuts="0" data-fold-menu-entry="1" data-level="7"
           data-cap-dyn-menu-caption="{$hr}">
        </a>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="cap:trailing">
    <!-- The cap:trailing function returns the nodes in the node set passed as
         the first argument that follow, in document order, the first node in
         the node set passed as the second argument. If the first node in the
         second node set is not contained in the first node set, then an empty
         node set is returned. If the second node set is empty, then the first
         node set is returned. -->
    <xsl:param name="nodes" />
    <xsl:param name="node"  />

    <xsl:variable name="end-node" select="$node[1]"/>
    <xsl:choose>
      <xsl:when test="not ($end-node) or not ($nodes)">
        <xsl:sequence select="$nodes"/>
      </xsl:when>
      <xsl:when test="count ($nodes | $end-node) != count ($nodes)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="count ($nodes[1] | $end-node) = 1">
        <xsl:sequence select="$nodes[position() > 1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="cap:trailing ($nodes[position() > 1], $end-node)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="footnotes-wrapper">
    <div class="footnotes-wrapper">
      <xsl:choose>
        <xsl:when test="self::anchor">
          <!-- end of capitulatio -->
          <xsl:apply-templates
              mode="move-notes"
              select="cap:trailing (
                      preceding-sibling::ab|../milestone,
                      ../tei:milestone[@unit = 'capitulatio' and @spanTo = concat ('#', current()/@xml:id)]
                      )" />
        </xsl:when>
        <xsl:otherwise>
          <!-- default: generate footnote bodies for immediately preceding ab-meta's
               and ab's linked to this one by @next -->
          <!-- Go back and get all ab's but stop on the first ab-text or anchor -->

          <xsl:apply-templates
              mode="move-notes"
              select="cap:trailing (
                      preceding-sibling::*[
                        self::ab or
                        self::anchor
                      ],
                      preceding-sibling::*[
                        self::ab[@type='text' and not (@next)] or
                        self::anchor[starts-with (@xml:id, 'capitulatio-finis')]
                      ][1])" />
        </xsl:otherwise>
      </xsl:choose>

      <!-- generate footnote bodies for this ab -->
      <xsl:apply-templates mode="move-notes" />
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="body//note">
  </xsl:template>

  <xsl:template match="note" mode="move-notes">
    <!-- Generate the footnote decorations, then call auto-note mode to generate
         the footnote body. -->
    <xsl:text>&#x0a;</xsl:text>
    <div id="{@xml:id}-content" class="annotation-content">
      <div class="annotation-text">
        <xsl:apply-templates />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="text ()" mode="move-notes">
  </xsl:template>

  <xsl:template match="body/ab[@type='meta-text']" priority="2">
    <xsl:if test="not (.//milestone[@unit='span' and @corresp and @spanTo])">
      <xsl:call-template name="make-sidebar-bk-chapter" />
    </xsl:if>
    <xsl:call-template name="make-chapter-mark" />

    <div lang="la">
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:if>
      <xsl:apply-templates/>
      <span> &#xa0;</span> <!-- Do not let footnotes escape the ab. -->
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <!-- If the manuscript ends here,
         or is followed by a capitulatio,
         or is an epilog or explicit. -->
    <xsl:if test="not (following-sibling::ab) or following-sibling::*[1][self::milestone[@unit='capitulatio']] or contains (@corresp, '_epilog') or contains (@corresp, 'explicit')">
      <xsl:call-template name="footnotes-wrapper"/>
      <xsl:call-template name="page-break" />
    </xsl:if>

  </xsl:template>

  <xsl:template match="body/ab[@type='text']" priority="2">
    <xsl:if test="not (.//milestone[@unit='span' and @corresp and @spanTo])">
      <xsl:call-template name="make-sidebar-bk-chapter" />
    </xsl:if>
    <xsl:call-template name="make-chapter-mark" />

    <div lang="la">
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:if>
      <xsl:apply-templates/>
      <span> &#xa0;</span> <!-- Do not let footnotes escape the ab. -->
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <xsl:choose>
      <xsl:when test="@next">
        <xsl:call-template name="hr" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="footnotes-wrapper"/>
        <xsl:call-template name="page-break" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="body/ab">
    <div>
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="lb">
    <xsl:if test="not (@break = 'no')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cb">
    <xsl:if test="not (@break = 'no')">
      <xsl:text> </xsl:text>
    </xsl:if>

    <xsl:variable name="cb_prefix">
      <xsl:choose>
        <!-- recto -->
        <xsl:when test="contains (@n, 'r')">
          <xsl:text>fol.</xsl:text>
        </xsl:when>
        <!-- verso -->
        <xsl:when test="contains (@n, 'v')">
          <xsl:text>fol.</xsl:text>
        </xsl:when>
        <!-- other -->
        <xsl:otherwise>
          <xsl:text>p.</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <span class="folio" data-shortcuts="0">
      <xsl:text>[cap_image_server id="</xsl:text>
      <xsl:value-of select="/TEI/@xml:id" />
      <xsl:text>" n="</xsl:text>
      <xsl:value-of select="@n" />
      <xsl:text>"]</xsl:text>
      <xsl:value-of select="concat ('[', $cb_prefix, '&#xa0;', @n, ']')"/>
      <xsl:text>[/cap_image_server]</xsl:text>
    </span>

    <xsl:if test="not (@break = 'no')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="milestone[not (@unit='span')]">
    <xsl:call-template name="make-sidebar-bk">
      <xsl:with-param name="corresp" select="@n" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="milestone[@unit='span' and @corresp and @spanTo]">
    <xsl:if test="@xml:id">
      <a id="{@xml:id}" class="milestone milestone-span milestone-span-start"/>
    </xsl:if>
    <xsl:call-template name="make-sidebar-bk-chapter" />
  </xsl:template>

  <xsl:template match="anchor[starts-with (@xml:id, 'capitulatio-finis')]">
    <!-- this anchor marks the end of a capitulatio -->
    <span class="milestone milestone-capitulatio-end" />
    <xsl:call-template name="footnotes-wrapper" />
    <xsl:call-template name="page-break" />
  </xsl:template>

  <xsl:template match="anchor">
    <!-- <span class="tei-anchor" data-note-id="{@xml:id}" /> -->
  </xsl:template>

  <!--
      Typ-Unterscheidung hinzufügen!!!

      Die einzelnen Typen sollen optisch unterscheidbar sein, ohne daß man Farbe
      verwenden muß.  Alle größer und fett; zusätzlich zur Unterscheidung
      verschiedene Größen/Schrifttypen?
  -->

  <xsl:template match="seg[@type='initial']">
    <span>
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:attribute name="title">
        <xsl:text>Initiale</xsl:text>
        <xsl:if test="contains(@type,'-')">
          <xsl:text>, Typ </xsl:text>
          <xsl:value-of select="substring-after(@type, '-')"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="seg">
    <xsl:element name="{if (@htmltag) then @htmltag else 'span'}">
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="hi">
    <xsl:element name="{if (@htmltag) then @htmltag else 'span'}">
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="cit">
    <xsl:apply-templates select="quote"/>
  </xsl:template>

  <xsl:template match="metamark">
    <!-- metamark vorerst ignorieren -->
    <span class="tei-metamark" />
  </xsl:template>

  <xsl:template match="span[@xml:id]">
    <span class="tei-span">
      <!-- "Erstreckungsfußnoten" -->

      <xsl:variable name="before">
        <xsl:value-of select="normalize-space(substring-before(text()[last()],' '))"/>
      </xsl:variable>
      <xsl:variable name="after">
        <xsl:value-of select="substring-after(text()[last()],' ')"/>
      </xsl:variable>

      <xsl:value-of select="node()[1]"/>
      <xsl:apply-templates select="add"/>
      <xsl:value-of select="$before"/>
      <xsl:apply-templates select="following-sibling::node()[1][name()='note']"/>
      <xsl:value-of select="$after"/>
    </span>
  </xsl:template>

  <xsl:template match="figure">
    <!--
        Neues Element: figure; wie verarbeiten? (bm 21.01.16) –

        Markiert eine Stelle, an der eine Miniatur/Illustration in der
        Handschrift steht.  Kommt nur selten vor; kann leer sein (evtl. mit
        graphic url) oder mit Text, der als Fußnote ausgegeben werden soll.
        Eigentlich brauchen wir nur ein Symbol für “Bild”, das an der
        entsprechenden Stelle erscheint. (bm 26.01.16) (NG, 27.01.16: Gibt es
        hierbei auch die “Hand-X-Problematik”?)
    -->

    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="figDesc">
          <xsl:apply-templates select="figDesc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[:de]Platzhalter für Bild[:en]Picture[:]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="graphic/@url">
        <a target="_blank" title="{$title}" href="graphic/@url">
          <!-- WordPress-Icon -->
          <span class="dashicons dashicons-format-image" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <!-- WordPress-Icon -->
        <span class="dashicons dashicons-format-image" title="{$title}" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
