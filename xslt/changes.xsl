<?xml version="1.0" encoding="UTF-8"?>

<!--

Input files:  /cache/lists/corpus.xml
Output files: /cache/lists/changes.html /cache/lists/changes90.html

URL: /cache/lists/changes.html   /mss/status/
URL: /cache/lists/changes90.html /mss/status/

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xhtml xs xsl cap"
    version="3.0">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- Prefix all ids with this string.
       So you can add multiple tables to one page. -->
  <xsl:param name="prefix" select="'A'" />

  <!-- Only go back this long, eg. "P90D" -->
  <xsl:param name="scope" select="''" />

  <xsl:variable name="cutoff">
    <xsl:choose>
      <xsl:when test="$scope = ''">
        <xsl:value-of select="'1970-01-01'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="format-date (current-date () - xs:dayTimeDuration ($scope), '[Y0001]-[M01]-[D01]')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/teiCorpus">
    <xsl:comment>Cutoff date: <xsl:value-of select="$cutoff" /></xsl:comment>
    <div class='mss-changes'>
      <table>
        <!-- loop on title initial -->
        <!-- compare on the stringified dates
             because some dates found in @when show the year only -->
        <xsl:for-each-group
            select="TEI[.//revisionDesc/change/@when &gt; $cutoff]"
            group-by="substring (normalize-space (teiHeader/fileDesc/titleStmt/title[@type='main']), 1, 1)">
          <xsl:sort select="normalize-space (teiHeader/fileDesc/titleStmt/title[@type='main'])" />

          <xsl:text>&#x0a;[if_any_visible path="</xsl:text>
            <xsl:value-of select="string-join (current-group ()/concat ('/mss/', @xml:id), ' ')" />
          <xsl:text>"]&#x0a;</xsl:text>

          <tbody>
            <tr>
              <th id="{$prefix}{current-grouping-key ()}" colspan='2'>
                <xsl:value-of select="current-grouping-key ()" />
              </th>
            </tr>

            <!-- loop on title -->
            <xsl:for-each select="current-group ()">
              <xsl:sort select="normalize-space (teiHeader/fileDesc/titleStmt/title[@type='main'])" />

              <xsl:text>&#x0a;[if_visible path="</xsl:text>
                <xsl:value-of select="concat ('/mss/', @xml:id)" />
              <xsl:text>"]&#x0a;</xsl:text>

              <tr>
                <td colspan='2' class='mss-status-post-status-{}'>
                  <a href="{concat ('/mss/', @xml:id)}">
                    <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title[@type='main']" />
                  </a>
                </td>
              </tr>

              <!-- loop on changes -->
              <xsl:for-each select=".//revisionDesc/change[not (starts-with (., 'Datei erstellt'))]">
                <tr>
                  <td class='date'><xsl:value-of select="@when" /></td>
                  <td class='what'><xsl:value-of select="." /></td>
                </tr>
              </xsl:for-each>

              <xsl:text>&#x0a;[/if_visible]&#x0a;</xsl:text>
            </xsl:for-each>

          </tbody>

          <xsl:text>&#x0a;[/if_any_visible]&#x0a;</xsl:text>

        </xsl:for-each-group>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="note">
  </xsl:template>

</xsl:stylesheet>
