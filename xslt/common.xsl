<xsl:stylesheet
    version="1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">

  <xsl:template name="back-to-top">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <div class="back-to-top">
	  <a class="ssdone" title="Zum Seitenanfang" href="#top"></a>
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template name="back-to-top-hr">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <div class="back-to-top back-to-top-with-rule">
	  <a class="ssdone" title="Zum Seitenanfang" href="#top"></a>
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template name="back-to-top-compact">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <div class="back-to-top back-to-top-compact">
	  <a class="ssdone" title="Zum Seitenanfang" href="#top"></a>
    </div>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template name="hr">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <div class="hr" />
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template name="page-break">
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <div class="page-break" />
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
