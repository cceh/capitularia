<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:param name="dir" />
  <xsl:param name="dir2" select="''" />

  <xsl:import href="common-3.xsl" />

  <xsl:template name="main">
    <teiCorpus>
      <teiHeader />
      <xsl:apply-templates select="collection (concat ('file:///', $dir, '?select=*.xml'))" />
      <xsl:if test="$dir2 != ''">
        <xsl:apply-templates select="collection (concat ('file:///', $dir2, '?select=*.xml'))" />
      </xsl:if>
    </teiCorpus>
  </xsl:template>

  <xsl:template name="hands">
    <xsl:param name="e" />
    <xsl:if test="$e//@hand">
      <xsl:attribute name="cap:hands">
        <xsl:for-each-group select="$e//@hand" group-by=".">
          <xsl:sort select="." />
          <xsl:value-of select="current-grouping-key ()"/>
        </xsl:for-each-group>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/TEI">
    <TEI>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="cap:file"  select="document-uri (..)"/>
      <xsl:call-template name="hands">
        <xsl:with-param name="e" select="." />
      </xsl:call-template>

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

  <xsl:template match="ab[@corresp][not (@prev)]">
    <xsl:if test="not (.//milestone[@unit='span'][@corresp][not (@prev)])">
      <milestone unit="chapter" corresp="{@corresp}">
      <xsl:if test="not (/TEI[@xml:id = 'bk-textzeuge'])">
        <xsl:attribute name="locus" select="@xml:id"/>
      </xsl:if>
        <xsl:call-template name="hands">
          <xsl:with-param name="e">
            <xsl:call-template name="collect" />
          </xsl:with-param>
        </xsl:call-template>
      </milestone>
      <xsl:text> </xsl:text>
    </xsl:if>
    <ab>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select=".//milestone|.//cb|.//lb" />
    </ab>
  </xsl:template>

  <xsl:template match="milestone[@unit='span'][@corresp][not (@prev)]">
    <milestone unit="chapter" corresp="{@corresp}">
      <xsl:if test="not (/TEI[@xml:id = 'bk-textzeuge'])">
        <xsl:attribute name="locus" select="@xml:id"/>
      </xsl:if>
      <xsl:call-template name="hands">
        <xsl:with-param name="e">
          <xsl:call-template name="collect" />
        </xsl:with-param>
      </xsl:call-template>
    </milestone>
  </xsl:template>

  <xsl:template match="ab">
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
