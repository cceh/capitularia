<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs the transcription section of a single manuscript page with editor
comments.  Used internally by the editors.

Input files:  /mss/*.xml
Output files: /cache/mss/*.transcript.commented.html

URL: /cache/mss/*.transcript.commented.html /internal/mss-comments/*/

-->

<xsl:stylesheet
    version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#default tei"
    extension-element-prefixes="cap exsl func set str">
  <!-- libexslt does not support the regexp extension ! -->

  <xsl:import href="mss-transcript.xsl" />

  <xsl:template match="comment ()">
    <xsl:text> </xsl:text>
    <span class="xml-comment" style="font-size: small">
      <xsl:text>Comment: </xsl:text>
      <xsl:value-of select="." />
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

</xsl:stylesheet>
