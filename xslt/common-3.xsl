<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:key name="id" match="*" use="@xml:id" />

  <xsl:template name="collect">
    <!-- Collect the whole text of a chapter that may be spread over multiple
         <ab next="">s and/or <milestone spanTo="">s. -->
    <xsl:choose>
      <xsl:when test="local-name (.) = 'ab'">
        <xsl:copy>
          <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
        <xsl:for-each select="key ('id', substring-after (@next, '#'))">
          <xsl:call-template name="collect" />
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="local-name (.) = 'milestone'">
        <xsl:variable name="to"  select="substring-after (concat (@spanTo, @next), '#')" />
        <xsl:copy>
          <xsl:apply-templates select="@*" />
        </xsl:copy>
        <xsl:apply-templates
            select="following-sibling::node ()[(following-sibling::*|self::*)[@xml:id = $to]]" />
        <xsl:for-each select="key ('id', $to)">
          <xsl:call-template name="collect" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
