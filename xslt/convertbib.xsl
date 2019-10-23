<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<xsl:output method="text"/>
<xsl:strip-space elements="*"/>
<xsl:key name="B" match="biblStruct" use="1"/>

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
    <xsl:apply-templates mode="tobib"/>

    <pubstate>
      <xsl:value-of select="@status" />
    </pubstate>

    <ids>
      <xsl:value-of select="@xml:id" />
    </ids>

    <xsl:for-each select=".//idno[@type='short_title']">
      <ids>
        <xsl:value-of select="replace (normalize-space (.), '_', ' ')"/>
      </ids>
    </xsl:for-each>

    <xsl:for-each select="./note[@type='rel_text']">
      <keywords>
        <xsl:value-of select="."/>
      </keywords>
    </xsl:for-each>

    <xsl:for-each select="./relatedItem[@type][@target]">
      <related>
        <xsl:value-of select="substring (./@target, 2)" />
      </related>
      <relatedtype>
        <xsl:value-of select="./@type" />
      </relatedtype>
    </xsl:for-each>
  </xsl:variable>

  <xsl:for-each-group select="$all/*" group-by="local-name (.)">
    <xsl:sort select="local-name (.)" />

    <xsl:text>&#09;</xsl:text>
    <xsl:value-of select="current-grouping-key ()" />
    <xsl:text>={</xsl:text>

    <xsl:for-each-group select="current-group ()" group-by="normalize-space (.)">
      <xsl:sort select="normalize-space (.)" />

      <xsl:if test="normalize-space (.) and . != '-'">
        <xsl:text>{</xsl:text>
        <xsl:value-of select="normalize-space (.)" />
        <xsl:text>}</xsl:text>
        <xsl:if test="position () != last ()">
          <xsl:choose>
            <xsl:when test="local-name (.) = 'ids'">, </xsl:when>
            <xsl:when test="local-name (.) = 'keywords'">, </xsl:when>
            <xsl:when test="local-name (.) = 'note'">; </xsl:when>
            <xsl:when test="local-name (.) = 'title'">. </xsl:when>
            <xsl:when test="local-name (.) = 'booktitle'">. </xsl:when>
            <xsl:when test="local-name (.) = 'journaltitle'">. </xsl:when>
            <xsl:when test="local-name (.) = 'subtitle'">. </xsl:when>
            <xsl:when test="local-name (.) = 'booksubtitle'">. </xsl:when>
            <xsl:when test="local-name (.) = 'journalsubtitle'">. </xsl:when>
            <xsl:otherwise> and </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
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
        <xsl:value-of select="."/>
      </institution>
    </xsl:when>
    <xsl:otherwise>
      <publisher>
        <xsl:value-of select="."/>
      </publisher>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="idno[@type='isbn']">
  <isbn>
    <xsl:value-of select="."/>
  </isbn>
</xsl:template>

<xsl:template mode="tobib" match="idno[@type='short_title']">
  <shorttitle>
    <xsl:value-of select="replace (normalize-space (.), '_', ' ')"/>
  </shorttitle>
</xsl:template>

<xsl:template mode="tobib" match="pubPlace">
  <location>
    <xsl:value-of select="."/>
  </location>
</xsl:template>

<xsl:template mode="tobib" match="date">
  <date>
    <xsl:value-of select="."/>
  </date>
</xsl:template>

<xsl:template mode="tobib" match="date[@type='access']">
  <urldate><xsl:value-of select="@when"/></urldate>
</xsl:template>

<xsl:template mode="tobib" match="title[@type='main']">
  <xsl:choose>
    <xsl:when test="@level='j'">
      <journaltitle><xsl:value-of select="."/></journaltitle>
    </xsl:when>
    <xsl:when test="parent::series">
      <series><xsl:value-of select="."/></series>
    </xsl:when>
    <xsl:when test="parent::monogr and ../../analytic">
      <xsl:choose>
        <xsl:when test="ancestor::biblStruct[@type='webPublication']">
          <note>XXX booktitle <xsl:value-of select="."/></note>
        </xsl:when>
        <xsl:otherwise>
          <booktitle><xsl:value-of select="."/></booktitle>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <title><xsl:value-of select="."/></title>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="title[@type='sub']">
  <xsl:choose>
    <xsl:when test="@level='j'">
      <journalsubtitle><xsl:value-of select="."/></journalsubtitle>
    </xsl:when>
    <xsl:when test="parent::monogr and ../../analytic">
      <!-- zotero and citavi don't yet grok booksubtitle -->
      <booktitle><xsl:value-of select="."/></booktitle>
    </xsl:when>
    <xsl:otherwise>
      <subtitle><xsl:value-of select="."/></subtitle>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="tobib" match="idno[@type='url' or @type='URL']">
  <xsl:choose>
    <xsl:when test="parent::monogr and ../../analytic">
      <xsl:choose>
        <xsl:when test="ancestor::biblStruct[@type='webPublication']">
          <note>XXX bookurl <xsl:value-of select="."/></note>
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
      <xsl:value-of select=".//surname"/>
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
  <editor type="publisher">
    <xsl:call-template name="names" />
  </editor>
</xsl:template>

<xsl:template mode="tobib" match="editor[note[@type='role'][. = 'Mitarb.']]">
  <editor type="collaborator">
    <xsl:call-template name="names" />
  </editor>
</xsl:template>

<xsl:template mode="tobib" match="editor">
  <editor>
    <xsl:call-template name="names" />
  </editor>
</xsl:template>

<xsl:template mode="tobib" match="note">
  <xsl:choose>
	<xsl:when test="@type='notes'">
      <note>XXX Anmerkung <xsl:value-of select="."/></note>
    </xsl:when>
	<xsl:when test="@type='reprint'">
      <note>XXX Reprint <xsl:value-of select="."/></note>
      <xsl:analyze-string select="." regex="(\d{{4}})">
        <xsl:matching-substring>
          <origdate><xsl:value-of select="regex-group (1)"/></origdate>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:when>
	<xsl:when test="@type='rel_text' and . = 'Katalog'">
      <note>XXX <xsl:value-of select="."/></note>
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
  </xsl:choose>
</xsl:template>

<!--
<xsl:template mode="tobib" match="note[@type='access' and . = 'frei']">
  <xsl:text>@copyright={free}</xsl:text>
</xsl:template>
-->

</xsl:stylesheet>
