<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs the transcription section of a single manuscript page with editor
comments.  Used internally by the editors.

Transforms: $(CACHE_DIR)/mss/%.transcript.phase-1.xml -> $(CACHE_DIR)/mss/%.transcript.commented.html

URL: $(CACHE_DIR)/mss/%.transcript.commented.html /internal/mss-comments/%/

Target: mss $(CACHE_DIR)/mss/%.transcript.commented.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <xsl:import href="mss-transcript-phase-2.xsl" />

  <xsl:template match="comment ()">
    <xsl:text> </xsl:text>
    <span class="xml-comment" style="font-size: small">
      <xsl:text>Comment: </xsl:text>
      <xsl:value-of select="." />
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

</xsl:stylesheet>
