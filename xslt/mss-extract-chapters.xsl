<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet splits one TEI manuscript into its @correps.
It reassembles @corresps split into multiple <ab>s and <milestone>s.

Sometimes there are more than one copy of the same capitular in a manuscript. In
this case each copy gets its own section.

Plain text versions are generated along the TEI versions. These are already
preprocessed for collation and fulltext search.

Sections are gathered by following @next links through <ab>s and/or from
<milestone>s to <anchor>s.  For the details, see:
https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

Transforms: $(MSS_DIR)/%.xml -> $(CACHE_DIR)/extracted/%.xml

Scrape: extracted $(CACHE_DIR)/extracted/%.xml

Target: extraction $(CACHE_DIR)/extracted/%.xml

-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:import href="common-3.xsl" />

  <xsl:template match="/TEI">
    <TEI>
      <xsl:copy-of select="@*"/>
      <list>
        <xsl:variable name="body" select="text/body" />
        <xsl:variable name="all_corresps" select="string-join ($body//@corresp, ' ')" />

        <xsl:for-each-group select="tokenize (normalize-space ($all_corresps), ' ')" group-by="." >
          <xsl:sort select="cap:natsort (.)"/>

          <xsl:variable name="corresp" select="current-grouping-key ()"/>

          <!-- iterate over multiple copies of the same @corresp -->
          <xsl:iterate
              select="$body//tei:ab[contains-token (@corresp, $corresp)][not (@prev)][not (.//tei:milestone[@corresp][@unit='span'])] |
                      $body//tei:milestone[contains-token (@corresp, $corresp)][not (@prev)][@unit='span']">
            <xsl:param name="n" select="1" as="xs:integer" />

            <xsl:variable name="extracted">
              <xsl:call-template name="collect" />
            </xsl:variable>

            <xsl:text>&#x0a;</xsl:text>
            <xsl:text>&#x0a;</xsl:text>
            <item corresp="{$corresp}_{$n}" cap:hands="{cap:hands ($extracted)}">
              <xsl:copy-of select="$extracted"/>
            </item>

            <!-- go to the next corresp -->

            <xsl:next-iteration>
              <xsl:with-param name="n" select="$n + 1"/>
            </xsl:next-iteration>
          </xsl:iterate>
        </xsl:for-each-group>
      </list>
    </TEI>
  </xsl:template>

  <xsl:template match="@*|node ()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
