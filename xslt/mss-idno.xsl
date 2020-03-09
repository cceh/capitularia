<?xml version="1.0" encoding="UTF-8"?>

<!--

Transforms: $(MSS_DIR)/lists/manuscripts.xml $(CACHE_DIR)/lists/corpus.xml -> $(CACHE_DIR)/lists/mss-idno.html : corpus=$(CACHE_DIR)/lists/corpus.xml make=false

URL: $(CACHE_DIR)/lists/mss-idno.html /mss/idno/

Target: lists $(CACHE_DIR)/lists/mss-idno.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <xsl:include href="common-3.xsl"/>
  <xsl:include href="common-html.xsl"/>

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:param name="corpus" select="corpus.xml" />

  <xsl:variable name="corpus_xml" select="document ($corpus)"/>

  <xsl:template match="/lists">
    <div class="mss-idno-xsl">
      <table>
        <tbody>
          <xsl:for-each-group select="list/item" group-by="substring (title, 1, 1)">
            <xsl:sort select="current-grouping-key ()" />

            <tr>
              <th id="{current-grouping-key ()}">
                <xsl:value-of select="current-grouping-key ()"/>
              </th>
            </tr>

            <xsl:for-each select="current-group ()">
              <xsl:sort select="cap:natsort (title)" />

              <tr>
                <td>
                  <xsl:call-template name="if-visible">
                    <xsl:with-param name="path" select="concat ('/mss/', @xml:id)"/>
                    <xsl:with-param name="text" select="string (title)"/>
                  </xsl:call-template>

                  <xsl:apply-templates select="siglum"/>

                  <!-- some urls are invalid and of the form:
                       url="urn:nbn:de:hebis:30:2-45087 http://sammlungen.ub.uni-frankfurt.de/msma/content/titleinfo/4655261"
                  -->
                  <xsl:variable
                      name="urls"
                      select="tokenize (normalize-space (string-join ($corpus_xml/teiCorpus/TEI[@xml:id=current()/@xml:id]/facsimile/graphic/@url[1], ' ')))"
                      />

                  <xsl:for-each select="$urls">
                    <xsl:if test="starts-with (., 'http')">
                      <a href="{.}" class="external" title="Zum Digitalisat"></a>
                    </xsl:if>
                  </xsl:for-each>
                </td>
              </tr>
              <xsl:text>&#x0a;&#x0a;</xsl:text>

            </xsl:for-each>
          </xsl:for-each-group>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="siglum">
    <span class="siglum">
      <xsl:text> [</xsl:text>
      <xsl:apply-templates />
      <xsl:text>]</xsl:text>

      <xsl:if test="@type = 'new'">
        <xsl:text> [:de](NEU)[:en](NEW)[:]</xsl:text>
      </xsl:if>

      <xsl:if test="@type = 'old'">
        <xsl:text> (olim)</xsl:text>
      </xsl:if>
    </span>
  </xsl:template>

</xsl:stylesheet>
