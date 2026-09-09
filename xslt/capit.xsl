<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs a single Capitulary page.

Transforms: $(CAPIT_DIR)/pre814/%.xml  -> $(CACHE_DIR)/capits/pre814/%.html
Transforms: $(CAPIT_DIR)/ldf/%.xml     -> $(CACHE_DIR)/capits/ldf/%.html
Transforms: $(CAPIT_DIR)/post840/%.xml -> $(CACHE_DIR)/capits/post840/%.html
Transforms: $(CAPIT_DIR)/undated/%.xml -> $(CACHE_DIR)/capits/undated/%.html
Transforms: $(CAPIT_DIR)/iv/ldf%.xml -> $(CACHE_DIR)/capits/iv/ldf/%.html

URL: $(CACHE_DIR)/capits/pre814/%.html  /capit/pre814/%/
URL: $(CACHE_DIR)/capits/ldf/%.html     /capit/ldf/%/
URL: $(CACHE_DIR)/capits/post840/%.html /capit/post840/%/
URL: $(CACHE_DIR)/capits/undated/%.html /capit/undated/%/
URL: $(CACHE_DIR)/capits/iv/ldf/%.html /capit/iv/ldf/%/

Target: capits $(CACHE_DIR)/capits/pre814/%.html
Target: capits $(CACHE_DIR)/capits/ldf/%.html
Target: capits $(CACHE_DIR)/capits/post840/%.html
Target: capits $(CACHE_DIR)/capits/undated/%.html
Target: capits $(CACHE_DIR)/capits/iv/ldf/%.html

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
      <xsl:call-template name="render-concordance"/>
      
      <!-- Combined newEdition block from all sections -->
      <xsl:if test="//note[@type='newEdition']">
        <div>
          <h4 id="newEdition">[:de]Neue Edition[:en]New Edition[:]</h4>
          <table>
            <tbody>
              <xsl:apply-templates select="//note[@type='newEdition']/node()"/>
            </tbody>
          </table>
        </div>
        <hr/>
      </xsl:if>

      <!-- Process each section div individually -->
      <xsl:for-each select="text/body/div">
        <xsl:call-template name="render-section">
          <xsl:with-param name="section-content" select="."/>
        </xsl:call-template>
      </xsl:for-each>

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


   <xsl:template name="render-concordance">
    <xsl:variable name="all-items" select="//list[@type='concordance']//item"/>

    <xsl:if test="exists($all-items)">
      <div class="concordances">
        <xsl:variable name="iv-items" select="$all-items[starts-with(@corresp, 'IV.')]"/>

        <xsl:choose>
          <xsl:when test="not(empty($iv-items))">
            <span class="ab-note">[:de]Entspricht[:en]Corresponds to[:] </span>

            <xsl:for-each-group select="$all-items" group-by="ref/@target">
              <xsl:sort select="replace(current-grouping-key(), 'ldf/bk-nr-', '')" data-type="number"/>

              <xsl:apply-templates select="current-group()[1]"/>
              <xsl:text>(</xsl:text>
              <xsl:for-each select="current-group()">
                <xsl:sort select="@corresp"/>
                <xsl:if test="position() > 1">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="replace(replace(@corresp, '\.', ' '), '_', ' c. ')"/>
              </xsl:for-each>
              <xsl:text>)</xsl:text>

             <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
              </xsl:if>

            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <div class="bk-note-header">
              <div class="icon"></div>
              <b>[:de]ACHTUNG![:en]ATTENTION[:]</b>
            </div>
            <span class="bk-note">
              <div>[:de]Diese Seite wird nicht mehr aktualisiert[:en]This page is no longer being updated[:]. 
              [:de]Zur Neuedition geht es hier[:en]The new edition can be found here[:]:</div>
            </span>
            <xsl:apply-templates select="$all-items"/>

          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-section">
    <xsl:param name="section-content"/>
    
    <!-- Extract section ID from head/@corresp (e.g., "IV.21a" -> "a") -->
    <xsl:variable name="head-corresp" select="$section-content/head/@corresp"/>
    <xsl:variable name="section-id" select="if (contains($head-corresp, '.')) then substring($head-corresp, string-length($head-corresp)) else 'section'"/>
    
    <!-- Create section with heading -->
    <section id="{$section-id}">
      <xsl:if test="count(/TEI/text/body/div[head]) > 1">
        <h3 id="{$section-id}">
          <xsl:value-of select="$section-content/head"/>
        </h3>
      </xsl:if>
      
      <!-- Process all child elements except head, newEdition and concordance -->
      <xsl:apply-templates select="$section-content/node()[not(self::head or self::note[@type='newEdition'] or self::list[@type='concordance'])]"/>
    </section>
  </xsl:template>


  <xsl:template match="note[@type='annotation']">
    <div class="capit-annotation">
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match="note[@type='titles']">
    <xsl:choose>
      <xsl:when test="//note[@type='newEdition']">
        <div>
          <h4 id="titles">[:de]"Titel in älteren Editionen[:en]Titles in Older Editions[:]</h4>
          <table>
            <tbody>
              <xsl:apply-templates/>
            </tbody>
          </table>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <h4 id="titles">[:de]Titel[:en]Captions[:]</h4>
          <table>
            <tbody>
              <xsl:apply-templates/>
            </tbody>
          </table>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="note[@type='date']">
    <div>
      <h4 id="date">[:de]Datierung[:en]Date[:]</h4>
      <table>
        <tbody>
          <xsl:apply-templates/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template name="resp">
    <td class="resp">
      <xsl:choose>
        <xsl:when test="editorLabel">
          <xsl:text>[:de]von[:en]by[:] </xsl:text>
          <xsl:value-of select="editorLabel/@name"/>
        </xsl:when>

        <xsl:when test="@resp='bk'">
          <xsl:text>[:de]bei[:en]by[:] </xsl:text>
          <xsl:text>Boretius/Krause</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[:de]bei[:en]by[:] </xsl:text>
          <xsl:value-of select="@resp"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td class="value">
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  
  <xsl:template match="citedRange">
    <xsl:text>S. </xsl:text>
    <xsl:value-of select="@from"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@to"/>
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
    <xsl:choose>
    <xsl:when test="parent::list[@type='concordance']">
      <!-- Apply ref template -->
      <xsl:apply-templates/>
      <!-- if ref/corresp holds kapitel-info, print it  -->
      <xsl:if test="contains(ref/@corresp, '_')">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="replace(replace(ref/@corresp, '\.', ' '), '_', ' c. ')"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>

    </xsl:when>
    <xsl:otherwise>
      <tr>
        <td class="value">
          <xsl:if test="@corresp">
            <xsl:variable name="id" select="replace (replace (substring-before (../../head, ':'), ' Nr. ', '_'), ' ', '_')"/>
            <xsl:variable name="norm-id" select="replace($id, '(^[A-Za-z_]+)0+([0-9]+$)', '$1$2')"/>          
            <xsl:variable name="path"  select="concat ('/mss/', @corresp, '/')"/>
            <xsl:variable name="href"  select="concat ('/mss/', @corresp, '#', replace ($norm-id, 'BK_185', 'BK_185A'))"/>
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
    </xsl:otherwise>
    </xsl:choose>
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
