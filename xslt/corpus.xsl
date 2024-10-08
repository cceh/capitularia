<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet builds a corpus.xml file by concatenating all TEI manuscript files found
in $dir into one huge file.  To reduce file size, only interesting sections are
retained, eg. all <ab> text is removed.

The corpus.xml file is used to speed up subsequent transformations.

Transforms: $(MSS_DIR)/%.xml -> $(CACHE_DIR)/lists/corpus.xml : make=false

Scrape: mss $(CACHE_DIR)/lists/corpus.xml

-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xsl tei cap"
    version="3.0">

  <xsl:import href="common-3.xsl" />

  <xsl:param name="dir" />

  <xsl:template name="main">
    <teiCorpus>
      <teiHeader />

      <xsl:for-each select="collection (concat ('file:///', $dir, '?select=*.xml;on-error=warning'))">
        <xsl:sort select="cap:natsort (document-uri (.))" />
        <xsl:apply-templates select="." />
      </xsl:for-each>

    </teiCorpus>
  </xsl:template>

  <xsl:template match="/TEI">
    <TEI>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="cap:file" select="document-uri (..)"/>

      <xsl:apply-templates />
    </TEI>
  </xsl:template>

  <xsl:template match="fileDesc/titleStmt/respStmt">
  </xsl:template>

  <xsl:template match="fileDesc/publicationStmt">
  </xsl:template>

  <xsl:template match="msContents/summary">
  </xsl:template>

  <xsl:template match="encodingDesc">
  </xsl:template>

  <xsl:template match="additional">
    <additional>
      <listBibl>
        <listBibl type="cap">
          <!-- to generate a link into the pdf on the downloads page -->
          <xsl:apply-templates select=".//bibl[@corresp='#Mordek_1995']" />
        </listBibl>
      </listBibl>
    </additional>
  </xsl:template>

  <xsl:template match="front">
  </xsl:template>

  <xsl:template match="msItem">
    <msItem>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select=".//locus"/>
      <xsl:apply-templates select=".//title[@corresp]"/>
    </msItem>
  </xsl:template>

  <xsl:template match="ab[@corresp][not (@prev)][not (.//milestone[@corresp][@unit='span'])] |
                       milestone[@corresp][not (@prev)][@unit='span']">
    <xsl:choose>
      <xsl:when test="local-name (.) = 'ab'">
        <milestone unit="chapter" corresp="{@corresp}">
          <xsl:if test="not (/TEI[@xml:id = 'bk-textzeuge'])">
            <xsl:attribute name="locus" select="@xml:id"/>
          </xsl:if>
        </milestone>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select=".//milestone|.//cb|.//lb" />
      </xsl:when>

      <xsl:when test="local-name (.) = 'milestone'">
        <milestone unit="chapter" corresp="{@corresp}">
          <xsl:if test="not (/TEI[@xml:id = 'bk-textzeuge'])">
            <xsl:attribute name="locus" select="ancestor::*[@xml:id][1]/@xml:id" />
          </xsl:if>
        </milestone>
        <xsl:text> </xsl:text>
      </xsl:when>

      <xsl:otherwise>
        <!-- not interested -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ab">
    <xsl:apply-templates select=".//milestone|.//cb|.//lb" />
  </xsl:template>

  <xsl:template match="/TEI[@xml:id = 'bk-textzeuge']/text/body/comment()">
    <!-- throw away lots of commented-out text in bk-textzeuge -->
  </xsl:template>

  <xsl:template match="/TEI[@xml:id = 'bk-textzeuge']/text/body//@xml:id">
    <!-- xml:ids in bk-textzeuge are no loci -->
  </xsl:template>

  <xsl:template match="@rend">
  </xsl:template>

  <xsl:template match="@* | element () | text () | comment ()">
    <!-- copy everything yet get rid of processing instructions -->
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
