<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:regexp="http://exslt.org/regular-expressions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    version="1.0"
    exclude-result-prefixes="tei xhtml exslt">

  <!-- Diese Datei enthält Anweisungen für alle Sonderfälle, die bei
       der Transformation aus dem CTE beachtet werden müssen. -->

  <!-- 29.08. DS ### Kleinere Anpassungen zur Verarbeitung des
       nachbearbeiteten CTE-Outputs #### (ref @subtype=witness - muss
       automatisiert werden), tei:note[@type='crittext'] -->

  <xsl:import href="transkription_PublWP.xsl" />

  <xsl:preserve-space elements="tei:ab tei:lb tei:text tei:hi"/>

  <xsl:template match="/">
    <!-- Wrapped in div because match="/" may return only *one*
         element. class=CTE is a switch for the footnote
         post-processor to leave keyboard shortcuts alone. -->
    <div class="CTE">
      <style type="text/css">
	.tei-witness        { font-style: italic; }
	.tei-witness-siglum { font-weight: bold; color: rgb(185,41,0);}
      </style>
      <xsl:apply-imports />
    </div>
  </xsl:template>

  <!-- undo italicizing of tei:mentioned -->
  <xsl:template match="//tei:body//tei:note[@type='textcrit']//tei:mentioned">
    <span class="regular tei-mentioned"><xsl:apply-templates /></span>
  </xsl:template>


  <!-- DS, 29.08.2016 Hinzufügung zur Verarbeitung des kritischen Textes-->
  <xsl:template match="tei:note[@type='crittext']">
    <xsl:variable name="vIndex">
      <xsl:call-template name="indexOf_a">
	<xsl:with-param name="pSeq" select="$funoNumerisch"/>
	<xsl:with-param name="pNode" select="."/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="vBezug" select="."/>

    <span class="annotation annotation-comment">
      <xsl:call-template name="footnote"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:sourceDesc">
    <div class="sourceDesc">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:listWit"/><!-- Momentan ausgeklammert, da sich sonst die synoptische Darstellung verschiebt -->
    <!--<div id="editorial-preface-manuscripts">
      <h5 data-cap-dyn-menu-caption="[:de]Handschriften[:en]Manuscripts[:]">[:de]Handschriften[:en]Manuscripts[:]</h5>
      <xsl:apply-templates select="tei:witness[@xml:id]" />
    </div>
    <div id="editorial-preface-prints">
      <h5 data-cap-dyn-menu-caption="[:de]Drucke[:en]Prints[:]">[:de]Drucke[:en]Prints[:]</h5>
      <xsl:apply-templates select="tei:witness[not (@xml:id)]" />
    </div>
  </xsl:template>-->

  <xsl:template match="tei:listWit/tei:witness">
    <!--Anpassen: Der @n-Wert sollte die BK-Nummer in der Form sein, in der sie in den Milestones verwendet werden-->
    <div id="{@n}" class="tei-witness">
      <span class="tei-witness-siglum">
        <xsl:choose><xsl:when test="@n='P4'"><xsl:text>P</xsl:text><sub>4</sub></xsl:when>
          <xsl:otherwise><xsl:value-of select="@n" /></xsl:otherwise></xsl:choose>
        </span>
      <xsl:text> </xsl:text>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:listWit/tei:witness/tei:title">
    <span class="tei-witness-title">
      <xsl:apply-templates />
    </span>
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

  <!-- Links auskommentiert solange Handschriften nicht online sind  -->
   <!-- <a target="_blank">
      <xsl:attribute name="title">
	<xsl:value-of select="//tei:witness[@n=current()/@target]/tei:title"/>
      </xsl:attribute>
      <xsl:attribute name="href">
	<xsl:value-of select="$mss"/>
	<xsl:value-of select="//tei:witness[@n=current()/@target]/@xml:id"/>
	<xsl:text>#</xsl:text>
	<xsl:value-of select="//tei:listWit/@n"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:if test="string-length(node())=0">
	<xsl:text>→</xsl:text>
      </xsl:if>
    </a>
  -->
    <span title="{//tei:witness[@n=current()/@target]/tei:title}" class="tei-witness-siglum">
      <xsl:apply-templates/>
    </span></xsl:template>

</xsl:stylesheet>
