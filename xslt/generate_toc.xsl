<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs a content div for insertion in a manuscript file.

Input file: cap/mss/*
Output: divContent

Einige Anpassungswünsche (06.10.16):

Interpunktionszeichen sollen herausgefiltert werden;
abbr innerhalb von choice sowie numDenom sollen ebenfalls nicht angezeigt werden;
Reihenfolge: num soll immer am Anfang eines items stehen;
schon in divContent vorhandene items (Identifizierung über ptr target) bei einem wiederholten Generieren weglassen;
meta-text-Elemente nach einem milestone unit=”capitulatio” bis zum anchor xml:id=”capitulatio-finis_[XYZ]”
nicht herausfiltern, bis auf das erste meta-text-Element (Beginn der Capitulatio).

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

  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>

  <xsl:template match="/">
    <div type="content" xml:id="divContent">
      <list>
        <xsl:apply-templates select=".//tei:ab[@type='meta-text']" />
      </list>
    </div>
  </xsl:template>

  <xsl:template match="tei:ab[@type='meta-text']">
    <xsl:variable name="target"          select="concat ('#', @xml:id)"/>
    <xsl:variable name="n"               select="count (preceding-sibling::tei:ab[@type='meta-text']) + 1"/>
    <xsl:variable name="capitulatio"     select="substring-after (preceding-sibling::tei:milestone[@unit='capitulatio'][1]/@spanTo, '#')" />
    <xsl:variable name="end-capitulatio" select="following-sibling::tei:anchor[@xml:id=$capitulatio]" />
    <xsl:variable name="old-entry"       select="//tei:ptr[@target = $target]" />

    <xsl:if test="not ($capitulatio and $end-capitulatio and ($n > 1)) and not ($old-entry)">
      <item n="{$n}">
        <ptr type="internal" target="{$target}" />
        <xsl:variable name="text">
          <xsl:apply-templates select="tei:seg[@type='num']" mode="num"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="normalize-space (translate (str:concat (exsl:node-set ($text)), '.,:;!?*', ''))"/>
      </item>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:seg[@type='num']" mode="num">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:seg[@type='num']"/>
  <xsl:template match="tei:note"/>
  <xsl:template match="tei:del"/>
  <xsl:template match="tei:choice/tei:abbr"/>
  <xsl:template match="tei:numDenom/tei:abbr"/>

</xsl:stylesheet>
