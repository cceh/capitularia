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

  <func:function name="cap:make-id">
    <!--
        Replace characters that are invalid in a HTML id.

        Also remove characters that need escaping in jQuery selectors.
    -->
    <xsl:param name="id"/>
    <func:result select="translate ($id, ' .:,;!?+', '________')"/>
  </func:function>

  <func:function name="cap:lookup-element">
    <!--
        Lookup an element in a `table´.

        The `table´ is a variable that contains a sequence of <item> elements.  Each <item> has a
        @key attribute and contains the element to return.
    -->
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <func:result select="exsl:node-set ($table)/item[@key=$key]"/>
  </func:function>

  <func:function name="cap:lookup-value">
    <!--
        Lookup a value in a `table´.

        The `table´ is a variable that contains a sequence of <item> elements.  Each <item> has a
        @key attribute and a @value attribute, which is returned.
    -->
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <func:result select="exsl:node-set ($table)/item[@key=$key]/@value"/>
  </func:function>

  <func:function name="cap:human-readable-siglum">
    <!--
        Make a siglum human-readable.

        "BK.001"   => "BK 1"
        "BK_020a"  => "BK 20a"
        "Mordek_7" => "Mordek 7"
    -->
    <xsl:param name="siglum"/>

    <func:result select="str:replace (str:replace (str:replace (str:replace ($siglum, '.', '_'), '_00', ' '), '_0', ' '), '_', ' ')"/>
  </func:function>

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

  <xsl:template name="if-published-then-else">
    <xsl:param name="path"/>
    <xsl:param name="then"/>
    <xsl:param name="else"/>

    <xsl:text>[if_status status="publish" path="</xsl:text>
    <xsl:value-of select="$path"/>
    <xsl:text>"]</xsl:text>
    <xsl:copy-of select="$then"/>
    <xsl:text>[/if_status]</xsl:text>

    <xsl:text>[if_not_status status="publish" path="</xsl:text>
    <xsl:value-of select="$path"/>
    <xsl:text>"]</xsl:text>
    <xsl:copy-of select="$else"/>
    <xsl:text>[/if_not_status]</xsl:text>
  </xsl:template>

  <xsl:template name="if-published">
    <xsl:param name="path"/> <!-- test path -->
    <xsl:param name="text"/>
    <xsl:param name="href"   select="$path" />
    <xsl:param name="title"  select="''"/>
    <xsl:param name="target" select="''"/>

    <xsl:call-template name="if-published-then-else">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="then">
        <a href="{$href}">
          <xsl:if test="$title">
            <xsl:attribute name="title">
              <xsl:value-of select="$title"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="$target">
            <xsl:attribute name="target">
              <xsl:value-of select="$target"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$text"/>
        </a>
      </xsl:with-param>
      <xsl:with-param name="else">
        <xsl:copy-of select="$text"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
