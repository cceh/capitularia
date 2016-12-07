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

  <!--
      This is the new stylesheet that generates the transcription section of the
      manuscript pages. It replaces the transkription_PublWP* series of
      stylesheets.

      @authors: NG, MP
  -->

  <xsl:include href="common.xsl"/>                    <!-- common templates and functions -->
  <xsl:include href="mss-transcript-footnotes.xsl"/>  <!-- generation of footnotes / tooltips -->

  <!-- Needed for the correct determination of the word around an editorial
       intervention. -->
  <xsl:strip-space elements="tei:subst tei:choice"/>

  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <xsl:template match="/tei:TEI">
    <!-- transkription-body is a flag for the post-processor -->
    <div class="tei-TEI mss-transcript-xsl transkription-body">
      <xsl:apply-templates select="tei:text"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:text">
    <div class="tei-text">
      <h4 id="transcription">[:de]Transkription[:en]Transcription[:]</h4>

      <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:encodingDesc"/>
      <xsl:apply-templates select="tei:front"/>
      <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc"/>

      <!-- This is for automatically generating the sidebar menu,
           not for users' eyes. -->
      <div id="inhaltsverzeichnis" style="display: none">
        <h5 id="contents-rubrics">
          [:de]Inhalt (Rubriken)[:en]Contents (Rubrics)[:]
        </h5>
        <xsl:apply-templates select="id ('divContent')" mode="toc"/>
        <h5 id="contents-bknos">
          [:de]Inhalt (BK-Nummern)[:en]Contents (BK-Nos.)[:]
        </h5>
      </div>

      <xsl:call-template name="page-break" />
      <xsl:apply-templates select="tei:body"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:encodingDesc">
    <div class="italic tei-encodingDesc">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:front">
    <div class="tei-front">
      <h5 id="editorial-preface"
          data-cap-dyn-menu-caption="[:de]Editorische Vorbemerkung[:en]Editorial Preface[:]">
        [:de]Editorische Vorbemerkung zur Transkription[:en]Editorial Preface to the Transcription[:]
      </h5>
      <xsl:apply-templates select="tei:div[normalize-space (.)]" />
    </div>
  </xsl:template>

  <xsl:template match="tei:body">
    <div class="tei-body">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:sourceDesc" /><!-- overridden in transkription_CTE.xsl -->
  <xsl:template match="tei:projectDesc"/>
  <xsl:template match="tei:editorialDecl"/>
  <xsl:template match="tei:revisionDesc"/>

  <xsl:template match="tei:front/tei:div">
    <div class="italic tei-front-div">
      <h6>
        <xsl:choose>
          <xsl:when test="@type='scribe'">                       Schreiber</xsl:when>
          <xsl:when test="@type='lett' or @type='letters'">      Buchstabenformen</xsl:when>
          <xsl:when test="@type='abbr' or @type='abbreviation' or @type='abbreviations'">Abkürzungen</xsl:when>
          <xsl:when test="@type='punct' or @type='punctuation'"> Interpunktion</xsl:when>
          <xsl:when test="@type='struct' or @type='structure'">  Gliederungsmerkmale</xsl:when>
          <xsl:when test="@type='other'">                        Sonstiges</xsl:when>
          <xsl:when test="@type='mshist'">                       Zur Handschrift</xsl:when>
          <xsl:when test="@type='annotations'">                  Benutzungsspuren</xsl:when>
        </xsl:choose>
      </h6>

      <xsl:apply-templates select="tei:p"/>
    </div>
  </xsl:template>

  <!-- Das strukturierte Inhaltsverzeichnis in der Sidebar wird
       vorläufig aus einem nur zu diesem Zwecke angelegten div
       erzeugt.  TODO: Struktur irgendwie aus dem Haupttext
       ableiten. -->

  <xsl:template match="tei:list" mode="toc">
    <ul>
      <xsl:apply-templates select="tei:item" mode="toc"/>
    </ul>
  </xsl:template>

  <xsl:template match="tei:item" mode="toc">
    <li class="toc">
      <a href="{tei:ptr/@target}" data-level="{count (ancestor::tei:item)}">
        <xsl:apply-templates select="text ()"/>
      </a>
      <xsl:apply-templates select="tei:list" mode="toc"/>
    </li>
  </xsl:template>

  <!--
      #############################################################################################
  -->

  <xsl:template match="tei:p">
    <p class="tei-p">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:mentioned">
    <span class="regular tei-mentioned"><xsl:apply-templates /></span>
  </xsl:template>

  <xsl:template match="tei:body//tei:mentioned">
    <span class="italic tei-mentioned"><xsl:apply-templates /></span>
  </xsl:template>

  <xsl:template name="tCorresp">
    <!-- Transform 'BK.123_4' to 'BK 123 c. 4' and remove entries containing
         '_inscriptio' and '_incipit'. -->
    <xsl:variable name="search">
      <tei:item>.</tei:item>
      <tei:item>_</tei:item>
    </xsl:variable>

    <xsl:variable name="replace">
      <tei:item> </tei:item>
      <tei:item> c. </tei:item>
    </xsl:variable>

    <xsl:variable name="corresp">
      <xsl:for-each select="str:split (@corresp)">
        <xsl:if test="not (contains (., '_in'))">
          <xsl:value-of select="normalize-space (str:replace (., exsl:node-set ($search)/tei:item, exsl:node-set ($replace)/tei:item))"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="normalize-space ($corresp)">
      <xsl:text>&#x0a;</xsl:text>
      <div class="corresp">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="normalize-space ($corresp)"/>
        <xsl:text>]</xsl:text>
      </div>
      <xsl:text>&#x0a;&#x0a;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="footnotes-wrapper">
    <div class="footnotes-wrapper">
      <!-- generate footnote bodies for all immediately preceding ab-meta's and
           for this ab -->
      <xsl:apply-templates
          mode="auto-note-wrapper"
          select="set:trailing (preceding-sibling::tei:ab, preceding-sibling::tei:ab[@type='text'][1])"/>
      <xsl:apply-templates mode="auto-note-wrapper" />
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:body/tei:ab[@type='meta-text']">
    <xsl:call-template name="tCorresp" />

    <div class="ab ab-meta-text" lang="la" data-shortcuts="1">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <!-- Änderung von Wert red auf coloured wg. Anpassung an TRL # DS 22.02.16 -->
        <xsl:when test="@rend='coloured'">
          <xsl:attribute name="class">"ab ab-meta-text rend-red</xsl:attribute>
        </xsl:when>
        <xsl:when test="@rend='default'">
          <xsl:attribute name="class">"ab ab-meta-text rend-default</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <span> &#xa0;</span> <!-- Do not let footnotes escape the ab. -->
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <!-- sometimes the text ends with an ab meta. -->
    <xsl:if test="not (following-sibling::tei:ab)">
      <xsl:call-template name="footnotes-wrapper"/>
      <xsl:call-template name="page-break" />
    </xsl:if>

  </xsl:template>

  <xsl:template match="tei:body/tei:ab[@type='text']">
    <xsl:call-template name="tCorresp" />

    <div class="ab ab-text" lang="la" data-shortcuts="1">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
      <span> &#xa0;</span> <!-- Do not let footnotes escape the ab. -->
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <xsl:call-template name="footnotes-wrapper"/>

    <xsl:call-template name="page-break" />
  </xsl:template>

  <xsl:template match="tei:seg[@type = 'numDenom' or @type = 'num']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:lb">
    <xsl:if test="not (@break = 'no')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:cb">
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
      <xsl:value-of select="/tei:TEI/@xml:id" />
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

  <xsl:template match="tei:milestone">
    <!-- wird vom Sidebar-Menu benützt -->
    <span id="{cap:make-id (@n)}" class="milestone">
      <span style="display: none">
        <xsl:value-of select="str:replace (substring-before (concat (@n, '_'), '_'), '.', ' ')"/>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="tei:anchor[../tei:milestone[@unit = 'capitulatio' and @spanTo = concat ('#', current()/@xml:id)]]">
    <!-- this anchor marks the end of a capitulatio -->
    <span class="milestone milestone-capitulatio-end" />
    <xsl:call-template name="page-break" />
  </xsl:template>

  <!--
      Typ-Unterscheidung hinzufügen!!!

      Die einzelnen Typen sollen optisch unterscheidbar sein, ohne daß man Farbe
      verwenden muß.  Alle größer und fett; zusätzlich zur Unterscheidung
      verschiedene Größen/Schrifttypen?
  -->
  <xsl:template match="tei:seg[@type='initial']">
    <span class="initial">
      <xsl:choose>
        <xsl:when test="@rend='coloured'">
          <xsl:attribute name="class">initial rend-red</xsl:attribute>
        </xsl:when>
        <xsl:when test="@rend='default'">
          <xsl:attribute name="class">initial rend-default</xsl:attribute>
        </xsl:when>
      </xsl:choose>
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

  <xsl:template match="tei:seg[@type='versalie']">
    <span class="versalie">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type='numDenom'][@rend='coloured']">
    <span class="rend-coloured">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type='numDenom'][@rend='default']">
    <span class="rend-default">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type='numDenom'][not(@rend)]">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:seg[@type='num'][@rend='coloured']">
    <span class="rend-coloured">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type='num'][@rend='default']">
    <span class="rend-default">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type='num'][not(@rend)]">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:cit">
    <xsl:apply-templates select="tei:quote"/>
  </xsl:template>

  <xsl:template match="tei:metamark">
    <!-- metamark vorerst ignorieren -->
    <span class="tei-metamark" />
  </xsl:template>

  <xsl:template match="tei:hi[@rend='super']">
    <sup class="tei-hi rend-super">
      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='sub']">
    <sub class="tei-hi rend-sub">
      <xsl:apply-templates />
    </sub>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='coloured']">
    <!-- Baustelle: Klasse für "rote" span?! -->
    <span class="tei-hi rend-coloured">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='default']">
    <!-- Baustelle: Klasse für "default" span?! -->
    <span class="tei-hi rend-default">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='italic']">
    <span class="tei-hi rend-italic italic">
      <xsl:apply-templates />
    </span>
  </xsl:template>


  <xsl:template match="tei:span[@xml:id]">
    <span class="tei-span">
      <!-- "Erstreckungsfußnoten" -->

      <xsl:variable name="before">
        <xsl:value-of select="normalize-space(substring-before(text()[last()],' '))"/>
      </xsl:variable>
      <xsl:variable name="after">
        <xsl:value-of select="substring-after(text()[last()],' ')"/>
      </xsl:variable>

      <xsl:value-of select="node()[1]"/>
      <xsl:apply-templates select="tei:add"/>
      <xsl:value-of select="$before"/>
      <xsl:apply-templates select="following-sibling::node()[1][name()='note']"/>
      <xsl:value-of select="$after"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:figure">
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
        <xsl:when test="tei:figDesc">
          <xsl:apply-templates select="tei:figDesc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[:de]Platzhalter für Bild[:en]Picture[:]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="tei:graphic/@url">
        <a target="_blank" title="{$title}" href="tei:graphic/@url">
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
