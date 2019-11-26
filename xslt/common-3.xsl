<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:key name="id" match="*" use="@xml:id" />

  <xsl:variable name="hand-names">
    <item key="X">
      <name>Korrekturhand 1</name>
    </item>
    <item key="Y">
      <name>Korrekturhand 2</name>
    </item>
    <item key="Z">
      <name>Korrekturhand 3</name>
    </item>
  </xsl:variable>

  <xsl:template name="collect">
    <!-- Collect the whole text of a chapter that may be spread over multiple
         <ab next="">s and/or <milestone spanTo="">s. -->
    <xsl:choose>
      <xsl:when test="local-name (.) = 'ab'">
        <ab>
          <xsl:copy-of select="node()|@*" />
          <xsl:for-each select="key ('id', substring-after (@next, '#'))">
            <!-- recurse -->
            <xsl:call-template name="collect" />
          </xsl:for-each>
        </ab>
      </xsl:when>
      <xsl:when test="local-name (.) = 'milestone'">
        <milestone>
          <xsl:copy-of select="@*" />
        </milestone>
        <xsl:variable name="to"  select="substring-after (concat (@spanTo, @next), '#')" />
        <xsl:copy-of select="following-sibling::node ()[(following-sibling::*|self::*)[@xml:id = $to]]" />
        <xsl:for-each select="key ('id', $to)">
          <!-- recurse -->
          <xsl:call-template name="collect" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- not interested -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="cap:hands">
    <!-- Return a sequence of all hands used inside element e

    -->
    <xsl:param name="e" />

    <xsl:sequence>
      <xsl:if test="$e//@hand">
        <xsl:for-each-group select="$e//@hand" group-by=".">
          <xsl:sort select="." />
          <xsl:value-of select="current-grouping-key ()"/>
        </xsl:for-each-group>
      </xsl:if>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="cap:get-rend">
    <!--
        Get the nearest @rend attribute.

        The effective @rend attribute is the one on the nearest ancestor.
    -->
    <xsl:param name="e" />

    <xsl:sequence>
      <xsl:choose>
        <xsl:when test="$e/@rend">
          <xsl:value-of select="$e/@rend"/>
        </xsl:when>
        <xsl:when test="$e/self::tei:body">
          <!-- don't look higher than the <body> -->
          <xsl:value-of select="''" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="cap:get-rend ($e/parent::*)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="cap:get-rend-class">
    <xsl:param name="e" />

    <xsl:variable name="classes">
      <xsl:for-each select="tokenize (cap:get-rend ($e), '\s+')">
        <xsl:value-of select="concat ('rend-', .)"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="string-join ($classes)" />
  </xsl:function>

  <xsl:template name="handle-rend">
    <xsl:param name="extra-class" select="''" />

    <xsl:variable name="class">
      <xsl:value-of select="normalize-space (concat ($extra-class, cap:get-rend-class (.)))"/>
    </xsl:variable>

    <xsl:if test="$class != ''">
      <xsl:attribute name="class">
        <xsl:value-of select="$class" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:function name="cap:string-pad" as="xs:string">
    <xsl:param name="padCount" as="xs:integer"/>
    <xsl:param name="padString" as="xs:string?"/>
    <xsl:sequence select="string-join (for $i in 1 to $padCount return $padString)"/>
  </xsl:function>

</xsl:stylesheet>
