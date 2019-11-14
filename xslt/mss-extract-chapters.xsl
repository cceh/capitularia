<?xml version="1.0" encoding="UTF-8"?>

<!--

Extracts all chapters (@corresp values) from a TEI file and puts them into
separate files in a directory.  Reassembles chapters that are spread over
multiple <ab>s and/or <milestone>...<anchor>s.  Puts multiple copies of the same
chapter into separate files.

See: https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

-->

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:param name="directory" />

  <xsl:import href="common-3.xsl" />

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates select="/TEI/text/body" />
  </xsl:template>

  <xsl:template match="body">
    <xsl:variable name="body" select="." />
    <xsl:variable name="all_corresps" select="string-join (.//@corresp, ' ')" />

    <xsl:for-each-group select="tokenize (normalize-space ($all_corresps), ' ')" group-by="." >
      <xsl:sort select="."/>

      <xsl:variable name="corresp" select="current-grouping-key ()"/>

      <xsl:iterate
          select="$body//tei:ab[@corresp = $corresp][not (@prev)][not (.//tei:milestone[@corresp][@unit='span'])] |
                  $body//tei:milestone[@corresp = $corresp][not (@prev)][@unit='span']">
        <xsl:param name="n" select="1" as="xs:integer" />

        <xsl:result-document method="xml" href="{$directory}/{$corresp}_{$n}.xml">
          <TEI>
            <xsl:copy-of select="/TEI/@*"/>
            <text>
              <body corresp="{$corresp}" n="{$n}/{last()}">
                <xsl:call-template name="collect" />
              </body>
            </text>
          </TEI>
        </xsl:result-document>

        <xsl:next-iteration>
          <xsl:with-param name="n" select="$n + 1"/>
        </xsl:next-iteration>
      </xsl:iterate>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="note" />

  <xsl:template match="@* | node ()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node ()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
