<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xs xsl">

  <output method="text"/>

  <key name="xml_id" match="*" use="@xml:id"/>

  <function name="cap:basename">
    <param name="file" />
    <sequence select="tokenize ($file, '/')[last ()]" />
  </function>

  <template match="/">
    <apply-templates select="//body//*" mode="span" />
    <apply-templates select="//body//*" />
  </template>

  <template match="milestone[@unit='span'][@corresp]" mode="span">
    <variable name="e" select="." />
    <variable name="corresp" select="@corresp" />

    <if test="($e/following::ab|$e/following::milestone[@unit='span'])[@corresp = $corresp][not (@prev)]">
      <text expand-text="yes">{cap:basename (base-uri ($e))} {$corresp} no-prev&#x0a;</text>
    </if>
    <if test="($e/preceding::ab|$e/preceding::milestone[@unit='span'])[@corresp = $corresp][not (@next)]">
      <text expand-text="yes">{cap:basename (base-uri ($e))} {$corresp} no-next&#x0a;</text>
    </if>
  </template>

  <template match="*[@prev or @next]">
    <variable name="el"      select="." />
    <variable name="corresp" select="@corresp" />

    <if test="not (@xml:id)">
      <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} no-xml-id&#x0a;</text>
    </if>

    <if test="not (@corresp)">
      <text expand-text="yes">{cap:basename (base-uri ($el))} {@xml:id} no-corresp&#x0a;</text>
    </if>

    <if test="@next">
      <variable name="next"      select="substring-after (@next, '#')" />
      <variable name="target_el" select="key ('xml_id', $next)" />

      <if test="not ($target_el)">
        <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} {$next} next-no-target&#x0a;</text>
      </if>

      <if test="not ($target_el/@prev)">
        <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} {$next} next-target-no-prev&#x0a;</text>
      </if>

      <for-each select="tokenize (@corresp)">
        <if test="not (contains-token ($target_el/@corresp, .))">
          <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} {$next} next-target-no-corresp&#x0a;</text>
        </if>
      </for-each>
    </if>

    <if test="@prev">
      <variable name="prev"      select="substring-after (@prev, '#')" />
      <variable name="target_el" select="key ('xml_id', $prev)" />

      <if test="not ($target_el)">
        <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} {$prev} prev-no-target&#x0a;</text>
      </if>

      <if test="not ($target_el/@next)">
        <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} {$prev} prev-target-no-next&#x0a;</text>
      </if>

      <for-each select="tokenize (@corresp)">
        <if test="not (contains-token ($target_el/@corresp, .))">
          <text expand-text="yes">{cap:basename (base-uri ($el))} {$corresp} {$prev} prev-target-no-corresp&#x0a;</text>
        </if>
      </for-each>
    </if>
  </template>

  <template match="text ()" mode="span" />
  <template match="text ()" />

</xsl:stylesheet>
