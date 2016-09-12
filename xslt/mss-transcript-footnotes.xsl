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
        <xsl:value-of select="str:concat ($e/preceding::text ()[position () &lt; 10])"/>
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
        <xsl:value-of select="str:concat ($e/following::text ()[position () &lt; 10])"/>
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
    <xsl:param name="node"/>
    <func:result select="contains (normalize-space ($node), ' ')"/>
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
    <xsl:if test="@rend='default'">
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
    <span class="tei-choice" data-note-id="{generate-id ()}">
      <xsl:apply-templates select="tei:expan"/>
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
      data-node-id attribute.
  -->


  <xsl:template match="tei:add|tei:del[normalize-space ()]" mode="refs-only">
    <span class="tei-{local-name ()}">
      <xsl:if test="not (parent::tei:subst)">
        <xsl:attribute name="data-note-id"><xsl:value-of select="generate-id ()"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="refs-only"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:subst|tei:mod|tei:note|tei:space|tei:choice|tei:handShift" mode="refs-only">
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

      To get the footnotes in the right chronological order, we need a
      depth-first traversal, on the assumption that older edits are nested
      deeper than newer edits.

      FIXME: what about <choice> inside <add> or <del>? Choice should then
      output after the parent.
  -->

  <xsl:template match="tei:add|tei:del[normalize-space ()]" mode="auto-note-wrapper">
    <!-- generate notes from children depth first -->
    <xsl:apply-templates mode="auto-note-wrapper"/>
    <!-- generate note from this node -->
    <xsl:if test="not (parent::tei:subst)">
      <xsl:call-template name="auto-note-wrapper"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:subst|tei:mod|tei:note|tei:space|tei:choice|tei:handShift"
                mode="auto-note-wrapper">
    <!-- generate notes from children depth first -->
    <xsl:apply-templates mode="auto-note-wrapper"/>
    <!-- generate note from this node -->
    <xsl:call-template name="auto-note-wrapper"/>
  </xsl:template>

  <xsl:template name="auto-note-wrapper">
    <!-- Generate the footnote decorations, then call auto-note mode to generate
         the footnote body. -->
    <xsl:text>&#x0a;</xsl:text>
    <div id="{generate-id ()}-content" class="annotation-content">
      <div class="annotation-text">
        <!-- run again on this node -->
        <xsl:apply-templates select="." mode="auto-note"/>
        <!-- This is to assure that footnote refs do not get moved past the
             div's end. Do *not* remove! -->
        <xsl:text>&#x0a;</xsl:text>
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
        <xsl:variable name="del">
          <xsl:apply-templates select="tei:del" mode="original" />
        </xsl:variable>
        <xsl:if test="cap:is-phrase (str:concat (exsl:node-set ($del)))">
          <span class="mentioned" data-shortcuts="1">
            <xsl:value-of select="$before"/><xsl:apply-templates select="tei:del" mode="original" /><xsl:value-of select="$after"/>
          </span>
        </xsl:if>
        <xsl:call-template name="hand-blurb"/>
        <xsl:text> korr. zu </xsl:text>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/><xsl:apply-templates select="tei:add" mode="edited"/><xsl:value-of select="$after"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="add">
          <xsl:apply-templates select="tei:add"/>
        </xsl:variable>
        <xsl:if test="cap:is-phrase (str:concat (exsl:node-set ($add)))">
          <span class="mentioned" data-shortcuts="1">
            <xsl:value-of select="$before"/><xsl:apply-templates select="tei:add"/><xsl:value-of select="$after"/>
          </span>
        </xsl:if>
        <xsl:call-template name="hand-blurb"/>
        <xsl:text> korr. aus </xsl:text>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/><xsl:apply-templates select="tei:del" mode="original"/><xsl:value-of select="$after"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:add" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)"/>
    <xsl:variable name="after"    select="cap:word-after (.)"/>

    <xsl:variable name="index">
      <!-- the index, eg. a², only if needed -->
      <xsl:if test="(string-length () = 1) and (cap:count-char (concat ($before, $after), string ()) > 0)">
        <sup class="mentioned-index">
          <xsl:value-of select="1 + cap:count-char ($before, string ())"/>
        </sup>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="edited">
      <span class="mentioned" data-shortcuts="1">
        <xsl:value-of select="$before"/><xsl:apply-templates/><xsl:value-of select="$after"/>
      </span>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="cap:is-later-hand ()">
        <xsl:choose>
          <xsl:when test="$before = '' and $after = ''">
            <xsl:text>folgt</xsl:text>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> ergänztes </xsl:text>
            <xsl:copy-of select="$edited"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> korr. zu </xsl:text>
            <xsl:copy-of select="$edited"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise> <!-- not later hand -->
        <span class="mentioned" data-shortcuts="1">
          <xsl:apply-templates/><xsl:copy-of select="$index"/>
        </span>
        <xsl:call-template name="hand-blurb"/>
        <xsl:text> ergänzt</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:del[normalize-space ()]" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)"/>
    <xsl:variable name="after"    select="cap:word-after (.)"/>

    <xsl:variable name="original">
      <span class="mentioned" data-shortcuts="1">
        <xsl:value-of select="$before"/><xsl:apply-templates select="." mode="original" /><xsl:value-of select="$after"/>
      </span>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$before = '' and $after = ''">
        <!-- Whole word deleted. -->
        <xsl:choose>
          <xsl:when test="cap:is-later-hand ()">
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> getilgt</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- The footnote reference will be moved to the end of the preceding word. -->
            <xsl:text>folgt</xsl:text>
            <xsl:call-template name="hand-blurb"/>
            <xsl:text> getilgtes </xsl:text>
            <xsl:copy-of select="$original"/>
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
            <xsl:copy-of select="$original"/>
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

  <xsl:template match="tei:choice" mode="auto-note">
    <xsl:text>gek. </xsl:text>
    <span class="mentioned" data-shortcuts="1">
      <xsl:apply-templates select="tei:abbr"/>
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
