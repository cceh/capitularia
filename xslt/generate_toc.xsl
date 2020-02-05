<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs a content div for insertion in a manuscript file.

Input files: /mss/*.xml

Output: divContent

Needs SAXON !!! (Saxon does not grok str:concat (), but our editors use Saxon,
so we have to use string-join () instead, which is XPath 2.0).

  $ saxon xml-file xsl-file

Einige Anpassungswünsche (06.10.16):

Interpunktionszeichen sollen herausgefiltert werden;
abbr innerhalb von choice sowie numDenom sollen ebenfalls nicht angezeigt werden;
Reihenfolge: num soll immer am Anfang eines items stehen;
schon in divContent vorhandene items (Identifizierung über ptr target) bei einem wiederholten Generieren weglassen;
meta-text-Elemente nach einem milestone unit=”capitulatio” bis zum anchor xml:id=”capitulatio-finis_[XYZ]”
nicht herausfiltern, bis auf das erste meta-text-Element (Beginn der Capitulatio).

-->

<xsl:stylesheet
    version="2.0"
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
    <div type="content">
      <list>
        <xsl:apply-templates select=".//tei:ab" />
      </list>
    </div>
  </xsl:template>

  <xsl:template match="tei:ab[@type='meta-text']">
    <xsl:variable name="target"               select="concat ('#', @xml:id)"/>
    <xsl:variable name="old-entry"            select="//tei:ptr[@target = $target]" />
    <xsl:variable name="n"                    select="count (preceding-sibling::tei:ab[@type='meta-text']) + 1"/>
    <xsl:variable name="start-capitulatio"    select="preceding-sibling::tei:milestone[@unit='capitulatio'][1]" />
    <xsl:variable name="capitulatio"          select="substring-after ($start-capitulatio/@spanTo, '#')" />
    <xsl:variable name="end-capitulatio"      select="following::tei:anchor[@xml:id=$capitulatio]" />
    <xsl:variable name="first-in-capitulatio" select="$start-capitulatio/following-sibling::tei:ab[1] = self::*" />
    <xsl:variable name="filter-capitulatio"   select="$capitulatio and $end-capitulatio and not ($first-in-capitulatio)" />

    <xsl:if test="not ($filter-capitulatio) and not ($old-entry)">
      <item n="{$n * 10}">
        <ptr type="internal" target="{$target}" />
        <xsl:variable name="text">
          <span class="tei-seg tei-seg-num">
            <xsl:apply-templates select=".//tei:seg[@type='num']" mode="num"/>
          </span>
          <xsl:text> </xsl:text>
          <xsl:apply-templates/>
        </xsl:variable>
        <!-- libxsl version: <xsl:value-of select="normalize-space (translate (str:concat
             (exsl:node-set ($text)), '.,:;!?*', ''))"/>
        -->
        <!-- Saxon version: -->
        <xsl:value-of select="normalize-space (translate (string-join ($text, ''), '.,:;!?*', ''))"/>
      </item>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:ab[@type='text']">
    <xsl:variable name="target"          select="concat ('#', @xml:id)"/>
    <xsl:variable name="n"               select="count (preceding-sibling::tei:ab[@type='meta-text']) + 1"/>
    <xsl:variable name="old-entry"       select="//tei:ptr[@target = $target]" />

    <xsl:if test="preceding-sibling::tei:ab[1][self::*[@type='text']] and not ($old-entry)">
      <item n="{$n * 10}">
        <ptr type="internal" target="{$target}"/>
        <xsl:comment>meta-text fehlt</xsl:comment>
      </item>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:ab" />

  <xsl:template match="tei:seg[@type='num']" mode="num">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:gap[@quantity]">
    <xsl:choose>
      <xsl:when test="number (@quantity) &lt; 3">
        <xsl:text>[</xsl:text>
        <!-- xsl:value-of select="str:padding (number (@quantity), '.')"/ -->
        <xsl:value-of select="string-join ((for $i in 1 to @quantity return '.'), '')"/>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[...]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:seg[@type='num']"/>
  <xsl:template match="tei:note"/>
  <xsl:template match="tei:del"/>
  <xsl:template match="tei:choice/tei:abbr"/>
  <xsl:template match="tei:numDenom/tei:abbr"/>

</xsl:stylesheet>
