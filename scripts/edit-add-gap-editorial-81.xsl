<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
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

  <xsl:output method="xml" indent="no" encoding="UTF-8" />

  <xsl:template name="gap">
    <!-- add <gap reason="editorial"> before . -->
    <!-- avoid duplicating gap tags   -->
    <xsl:if test="not (preceding-sibling::*[1][self::tei:gap[@reason='editorial']])">
      <gap reason="editorial"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:cb[not (ancestor::tei:ab)][preceding-sibling::tei:ab][following-sibling::*[1][self::tei:lb]]">
    <xsl:call-template name="gap"/>
  </xsl:template>

  <xsl:template match="tei:lb[@n][not (ancestor::tei:ab)][preceding-sibling::tei:ab][not (preceding-sibling::*[1][self::tei:cb])]">
    <xsl:call-template name="gap"/>
  </xsl:template>

  <!-- copy everything else -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
