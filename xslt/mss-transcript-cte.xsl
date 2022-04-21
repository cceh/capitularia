<?xml version="1.0" encoding="UTF-8"?>

<!--

Diese Datei enthält Anweisungen für alle Sonderfälle, die bei
der Transformation aus dem CTE beachtet werden müssen.

Transforms: $(CACHE_DIR)/mss/cte-137.transcript.phase-1.xml    -> $(CACHE_DIR)/mss/cte-137.html    : title=Edition
Transforms: $(CACHE_DIR)/mss/cte-137-de.transcript.phase-1.xml -> $(CACHE_DIR)/mss/cte-137-de.html : title=Übersetzung

URL: $(CACHE_DIR)/mss/cte-137.html    /resources/texts/ldf-bk137/
URL: $(CACHE_DIR)/mss/cte-137-de.html /resources/texts/ldf-bk137/

Target: mss $(CACHE_DIR)/mss/cte-137.html
Target: mss $(CACHE_DIR)/mss/cte-137-de.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <xsl:import href="mss-transcript-phase-2.xsl" />

  <!-- do not replace punctuation -->
  <xsl:template match="body">
    <!-- This is the target for the "Contents *" links in the sidebar. -->
    <div class="tei-body" id="start-of-text">
      <xsl:copy-of select="@class"/>
      <xsl:attribute name="data-shortcuts" select="0"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- undo italicizing of mentioned -->
  <xsl:template match="//body//note[@type='textcrit']//mentioned">
    <span class="regular tei-mentioned"><xsl:apply-templates /></span>
  </xsl:template>

  <!-- override mss-transcript-phase-2.xsl -->
  <xsl:template match="sourceDesc">
    <div class="tei-sourceDesc">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="listWit">
    <!-- Momentan ausgeklammert, da sich sonst die synoptische Darstellung verschiebt -->
  <!--<div id="editorial-preface-manuscripts">
      <h5 data-cap-dyn-menu-caption="[:de]Handschriften[:en]Manuscripts[:]">[:de]Handschriften[:en]Manuscripts[:]</h5>
      <table>
      <tbody>
      <xsl:apply-templates select="witness[@xml:id]" />
      </tbody>
      </table>
      </div>
      <div id="editorial-preface-prints">
      <h5 data-cap-dyn-menu-caption="[:de]Drucke[:en]Prints[:]">[:de]Drucke[:en]Prints[:]</h5>
      <table>
      <tbody>
      <xsl:apply-templates select="witness[not (@xml:id)]" />
      </tbody>
      </table>
      </div>
      </xsl:template> -->
  </xsl:template>

  <xsl:template match="listWit/witness">
    <!--Anpassen: Der @n-Wert sollte die BK-Nummer in der Form sein, in der sie in den Milestones verwendet werden-->
    <tr id="{@n}" class="tei-witness">
      <td class="tei-witness-siglum">
        <xsl:choose><xsl:when test="@n='P4'"><xsl:text>P</xsl:text><sub>4</sub></xsl:when>
        <xsl:otherwise><xsl:value-of select="@n" /></xsl:otherwise></xsl:choose>
      </td>
      <td class="tei-witness-title">
        <xsl:apply-templates />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="listWit/witness/title">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="ref[@type='internal' and @subtype='witness' and //witness[not (@xml:id) and @n=current()/@target]]">
    <!-- <xsl:apply-templates select="//witness[@n=current()/@target]/title"/> -->
    <span title="{//witness[@n=current()/@target]/title}" class="tei-witness-siglum">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="ref[@type='internal' and @subtype='witness' and //witness[@xml:id and @n=current()/@target]]">
    <!-- Hinzugefügt am 29.08.2016 durch DS für die Verarbeitung von
         Links im kritischen Text ### bitte automatisieren ###-->
    <!-- unter Rückgriff auf die listWit sollen für diejenigen
         Textzeugen (witness), die eine xml:id enthalten, Links gebaut
         werden - nimmt den @n-Wert (=Sigle) und suche den witness mit
         dem gleichen @n-Wert - falls dieser eine xml:id hat, soll ein
         Link gebaut werden, sonst nur im Tooltip der Wert des
         title-Elements angezeigt werden (gilt für Drucke etc.)  für
         die Handschriften wäre ansonsten auch der Weg über die
         sigle.xml möglich, in den alle Hss. hinterlegt sein sollten,
         jedoch keine weiteren Zeugen-->

    <xsl:variable name="id" select="//witness[@n=current()/@target]/@xml:id"/>

    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/mss/', $id)" />
      <xsl:with-param name="href" select="concat ('/mss/', $id, '#', //listWit/@n)"/>
      <xsl:with-param name="title">
        <xsl:value-of select="//witness[@n=current()/@target]/title"/>
      </xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
