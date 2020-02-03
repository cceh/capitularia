<?xml version="1.0" encoding="UTF-8"?>

<!--
  Transforms the old-style mss_by_cap.xml into a list of manuscripts names.
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

  <xsl:template match="/Kapitularien">
    <xsl:comment>
      Liste aller Manuskripte mit xml:id, Titel und Siglum.

      Diese Liste wird von anderen Transformationen gelesen,
    </xsl:comment>
    <lists>
      <list type="manuscripts">
        <xsl:for-each-group select="Eintrag" group-by="hss/@url">
          <xsl:sort select="cap:natsort (hss/@url)"/>

          <item xml:id="{ current-grouping-key () }">
            <xsl:for-each-group select="current-group ()/hss" group-by=".">
              <xsl:sort select="normalize-space (.)"/>

              <title>
                <xsl:apply-templates />
              </title>
            </xsl:for-each-group>

            <xsl:if test="normalize-space (siglum)">
              <siglum>
                <xsl:apply-templates select="siglum"/>
              </siglum>
            </xsl:if>
          </item>
        </xsl:for-each-group>
      </list>
    </lists>
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
