<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:param name="dir" />

  <xsl:import href="common-3.xsl" />

  <xsl:template name="main">
    <teiCorpus>
      <teiHeader />
      <xsl:apply-templates select="collection (concat ('file:///', $dir, '?select=*.xml'))" />
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
            <xsl:attribute name="locus" select="../@xml:id"/>
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
