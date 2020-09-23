<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet splits one TEI manuscript into its @correps.
It reassembles @corresps split into multiple <ab>s and <milestone>s.

Sometimes there are more than one copy of the same capitular in a manuscript. In
this case each copy gets its own section.

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
    exclude-result-prefixes="tei xs xsl"
    version="3.0">

  <xsl:include href="common-3.xsl"/>

  <xsl:template name="collect">
    <!-- Collect the whole text of a chapter that may be spread over multiple
         <ab next="">s and/or <milestone spanTo="">s. -->
    <xsl:choose>
      <xsl:when test="self::ab">
        <xsl:text>&#x0a;  </xsl:text>
        <ab>
          <xsl:copy-of select="node()|@*" />
        </ab>

        <xsl:variable name="next" select="substring-after (@next,  '#')" />
        <xsl:for-each select="key ('id', $next)">
          <!-- recurse -->
          <xsl:call-template name="collect" />
        </xsl:for-each>
      </xsl:when>

      <xsl:when test="self::milestone">
        <xsl:text>&#x0a;  </xsl:text>
        <milestone>
          <xsl:copy-of select="@*" />
        </milestone>

        <xsl:variable name="to" select="substring-after (@spanTo, '#')" />
        <xsl:copy-of select="following-sibling::node ()[(following-sibling::*|self::*)[@xml:id = $to]]" />

        <xsl:variable name="next" select="substring-after (@next, '#')" />
        <xsl:for-each select="key ('id', $next)">
          <!-- recurse -->
          <xsl:call-template name="collect" />
        </xsl:for-each>
      </xsl:when>

      <xsl:otherwise>
        <!-- not interested -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ab|ab//milestone">
    <xsl:variable name="extracted">
      <xsl:call-template name="collect" />
    </xsl:variable>

    <xsl:variable name="hands">
      <xsl:value-of select="cap:hands ($extracted)" />
    </xsl:variable>

    <xsl:for-each select="tokenize (normalize-space (@corresp), ' ')">
      <xsl:text>&#x0a;</xsl:text>
      <xsl:text>&#x0a;</xsl:text>
      <div corresp="{.}" cap:hands="{$hands}">
        <xsl:copy-of select="$extracted" />
        <xsl:text>&#x0a;</xsl:text>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="milestone[@unit='capitulare']" priority="2">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/TEI">
    <TEI>
      <xsl:copy-of select="@*"/>
      <!-- skip all else -->
      <xsl:apply-templates
          select="text/body/ab[@corresp][not (@prev)][not (.//milestone[@corresp][@unit='span'])] |
                  text/body/ab//milestone[@corresp][not (@prev)][@unit='span'] |
                  text/body//milestone[@unit='capitulare']" />
    </TEI>
  </xsl:template>

  <xsl:template match="@*|node ()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
