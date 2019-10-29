<?xml version="1.0" encoding="utf-8"?>

<!--
     Convert the Capitularia Bibliograhy from TEI into biblatex format,
     for use by biblatex or import into zotero or citavi.

     Author: Marcello Perathoner <marcello@perathoner.de>

     Usage: saxon -s:bibl.tei convertbib.xsl style=biblatex > bibl.bib
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:foo="http://cceh.uni-koeln.de/marcello"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="3.0">

<!-- tweak output for biblatex/zotero/citavi.
     Select which fields to output and how to output rich text
     formatting: \emph{x} or <i>x</i> or nothing. -->
<xsl:param name="style">citavi</xsl:param>

<xsl:output method="text"/>
<xsl:strip-space elements="*"/>
<xsl:key name="B" match="biblStruct" use="1"/>

<!-- normalize a bibtex field -->

<xsl:function name="foo:normalize">
  <xsl:param name="e" />

  <xsl:variable name="sep">
    <xsl:choose>
      <xsl:when test="matches (local-name ($e), '^(ids|keywords)$')">
        <tei:prefix>{</tei:prefix>
        <tei:suffix>}</tei:suffix>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="$sep/prefix" />
  <xsl:value-of select="normalize-space ($e)" />
  <xsl:value-of select="$sep/suffix" />
</xsl:function>

<!-- get prefixes suffixes for different styles -->

<xsl:function name="foo:style">
  <tei:style>
    <xsl:choose>
      <xsl:when test="$style = 'citavi'">
        <tei:quote>
          <tei:prefix>"</tei:prefix>
          <tei:suffix>"</tei:suffix>
        </tei:quote>
        <!-- citavi doesn't know about rich text -->
      </xsl:when>
      <xsl:when test="$style = 'zotero'">
        <!-- See: https://www.zotero.org/support/kb/rich_text_bibliography -->
        <tei:quote>
          <tei:prefix>"</tei:prefix>
          <tei:suffix>"</tei:suffix>
        </tei:quote>
        <tei:italic>
          <tei:prefix>&lt;i&gt;</tei:prefix>
          <tei:suffix>&lt;/i&gt;</tei:suffix>
        </tei:italic>
        <tei:super>
          <tei:prefix>&lt;sup&gt;</tei:prefix>
          <tei:suffix>&lt;/sup&gt;</tei:suffix>
        </tei:super>
      </xsl:when>
      <xsl:otherwise>
        <tei:quote>
          <tei:prefix>\mkbibquote{</tei:prefix>
          <tei:suffix>}</tei:suffix>
        </tei:quote>
        <tei:italic>
          <tei:prefix>\emph{</tei:prefix>
          <tei:suffix>}</tei:suffix>
        </tei:italic>
        <tei:super>
          <tei:prefix>\textsuperscript{</tei:prefix>
          <tei:suffix>}</tei:suffix>
        </tei:super>
      </xsl:otherwise>
    </xsl:choose>
  </tei:style>
</xsl:function>

<xsl:variable name="thestyle" select="foo:style ()" />

<xsl:template match="/">
  <xsl:for-each select="key ('B', 1)">
    <!-- nur Literatur und Kataloge exportieren -->
    <xsl:if test="./note[@type='rel_text'][. = 'Literatur' or . = 'Katalog']">
      <xsl:call-template name="biblStruct2bibtex"/>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template name="biblStruct2bibtex">
  <xsl:text>@</xsl:text>
  <xsl:choose>
    <xsl:when test="@type='book'">
      <xsl:text>book</xsl:text>
    </xsl:when>
    <xsl:when test="@type='bookSection'">
      <xsl:text>incollection</xsl:text>
    </xsl:when>
    <xsl:when test="@type='journalArticle'">
      <xsl:text>article</xsl:text>
    </xsl:when>
    <xsl:when test="@type='webPublication'">
      <xsl:text>online</xsl:text>
    </xsl:when>
  </xsl:choose>
  <xsl:text>{</xsl:text>
  <xsl:value-of select="@xml:id"/>
  <xsl:text>,&#10;</xsl:text>

  <xsl:variable name="all">
    <ids>
      <xsl:value-of select="@xml:id" />
    </ids>

    <pubstate>
      <xsl:value-of select="@status" />
    </pubstate>

    <xsl:apply-templates mode="tobib"/>
  </xsl:variable>

  <xsl:for-each-group select="$all/*[not (matches (normalize-space (.), '^(|-|Unbekannt)$'))]"
                      group-by="local-name (.)">
    <xsl:sort select="local-name (.)" />

    <xsl:text>&#09;</xsl:text>
    <xsl:value-of select="current-grouping-key ()" />
    <xsl:text>={</xsl:text>

    <!-- group to eliminate duplicates -->
    <xsl:for-each-group select="current-group ()" group-by="normalize-space (.)">
      <xsl:sort select="normalize-space (.)" />

      <xsl:value-of select="foo:normalize (.)" />

      <xsl:if test="position () != last ()">
        <xsl:choose>
          <xsl:when test="local-name (.) = 'ids'">, </xsl:when>
          <xsl:when test="local-name (.) = 'keywords'">, </xsl:when>
          <xsl:when test="local-name (.) = 'note'">; </xsl:when>
          <xsl:when test="local-name (.) = 'addendum'"> </xsl:when>
          <xsl:when test="local-name (.) = 'related'">, </xsl:when>
          <xsl:when test="local-name (.) = 'relatedtype'">, </xsl:when>
          <xsl:when test="local-name (.) = 'origdate'">/</xsl:when>
          <xsl:when test="matches (local-name (.), 'title$')">. </xsl:when>
          <xsl:otherwise> and </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each-group>

    <xsl:text>}</xsl:text>
    <xsl:if test="position () != last ()">,</xsl:if>
    <xsl:text>&#10;</xsl:text>

  </xsl:for-each-group>

  <xsl:text>}&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template mode="tobib" match="publisher">
  <xsl:choose>
    <xsl:when test="ancestor::biblStruct/series or  ancestor::biblStruct/idno[@type='url']">
      <institution>
        <xsl:apply-templates mode="tobib" />
      </institution>
    </xsl:when>
    <xsl:otherwise>
      <publisher>
        <xsl:apply-templates mode="tobib" />
      </publisher>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="idno[@type='isbn']">
  <isbn>
    <xsl:value-of select="."/>
  </isbn>
</xsl:template>

<xsl:template mode="tobib" match="pubPlace">
  <xsl:choose>
    <!-- citavi doesn't know 'location' so use the obsolete 'address' instead -->
    <xsl:when test="$style = 'citavi'">
      <address>
        <xsl:apply-templates mode="tobib" />
      </address>
    </xsl:when>
    <xsl:otherwise>
      <location>
        <xsl:apply-templates mode="tobib" />
      </location>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="date">
  <!-- citavi doesn't know 'date' from a hole in the ground,
       so use the obsolete 'year' instead -->
  <xsl:choose>
    <xsl:when test="$style = 'citavi'">
      <year><xsl:value-of select="."/></year>
    </xsl:when>
    <xsl:otherwise>
      <date><xsl:value-of select="replace (., '(\d{4})-', '$1/')"/></date>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="date[@type='access']">
  <urldate><xsl:value-of select="@when"/></urldate>
</xsl:template>

<xsl:template mode="tobib" match="title[@type='main']">
  <xsl:choose>
    <xsl:when test="@level='j'">
      <journaltitle><xsl:apply-templates mode="tobib" /></journaltitle>
    </xsl:when>
    <xsl:when test="parent::series">
      <series><xsl:apply-templates mode="tobib" /></series>
    </xsl:when>
    <xsl:when test="parent::monogr and ../../analytic">
      <xsl:choose>
        <xsl:when test="ancestor::biblStruct[@type='webPublication']">
          <xsl:if test="$style = 'citavi'">
            <note>XXX booktitle <xsl:apply-templates mode="tobib" /></note>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <booktitle><xsl:apply-templates mode="tobib" /></booktitle>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <title><xsl:apply-templates mode="tobib" /></title>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="title[@type='sub']">
  <xsl:choose>
    <xsl:when test="@level='j'">
      <journalsubtitle><xsl:apply-templates mode="tobib" /></journalsubtitle>
    </xsl:when>
    <xsl:when test="parent::monogr and ../../analytic">
      <xsl:choose>
        <xsl:when test="$style = 'zotero' or $style = 'citavi'">
          <!-- zotero and citavi don't know booksubtitle -->
          <booktitle><xsl:apply-templates mode="tobib" /></booktitle>
        </xsl:when>
        <xsl:otherwise>
          <booksubtitle><xsl:apply-templates mode="tobib" /></booksubtitle>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$style = 'zotero'">
          <!-- zotero doesn't know subtitles -->
          <title><xsl:apply-templates mode="tobib" /></title>
        </xsl:when>
        <xsl:otherwise>
          <subtitle><xsl:apply-templates mode="tobib" /></subtitle>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="idno[@type='short_title']">
  <xsl:choose>
    <xsl:when test="parent::monogr and ../../analytic">
      <!-- use the one from analytic -->
    </xsl:when>
    <xsl:otherwise>
      <ids>
        <xsl:value-of select="replace (normalize-space (.), '_', ' ')"/>
      </ids>
      <shorttitle>
        <xsl:value-of select="replace (normalize-space (.), '_', ' ')"/>
      </shorttitle>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="idno[@type='url' or @type='URL']">
  <xsl:choose>
    <xsl:when test="parent::monogr and ../../analytic">
      <xsl:choose>
        <xsl:when test="ancestor::biblStruct[@type='webPublication']">
          <xsl:if test="$style = 'citavi'">
            <note>XXX bookurl <xsl:value-of select="."/></note>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <bookurl><xsl:value-of select="."/></bookurl>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <url><xsl:value-of select="."/></url>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="biblScope[@unit='page']">
  <pages>
    <xsl:apply-templates mode="tobib"/>
  </pages>
</xsl:template>

<xsl:template mode="tobib" match="biblScope[@unit='chapter']">
  <chapter>
    <xsl:apply-templates mode="tobib"/>
  </chapter>
</xsl:template>

<xsl:template mode="tobib" match="biblScope[@unit='volume']">
  <xsl:choose>
    <xsl:when test="parent::series">
      <number><xsl:apply-templates mode="tobib"/></number>
    </xsl:when>
    <xsl:otherwise>
      <volume><xsl:apply-templates mode="tobib"/></volume>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="biblScope[@unit='number']">
  <number>
    <xsl:apply-templates mode="tobib"/>
  </number>
</xsl:template>

<xsl:template mode="tobib" match="biblScope[@unit='issue']">
  <issue>
    <xsl:apply-templates mode="tobib"/>
  </issue>
</xsl:template>

<xsl:template mode="tobib" match="edition">
  <edition>
    <xsl:value-of select="@n"/>
  </edition>
</xsl:template>

<xsl:template name="names">
  <xsl:choose>
    <xsl:when test=".//forename and .//surname">
      <!-- make sure there is no space before the comma -->
      <xsl:value-of select="normalize-space (.//surname)"/>
	  <xsl:text>, </xsl:text>
	  <xsl:value-of select=".//forename"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates mode="tobib"/>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="note[@type='role']">
</xsl:template>

<xsl:template mode="tobib" match="author">
  <author>
    <xsl:call-template name="names" />
  </author>
</xsl:template>

<!-- Hg. Übers. Bearb. Mitarb. -->

<xsl:template mode="tobib" match="editor[note[@type='role'][. = 'Übers.']]">
  <translator>
    <xsl:call-template name="names" />
  </translator>
</xsl:template>

<xsl:template mode="tobib" match="editor[note[@type='role'][. = 'Hg.']]">
  <editor>
    <xsl:call-template name="names" />
  </editor>
</xsl:template>

<xsl:template mode="tobib" match="editor[note[@type='role'][. = 'Mitarb.']]">
  <editoratype>collaborator</editoratype>
  <editora>
    <xsl:call-template name="names" />
  </editora>
</xsl:template>

<xsl:template mode="tobib" match="editor">
  <editor>
    <xsl:call-template name="names" />
  </editor>
</xsl:template>

<xsl:template mode="tobib" match="note">
  <xsl:choose>
	<xsl:when test="@type='notes'">
      <xsl:if test="$style = 'citavi'">
        <note>XXX Anmerkung <xsl:apply-templates mode="tobib" /></note>
      </xsl:if>
      <addendum><xsl:apply-templates mode="tobib" /></addendum>
    </xsl:when>
	<xsl:when test="@type='reprint'">
      <xsl:if test="$style = 'citavi'">
        <note>XXX Reprint <xsl:apply-templates mode="tobib" /></note>
      </xsl:if>
      <addendum><xsl:apply-templates mode="tobib" /></addendum>
      <xsl:analyze-string select="." regex="(\d{{4}})">
        <xsl:matching-substring>
          <origdate><xsl:value-of select="regex-group (1)"/></origdate>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:when>
	<xsl:when test="@type='rel_text'">
      <xsl:if test="$style = 'citavi'">
        <xsl:if test=". = 'Katalog'">
          <note>XXX <xsl:value-of select="."/></note>
        </xsl:if>
      </xsl:if>
      <keywords>
        <xsl:value-of select="."/>
      </keywords>
    </xsl:when>
	<xsl:when test="@type='tags'">
      <xsl:for-each select="tokenize (., ' ')">
        <keywords><xsl:value-of select="."/></keywords>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="@type='item' and @subtype='digitized_version'">
      <file>
        <xsl:value-of select="@target" />
      </file>
    </xsl:when>
	<!--
      <xsl:when test="@type='access'">
        <copyright><xsl:value-of select="."/></copyright>
      </xsl:when>
    -->
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="relatedItem[@type][@target]">
  <related>
    <xsl:value-of select="substring-after (@target, '#')" />
  </related>
  <relatedtype>
    <xsl:value-of select="lower-case (@type)" />
  </relatedtype>
</xsl:template>

<xsl:template mode="tobib" match="q">
  <xsl:value-of select="$thestyle/quote/prefix" />
  <xsl:apply-templates mode="tobib" />
  <xsl:value-of select="$thestyle/quote/suffix" />
</xsl:template>

<xsl:template name="rend">
  <xsl:param name="rend" />

  <xsl:variable name="r" select="substring-before ($rend, ' ')" />
  <xsl:variable name="s" select="$thestyle/*[local-name() = $r]" />

  <xsl:choose>
    <xsl:when test="$r = ''">
      <!-- end recursion -->
      <xsl:apply-templates mode="tobib" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$s/prefix" />
      <!-- recurse -->
      <xsl:call-template name="rend">
        <xsl:with-param name="rend" select="substring-after ($rend, ' ')" />
      </xsl:call-template>
      <xsl:value-of select="$s/suffix" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="hi[@rend]">
  <xsl:call-template name="rend">
    <xsl:with-param name="rend" select="concat (@rend, ' ')" />
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
