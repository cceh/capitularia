<?xml version="1.0" encoding="UTF-8"?>

<stylesheet
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <output method="text" />

  <template match="/TEI" expand-text="yes">
    <iterate select="text/body//ab[@type='text' and @corresp and not (@prev)]">
      <param name="last_corresp" select="''" as="xs:string" />

      <choose>
        <when test="$last_corresp = @corresp">
          <text>{base-uri ()} duplicate ab {@corresp}</text>
          <text>&#x0a;</text>
        </when>
        <otherwise>
          <next-iteration>
            <with-param name="last_corresp" select="@corresp"/>
          </next-iteration>
        </otherwise>
      </choose>
    </iterate>

    <for-each select="text/body//ab[@type='text' and @corresp]">
      <variable name="el" select="." />

      <variable name="corresps">
        <for-each select="tokenize ($el/@corresp)">
          <if test="matches (., '^BK')">
            <tei:item><value-of select="." /></tei:item>
          </if>
        </for-each>
      </variable>

      <if test="count ($corresps/item) > 1">
        <for-each select="$corresps/item">
          <variable name="corresp" select="string (.)" />

          <if test="not ($el//milestone[contains-token (@corresp, $corresp)])">
            <text>{base-uri ($el)} {$el/@corresp} missing milestone for {$corresp}</text>
            <text>&#x0a;</text>
          </if>
        </for-each>
      </if>
    </for-each>


  </template>

</stylesheet>
