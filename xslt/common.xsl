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

  <xsl:include href="base_variables.xsl"/>

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

    <func:result select="str:replace (str:replace (str:replace (str:replace ($siglum, '.', '_'), '_00', '&#xa0;'), '_0', '&#xa0;'), '_', '&#xa0;')"/>
  </func:function>

  <func:function name="cap:get-rend">
    <!--
        Get the nearest @rend attribute.

        The effective @rend attribute is the one on the nearest ancestor.
    -->
    <xsl:param name="e" select="." />

    <func:result>
      <xsl:choose>
        <xsl:when test="$e/@rend">
          <xsl:value-of select="$e/@rend"/>
        </xsl:when>
        <xsl:when test="$e/self::tei:body">
          <!-- don't look higher than the <body> -->
          <xsl:value-of select="''" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="cap:get-rend ($e/parent::*)" />
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="cap:get-rend-class">
    <xsl:param name="e" select="." />

    <func:result>
      <xsl:for-each select="str:split (cap:get-rend ($e))">
        <xsl:value-of select="concat (' rend-', .)"/>
      </xsl:for-each>
    </func:result>
  </func:function>

  <func:function name="cap:make-human-readable-bk">
    <!-- Make a human readable BK string.

         Transform the @corresp 'BK.123_4' to 'BK 123 c. 4' and remove entries
         containing '_inscriptio' and '_incipit'.
    -->

    <xsl:param name="corresp" select="@corresp" />

    <xsl:variable name="search">
      <tei:item>_prolog</tei:item>
      <tei:item>_praefatio</tei:item>
      <tei:item>_epilog</tei:item>
      <tei:item>_explicit</tei:item>
      <tei:item>.</tei:item>
      <tei:item>_</tei:item>
    </xsl:variable>

    <xsl:variable name="replace">
      <tei:item> Prolog</tei:item>
      <tei:item> Praefatio</tei:item>
      <tei:item> Epilog</tei:item>
      <tei:item> Explicit</tei:item>
      <tei:item> </tei:item>
      <tei:item> c. </tei:item>
    </xsl:variable>

    <xsl:variable name="hr">
      <xsl:for-each select="str:split ($corresp)">
        <xsl:if test="not (contains (., '_inscriptio') or contains (., '_incipit') or contains (., 'explicit'))">
          <xsl:value-of select="normalize-space (str:replace (., exsl:node-set ($search)/tei:item, exsl:node-set ($replace)/tei:item))"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <func:result>
      <xsl:value-of select="normalize-space ($hr)"/>
    </func:result>
  </func:function>

  <xsl:template name="handle-rend">
    <xsl:param name="extra-class" select="''" />

    <xsl:variable name="class">
      <xsl:value-of select="normalize-space (concat ($extra-class, cap:get-rend-class (.)))"/>
    </xsl:variable>

    <xsl:if test="$class != ''">
      <xsl:attribute name="class">
        <xsl:value-of select="$class" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

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

  <xsl:template name="if-visible-then-else">
    <xsl:param name="path"/>
    <xsl:param name="then"/>
    <xsl:param name="else"/>

    <xsl:text>[if_visible path="</xsl:text>
    <xsl:value-of select="$path"/>
    <xsl:text>"]</xsl:text>
    <xsl:copy-of select="$then"/>
    <xsl:text>[/if_visible]</xsl:text>

    <xsl:text>[if_not_visible path="</xsl:text>
    <xsl:value-of select="$path"/>
    <xsl:text>"]</xsl:text>
    <xsl:copy-of select="$else"/>
    <xsl:text>[/if_not_visible]</xsl:text>
  </xsl:template>

  <xsl:template name="if-visible">
    <xsl:param name="path"/> <!-- test path -->
    <xsl:param name="text"/>
    <xsl:param name="href"   select="$path" />
    <xsl:param name="title"  select="''"/>
    <xsl:param name="target" select="''"/>

    <xsl:call-template name="if-visible-then-else">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="then">
        <a class="internal" href="{$href}">
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

  <!-- Verlinkungen zu Resourcen -->
  <xsl:template name="make-link-to-resource">
    <xsl:variable name="target" select="cap:lookup-element ($tei-ref-external-targets, @subtype)"/>
    <xsl:choose>
      <xsl:when test="$target">
        <a class="external" href="{string ($target/prefix)}{@target}" target="_blank" title="{string ($target/caption)}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:ref[@type='external']">
    <xsl:choose>
      <!-- bibl with @corresp already generates an <a>.  do not generate nested
           <a>s here -->
      <xsl:when test="ancestor::tei:bibl[@corresp]">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-link-to-resource" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:ref[@type='internal']">
    <xsl:choose>
      <xsl:when test="@subtype='mss'">
        <xsl:choose>
          <xsl:when test="@target">
            <xsl:variable name="target">
              <!-- example target="vatikan-bav-reg-lat-980_f14rv" -->
              <xsl:value-of select="str:replace (@target, '_', '#')"/>
            </xsl:variable>
            <xsl:call-template name="if-visible">
              <xsl:with-param name="path"  select="substring-before (concat ('/mss/', $target, '#'), '#')"/>
              <xsl:with-param name="href"  select="concat ('/mss/', $target)"/>
              <xsl:with-param name="title" select="'[:de]Zur Handschrift[:en]To the manuscript[:]'"/>
              <xsl:with-param name="text">
                <xsl:apply-templates />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="@subtype='capit'">
        <a class="internal" href="{$capit}{@target}" title="[:de]Zum Kapitular[:en]To the respective capitulary[:]">
          <xsl:apply-templates/>
        </a>
      </xsl:when>

      <xsl:when test="@subtype='mom'">
        <a class="internal" href="{$blog}{@target}" title="[:de]Zum Artikel[:en]To the manuscript of the month blogpost[:]">
          <xsl:text>
            [:de]Zum Artikel in der Rubrik "Handschrift des Monats"
            [:en]To the "Manuscript of the Month" blogpost
            [:]
          </xsl:text>
        </a>
      </xsl:when>

      <xsl:otherwise>
        <a class="internal" href="{@target}">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
