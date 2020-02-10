<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet takes one TEI manuscript file and breaks it up into sections by
their @corresp attribute.  It then outputs one TEI file and one or more plain
text files for each section.

Sometimes there are more than one copy of the same capitular in a manuscript. In
this case each copy gets its own sections and files.

Plain text versions are generated along the TEI versions. These are already
preprocessed for collation and fulltext search.

Sections are gathered by following @next links through <ab>s and/or from
<milestone>s to <anchor>s.  For the details, see:
https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

Transforms: $(MSS_DIR)/%.xml -> $(CACHE_DIR)/extracted/%/ : make=false

Scrape: fulltext $(CACHE_DIR)/extracted/%/

Target: fulltext $(CACHE_DIR)/extracted/%/

-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    default-mode="extract"
    version="3.0">

  <xsl:param name="directory" />

  <xsl:import href="mss-transcript-collation.xsl" />

  <xsl:template match="/">
    <xsl:variable name="body" select="/TEI/text/body" />
    <xsl:variable name="all_corresps" select="string-join (.//@corresp, ' ')" />

    <xsl:for-each-group select="tokenize (normalize-space ($all_corresps), ' ')" group-by="." >
      <xsl:sort select="."/>

      <xsl:variable name="corresp" select="current-grouping-key ()"/>

      <xsl:iterate
          select="$body//tei:ab[@corresp = $corresp][not (@prev)][not (.//tei:milestone[@corresp][@unit='span'])] |
                  $body//tei:milestone[@corresp = $corresp][not (@prev)][@unit='span']">
        <xsl:param name="n" select="1" as="xs:integer" />

        <!-- <xsl:message
             expand-text="yes">{$directory}/{$corresp}_{$n}.xml</xsl:message>
             -->

        <xsl:variable name="collected">
          <xsl:call-template name="collect" />
        </xsl:variable>

        <xsl:variable name="extracted">
          <TEI>
            <xsl:copy-of select="/TEI/@*"/>
            <xsl:attribute name="cap:hands" select="cap:hands ($collected)"/>
            <text>
              <body corresp="{$corresp}" n="{$n}/{last()}">
                <xsl:copy-of select="$collected" />
              </body>
            </text>
          </TEI>
        </xsl:variable>

        <!-- build the xml file -->

        <xsl:result-document method="xml" href="{$directory}/{$corresp}_{$n}.xml">
          <xsl:copy-of select="$extracted"/>
        </xsl:result-document>

        <!-- build text files for search and collation-->

        <xsl:variable name="extracted_text">
          <!-- apply the templates in mss-transcript-collation.xsl -->
          <xsl:apply-templates select="$extracted" mode="collation">
            <xsl:with-param name="include-later-hand" select="false ()" tunnel="yes" />
          </xsl:apply-templates>
        </xsl:variable>

        <xsl:result-document method="text" href="{$directory}/{$corresp}_{$n}.txt">
          <xsl:value-of select="normalize-space ($extracted_text)" />
        </xsl:result-document>

        <!-- maybe build the "later_hands" text file -->

        <xsl:if test="contains ($extracted/TEI/@cap:hands, 'X')">
          <xsl:variable name="extracted_text_later_hands">
            <!-- apply the templates in mss-transcript-collation.xsl -->
            <xsl:apply-templates select="$extracted" mode="collation">
              <xsl:with-param name="include-later-hand" select="true ()" tunnel="yes" />
            </xsl:apply-templates>
          </xsl:variable>

          <xsl:result-document method="text" href="{$directory}/{$corresp}_{$n}_later_hands.txt">
            <xsl:value-of select="normalize-space ($extracted_text_later_hands)" />
          </xsl:result-document>
        </xsl:if>

        <!-- goto next corresp -->

        <xsl:next-iteration>
          <xsl:with-param name="n" select="$n + 1"/>
        </xsl:next-iteration>
      </xsl:iterate>
    </xsl:for-each-group>
  </xsl:template>

</xsl:stylesheet>
