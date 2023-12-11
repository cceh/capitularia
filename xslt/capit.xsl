<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs a single Capitulary page.

Transforms: $(CAPIT_DIR)/pre814/%.xml  -> $(CACHE_DIR)/capits/pre814/%.html
Transforms: $(CAPIT_DIR)/ldf/%.xml     -> $(CACHE_DIR)/capits/ldf/%.html
Transforms: $(CAPIT_DIR)/post840/%.xml -> $(CACHE_DIR)/capits/post840/%.html
Transforms: $(CAPIT_DIR)/undated/%.xml -> $(CACHE_DIR)/capits/undated/%.html

URL: $(CACHE_DIR)/capits/pre814/%.html  /capit/pre814/%/
URL: $(CACHE_DIR)/capits/ldf/%.html     /capit/ldf/%/
URL: $(CACHE_DIR)/capits/post840/%.html /capit/post840/%/
URL: $(CACHE_DIR)/capits/undated/%.html /capit/undated/%/

Target: capits $(CACHE_DIR)/capits/pre814/%.html
Target: capits $(CACHE_DIR)/capits/ldf/%.html
Target: capits $(CACHE_DIR)/capits/post840/%.html
Target: capits $(CACHE_DIR)/capits/undated/%.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <xsl:include href="common-3.xsl"/>
  <xsl:include href="common-html.xsl"/>

  <xsl:template match="/TEI">
    <div class="capit-xsl">
      <xsl:apply-templates select="text/body/div/note[@type='annotation']"/>
      <xsl:apply-templates select="text/body/div/note[@type='titles']"/>
      <xsl:apply-templates select="text/body/div/note[@type='date']"/>
      <xsl:apply-templates select="text/body/div/list[@type='transmission']"/>
      <xsl:apply-templates select="text/body/div/listBibl[@type='literature']"/>
      <xsl:apply-templates select="text/body/div/listBibl[@type='translation']"/>

      <xsl:call-template name="hr"/>

      <xsl:if test="text/body//ref[@subtype]">
        <!-- Links zum Artikel: Manuskript/Kapitular/Kapitel/Sammlung des Monats -->
        <xsl:apply-templates select="text/body//ref[@subtype='mom']"/>
        <xsl:apply-templates select="text/body//ref[@subtype='com']"/>
        <xsl:apply-templates select="text/body//ref[@subtype='chom']"/>
        <xsl:apply-templates select="text/body//ref[@subtype='collom']"/>

        <xsl:call-template name="hr"/>
      </xsl:if>

      <xsl:call-template name="cite_as">
        <xsl:with-param name="author" select="''" />
      </xsl:call-template>

      <xsl:call-template name="hr"/>

      <xsl:call-template name="downloads">
        <xsl:with-param name="url" select="concat ($capit_downloads, @corresp, '.xml')"/>
      </xsl:call-template>
    </div>
  </xsl:template>

  <xsl:template match="note[@type='annotation']">
    <div class="capit-annotation">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="note[@type='titles' or @type='date']">
    <div>
      <h4 id="{@type}">
        <xsl:if test="@type='titles'">[:de]Titel[:en]Captions[:]</xsl:if>
        <xsl:if test="@type='date'">[:de]Datierung[:en]Origin[:]</xsl:if>
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

  <xsl:template name="bibl">
    <xsl:if test="@corresp">
      <a class="internal bib" href="{$biblio}{@corresp}"
         title="[:de]Zum bibliographischen Eintrag[:en]Go to bibliography[:]">
        <xsl:apply-templates/>
      </a>
    </xsl:if>
    <xsl:if test="not (@corresp)">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="name | note[@type='date']/date">
    <tr>
      <xsl:call-template name="resp"/>
    </tr>
  </xsl:template>

  <xsl:template match="list[@type='transmission']">
    <div>
      <h4 id="transmission">[:de]Überlieferung[:en]Transmission[:]</h4>
      <table>
        <tbody>
          <xsl:apply-templates/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="item">
    <tr>
      <td class="value">
        <xsl:if test="@corresp">
          <xsl:variable name="id" select="replace (replace (substring-before (../../head, ':'), ' Nr. ', '_'), ' ', '_')"/>
          <xsl:variable name="path"  select="concat ('/mss/', @corresp, '/')"/>
          <xsl:variable name="href"  select="concat ('/mss/', @corresp, '#', replace ($id, 'BK_185', 'BK_185A'))"/>
          <!-- Make a link to the manuscript if it is already published, else: no link, just the
               name. -->
          <xsl:call-template name="if-visible-then-else">
            <xsl:with-param name="path"  select="$path"/>
            <xsl:with-param name="then">
              <a class="internal" href="{$path}"
                 title="[:de]Zur Handschrift[:en]Go to the manuscript[:]">
                <xsl:apply-templates/>
              </a>
              <!-- Add a deep link to the capitular if it is already transcribed in that ms. -->
              <xsl:text>[if_transcribed ms_id="</xsl:text>
              <xsl:value-of select="@corresp"/>
              <xsl:text>" cap_id="</xsl:text>
              <xsl:value-of select="/TEI/@corresp"/>
              <xsl:text>"]</xsl:text>
              <a class="internal transcription" href="{$href}"
                 title="[:de]Zur Transkription[:en]Go to the transcription[:]">
              </a>
              <xsl:text>[/if_transcribed]</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="else">
              <xsl:apply-templates/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not (@corresp)">
          <xsl:apply-templates/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="listBibl[@type='literature' or @type='translation']">
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
          <xsl:apply-templates select="bibl"/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="listBibl/bibl">
    <tr>
      <td>
        <xsl:call-template name="bibl" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="bibl">
    <xsl:call-template name="bibl" />
  </xsl:template>

  <xsl:template match="lb">
    <br/>
  </xsl:template>

</xsl:stylesheet>
