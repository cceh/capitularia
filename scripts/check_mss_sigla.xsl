<?xml version="1.0" encoding="UTF-8"?>

<!--

Cross-check files sigle.xml and manuscripts.xml.

<lists>
    <list id="sigla">
        <item>
            <sigle>V41</sigle>
            <mss>Vatikan, Biblioteca Apostolica Vaticana, Vat. Lat. 4227</mss>
            <url>vatikan-bav-vat-lat-4227</url>
        </item>
    </list>
    <list id="newsigla">

<lists xmlns="http://www.tei-c.org/ns/1.0">
   <list type="manuscripts">
      <item xml:id="admont-sb-712">
         <title>Admont, Stiftsbibliothek, 712</title>
         <siglum>Ad</siglum>
      </item>
-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xhtml cap xsl"
    version="3.0">

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:param name="sigle" select="sigle.xml" />

  <xsl:variable name="sigle_xml" select="document ($sigle)"/>


  <xsl:template match="item">
    <xsl:variable name="siglum" select="$sigle_xml//*:item[string (*:url)=current()/@xml:id]/*:sigle" />

    <xsl:if test="$siglum != siglum">
      <error/>
    </xsl:if>

    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
      <xsl:for-each select="$siglum">
        <xsl:text>   </xsl:text>
        <siglum><xsl:if test="ancestor::*:list[@id='newsigla']">
          <xsl:attribute name="type" select="'new'"/>
        </xsl:if><xsl:value-of select="."/></siglum>
        <xsl:text>&#x0a;      </xsl:text>
      </xsl:for-each>
    </xsl:copy>

  </xsl:template>

  <xsl:template match="siglum" />

</xsl:stylesheet>
