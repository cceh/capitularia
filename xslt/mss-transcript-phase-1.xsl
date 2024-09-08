<?xml version="1.0" encoding="UTF-8" ?>

<!--

Outputs the transcription section of a single manuscript page.
TEI -> TEI preprocessing.

Transforms: $(MSS_DIR)/%.xml      -> $(CACHE_DIR)/mss/%.transcript.phase-1.xml
Transforms: $(MSS_PRIV_DIR)/%.xml -> $(CACHE_DIR)/internal/mss/%.transcript.phase-1.xml

Transforms: $(MSS_DIR)/texts/137.xml    -> $(CACHE_DIR)/mss/cte-137.transcript.phase-1.xml
Transforms: $(MSS_DIR)/texts/137-de.xml -> $(CACHE_DIR)/mss/cte-137-de.transcript.phase-1.xml


Phase 1 is a TEI to TEI conversion that:

 - Resolves add, del, subst, choose, and expan into one text flow, and

 - generates notes that explain how those constructs were resolved.

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

- The hands A - W are considered original scribes.
- The hands X - Z are considered later hands.

The "include-later-hand" tunneled parameter can be used to control which text is
output. If false, the text by the original hand is output, if true, the text corrected
by a later hand is output.

There are 3 classes of corrections:

- corrections of phrases,
- corrections of a whole word, and
- corrections that change a part of a word.

The generated text of the footnote varies according to these cases.


@author: MP

-->

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    default-mode="phase1"
    exclude-result-prefixes="cap tei xs xsl">

  <!-- Needed for the correct determination of the word around an editorial
       intervention. -->
  <xsl:strip-space elements="subst choice"/>

  <xsl:output method="xml" encoding="UTF-8" indent="no"/>

  <xsl:include href="common-3.xsl" />

  <xsl:variable name="all_hands" as="xs:boolean">
    <!-- are there other hands besides hand X ? -->
    <xsl:value-of select="count (//@hand[contains ('YZ', .)]) > 0" />
  </xsl:variable>

  <xsl:variable name="hand-names">
    <root xmlns="http://www.tei-c.org/ns/1.0">
      <item key="0">
        <name>anderer Hand</name>
      </item>
      <item key="X">
        <name>Korrekturhand 1</name>
      </item>
      <item key="Y">
        <name>Korrekturhand 2</name>
      </item>
      <item key="Z">
        <name>Korrekturhand 3</name>
      </item>
    </root>
  </xsl:variable>

  <xsl:template match="/TEI/text/body">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:if test="not (@data-shortcuts)">
        <xsl:attribute name="data-shortcuts" select="1"/>
      </xsl:if>

      <milestone type="tei-body-start" />
      <xsl:apply-templates />
      <milestone type="tei-body-end" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@* | element () | text () | comment ()">
    <!-- copy everything yet get rid of processing instructions -->
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="auto-note">
    <xsl:apply-templates select="@*|node()" mode="auto-note" />
  </xsl:template>

  <xsl:function name="cap:starts-with-whitespace" as="xs:boolean">
    <xsl:param name="s"/>
    <xsl:sequence select="matches ($s, '^\s')" />
  </xsl:function>

  <xsl:function name="cap:contains-whitespace" as="xs:boolean">
    <xsl:param name="s"/>
    <xsl:sequence select="matches ($s, '\s')" />
  </xsl:function>

  <xsl:function name="cap:ends-with-whitespace" as="xs:boolean">
    <xsl:param name="s"/>
    <xsl:sequence select="matches ($s, '\s$')" />
  </xsl:function>

  <xsl:function name="cap:word-before">
    <!--
        Get the word fragment before the element.

        Return the word fragment before the $e element.  Get the first preceding
        text node and analyze it.  If it does not contain whitespace recurse and
        get the next preceding text node, and so on until we either find some
        whitespace or bump into a <note>.
    -->
    <xsl:param name="e"/>

    <xsl:variable name="before" select="$e/preceding::node ()[self::text () or self::note][not (parent::abbr)][1]"/>
    <xsl:variable name="class"  select="cap:get-rend-class ($before)" />

    <xsl:sequence>
      <xsl:choose>
        <!-- We found a <note>.  We assume that a <note> is always at the end of
             a word: return nothing. -->
        <xsl:when test="$before/self::note" />

        <!-- This text node ends with whitespace: return nothing. -->
        <xsl:when test="cap:ends-with-whitespace ($before)" />

        <!-- This text node contains a whitespace: return the chars after the
             last whitespace. -->
        <xsl:when test="cap:contains-whitespace ($before)">
          <xsl:choose>
            <xsl:when test="$class">
              <seg class="{$class}">
                <xsl:value-of select="tokenize ($before, '\s+')[last ()]"/>
              </seg>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tokenize ($before, '\s+')[last ()]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- This text node contains no whitespace: return the whole contents
             and recurse. -->
        <xsl:otherwise>
          <xsl:copy-of select="cap:word-before ($before)"/>
          <xsl:choose>
            <xsl:when test="$class">
              <seg class="{$class}">
                <xsl:copy-of select="$before"/>
              </seg>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$before"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="cap:word-after">
    <!--
        Get the word fragment after the element.

        Return the word fragment after the $e element.
    -->
    <xsl:param name="e"/>

    <xsl:variable name="after" select="$e/following::node ()[self::text () or self::note][not (parent::abbr)][1]"/>
    <xsl:variable name="class" select="cap:get-rend-class ($after)" />

    <xsl:sequence>
      <xsl:choose>
        <!-- we assume that a note is always at the end of a word, return nothing -->
        <xsl:when test="$after/self::note" />

        <!-- This text node starts with whitespace: return nothing. -->
        <xsl:when test="cap:starts-with-whitespace ($after)" />

        <!-- This text node contains a whitespace, return the chars before the first
             whitespace char. -->
        <xsl:when test="cap:contains-whitespace ($after)">
          <xsl:choose>
            <xsl:when test="$class">
              <seg class="{$class}">
                <xsl:value-of select="tokenize ($after, '\s+')[1]"/>
              </seg>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tokenize ($after, '\s+')[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- no whitespace, return all chars and recurse -->
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$class">
              <seg class="{$class}">
                <xsl:copy-of select="$after"/>
              </seg>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$after"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:copy-of select="cap:word-after ($after)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="cap:count-char">
    <!-- Count how many of char c are in string s. -->
    <xsl:param name="s"/>
    <xsl:param name="c"/>

    <xsl:sequence select="number (string-length (string-join ($s)) - string-length (translate (string-join ($s), $c, '')))"/>
  </xsl:function>

  <xsl:function name="cap:is-whole-word">
    <xsl:param name="before"/>
    <xsl:param name="after"/>

    <xsl:sequence select="normalize-space (concat (string-join ($before), string-join ($after))) = ''"/>
  </xsl:function>

  <xsl:function name="cap:is-phrase">
    <!-- Test if the node contains a phrase (ie. more than one word). -->
    <xsl:param name="nodeset"/>

    <xsl:sequence select="cap:contains-whitespace (normalize-space (string-join ($nodeset)))"/>
  </xsl:function>

  <xsl:template match="note" mode="filter-notes" />

  <xsl:function name="cap:shorten-phrase">
    <!-- Transform "phrase with more than five words" into "phrase with ... five words" -->
    <xsl:param name="nodeset"/>

    <xsl:variable name="filtered">
      <xsl:apply-templates select="$nodeset" mode="filter-notes"/>
    </xsl:variable>

    <xsl:variable name="nodes" select="tokenize (normalize-space (string-join ($filtered)), '\s+')"/>
    <xsl:variable name="len" select="count ($nodes)"/>

    <xsl:choose>
      <xsl:when test="$len &gt; 5">
        <xsl:sequence select="string-join (($nodes[1], $nodes[2], '&#x2026;', $nodes[$len - 1], $nodes[$len]), ' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$nodeset"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="cap:get-hand">
    <!--
        Look for the closest @hand attribute.

        Look for @hand on self, parent::subst, and
        parent::subst/add.
    -->
    <xsl:param name="context" />
    <xsl:choose>
      <xsl:when test="$context/@hand">
        <xsl:sequence select="$context/@hand"/>
      </xsl:when>
      <xsl:when test="$context/add/@hand">
        <xsl:sequence select="$context/add/@hand"/>
      </xsl:when>
      <xsl:when test="$context/parent::subst/@hand">
        <xsl:sequence select="$context/../@hand"/>
      </xsl:when>
      <xsl:when test="$context/parent::subst/add/@hand">
        <xsl:sequence select="$context/../add/@hand"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="cap:translate-hand">
    <!--
        Translate hand siglum into human-readable stuff.
    -->
    <xsl:param name="hand"/>

    <xsl:choose>
      <xsl:when test="normalize-space ($hand) and contains ('XYZ', $hand)">
        <xsl:choose>
          <!-- if there are other hands beside hand X -->
          <xsl:when test="$all_hands">
            <xsl:variable name="name" select="$hand-names/root/item[@key = $hand]"/>
            <xsl:sequence select="string ($name/name)"/>
          </xsl:when>
          <!-- if there is only hand X -->
          <xsl:otherwise>
            <xsl:variable name="name" select="$hand-names/root/item[@key = '0']"/>
            <xsl:sequence select="string ($name/name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat ('Hand ', $hand)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="cap:is-normal-hand">
    <!-- If these hands made corrections we display them in the
         text and put the old text in the apparatus. -->
    <xsl:param name="context" />
    <xsl:variable name="hand" select="cap:get-hand ($context)"/>
    <xsl:sequence select="normalize-space ($hand) and contains ('ABCDEFGHIJKLMNOPQRSTU', $hand)"/>
  </xsl:function>

  <xsl:function name="cap:is-later-hand">
    <!-- If these hands made corrections we put them in
         the apparatus and display the old text. -->
    <xsl:param name="context" />
    <xsl:param name="include-later-hand" />

    <xsl:variable name="hand" select="cap:get-hand ($context)"/>
    <xsl:sequence select="normalize-space ($hand) and contains ('XYZ', $hand) and not ($include-later-hand)"/>
  </xsl:function>

  <xsl:template name="hand-blurb">
    <xsl:if test="cap:get-hand (.)">
      <xsl:text> von </xsl:text>
      <xsl:value-of select="cap:translate-hand (cap:get-hand (.))"/>
    </xsl:if>
    <xsl:if test="following-sibling::*[1][self::metamark]">
      <xsl:text> mit Einfügungszeichen</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="plural">
    <!-- Get singular or plural of known terms. -->
    <xsl:param name="quantity" select="0" />
    <xsl:param name="unit"     select="unit"/>

    <xsl:variable name="terms">
      <list unit="chars">
        <item>Buchstabe</item>
        <item>Buchstaben</item>
      </list>

      <list unit="words">
        <item>Wort</item>
        <item>Wörter</item>
      </list>

      <list unit="lines">
        <item>Zeile</item>
        <item>Zeilen</item>
      </list>

      <list unit="units">
        <item>Einheit</item>
        <item>Einheiten</item>
      </list>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="number ($quantity) = 1">
        <xsl:value-of select="$terms/list[@unit=$unit]/item[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$terms/list[@unit=$unit]/item[2]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate-note">
    <!-- Generate the footnote decorations, then call auto-note mode to generate
         the footnote body. -->
    <note xml:id="{generate-id ()}" type="generated">
      <!-- run again on this same node -->
      <xsl:apply-templates select="." mode="auto-note"/>
    </note>
  </xsl:template>

  <xsl:template name="xform-note">
    <!-- transform a real (non-generated) note -->
    <!-- the note, which will be moved behind the <ab> in phase 2 -->
    <note xml:id="{generate-id ()}" class="tei-note" data-shortcuts="0">
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </note>
    <!-- the post-processor turns this into a footnote ref -->
    <seg class="tei-note annotation annotation-{@type}" data-shortcuts="0"
         data-note-id="{generate-id ()}" />
  </xsl:template>

  <!--
      default mode for <note>s

      This mode generates the text section.
  -->

  <xsl:template match="body//note">
    <xsl:call-template name="xform-note"/>
  </xsl:template>

  <xsl:template match="subst">
    <xsl:call-template name="generate-note"/>
    <seg class="tei-subst" data-note-id="{generate-id ()}">
      <xsl:apply-templates select="del" />
      <xsl:apply-templates select="add" />
    </seg>
  </xsl:template>

  <xsl:template match="choice">
    <xsl:call-template name="generate-note" />
    <seg class="tei-choice"> <!-- data-note-id="{generate-id ()}"> -->
      <xsl:apply-templates select="expan" />
    </seg>
    <!-- FIXME: data-node-id moved here for bug compatibility (makes a leaner diff) -->
    <seg class="tei-choice" data-note-id="{generate-id ()}" />

    <xsl:apply-templates select="abbrev" mode="notes-only" />
  </xsl:template>

  <!--
      Typ-Unterscheidung hinzufügen!!!

      Die einzelnen Typen sollen optisch unterscheidbar sein, ohne daß man Farbe
      verwenden muß.  Alle größer und fett; zusätzlich zur Unterscheidung
      verschiedene Größen/Schrifttypen?
  -->

  <xsl:template match="body/ab">
    <ab>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="handle-rend">
        <xsl:with-param name="extra-class" select="concat ('ab ab-', @type)" />
      </xsl:call-template>

      <xsl:apply-templates />
    </ab>

    <!-- insert hints to help pagination in later phases -->

    <xsl:choose>
      <xsl:when test="@type='text' and not (@next)">
        <milestone type="footnotes-wrapper" />
        <milestone type="page-break" />
      </xsl:when>
      <!-- If this <ab type="meta-text"> is an epilog or explicit or
           is immediately followed by a capitulatio -->
      <xsl:when test="@type='meta-text' and (following-sibling::*[1][self::milestone[@unit='capitulatio']] or (contains (@corresp, '_epilog') and not (contains (@corresp, '_inscriptio'))) or contains (@corresp, 'explicit'))">
        <milestone type="footnotes-wrapper" />
        <milestone type="page-break" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="anchor[starts-with (@xml:id, 'capitulatio-finis')]">
    <!-- this anchor marks the end of a capitulatio -->
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
    <milestone type="footnotes-wrapper" />
    <milestone type="page-break" />
  </xsl:template>

  <xsl:template match="seg[@type]">
    <seg type="{@type}">
      <xsl:call-template name="handle-rend">
        <xsl:with-param name="extra-class" select="concat ('tei-seg tei-seg-', @type)" />
      </xsl:call-template>
      <xsl:apply-templates />
    </seg>
  </xsl:template>

  <xsl:template match="seg[@type='initial']" priority="2">
    <!-- for bug compatibility only, makes a leaner diff -->
    <seg type="{@type}">
      <xsl:call-template name="handle-rend">
        <xsl:with-param name="extra-class" select="@type" />
      </xsl:call-template>
      <xsl:apply-templates />
    </seg>
  </xsl:template>

  <xsl:template match="hi">
    <hi type="{@type}">
      <xsl:call-template name="handle-rend">
        <xsl:with-param name="extra-class" select="'tei-hi'"/>
      </xsl:call-template>
      <xsl:apply-templates />
    </hi>
  </xsl:template>

  <xsl:template match="add">
    <xsl:param name="include-later-hand" select="true ()" tunnel="yes" />

    <xsl:if test="not (parent::subst)">
      <xsl:call-template name="generate-note"/>
    </xsl:if>
    <seg class="tei-add">
      <xsl:if test="not (parent::subst)">
        <xsl:attribute name="data-note-id" select="generate-id ()"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="cap:is-later-hand (., $include-later-hand)">
          <xsl:apply-templates mode="notes-only" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="handle-rend">
            <xsl:with-param name="extra-class" select="'tei-add'"/>
          </xsl:call-template>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </seg>
  </xsl:template>

  <xsl:template name="empty-del">
    <!-- Special treatment for empty <del> -->
    <xsl:choose>
      <xsl:when test="not (normalize-space ()) and @quantity">
        <seg class="break-word"><xsl:value-of select="cap:string-pad (@quantity, '†')"/></seg>
      </xsl:when>
      <xsl:when test="not (normalize-space ())">
        <xsl:text>[†]</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="del" mode="original">
    <xsl:choose>
      <xsl:when test="normalize-space ()">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="empty-del"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="del">
    <xsl:param name="include-later-hand" select="true ()" tunnel="yes" />

    <!-- non-empty del -->
    <xsl:if test="not (parent::subst)">
      <xsl:call-template name="generate-note"/>
    </xsl:if>
    <seg class="tei-del">
      <xsl:if test="not (parent::subst)">
        <xsl:attribute name="data-note-id" select="generate-id ()"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="cap:is-later-hand (., $include-later-hand)">
          <xsl:call-template name="handle-rend">
            <xsl:with-param name="extra-class" select="'tei-del'"/>
          </xsl:call-template>
          <xsl:apply-templates />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="notes-only" />
        </xsl:otherwise>
      </xsl:choose>
    </seg>
  </xsl:template>

  <xsl:template match="del[not (normalize-space ())]">
    <xsl:param name="include-later-hand" select="true ()" tunnel="yes" />

    <!-- empty del -->
    <seg class="tei-del">
      <xsl:choose>
        <xsl:when test="parent::subst and cap:is-later-hand (., $include-later-hand)">
          <xsl:call-template name="empty-del"/>
        </xsl:when>
        <xsl:when test="not (parent::subst)">
          <xsl:call-template name="empty-del"/>
        </xsl:when>
      </xsl:choose>
    </seg>
  </xsl:template>

  <xsl:template match="mod">
    <xsl:call-template name="generate-note"/>
    <seg class="tei-mod" data-note-id="{generate-id ()}">
      <xsl:call-template name="handle-rend">
        <xsl:with-param name="extra-class" select="'tei-mod'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </seg>
  </xsl:template>

  <xsl:template match="space">
    <xsl:call-template name="generate-note"/>
    <seg class="tei-space" data-note-id="{generate-id ()}">
      <xsl:text> - - - </xsl:text>
    </seg>
  </xsl:template>

  <xsl:template match="handShift">
    <xsl:call-template name="generate-note"/>
    <seg class="tei-handShift" data-note-id="{generate-id ()}" />
  </xsl:template>

  <xsl:template match="unclear">
    <seg class="tei-unclear">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </seg>
  </xsl:template>

  <xsl:template name="gap-chars">
    <xsl:param name="char" />
    <xsl:param name="quantity" />

    <xsl:choose>
      <xsl:when test="not ($quantity)">
        <xsl:value-of select="$char"/>
      </xsl:when>
      <xsl:when test="xs:integer ($quantity) &lt; 6">
        <xsl:value-of select="cap:string-pad (xs:integer ($quantity), $char)"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- 6 chars or more, insert breaking joiners -->
        <xsl:value-of select="cap:string-pad (3, $char)"/>
        <xsl:value-of select="cap:string-pad ((xs:integer ($quantity) - 6) * 2 + 1, concat ('&#x200b;', $char))"/>
        <xsl:value-of select="cap:string-pad (3, $char)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gap">
    <seg class="tei-gap" data-shortcuts="0">
      <xsl:choose>
        <xsl:when test="ancestor::del"> <!-- crosses -->
          <xsl:choose>
            <xsl:when test="@quantity">
              <xsl:call-template name="gap-chars">
                <xsl:with-param name="char"     select="'†'" />
                <xsl:with-param name="quantity" select="@quantity" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>[†]</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise> <!-- dots -->
          <xsl:text>[</xsl:text>
          <xsl:call-template name="gap-chars">
            <xsl:with-param name="char"     select="'.'" />
            <xsl:with-param name="quantity" select="@quantity" />
          </xsl:call-template>
          <xsl:text>]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </seg>
  </xsl:template>

  <xsl:template match="gap[@reason='editorial']">
    <ab class="tei-gap-editorial" data-shortcuts="0">
      <xsl:text>[</xsl:text>
      <seg class="tei-gap-editorial-inner">Nicht transkribierter Text</seg>
      <xsl:text>]</xsl:text>
    </ab>
  </xsl:template>

  <xsl:template match="sic">
    <seg class="tei-sic">
      <xsl:apply-templates/>
      <xsl:text>&#xa0;</xsl:text>
      <seg data-shortcuts="0">
        <xsl:text>[!]</xsl:text>
      </seg>
    </seg>
  </xsl:template>

  <xsl:template match="ex">
    <seg class="tei-ex" rend="italic">
      <xsl:apply-templates/>
    </seg>
  </xsl:template>

  <!--
      notes-only mode

      Whenever execution takes only one of two paths in #default mode, (eg. in
      <add>, <del>, <choice>) we must traverse the other path in notes-only mode.
      This is to assure that all notes in all paths get generated.

      Otherwise if we had eg. a <choice> nested inside a <del> the <choice>
      would transform into a note.
  -->

  <xsl:template match="add|del[normalize-space ()]|subst|mod|space|choice|handShift" mode="notes-only">
    <xsl:call-template name="generate-note"/>
    <xsl:apply-templates mode="notes-only"/>
  </xsl:template>

  <xsl:template match="note" mode="notes-only">
    <xsl:call-template name="xform-note"/>
  </xsl:template>

  <xsl:template match="text ()" mode="notes-only">
  </xsl:template>

  <!--
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

  <!--
      auto-note mode

      auto-note mode generates the actual footnote bodies.  Every template in
      auto-note mode generates exactly one footnote body.  They do not recurse
      of themselves.
  -->

  <xsl:template match="subst" mode="auto-note">
    <xsl:param name="include-later-hand" select="true ()" tunnel="yes" />

    <xsl:variable name="before" select="cap:word-before (.)"/>
    <xsl:variable name="after"  select="cap:word-after (.)"/>
    <xsl:variable name="rend"   select="concat ('tei-mentioned', cap:get-rend-class (.))"/>


    <xsl:choose>
      <xsl:when test="cap:is-later-hand (., $include-later-hand)">
        <xsl:variable name="phrase">
          <xsl:copy-of select="$before"/>
          <xsl:apply-templates select="del" mode="original"/>
          <xsl:copy-of select="$after"/>
        </xsl:variable>
        <xsl:if test="cap:is-phrase ($phrase)">
          <seg class="{$rend}">
            <xsl:copy-of select="cap:shorten-phrase ($phrase)"/>
          </seg>
        </xsl:if>
        <seg class="generated" data-shortcuts="0">
          <xsl:call-template name="hand-blurb"/>
          <xsl:text> korr. zu </xsl:text>
        </seg>
        <seg class="{$rend}">
          <xsl:copy-of select="$before"/>
          <xsl:apply-templates select="add/node()" />
          <xsl:copy-of select="$after"/>
        </seg>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="phrase">
          <xsl:copy-of select="$before"/>
          <xsl:apply-templates select="add"/>
          <xsl:copy-of select="$after"/>
        </xsl:variable>
        <xsl:if test="cap:is-phrase ($phrase)">
          <seg class="{$rend}">
            <xsl:copy-of select="cap:shorten-phrase ($phrase)"/>
          </seg>
        </xsl:if>
        <seg class="generated" data-shortcuts="0">
          <xsl:call-template name="hand-blurb"/>
          <xsl:text> korr. aus </xsl:text>
        </seg>
        <seg class="{$rend}">
          <xsl:copy-of select="$before"/>
          <xsl:apply-templates select="del" mode="original"/>
          <xsl:copy-of select="$after"/>
        </seg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="add" mode="auto-note">
    <xsl:param name="include-later-hand" select="true ()" tunnel="yes" />

    <xsl:variable name="before" select="cap:word-before (.)"/>
    <xsl:variable name="after"  select="cap:word-after (.)"/>
    <xsl:variable name="rend"   select="concat ('tei-mentioned', cap:get-rend-class (.))"/>

    <xsl:choose>
      <xsl:when test="cap:is-later-hand (., $include-later-hand)">
        <seg class="generated" data-shortcuts="0">
          <xsl:choose>
            <xsl:when test="cap:is-whole-word ($before, $after)">
              <xsl:text> folgt </xsl:text>
              <xsl:if test="@place='inspace'">
                <xsl:text> in Lücke </xsl:text>
              </xsl:if>
              <xsl:call-template name="hand-blurb"/>
              <xsl:text> ergänztes </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="hand-blurb"/>
              <xsl:text> korr. zu </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </seg>
        <seg class="{$rend}">
          <xsl:copy-of select="$before"/>
          <xsl:apply-templates/>
          <xsl:copy-of select="$after"/>
        </seg>
      </xsl:when>
      <xsl:otherwise>
        <!-- not (cap:is-later-hand (., $include-later-hand)) -->
        <xsl:variable name="phrase">
          <!-- tentative fix for #125.  A milestone gets a <seg display:none>
               into $phrase but cap:shorten-phrase doesn't know enough to throw it out -->
          <xsl:apply-templates select="node ()[not (self::milestone)]" />
        </xsl:variable>
        <seg class="{$rend}">
          <xsl:choose>
            <xsl:when test="string-length () = 1">
              <xsl:apply-templates/>
              <!-- the index, eg. a² -->
              <!-- if there are more than one of this char -->
              <xsl:if test="cap:count-char (concat (string-join ($before), string-join ($after)), string (.)) &gt; 0">
                <!-- add the superscript -->
                <hi htmltag="sup" class="mentioned-index">
                  <xsl:value-of select="1 + cap:count-char (string-join ($before), string (.))"/>
                </hi>
              </xsl:if>
            </xsl:when>
            <xsl:when test="cap:is-phrase ($phrase)">
              <xsl:copy-of select="cap:shorten-phrase ($phrase)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$phrase"/>
            </xsl:otherwise>
          </xsl:choose>
        </seg>
        <seg class="generated" data-shortcuts="0">
          <xsl:if test="@place='inspace'">
            <xsl:text> in Lücke </xsl:text>
          </xsl:if>
          <xsl:call-template name="hand-blurb"/>
          <xsl:text> ergänzt</xsl:text>
        </seg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="del[normalize-space ()]" mode="auto-note">
    <xsl:param name="include-later-hand" select="true ()" tunnel="yes" />

    <xsl:variable name="before" select="cap:word-before (.)"/>
    <xsl:variable name="after"  select="cap:word-after (.)"/>
    <xsl:variable name="rend"   select="concat ('tei-mentioned', cap:get-rend-class (.))"/>

    <xsl:variable name="phrase">
      <xsl:copy-of select="$before"/>
      <xsl:apply-templates select="." mode="original"/>
      <xsl:copy-of select="$after"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="cap:is-whole-word ($before, $after)">
        <!-- Whole word deleted. -->
        <xsl:choose>
          <xsl:when test="cap:is-later-hand (., $include-later-hand)">
            <xsl:if test="cap:is-phrase ($phrase)">
              <seg class="{$rend}">
                <xsl:copy-of select="cap:shorten-phrase ($phrase)"/>
              </seg>
            </xsl:if>
            <seg class="generated" data-shortcuts="0">
              <xsl:call-template name="hand-blurb"/>
              <xsl:text> getilgt</xsl:text>
            </seg>
          </xsl:when>
          <xsl:otherwise>
            <seg class="generated" data-shortcuts="0">
              <!-- The footnote reference will be moved to the end of the preceding word. -->
              <xsl:text>folgt</xsl:text>
              <xsl:call-template name="hand-blurb"/>
              <xsl:text> getilgtes </xsl:text>
            </seg>
            <seg class="{$rend}">
              <xsl:copy-of select="$phrase"/>
            </seg>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- Part of word deleted. -->
        <xsl:choose>
          <xsl:when test="cap:is-later-hand (., $include-later-hand)">
            <seg class="generated" data-shortcuts="0">
              <xsl:call-template name="hand-blurb"/>
              <xsl:text> korr. zu </xsl:text>
            </seg>
            <seg class="{$rend}">
              <xsl:copy-of select="$before"/>
              <xsl:copy-of select="$after"/>
            </seg>
          </xsl:when>
          <xsl:otherwise>
            <seg class="generated" data-shortcuts="0">
              <xsl:call-template name="hand-blurb"/>
              <xsl:text> korr. aus </xsl:text>
            </seg>
            <seg class="{$rend}">
              <xsl:copy-of select="$phrase"/>
            </seg>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mod" mode="auto-note">
    <xsl:variable name="before" select="cap:word-before (.)"/>
    <xsl:variable name="after"  select="cap:word-after (.)"/>
    <xsl:variable name="rend"   select="concat ('tei-mentioned', cap:get-rend-class (.))"/>

    <xsl:choose>
      <xsl:when test="cap:is-whole-word ($before, $after)">
        <seg class="generated" data-shortcuts="0">korr. (?)</seg>
      </xsl:when>
      <xsl:otherwise>
        <seg class="{$rend}">
          <xsl:choose>
            <xsl:when test="string-length (.) = 1">
              <xsl:apply-templates/>
              <!-- the index, eg. a² -->
              <!-- <xsl:comment><xsl:value-of select="concat ($before, ., $after)"/></xsl:comment> -->
              <xsl:if test="cap:count-char (concat (string-join ($before), string-join ($after)), string (.)) &gt; 0">
                <hi htmltag="sup" class="mentioned-index">
                  <xsl:value-of select="1 + cap:count-char ($before, string (.))"/>
                </hi>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </seg>
        <seg class="generated" data-shortcuts="0"> korr. (?)</seg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="choice" mode="auto-note">
    <xsl:variable name="phrase">
      <xsl:apply-templates select="expan" />
    </xsl:variable>

    <xsl:if test="cap:is-phrase ($phrase)">
      <xsl:variable name="rend-expan" select="concat ('tei-mentioned', cap:get-rend-class (expan))"/>
      <seg class="{$rend-expan}">
        <xsl:copy-of select="cap:shorten-phrase ($phrase)"/>
      </seg>
    </xsl:if>

    <seg class="generated" data-shortcuts="0"> gek. </seg>

    <xsl:variable name="rend-abbr" select="concat ('tei-mentioned', cap:get-rend-class (abbr))"/>
    <seg class="{$rend-abbr}">
      <xsl:apply-templates select="abbr"/>
    </seg>
  </xsl:template>

  <xsl:template match="space" mode="auto-note">
    <seg class="generated" data-shortcuts="0">
      <xsl:text>Lücke von ca. </xsl:text>
      <xsl:value-of select="@quantity"/>
      <xsl:text> </xsl:text>
      <xsl:call-template name="plural">
        <xsl:with-param name="quantity" select="@quantity"/>
        <xsl:with-param name="unit"     select="@unit"/>
      </xsl:call-template>
    </seg>
  </xsl:template>

  <xsl:template match="handShift" mode="auto-note">
    <seg class="generated" data-shortcuts="0">
      <xsl:text>Ab diesem Wort Wechsel der Schreiberhand, vgl. die Vorbemerkung.</xsl:text>
    </seg>
  </xsl:template>

  <xsl:template match="pb|lb|cb">
    <!-- auto-mode templates need this -->
    <xsl:if test="not (@break = 'no')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>
