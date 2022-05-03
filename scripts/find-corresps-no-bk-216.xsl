<?xml version="1.0" encoding="UTF-8"?>

<stylesheet
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:import href="../xslt/common-3.xsl" />

  <xsl:param name="dir"/>

  <output method="text" />

  <xsl:template name="main">
    <xsl:for-each select="collection (concat ('file:///', $dir, '?select=*.xml;on-error=warning'))">
      <xsl:sort select="cap:natsort (document-uri (.))" />
      <xsl:apply-templates select="." />
    </xsl:for-each>
  </xsl:template>

  <template name="tok">
    <param name="text"/>
    <param name="id"/>

    <for-each select="tokenize ($text)">
      <if test="not (matches (., '^BK') or matches (., '^Mordek'))">
        <text expand-text="yes">{.}</text>
        <text>&#x09;</text>
        <value-of select="$id"/>
        <text>&#x0a;</text>
      </if>
    </for-each>
  </template>

  <template match="ab[@corresp]">
    <call-template name="tok">
      <with-param name="text" select="@corresp"/>
      <with-param name="id" select="/TEI/@xml:id"/>
    </call-template>
  </template>

  <template match="milestone[@n]">
    <call-template name="tok">
      <with-param name="text" select="@n"/>
      <with-param name="id" select="/TEI/@xml:id"/>
    </call-template>
  </template>

  <template match="text()"/>

</stylesheet>
