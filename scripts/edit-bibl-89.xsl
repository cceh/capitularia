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

  <xsl:variable name="sub">
    <item><from>MGH Capit. 1</from>               <to>Boretius 1883</to> <corresp>#Boretius_1883</corresp> </item>
    <item><from>MGH Capit. 2</from>               <to>Boretius 1897</to> <corresp>#Boretius_1897</corresp> </item>
    <item><from>MGH Capitula episcoporum 1</from> <to>Brommer 1984</to>  <corresp>#Brommer_1984</corresp>  </item>
    <item><from>MGH Conc. 6, 1 (1987)</from>      <to>Hehl 1987</to>     <corresp>#Hehl_1987</corresp>     </item>
    <item><from>MGH Conc. 6, 1</from>             <to>Hehl 1987</to>     <corresp>#Hehl_1987</corresp>     </item>
    <item><from>MGH Fontes Iuris [4]</from>       <to>Schwerin 1918</to> <corresp>#Schwerin_1918</corresp> </item>
    <item><from>MGH LL 1 (1835)</from>            <to>Pertz 1835</to>    <corresp>#Pertz_1835</corresp>    </item>
    <item><from>MGH LL 1</from>                   <to>Pertz 1835</to>    <corresp>#Pertz_1835</corresp>    </item>
  </xsl:variable>

  <xsl:template name="corresp">
    <xsl:param name="node" />
    <xsl:if test="starts-with (normalize-space ($node), tei:from)">
      <xsl:attribute name="corresp"><xsl:value-of select="tei:corresp" /></xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="sub">
    <xsl:param name="item" />
    <xsl:choose>
      <xsl:when test="starts-with (normalize-space (.), $item/tei:from)">
        <xsl:value-of select="$item/tei:to" />
        <xsl:value-of select="substring-after (., $item/tei:from)" />
      </xsl:when>
      <xsl:when test="$item/following-sibling::tei:item">
        <!-- recurse -->
        <xsl:call-template name="sub">
          <xsl:with-param name="item" select="$item/following-sibling::tei:item" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- nothing matched -->
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:teiHeader//tei:msDesc//tei:listBibl[@type='lit' or @type='cat' or @type='abb']/tei:bibl">
    <xsl:copy>
      <xsl:variable name="node" select="."/>
      <xsl:for-each select="exsl:node-set ($sub)/tei:item">
        <xsl:call-template name="corresp">
          <xsl:with-param name="node" select="$node" />
        </xsl:call-template>
      </xsl:for-each>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:teiHeader//tei:msDesc//tei:listBibl[@type='lit' or @type='cat' or @type='abb']/tei:bibl/text ()[1]">
    <xsl:call-template name="sub">
      <xsl:with-param name="item" select="exsl:node-set ($sub)/tei:item[1]" />
    </xsl:call-template>
  </xsl:template>

  <!-- copy everything else -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
