<?xml version="1.0" encoding="UTF-8"?>

<!--
  Transforms the old-style mss_by_cap.xml into a more TEI-like format.
-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    exclude-result-prefixes="xsl xs tei cap"
    version="3.0">

  <xsl:output method="xml" indent="yes" />

  <xsl:include href="../xslt/common-3.xsl" />

  <xsl:param name="manuscripts" select="manuscripts.xml" />

  <xsl:variable name="manuscripts_xml" select="document ($manuscripts)"/>

  <xsl:template match="/Kapitularien">
    <xsl:comment>
      Dies ist die Master-Datei zur Erzeugung von https://capitularia.uni-koeln.de/mss/capit/

      Zusätzlich wird die Datei manuscripts.xml verwendet um Manuskript-Ids in Titel
      zu übersetzen.

      Der Titel eines Manuskripts wird so berechnet:

      1. Wenn msIdentifier/title vorhanden ist, wird dieser Wert übernommen.

      2. Wenn msIdentifier/@target vorhanden ist und eine entsprechende @xml:id
         in der Datei manuscripts.xml gefunden wird, so wird der Titel von dort übernommen.

      3. Ansonsten wird msIdentifier/@target als Platzhalter ausgegeben.

      Nach dem Titel wird msIdentifier/note in kleinerer Schrift ausgegeben.
    </xsl:comment>

    <lists>
      <list type="capitularies">
        <xsl:for-each-group select="Eintrag" group-by="string (Kapitular/@id)">
          <xsl:sort select="cap:natsort (current-grouping-key ())" />

          <item n="{current-grouping-key ()}">
            <title><xsl:value-of select="normalize-space (Kapitular)"/></title>
            <xsl:for-each select="current-group ()">
              <xsl:sort select="cap:natsort (hss/@url)" />
              <xsl:apply-templates />
            </xsl:for-each>
          </item>
        </xsl:for-each-group>
      </list>
    </lists>
  </xsl:template>

  <xsl:template match="hss">
    <msIdentifier>
      <xsl:choose>
        <xsl:when test="@url">
          <xsl:attribute name="target">
            <xsl:value-of select="@url"/>
          </xsl:attribute>

          <!-- add ms. title if different than canonical title
               this will override the canonical title -->
          <xsl:if test="normalize-space (.) != normalize-space ($manuscripts_xml//tei:item[@xml:id=current ()/@url]/tei:title)">
            <title>
              <xsl:apply-templates />
            </title>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <title>
            <xsl:apply-templates />
          </title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="hss"/>
    </msIdentifier>
  </xsl:template>

  <xsl:template match="Kapitular">
  </xsl:template>

  <xsl:template match="siglum">
  </xsl:template>

  <xsl:template match="note">
    <note>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </note>
  </xsl:template>

  <xsl:template match="ref">
    <ref>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </ref>
  </xsl:template>

</xsl:stylesheet>
