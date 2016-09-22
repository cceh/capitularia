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
  <!-- libexslt does not support the regexp extension ! -->

  <!--
This stylesheet generates footnotes.

Footnotes come in 2 flavours:

- footnotes provided by the user in <tei:note> elements, and

- footnotes automatically generated from <tei:add>, <tei:del>,
<tei:subst>, etc. elements.

Footnote generation examples:

  co<subst>
      <del>r</del>
      <add>n</add>
    </subst>cordet

will generate markup equivalent to:

  con<note>korr. aus <mentioned>corcordet</mentioned></note>cordet

and

  ad<add @hand="X">d</add>endum

will generate markup equivalent to:

  ad<note>von Hand X korr. zu <mentioned>addendum</mentioned></note>endum


Complications:

There are 2 classes of hands:

- The hands A - W are considered original scribes and their changes
are displayed in the text.  The old text is put in the footnote.

- The hands X - Z are considered later hands and their changes are put
in the footnote while the old text is displayed.

There are 3 classes of corrections:

- corrections of phrases,

- corrections of a whole word, and

- corrections that change a part of a word.

The generated text of the footnote varies according to these cases.


Post processing:

The output of this stylesheet will be processed by footnotes-post-processor.php.
That script will move generated footnotes to the end of the word eventually
merging multiple generated footnotes into one.  Generated footnotes will be
suppressed if there is a editorial note at the end of the word.  Isolated
footnotes will be joined to the preceding word.

@authors: NG & MP

-->


  <func:function name="cap:word-before">
    <!--
        Get the word fragment before the element.

        Return the word fragment before the $e element.
    -->
    <xsl:param name="e"/>

    <xsl:variable name="before">
      <xsl:variable name="s">
        <xsl:value-of select="str:concat ($e/preceding::text ()[not (ancestor::tei:note)][position () &lt; 10])"/>
      </xsl:variable>
      <!-- str:tokenize does not return the empty token if string ends with whitespace. -->
      <xsl:if test="normalize-space (substring ($s, string-length ($s)))">
        <xsl:value-of select="str:tokenize ($s)[last ()]"/>
      </xsl:if>
    </xsl:variable>

    <func:result select="$before"/>
  </func:function>

  <func:function name="cap:word-after">
    <!--
        Get the word fragment after the element.

        Return the word fragment after the $e element.
    -->
    <xsl:param name="e"/>

    <xsl:variable name="after">
      <xsl:variable name="s">
        <xsl:value-of select="str:concat ($e/following::text ()[not (ancestor::tei:note)][position () &lt; 10])"/>
      </xsl:variable>
      <!-- str:tokenize does not return the empty token if string starts with whitespace. -->
      <xsl:if test="normalize-space (substring ($s, 1, 1))">
        <xsl:value-of select="str:tokenize ($s)[1]"/>
      </xsl:if>
    </xsl:variable>

    <func:result select="$after"/>
  </func:function>

  <func:function name="cap:count-char">
    <!-- Count how many of char c are in string s. -->
    <xsl:param name="s"/>
    <xsl:param name="c"/>

    <func:result select="number (string-length ($s) - string-length (translate ($s, $c, '')))"/>
  </func:function>

  <func:function name="cap:is-phrase">
    <!-- Test if the node contains a single word or a phrase. -->
    <xsl:param name="nodeset"/>

    <func:result select="contains (normalize-space (str:concat ($nodeset)), ' ')"/>
  </func:function>

  <func:function name="cap:shorten-phrase">
    <!-- Transform "phrase with more than five words" into "phrase with ... five words" -->
    <xsl:param name="nodeset"/>

    <xsl:variable name="nodes" select="str:split (str:concat ($nodeset))"/>
    <xsl:variable name="len" select="count ($nodes)"/>

    <xsl:choose>
      <xsl:when test="$len &gt; 5">
        <func:result select="concat ($nodes[1], ' ', $nodes[2], ' &#x2026; ', $nodes[$len - 1], ' ', $nodes[$len])"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="$nodeset"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="cap:get-hand">
    <!--
        Look for the closest @hand attribute.

        Look for @hand on self, parent::tei:subst, and
        parent::tei:subst/tei:add.
    -->
    <xsl:choose>
      <xsl:when test="@hand">
        <func:result select="@hand"/>
      </xsl:when>
      <xsl:when test="tei:add/@hand">
        <func:result select="tei:add/@hand"/>
      </xsl:when>
      <xsl:when test="parent::tei:subst/@hand">
        <func:result select="../@hand"/>
      </xsl:when>
      <xsl:when test="parent::tei:subst/tei:add/@hand">
        <func:result select="../tei:add/@hand"/>
      </xsl:when>
      <otherwise>
        <func:result select="''"/>
      </otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="cap:is-normal-hand">
    <!-- If these hands made corrections we display them in the
         text and put the old text in the apparatus. -->
    <xsl:param name="hand" select="cap:get-hand ()"/>
    <func:result select="normalize-space ($hand) and contains ('ABCDEFGHIJKLMNOPQRSTU', $hand)"/>
  </func:function>

  <func:function name="cap:is-later-hand">
    <!-- If these hands made corrections we put them in
         the apparatus and display the old text. -->
    <xsl:param name="hand" select="cap:get-hand ()"/>
    <func:result select="normalize-space ($hand) and contains ('XYZ', $hand)"/>
  </func:function>

  <xsl:template name="hand-blurb">
    <xsl:if test="cap:get-hand ()">
      <xsl:text> von Hand </xsl:text>
      <xsl:value-of select="cap:get-hand ()"/>
    </xsl:if>
    <xsl:if test="following-sibling::*[1][self::tei:metamark]">
      <xsl:text> mit Einfügungszeichen</xsl:text>
    </xsl:if>
    <xsl:if test="@rend='default' or tei:add/@rend='default'">
      <xsl:text> in Texttinte</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="plural">
    <!-- Get singular or plural of known terms. -->
    <xsl:param name="quantity" select="0" />
    <xsl:param name="unit"     select="unit"/>

    <xsl:variable name="terms">
      <tei:list unit="chars">
        <tei:item>Buchstabe</tei:item>
        <tei:item>Buchstaben</tei:item>
      </tei:list>

      <tei:list unit="words">
        <tei:item>Wort</tei:item>
        <tei:item>Wörter</tei:item>
      </tei:list>

      <tei:list unit="lines">
        <tei:item>Zeile</tei:item>
        <tei:item>Zeilen</tei:item>
      </tei:list>

      <tei:list unit="units">
        <tei:item>Einheit</tei:item>
        <tei:item>Einheiten</tei:item>
      </tei:list>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="number ($quantity) = 1">
        <xsl:value-of select="exsl:node-set ($terms)/tei:list[@unit=$unit]/tei:item[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="exsl:node-set ($terms)/tei:list[@unit=$unit]/tei:item[2]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      default mode

      This mode generates the text section.
  -->

  <xsl:template match="//tei:body//tei:note[@type]">
    <span data-note-id="{generate-id ()}" class="tei-note annotation annotation-{@type}" data-shortcuts="0">
    </span>
  </xsl:template>

  <xsl:template match="//tei:body//tei:note" priority="-0.5">
    <span data-note-id="{generate-id ()}" class="tei-note annotation" data-shortcuts="0">
    </span>
  </xsl:template>

  <xsl:template match="tei:subst">
    <span class="tei-subst" data-note-id="{generate-id ()}">
      <xsl:apply-templates select="tei:del"/>
      <xsl:apply-templates select="tei:add"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:add" mode="edited">
    <xsl:if test="@rend='coloured'">
      <xsl:attribute name="class">tei-add rend-coloured</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:add">
    <span class="tei-add">
      <xsl:if test="not (parent::tei:subst)">
        <xsl:attribute name="data-note-id"><xsl:value-of select="generate-id ()"/></xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="cap:is-later-hand ()">
          <xsl:apply-templates mode="refs-only"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="edited"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template name="empty-del">
    <!-- Special treatment for empty <del> -->
    <xsl:choose>
      <xsl:when test="not (normalize-space ()) and @quantity">
        <xsl:value-of select="str:padding (@quantity, '+')"/>
      </xsl:when>
      <xsl:when test="not (normalize-space ())">
        <xsl:text>[+]</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:del" mode="original">
    <xsl:choose>
      <xsl:when test="normalize-space ()">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="empty-del"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:del">
    <!-- non-empty del -->
    <span class="tei-del">
      <xsl:if test="not (parent::tei:subst)">
        <xsl:attribute name="data-note-id"><xsl:value-of select="generate-id ()"/></xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="cap:is-later-hand ()">
          <xsl:apply-templates />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="refs-only"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="tei:del[not (normalize-space ())]">
    <!-- empty del -->
    <span class="tei-del">
      <xsl:choose>
        <xsl:when test="parent::tei:subst and cap:is-later-hand ()">
          <xsl:call-template name="empty-del"/>
        </xsl:when>
        <xsl:when test="not (parent::tei:subst)">
          <xsl:call-template name="empty-del"/>
        </xsl:when>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="tei:choice">
    <span class="tei-choice">
      <xsl:apply-templates select="tei:expan"/>
      <xsl:apply-templates select="tei:abbr" mode="refs-only"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:mod">
    <span class="tei-mod" data-note-id="{generate-id ()}">
      <xsl:if test="@rend='coloured'">
        <xsl:attribute name="class">tei-mod rend-coloured</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:space">
    <span class="tei-space" data-note-id="{generate-id ()}">
      <xsl:text> - - - </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:handShift">
    <span class="tei-handShift" data-note-id="{generate-id ()}">
    </span>
  </xsl:template>

  <xsl:template match="tei:unclear">
    <span class="tei-unclear">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:gap">
    <span class="tei-gap" data-shortcuts="0">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="str:padding (@quantity, '.')"/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:sic">
    <span class="tei-sic">
      <xsl:apply-templates/>
      <span data-shortcuts="0">
        <xsl:text> [!]</xsl:text>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="tei:num">
    <span class="tei-num">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:ex">
    <span class="tei-ex rend-italic italic">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!--
      refs-only mode

      While generating the text section, whenever execution takes one of two or
      more paths, (eg. the normal-hand or the later-hand paths in an <add> or
      <del>) we must traverse the other path in refs-only mode.

      This is to assure that all footnote refs in all paths get generated in the
      text section.  Otherwise if we had eg. a <choice> nested inside an <add
      hand="X"> the <choice> would not get transformed in the text, leaving no
      generated note ref and a dangling note body.

      Some footnote refs will also get generated in the footnote section, but
      those will be ignored by the post-processor.

      refs-only mode generates refs and nothing else.  Refs are <span>s with a
      data-note-id attribute.
  -->


  <xsl:template match="tei:add|tei:del[normalize-space ()]" mode="refs-only">
    <span class="tei-{local-name ()}">
      <xsl:if test="not (parent::tei:subst)">
        <xsl:attribute name="data-note-id"><xsl:value-of select="generate-id ()"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="refs-only"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:subst|tei:mod|tei:note|tei:space|tei:choice/tei:abbr|tei:handShift" mode="refs-only">
    <span class="tei-{local-name ()}" data-note-id="{generate-id ()}">
      <xsl:apply-templates mode="refs-only"/>
    </span>
  </xsl:template>

  <xsl:template match="text ()" mode="refs-only">
  </xsl:template>

  <!--
      auto-note-wrapper mode

      auto-note-wrapper mode is used at the end of every <ab> to generate and
      collect all footnotes into a footnote section.

      Should we use a pre-order or post-order traversal when outputting
      footnotes?

      Inspection of ~300 files on 22 Sep. 2016 counted following constructs:

        add          1768
        del          1418
        subst         948
        abbr          792
        expan        3158
        choice        784
        add//choice    15
        del//choice     4
        subst//choice   2
        abbr//add       3
        abbr//del       3
        expan//add     17
        expan//del     18

      Since expan does not output anything the most frequent construct is choice
      inside add.  Choice is use exclusively for abbreviations, so the most
      natural sounding footnote would be:

        "Wort" ergänzt
        gek. "W"

      That implies a pre-order traversal.

      FIXME: needs change in footnotes-post-processor.php too.
  -->

  <xsl:template match="tei:add|tei:del[normalize-space ()]" mode="auto-note-wrapper">
    <!-- pre-order: this node first -->
    <xsl:if test="not (parent::tei:subst)">
      <xsl:call-template name="auto-note-wrapper"/>
    </xsl:if>
    <!-- the children last -->
    <xsl:apply-templates mode="auto-note-wrapper"/>
  </xsl:template>

  <xsl:template match="tei:subst|tei:mod|tei:note|tei:space|tei:choice/tei:abbr|tei:handShift"
                mode="auto-note-wrapper">
    <!-- pre-order: this node first -->
    <xsl:call-template name="auto-note-wrapper"/>
    <!-- the children last -->
    <xsl:apply-templates mode="auto-note-wrapper"/>
  </xsl:template>

  <xsl:template name="auto-note-wrapper">
    <!-- Generate the footnote decorations, then call auto-note mode to generate
         the footnote body. -->
    <xsl:text>&#x0a;</xsl:text>
    <div id="{generate-id ()}-content" class="annotation-content">
      <div class="annotation-text">
        <!-- run again on this node -->
        <xsl:apply-templates select="." mode="auto-note"/>
        <!--
            This is to assure that footnote refs do not get moved past the
            div's end.  Needed if we decide to implement recursive footnotes.

            <xsl:text> &#xa0;&#x0a;</xsl:text>
        -->
      </div>
    </div>
  </xsl:template>

  <xsl:template match="text ()" mode="auto-note-wrapper">
  </xsl:template>

  <!--
      auto-note mode

      auto-note mode generates the actual footnote bodies.  It is called from
      auto-note-wrapper mode.  Every template in auto-note mode generates
      exactly one footnote body.  They do not recurse of themselves.
  -->

  <xsl:template match="tei:subst" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)"/>
    <xsl:variable name="after"    select="cap:word-after (.)"/>

    <xsl:choose>
      <xsl:when test="cap:is-later-hand ()">
        <xsl:variable name="phrase">
          <xsl:value-of select="$before"/>
          <xsl:apply-templates select="tei:del" mode="original"/>
          <xsl:value-of select="$after"/>
        </xsl:variable>
        <xsl:if test="cap:is-phrase (exsl:node-set ($phrase))">
          <span class="mentioned" data-shortcuts="1">
            <xsl:value-of select="cap:shorten-phrase (exsl:node-set ($phrase))"/>
          </span>
        </xsl:if>
        <xsl:call-template name="hand-blurb"/>
        <xsl:text> korr. zu </xsl:text>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/>
          <xsl:apply-templates select="tei:add" mode="edited"/>
          <xsl:value-of select="$after"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="phrase">
          <xsl:value-of select="$before"/>
          <xsl:apply-templates select="tei:add"/>
          <xsl:value-of select="$after"/>
        </xsl:variable>
        <xsl:if test="cap:is-phrase (exsl:node-set ($phrase))">
          <span class="mentioned" data-shortcuts="1">
            <xsl:value-of select="cap:shorten-phrase (exsl:node-set ($phrase))"/>
          </span>
        </xsl:if>
        <xsl:call-template name="hand-blurb"/>
        <xsl:text> korr. aus </xsl:text>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/>
          <xsl:apply-templates select="tei:del" mode="original"/>
          <xsl:value-of select="$after"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:add" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)"/>
    <xsl:variable name="after"    select="cap:word-after (.)"/>

    <xsl:choose>
      <xsl:when test="cap:is-later-hand ()">
        <xsl:choose>
          <xsl:when test="$before = '' and $after = ''">
            <xsl:text>folgt</xsl:text>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> ergänztes </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> korr. zu </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/>
          <xsl:apply-templates/>
          <xsl:value-of select="$after"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <!-- not (cap:is-later-hand ()) -->
        <xsl:variable name="phrase">
          <xsl:apply-templates/>
        </xsl:variable>
        <span class="mentioned" data-shortcuts="1">
          <xsl:choose>
            <xsl:when test="string-length () = 1">
              <xsl:apply-templates/>
              <!-- the index, eg. a² -->
              <xsl:if test="cap:count-char (concat ($before, $after), string ()) > 0">
                <sup class="mentioned-index">
                  <xsl:value-of select="1 + cap:count-char ($before, string ())"/>
                </sup>
              </xsl:if>
            </xsl:when>
            <xsl:when test="cap:is-phrase (exsl:node-set ($phrase))">
              <xsl:copy-of select="cap:shorten-phrase (exsl:node-set ($phrase))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$phrase"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:call-template name="hand-blurb"/>
        <xsl:text> ergänzt</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:del[normalize-space ()]" mode="auto-note">
    <xsl:variable name="before" select="cap:word-before (.)"/>
    <xsl:variable name="after"  select="cap:word-after (.)"/>

    <xsl:variable name="phrase">
      <xsl:value-of select="$before"/>
      <xsl:apply-templates select="." mode="original"/>
      <xsl:value-of select="$after"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$before = '' and $after = ''">
        <!-- Whole word deleted. -->
        <xsl:choose>
          <xsl:when test="cap:is-later-hand ()">
            <xsl:if test="cap:is-phrase (exsl:node-set ($phrase))">
              <span class="mentioned" data-shortcuts="1">
                <xsl:copy-of select="cap:shorten-phrase (exsl:node-set ($phrase))"/>
              </span>
            </xsl:if>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> getilgt</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- The footnote reference will be moved to the end of the preceding word. -->
            <xsl:text>folgt</xsl:text>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> getilgtes </xsl:text>
            <span class="mentioned" data-shortcuts="1">
              <xsl:copy-of select="$phrase"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- Part of word deleted. -->
        <xsl:call-template name="hand-blurb"/>
        <xsl:choose>
          <xsl:when test="cap:is-later-hand ()">
            <xsl:text> korr. zu </xsl:text>
            <span class="mentioned" data-shortcuts="1">
              <xsl:value-of select="concat ($before, $after)"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> korr. aus </xsl:text>
            <span class="mentioned" data-shortcuts="1">
              <xsl:copy-of select="$phrase"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:mod" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)"/>
    <xsl:variable name="after"    select="cap:word-after (.)"/>

    <xsl:choose>
      <xsl:when test="$before = '' and $after = ''">
        <xsl:text>korr. (?)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <span class="mentioned" data-shortcuts="1"><xsl:apply-templates/></span>
        <xsl:text> korr. (?)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:note" mode="auto-note">
    <xsl:if test="@target">
      <xsl:variable name="vPrecSeg" select="preceding-sibling::node ()[1][local-name ()='span'][@xml:id]"/>
      <xsl:variable name="vBezug">
        <xsl:value-of select="$vPrecSeg/text ()[1]"/>
        <xsl:value-of select="$vPrecSeg/tei:add"/>
        <xsl:value-of select="substring-before ($vPrecSeg/text ()[last ()],' ')"/>
        <xsl:text>...</xsl:text>
        <xsl:value-of select="substring-after ($vPrecSeg/text ()[last ()],' ')"/>
        <xsl:text>: </xsl:text>
      </xsl:variable>
      <xsl:value-of select="$vBezug"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:space" mode="auto-note">
    <xsl:text>Lücke von ca. </xsl:text>
    <xsl:value-of select="@quantity"/>
    <xsl:text> </xsl:text>

    <xsl:call-template name="plural">
      <xsl:with-param name="quantity" select="@quantity"/>
      <xsl:with-param name="unit"     select="@unit"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:choice/tei:abbr" mode="auto-note">
    <xsl:text>gek. </xsl:text>
    <span class="mentioned" data-shortcuts="1">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:handShift" mode="auto-note">
    <xsl:text>Im folgenden Schreiberwechsel zu Hand </xsl:text>
    <span class="rend-italic">
      <xsl:value-of select="@new"/>
    </span>
    <xsl:text>.</xsl:text>
  </xsl:template>

</xsl:stylesheet>
