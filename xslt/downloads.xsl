<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xhtml cap xsl"
    version="3.0">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/teiCorpus">
    <div class='resources-downloads'>
      <table>
        <thead>
          <tr>
            <th class='title'>[:de]Handschrift[:en]Manuscript[:]</th>
            <th class='xml-download'>[:de]XML-Dateien[:en]XML-Files[:]</th>
            <th class='pdf-download'>[:de]Beschreibung (Mordek 1995)[:en]Description (Mordek 1995)[:]</th>
          </tr>
        </thead>
        <xsl:for-each-group
            select="TEI"
            group-by="substring (normalize-space (teiHeader/fileDesc/titleStmt/title[@type='main']), 1, 1)">
          <xsl:sort select="normalize-space (teiHeader/fileDesc/titleStmt/title[@type='main'])" />

          <xsl:text>&#x0a;[if_any_visible path="</xsl:text>
            <xsl:value-of select="string-join (current-group ()/concat ('/mss/', @xml:id), ' ')" />
          <xsl:text>"]&#x0a;</xsl:text>

          <tbody>
            <tr>
              <th id="{current-grouping-key ()}" colspan='3'>
                <xsl:value-of select="current-grouping-key ()" />
              </th>
            </tr>

            <xsl:for-each select="current-group ()">
              <xsl:sort select="normalize-space (teiHeader/fileDesc/titleStmt/title[@type='main'])" />

              <xsl:variable name="mordek">
                <xsl:analyze-string select="substring-after ((.//bibl[@corresp='#Mordek_1995'])[1], 'S.')"
                                    regex="(\d+)">
                  <xsl:matching-substring>
                    <tei:num><xsl:value-of select="." /></tei:num>
                  </xsl:matching-substring>
                </xsl:analyze-string>
              </xsl:variable>

              <xsl:text>&#x0a;[if_visible path="</xsl:text>
                <xsl:value-of select="concat ('/mss/', @xml:id)" />
              <xsl:text>"]&#x0a;</xsl:text>

              <tr class='mss-status-post-status-private'>
                <td class='title'>
                  <a href="{concat ('/mss/', @xml:id)}">
                    <xsl:apply-templates
                        select="teiHeader/fileDesc/titleStmt/title[@type='main']" />
                  </a>
                </td>
                <td class='xml-download'>
                  <xsl:text>(</xsl:text>
                  <a href="{concat ('/cap/publ/mss/', @xml:id, '.xml')}" target='_blank'>xml</a>
                  <xsl:text>)</xsl:text>
                </td>
                <td class='pdf-download'>
                  <xsl:if test="$mordek/num">
                    <xsl:text>(</xsl:text>
                    <!-- 45 == pdf page offset -->
                    <a href="{concat ('/cap/publ/resources/Mordek_Bibliotheca_1995.pdf#page=', number ($mordek/num[1]) + 45)}"
                       target='_blank'>
                      <xsl:text>pdf S. </xsl:text>
                      <xsl:value-of select="string-join ($mordek/num[position () &lt; 3], '-')" />
                    </a>
                    <xsl:text>)</xsl:text>
                  </xsl:if>
                </td>
              </tr>
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
