<?xml version="1.0" encoding="UTF-8"?>

<!--

Diese Datei enthält Anweisungen für alle Sonderfälle, die bei
der Transformation aus dem CTE beachtet werden müssen.

Transforms: $(MSS_DIR)/texts/137.xml -> $(CACHE_DIR)/mss/cte-137.html    : title=Edition
Transforms: $(MSS_DIR)/texts/137.xml -> $(CACHE_DIR)/mss/cte-137-de.html : title=Übersetzung

URL: $(CACHE_DIR)/mss/cte-137.html    /resources/texts/ldf-bk137/
URL: $(CACHE_DIR)/mss/cte-137-de.html /resources/texts/ldf-bk137/

Target: mss $(CACHE_DIR)/mss/cte-137.html
Target: mss $(CACHE_DIR)/mss/cte-137-de.html

-->

<xsl:stylesheet
    version="1.0"
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

  <!-- 29.08. DS ### Kleinere Anpassungen zur Verarbeitung des
       nachbearbeiteten CTE-Outputs #### (ref @subtype=witness - muss
       automatisiert werden), tei:note[@type='crittext'] -->

  <xsl:import href="mss-transcript.xsl" />

  <xsl:template match="/tei:TEI">
    <!-- class=CTE is a switch for the footnote
         post-processor to leave keyboard shortcuts alone. -->
    <div class="tei-TEI mss-transcript-xsl transkription-body CTE">
      <xsl:apply-templates select="tei:text"/>
    </div>
  </xsl:template>

  <!-- undo italicizing of tei:mentioned -->
  <xsl:template match="//tei:body//tei:note[@type='textcrit']//tei:mentioned">
    <span class="regular tei-mentioned"><xsl:apply-templates /></span>
  </xsl:template>

  <!-- DS, 29.08.2016 Hinzufügung zur Verarbeitung des kritischen Textes-->
  <xsl:template match="tei:note[@type='crittext']">
    <span id="{generate-id(.)}" class="annotation annotation-comment" data-shortcuts="0">
      <xsl:call-template name="footnote-ref"/>
    </span>
  </xsl:template>

  <!-- override mss-transcript.xsl -->
  <xsl:template match="tei:sourceDesc">
    <div class="tei-sourceDesc">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:listWit">
    <!-- Momentan ausgeklammert, da sich sonst die synoptische Darstellung verschiebt -->
  <!--<div id="editorial-preface-manuscripts">
      <h5 data-cap-dyn-menu-caption="[:de]Handschriften[:en]Manuscripts[:]">[:de]Handschriften[:en]Manuscripts[:]</h5>
      <table>
      <tbody>
      <xsl:apply-templates select="tei:witness[@xml:id]" />
      </tbody>
      </table>
      </div>
      <div id="editorial-preface-prints">
      <h5 data-cap-dyn-menu-caption="[:de]Drucke[:en]Prints[:]">[:de]Drucke[:en]Prints[:]</h5>
      <table>
      <tbody>
      <xsl:apply-templates select="tei:witness[not (@xml:id)]" />
      </tbody>
      </table>
      </div>
      </xsl:template> -->
  </xsl:template>

  <xsl:template match="tei:listWit/tei:witness">
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

  <xsl:template match="tei:listWit/tei:witness/tei:title">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:ref[@type='internal' and @subtype='witness' and //tei:witness[not (@xml:id) and @n=current()/@target]]">
    <!-- <xsl:apply-templates select="//tei:witness[@n=current()/@target]/tei:title"/> -->
    <span title="{//tei:witness[@n=current()/@target]/tei:title}" class="tei-witness-siglum">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:ref[@type='internal' and @subtype='witness' and //tei:witness[@xml:id and @n=current()/@target]]">
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

    <xsl:variable name="id" select="//tei:witness[@n=current()/@target]/@xml:id"/>

    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/mss/', $id)" />
      <xsl:with-param name="href" select="concat ('/mss/', $id, '#', //tei:listWit/@n)"/>
      <xsl:with-param name="title">
        <xsl:value-of select="//tei:witness[@n=current()/@target]/tei:title"/>
      </xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
