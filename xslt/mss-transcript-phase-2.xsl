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

Phase 2 is a TEI to HTML conversion that:

 - converts all TEI elements into suitable HTML constructs,

 - puts all notes, generated and user-provided, out the main text flow and leaves
   <a>s at their place

Post processing:

The output of phase 2 will be processed by footnotes-post-processor.php.  That
script will move generated footnotes to the end of the word, eventually merging
multiple generated footnotes into one.  Generated footnotes will be suppressed
if there is a editorial note at the end of the word.  Isolated footnotes will be
joined to the preceding word.

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
      <xsl:copy-of select="@data-shortcuts|@class"/>
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

    <div class="glossa-nota-wrapper" data-shortcuts="0">
      <xsl:if test="contains (@rend, 'glossa')">
        <div class="glossa" title="[:de]Der Textabschnitt ist glossiert.[:en]The section is glossed.[:]">
        </div>
      </xsl:if>

      <xsl:if test="contains (@rend, 'nota')">
        <div class="nota" title="[:de]Der Textabschnitt ist annotiert.[:en]The section is annotated.[:]">
        </div>
      </xsl:if>
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <div class="corresp-wrapper" data-shortcuts="0">
      <xsl:if test="normalize-space ($corresp)"> <!-- is filtered by inscriptio incipit explicit etc. -->
        <div class="corresp">
          <xsl:text>[</xsl:text>
          <xsl:value-of select="$corresp"/>
          <xsl:text>]</xsl:text>
        </div>
      </xsl:if>
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>

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
      <!-- FIXME: this is the same id as for capitularies above. Should be different. -->
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

  <xsl:template name="footnotes-wrapper">
    <!-- Collect the footnotes that go into this footnote section.  The scope
         is all <ab>s between the previous <milestone type="footnotes-wrapper">
         and this node. -->

    <xsl:variable name="scope"
         select="preceding-sibling::milestone[@type='footnotes-wrapper' or @type='tei-body-start'][1]/following-sibling::ab intersect (self::ab | preceding-sibling::ab)" />

    <xsl:if test="count ($scope) > 0">
      <div class="footnotes-wrapper">
        <xsl:apply-templates mode="move-notes" select="$scope" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="body//note">
  </xsl:template>

  <xsl:template match="note" mode="move-notes">
    <!-- Generate the footnote decorations, then call auto-note mode to generate
         the footnote body. -->
    <xsl:text>&#x0a;</xsl:text>
    <div id="{@xml:id}-content" class="annotation-content">
      <div class="annotation-text">
        <xsl:copy-of select="@data-shortcuts"/>
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

    <xsl:if test="@next">
      <xsl:call-template name="hr" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="body/ab">
    <div>
      <xsl:copy-of select="@data-shortcuts|@data-note-id|@class"/>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="lb">
    <xsl:variable name="class">
      <xsl:if test="ancestor::ab
                    and normalize-space (string-join (following-sibling::node (), ''))
                    and normalize-space (string-join (preceding-sibling::node (), ''))">
        <xsl:text> tei-lb-show</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@break = 'no'">
        <span class="tei-lb{$class}" />
      </xsl:when>
      <xsl:otherwise>
        <span class="tei-lb{$class}"> </span>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="@n">
      <span class="line-number" data-shortcuts="0">[<xsl:value-of select="@n" />]</span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cb">
    <xsl:variable name="cb_space">
      <xsl:choose>
        <xsl:when test="@break = 'no'">
          <text/>
        </xsl:when>
        <xsl:otherwise>
          <text> </text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

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

    <span class="tei-cb" />

    <span class="folio" data-shortcuts="0">
      <xsl:value-of select="$cb_space"/>
      <xsl:text>[cap_image_server id="</xsl:text>
      <xsl:value-of select="/TEI/@xml:id" />
      <xsl:text>" n="</xsl:text>
      <xsl:value-of select="@n" />
      <xsl:text>"]</xsl:text>

      <xsl:value-of select="concat ('[', $cb_prefix, '&#xa0;', @n, ']')"/>

      <xsl:text>[/cap_image_server]</xsl:text>
      <xsl:value-of select="$cb_space"/>
    </span>
  </xsl:template>

  <xsl:template match="milestone">
    <xsl:choose>
      <xsl:when test="@type='page-break'">
        <xsl:call-template name="page-break" />
      </xsl:when>
      <xsl:when test="@type='footnotes-wrapper'">
        <xsl:call-template name="footnotes-wrapper" />
      </xsl:when>
      <xsl:when test="@type='tei-body-end'">
        <!-- just make sure we don't lose any footnotes -->
        <xsl:call-template name="footnotes-wrapper" />
        <xsl:call-template name="page-break" />
      </xsl:when>
      <xsl:when test="not (@unit='span')">
        <xsl:call-template name="make-sidebar-bk">
          <xsl:with-param name="corresp" select="@n" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@unit='span' and @corresp and @spanTo">
        <xsl:if test="@xml:id">
          <a id="{@xml:id}" class="milestone milestone-span milestone-span-start"/>
        </xsl:if>
        <xsl:call-template name="make-sidebar-bk-chapter" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="anchor[starts-with (@xml:id, 'capitulatio-finis')]">
    <!-- this anchor marks the end of a capitulatio -->
    <span class="milestone milestone-capitulatio-end" />
  </xsl:template>

  <xsl:template match="anchor" />

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
