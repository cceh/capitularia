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

con<note>korr. aus corcordet</note>cordet

and

ad<add @hand="A">d</add>endum

will generate markup equivalent to:

add<note>d von Hand A ergänzt</note>endum


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
suppressed if there is a manual note at the end of the word.  Isolated footnotes
will be joined to the preceding word.

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
        <xsl:value-of select="str:concat ($e/preceding::text()[position() &lt; 10])"/>
      </xsl:variable>
      <!-- str:tokenize does not return the empty token if string ends with whitespace. -->
      <xsl:if test="normalize-space (substring ($s, string-length ($s)))">
        <xsl:value-of select="str:tokenize ($s)[last()]"/>
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
        <xsl:value-of select="str:concat ($e/following::text()[position() &lt; 10])"/>
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
        <func:result select="@hand" />
      </xsl:when>
      <xsl:when test="tei:add/@hand">
        <func:result select="tei:add/@hand" />
      </xsl:when>
      <xsl:when test="parent::tei:subst/@hand">
        <func:result select="../@hand" />
      </xsl:when>
      <xsl:when test="parent::tei:subst/tei:add/@hand">
        <func:result select="../tei:add/@hand" />
      </xsl:when>
      <otherwise>
        <func:result select="''" />
      </otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="cap:is-normal-hand">
    <!-- If these hands made corrections we display them in the
         text and put the old text in the apparatus. -->
    <xsl:param name="hand" select="cap:get-hand ()" />
    <func:result select="normalize-space ($hand) and contains ('ABCDEFGHIJKLMNOPQRSTU', $hand)" />
  </func:function>

  <func:function name="cap:is-special-hand">
    <!-- If these hands made corrections we put them in
         the apparatus and display the old text. -->
    <xsl:param name="hand" select="cap:get-hand ()" />
    <func:result select="normalize-space ($hand) and contains ('XYZ', $hand)" />
  </func:function>

  <func:function name="cap:contains-whitespace">
    <xsl:param name="s" select="string (.)" />
    <func:result select="translate ($s, ' &#09;&#xa;&#xd;', '') != string ($s)"/>
  </func:function>

  <func:function name="cap:note-follows">
    <!--
        Check if there is a tei:note at the end of this word.

        Return true if the first tei:note after the current node
        comes before the first text node with whitespace.
    -->
    <xsl:param name="n" select="."/>
    <func:result select="boolean ($n/following::node ()[self::tei:note or (self::text () and cap:contains-whitespace (.))][1][self::tei:note])"/>
  </func:function>

  <xsl:template name="blurb">
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
    <xsl:param name="quantity" select="'0'"  />
    <xsl:param name="unit"     select="unit" />

    <xsl:variable name="terms">
      <tei:list unit="chars">
        <tei:item>Buchstabe</tei:item>
        <tei:item>Buchstaben</tei:item>
      </tei:list>

      <tei:list unit="word">
        <tei:item>Wort</tei:item>
        <tei:item>Wörter</tei:item>
      </tei:list>

      <tei:list unit="unit">
        <tei:item>Einheit</tei:item>
        <tei:item>Einheiten</tei:item>
      </tei:list>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$quantity = '1'">
        <xsl:value-of select="exsl:node-set ($terms)/tei:list[@unit=$unit]/tei:item[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="exsl:node-set ($terms)/tei:list[@unit=$unit]/tei:item[2]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="footnote-ref">
    <!-- Generate a footnote reference. That is the <sup>number</sup> that goes
         in the text. -->
    <a id="{generate-id(.)}-ref" href="#{generate-id(.)}-backref" class="annotation-ref ssdone">
      <span class="print-only footnote-number-ref"></span><!-- filled by post-processor -->
      <span class="screen-only footnote-siglum"></span>
    </a>
  </xsl:template>

  <xsl:template name="footnote-backref">
    <!-- Generate a footnote back reference. That is the number before the
         footnote text in the footnote section. -->
    <a id="{generate-id(.)}-backref" href="#{generate-id(.)}-ref" class="annotation-backref ssdone">
      <span class="print-only footnote-number-backref"></span><!-- filled by post-processor -->
      <span class="screen-only footnote-siglum"></span>
    </a>
  </xsl:template>

  <!--
      ##############################################################################
  -->

  <xsl:template match="//tei:body//tei:note[@type='editorial'][@target]">
    <!-- als Teil von "Erstreckungsfußnote" -->
    <xsl:call-template name="footnote-ref" />
  </xsl:template>

  <xsl:template match="//tei:body//tei:note[@type='editorial'][not(@target)]">
    <span id="{generate-id(.)}" class="annotation annotation-editorial">
      <xsl:call-template name="footnote-ref"/>
    </span>
  </xsl:template>

  <xsl:template match="//tei:body//tei:note[@type='comment']">
    <span id="{generate-id(.)}" class="annotation annotation-comment" data-shortcuts="0">
      <xsl:call-template name="footnote-ref"/>
    </span>
  </xsl:template>

  <xsl:template match="//tei:body//tei:note" priority="-0.5">
    <span id="{generate-id(.)}" class="annotation" data-shortcuts="0">
      <xsl:call-template name="footnote-ref"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:subst">
    <span class="tei-subst">
      <xsl:apply-templates select="tei:del" />
      <xsl:apply-templates select="tei:add" />
    </span>
    <xsl:call-template name="auto-note-ref"/>
  </xsl:template>

  <xsl:template match="tei:add">
    <span class="tei-add">
      <xsl:if test="not (cap:is-special-hand ())">
        <xsl:if test="@rend='coloured'">
          <xsl:attribute name="class">tei-add rend-coloured</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
      </xsl:if>
    </span>
    <xsl:if test="not (parent::tei:subst)">
      <xsl:call-template name="auto-note-ref"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:del">
    <span class="tei-del">
      <xsl:if test="cap:is-special-hand ()">
        <xsl:choose>
          <!-- Special cases for empty <del> -->
          <xsl:when test="not (normalize-space (.)) and @quantity">
            <xsl:value-of select="str:padding (@quantity, '+')"/>
          </xsl:when>
          <xsl:when test="not (normalize-space (.))">
            <xsl:text>[+]</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </span>
    <xsl:if test="not (parent::tei:subst)">
      <xsl:call-template name="auto-note-ref"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:mod">
    <span class="tei-mod">
      <xsl:if test="@rend='coloured'">
        <xsl:attribute name="class">tei-mod rend-coloured</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </span>

    <xsl:call-template name="auto-note-ref"/>
  </xsl:template>

  <xsl:template match="tei:choice">
    <span class="tei-choice">
      <xsl:apply-templates select="tei:expan"/>
    </span>

    <xsl:call-template name="auto-note-ref"/>
  </xsl:template>

  <xsl:template match="tei:unclear[tei:gap]">
    <span class="tei-unclear tei-unclear-gap" data-shortcuts="0">
      <xsl:text>...</xsl:text>
    </span>

    <xsl:call-template name="auto-note-ref"/>
  </xsl:template>

  <xsl:template match="tei:unclear[not (tei:gap)]">
    <span class="tei-unclear tei-unclear-not-gap">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:gap">
    <span class="tei-gap" data-shortcuts="0">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="str:padding (@quantity, ' .')"/>
      <xsl:text> ]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:ex">
    <span class="tei-ex rend-italic italic">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:sic">
    <span class="tei-sic">
      <xsl:apply-templates />
      <span data-shortcuts="0">
        <xsl:text> [!]</xsl:text>
      </span>
    </span>

    <!-- xsl:call-template name="auto-note-ref"/ -->
  </xsl:template>

  <xsl:template match="tei:num">
    <span class="tei-num">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:space">
    <span class="tei-space">
      <xsl:text> - - - </xsl:text>
    </span>

    <xsl:call-template name="auto-note-ref"/>
  </xsl:template>

  <xsl:template match="tei:handShift">
    <xsl:call-template name="auto-note-ref"/>
  </xsl:template>

  <!--
      Automatic footnote ref generation.
  -->

  <xsl:template name="auto-note-ref">
    <!--
        Generate a footnote from markup.

        For tei:add, tei:del, tei:subst, etc. elements we
        automatically generate a human-readable footnote from
        the markup.  This can be overridden by manually placing
        a tei:note after the element.
    -->
    <xsl:choose>
      <xsl:when test="not (cap:note-follows ())">
        <span id="{generate-id(.)}" class="annotation auto" data-shortcuts="0">
          <xsl:call-template name="footnote-ref"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="annotation auto note-follows-suppressed" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      Automatic footnote wrapper generation

      apply-templates with mode of 'auto-note-wrapper' is called at the end of
      every tei:ab to generate and collect all notes into one div.  Generating
      notes in a separate step and separate mode allows us to call the default
      mode templates from nested elements without the generated notes polluting
      the results. eg.

        <tei:subst>
          <tei:del>
            <tei:choice>
              <tei:expan>

      the tei:choice would generate a note, which would show up inside the
      tei:del content.  FIXME: Better explanation needed.
  -->

  <xsl:template match="tei:add|tei:del" mode="auto-note-wrapper">
    <!-- generate notes from children -->
    <xsl:apply-templates mode="auto-note-wrapper" />
    <!-- generate note from this node -->
    <xsl:if test="not (parent::tei:subst)">
      <xsl:call-template name="auto-note-wrapper" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:subst|tei:mod|tei:note|tei:space|tei:unclear[tei:gap]|tei:choice|tei:handShift"
                mode="auto-note-wrapper">
    <!-- generate notes from children -->
    <xsl:apply-templates mode="auto-note-wrapper" />
    <!-- generate note from this node -->
    <xsl:call-template name="auto-note-wrapper" />
  </xsl:template>

  <xsl:template name="auto-note-wrapper">
    <!--
        Generate a footnote from markup.

        For tei:add, tei:del, tei:subst, etc. elements we
        automatically generate a human-readable footnote from
        the markup.  This can be overridden by manually placing
        a tei:note after the element.
    -->
    <xsl:if test="not (cap:note-follows ())">
      <div id="{generate-id(.)}-content" class="annotation-content">
        <xsl:call-template name="footnote-backref"/>
        <div class="annotation-text">
          <!-- run again on this node -->
          <xsl:apply-templates select="." mode="auto-note" />
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()" mode="auto-note-wrapper">
  </xsl:template>

  <!--
      Automatic footnote text generation
  -->

  <xsl:template match="tei:subst" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)" />
    <xsl:variable name="after"    select="cap:word-after (.)" />

    <xsl:choose>
      <xsl:when test="cap:is-special-hand ()">
        <xsl:variable name="del">
          <xsl:apply-templates select="tei:del"/>
        </xsl:variable>
        <xsl:if test="cap:is-phrase (str:concat (exsl:node-set ($del)))">
          <span class="mentioned" data-shortcuts="1">
            <xsl:value-of select="$before"/><xsl:apply-templates select="tei:del"/><xsl:value-of select="$after"/>
          </span>
        </xsl:if>
        <xsl:call-template name="blurb" />
        <xsl:text> korr. zu </xsl:text>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/><xsl:apply-templates select="tei:add/node()"/><xsl:value-of select="$after"/>
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
        <xsl:call-template name="blurb" />
        <xsl:text> korr. aus </xsl:text>
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/><xsl:apply-templates select="tei:del/node()"/><xsl:value-of select="$after"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:add" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)" />
    <xsl:variable name="after"    select="cap:word-after (.)" />

    <xsl:variable name="index">
      <!-- the index, eg. a², only if needed -->
      <xsl:if test="(string-length (.) = 1) and (cap:count-char (concat ($before, $after), string (.)) > 0)">
        <sup class="mentioned-index">
          <xsl:value-of select="1 + cap:count-char ($before, string (.))"/>
        </sup>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="edited">
      <span class="mentioned" data-shortcuts="1">
        <xsl:value-of select="$before"/><xsl:apply-templates/><xsl:value-of select="$after"/>
      </span>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="cap:is-special-hand ()">
        <xsl:choose>
          <xsl:when test="$before = '' and $after = ''">
            <xsl:text>folgt</xsl:text>
            <xsl:call-template name="blurb" />
            <xsl:text> ergänztes </xsl:text>
            <xsl:copy-of select="$edited" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="blurb" />
            <xsl:text> korr. zu </xsl:text>
            <xsl:copy-of select="$edited"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise> <!-- not speacial hand -->
        <span class="mentioned" data-shortcuts="1">
          <xsl:apply-templates/><xsl:copy-of select="$index"/>
        </span>
        <xsl:call-template name="blurb" />
        <xsl:text> ergänzt</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:del" mode="auto-note">
    <xsl:if test="normalize-space (.)">
      <xsl:variable name="before"   select="cap:word-before (.)" />
      <xsl:variable name="after"    select="cap:word-after (.)" />

      <xsl:variable name="original">
        <span class="mentioned" data-shortcuts="1">
          <xsl:value-of select="$before"/><xsl:apply-templates/><xsl:value-of select="$after"/>
        </span>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$before = '' and $after = ''">
          <!-- Whole word deleted. -->
          <xsl:choose>
            <xsl:when test="cap:is-special-hand ()">
              <xsl:call-template name="blurb"/>
              <xsl:text> getilgt</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <!-- The footnote reference will be moved to the end of the preceding word. -->
              <xsl:text>folgt</xsl:text>
              <xsl:call-template name="blurb"/>
              <xsl:text> getilgtes </xsl:text>
              <xsl:copy-of select="$original" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <!-- Part of word deleted. -->
          <xsl:call-template name="blurb"/>
          <xsl:choose>
            <xsl:when test="cap:is-special-hand ()">
              <xsl:text> korr. zu </xsl:text>
              <span class="mentioned" data-shortcuts="1">
                <xsl:value-of select="concat ($before, $after)"/>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> korr. aus </xsl:text>
              <xsl:copy-of select="$original" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:mod" mode="auto-note">
    <xsl:variable name="before"   select="cap:word-before (.)" />
    <xsl:variable name="after"    select="cap:word-after (.)" />

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
      <xsl:variable name="vPrecSeg" select="preceding-sibling::node()[1][local-name(.)='span'][@xml:id]"/>
      <xsl:variable name="vBezug">
        <xsl:value-of select="$vPrecSeg/text()[1]"/>
        <xsl:value-of select="$vPrecSeg/tei:add"/>
        <xsl:value-of select="substring-before($vPrecSeg/text()[last()],' ')"/>
        <xsl:text>...</xsl:text>
        <xsl:value-of select="substring-after($vPrecSeg/text()[last()],' ')"/>
        <xsl:text>: </xsl:text>
      </xsl:variable>
      <xsl:value-of select="$vBezug"/>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <!--
  <xsl:template match="tei:sic" mode="auto-note">
    <xsl:text>sic Hs.</xsl:text>
  </xsl:template>
  -->

  <xsl:template match="tei:space" mode="auto-note">
    <xsl:text>Lücke von ca. </xsl:text>
    <xsl:value-of select="@quantity"/>
    <xsl:text> </xsl:text>

    <xsl:call-template name="plural">
      <xsl:with-param name="quantity" select="@quantity" />
      <xsl:with-param name="unit"     select="@unit" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:unclear[tei:gap]" mode="auto-note">
    <xsl:text>Lücke von ca. </xsl:text>
    <xsl:value-of select="@quantity"/>
    <xsl:text> </xsl:text>

    <xsl:call-template name="plural">
      <xsl:with-param name="quantity" select="@quantity" />
      <xsl:with-param name="unit"     select="@unit" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:choice" mode="auto-note">
    <xsl:text>gek. </xsl:text>
    <span class="mentioned" data-shortcuts="1">
      <xsl:apply-templates select="tei:abbr" />
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
