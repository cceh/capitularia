<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs a single Capitula-Page

Input file: cap/publ/capit/ldf/bk-nr-*.xml
Output URL: /capit/ldf/bk-nr-186/

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

  <xsl:import href="common.xsl"/>

  <xsl:template match="/tei:TEI">
    <div class="capit-xsl">
      <xsl:apply-templates select="tei:text/tei:body/tei:div/tei:note[@type='annotation']"/>
      <xsl:apply-templates select="tei:text/tei:body/tei:div/tei:note[@type='titles']"/>
      <xsl:apply-templates select="tei:text/tei:body/tei:div/tei:note[@type='date']"/>
      <xsl:apply-templates select="tei:text/tei:body/tei:div/tei:list[@type='transmission']"/>
      <xsl:apply-templates select="tei:text/tei:body/tei:div/tei:listBibl[@type='literature']"/>
      <xsl:apply-templates select="tei:text/tei:body/tei:div/tei:listBibl[@type='translation']"/>

      <xsl:call-template name="hr"/>

      <div id="download">
        <h5>[:de]Download[:en]Downloads[:]</h5>
        <ul class="downloads">
          <li class="download-icon">
            <!-- http://capitularia.uni-koeln.de/cap/publ/capit/ldf/bk-nr-148.xml -->
            <xsl:variable name="url"
                          select="concat ($capit_downloads, @corresp, '.xml')"/>
            <a class="screen-only ssdone" href="{$url}"
               title='[:de]Rechtsklick zum "Speichern unter"[:en]right button click to save file[:]'>
              <xsl:text>[:de]Datei in XML[:en]File in XML[:]</xsl:text>
            </a>
            <div class="print-only">
              <xsl:text>[:de]Datei in XML[:en]File in XML[:] </xsl:text>
              <xsl:value-of select="$url"/>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="tei:note[@type='annotation']">
    <div class="capit-annotation">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:note[@type='titles' or @type='date']">
    <div>
      <h4 id="{@type}">
        <xsl:if test="@type='titles'">
          [:de]Titel in älteren Editionen
          [:en]Captions used in older editions
          [:]
        </xsl:if>
        <xsl:if test="@type='date'">
          [:de]Datierung
          [:en]Origin
          [:]
        </xsl:if>
      </h4>
      <table>
        <tbody>
          <xsl:apply-templates/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template name="resp">
    <td class="resp">
      <xsl:text>[:de]bei[:en]by[:] </xsl:text>
      <xsl:if test="@resp!='bk'">
        <xsl:value-of select="@resp"/>
      </xsl:if>
      <xsl:if test="@resp='bk'">
        <xsl:text>Boretius/Krause</xsl:text>
      </xsl:if>
    </td>
    <td class="value">
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="tei:name | tei:note[@type='date']/tei:date">
    <tr>
      <xsl:call-template name="resp"/>
    </tr>
  </xsl:template>

  <xsl:template match="tei:list[@type='transmission']">
    <div>
      <h4 id="transmission">[:de]Überlieferung[:en]Transmission[:]</h4>
      <table>
        <tbody>
          <xsl:apply-templates/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="tei:item">
    <tr>
      <td class="value">
        <xsl:if test="@corresp">
          <xsl:variable name="id" select="str:replace (substring-before (../../tei:head, ':'), ' Nr. ', '_')"/>
          <xsl:variable name="path"  select="concat ('/mss/', @corresp)"/>
          <xsl:variable name="href"  select="concat ('/mss/', @corresp, '#', str:replace ($id, 'BK_185', 'BK_185A'))"/>
          <xsl:variable name="bk"    select="concat ('BK.', substring-after (/tei:TEI/@corresp, 'bk-nr-'))"/>
          <!-- Make a link to the manuscript if it is already published, else: no link, just the
               name. -->
          <xsl:call-template name="if-visible-then-else">
            <xsl:with-param name="path"  select="$path"/>
            <xsl:with-param name="then">
              <a class="internal" href="{$path}"
                 title="[:de]Zur Handschrift[:en]Go to the manuscript[:]">
                <xsl:apply-templates />
              </a>
              <!-- Add a deep link to the capitular if it is already transcribed in that ms. -->
              <xsl:text>[if_transcribed path="</xsl:text>
              <xsl:value-of select="$path"/>
              <xsl:text>" bk="</xsl:text>
              <xsl:value-of select="$bk"/>
              <xsl:text>"]</xsl:text>
              <a class="internal transcription" href="{$href}"
                 title="[:de]Zur Transkription[:en]Go to the transcription[:]">
              </a>
              <xsl:text>[/if_transcribed]</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="else">
              <xsl:apply-templates />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not (@corresp)">
          <xsl:apply-templates/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:listBibl[@type='literature' or @type='translation']">
    <div>
      <h4 id="{@type}">
        <xsl:if test="@type='literature'">
          [:de]Literatur[:en]References[:]
        </xsl:if>
        <xsl:if test="@type='translation'">
          [:de]Übersetzungen[:en]Translations[:]
        </xsl:if>
      </h4>
      <table>
        <tbody>
          <xsl:apply-templates select="tei:bibl"/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="tei:bibl">
    <tr>
      <td>
        <xsl:if test="@corresp">
          <a class="internal bib" href="{$biblio}{@corresp}"
             title="[:de]Zum bibliographischen Eintrag[:en]Go to bibliography[:]">
            <xsl:apply-templates/>
          </a>
        </xsl:if>
        <xsl:if test="not (@corresp)">
          <xsl:apply-templates/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:lb">
    <br/>
  </xsl:template>

</xsl:stylesheet>
