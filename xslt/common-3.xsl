<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xsl xs fn tei cap"
    version="3.0">

  <xsl:include href="config-3.xsl"/>

  <xsl:key name="id" match="*" use="@xml:id" />

  <xsl:variable name="hand-names">
    <item key="X">
      <name>Korrekturhand 1</name>
    </item>
    <item key="Y">
      <name>Korrekturhand 2</name>
    </item>
    <item key="Z">
      <name>Korrekturhand 3</name>
    </item>
  </xsl:variable>

  <!-- xsl functions -->

  <!-- Natural Sort (XSLT 3)

       Sorts numerical parts of ids and other strings in the expected natural way, eg.

       paris-bn-lat-1603
       paris-bn-lat-4613
       paris-bn-lat-10758
       paris-bn-lat-18237

       It does this by prefixing all runs of digits with the length of the run, eg.

       1   => 11
       12  => 212
       123 => 3123

       Usage example:

         <xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:fn="http://www.w3.org/2005/xpath-functions"
              xmlns:cap="http://cceh.uni-koeln.de/capitularia"
              exclude-result-prefixes="xsl fn cap"
              version="3.0">

         <xsl:for-each select="ms">
           <xsl:sort select="cap:natsort (@xml:id)" />
           <tr><td><xsl:value-of select="@xml:id" /></td></tr>
         </xsl:for-each>
  -->

  <xsl:function name="cap:natsort">
    <xsl:param name="s"/>

    <xsl:variable name="r">
      <!-- match either a string of digits in group 1 or a string of not-digits in group 2 -->
      <xsl:for-each select="analyze-string (string ($s), '0*([0-9]+)|([^0-9]+)')/fn:match">
        <xsl:if test="fn:group[@nr=1]">
          <xsl:value-of select="string (string-length (fn:group[@nr=1]))" />
          <xsl:value-of select="fn:group[@nr=1]" />
        </xsl:if>
        <xsl:if test="fn:group[@nr=2]">
          <xsl:value-of select="fn:group[@nr=2]" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="string-join ($r)"/>
  </xsl:function>

  <xsl:function name="cap:hands">
    <!-- Return a sequence of all hands used inside element e

    -->
    <xsl:param name="e" />

    <xsl:sequence>
      <xsl:if test="$e//@hand">
        <xsl:for-each-group select="$e//@hand" group-by=".">
          <xsl:sort select="." />
          <xsl:value-of select="current-grouping-key ()"/>
        </xsl:for-each-group>
      </xsl:if>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="cap:make-id">
    <!--
        Replace characters that are invalid in a HTML id.

        Also remove characters that need escaping in jQuery selectors.
    -->
    <xsl:param name="id"/>
    <xsl:value-of select="translate ($id, ' .:,;!?+', '________')" />
  </xsl:function>

  <xsl:function name="cap:lookup-element">
    <!--
        Lookup an element in a `table´.

        The `table´ is a variable that contains a sequence of <item> elements.  Each <item> has a
        @key attribute and contains the element to return.
    -->
    <xsl:param name="table"/>
    <xsl:param name="key"/>

    <xsl:copy-of select="$table/item[@key=string ($key)]" />
  </xsl:function>

  <xsl:function name="cap:lookup-value">
    <!--
        Lookup a value in a `table´.

        The `table´ is a variable that contains a sequence of <item> elements.  Each <item> has a
        @key attribute and a @value attribute, which is returned.
    -->
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <xsl:value-of select="$table/item[@key=string ($key)]/@value"/>
  </xsl:function>

  <xsl:function name="cap:human-readable-siglum">
    <!--
        Make a siglum human-readable.

        "BK.001"   => "BK 1"
        "BK_020a"  => "BK 20a"
        "Mordek_7" => "Mordek 7"
    -->
    <xsl:param name="siglum"/>

    <xsl:value-of select="replace ($siglum, '[_.]0*', '&#xa0;')" />
  </xsl:function>

  <xsl:function name="cap:get-rend">
    <!--
        Get the nearest @rend attribute.

        The effective @rend attribute is the one on the nearest ancestor.
    -->
    <xsl:param name="e" />

    <xsl:sequence>
      <xsl:choose>
        <xsl:when test="$e/@rend">
          <xsl:value-of select="$e/@rend"/>
        </xsl:when>
        <xsl:when test="$e/self::tei:body or not ($e/parent::*)">
          <!-- don't look higher than the <body> -->
          <xsl:value-of select="''" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="cap:get-rend ($e/parent::*)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="cap:get-rend-class">
    <xsl:param name="e" />

    <xsl:variable name="classes">
      <xsl:for-each select="tokenize (cap:get-rend ($e), '\s+')">
        <xsl:value-of select="concat ('rend-', .)"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="string-join ($classes)" />
  </xsl:function>


  <xsl:function name="cap:make-human-readable-bk">
    <!-- Make a human readable BK string.

         Transform the @corresp 'BK.123_4' to 'BK 123 c. 4'.
    -->

    <xsl:param name="corresp" /> <!-- ex default: @corresp -->

    <!-- FIXME: after we switch to saxon use regexps -->

    <xsl:variable name="search">
      <tei:item>_prolog</tei:item>
      <tei:item>_praefatio</tei:item>
      <tei:item>_epilog</tei:item>
      <tei:item>_explicit</tei:item>
      <tei:item>_a_</tei:item>
      <tei:item>_b_</tei:item>
      <tei:item>_c_</tei:item>
      <tei:item>_d_</tei:item>
      <tei:item>_e_</tei:item>
      <tei:item>_f_</tei:item>
      <tei:item>_g_</tei:item>
      <tei:item>_h_</tei:item>
      <tei:item>.</tei:item>
      <tei:item>_</tei:item>
    </xsl:variable>

    <xsl:variable name="replace">
      <tei:item> Prolog</tei:item>
      <tei:item> Praefatio</tei:item>
      <tei:item> Epilog</tei:item>
      <tei:item> Explicit</tei:item>
      <tei:item> Abschnitt A c. </tei:item>
      <tei:item> Abschnitt B c. </tei:item>
      <tei:item> Abschnitt C c. </tei:item>
      <tei:item> Abschnitt D c. </tei:item>
      <tei:item> Abschnitt E c. </tei:item>
      <tei:item> Abschnitt F c. </tei:item>
      <tei:item> Abschnitt G c. </tei:item>
      <tei:item> Abschnitt H c. </tei:item>
      <tei:item> </tei:item>
      <tei:item> c. </tei:item>
    </xsl:variable>

    <xsl:variable name="hr">
      <xsl:for-each select="tokenize ($corresp, '\s+')">
        <xsl:value-of select="normalize-space (replace (., $search/tei:item, $replace/tei:item))"/>
          <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="normalize-space ($hr)"/>
  </xsl:function>

  <xsl:function name="cap:strip-ignored-corresp">
    <!-- Remove @corresp tokens containing '_inscriptio' '_incipit', and 'explicit'.
    -->

    <xsl:param name="corresp" /> <!-- ex default: @corresp -->

    <xsl:variable name="result">
      <xsl:for-each select="tokenize ($corresp, '\s+')">
        <xsl:if test="not (contains (., '_inscriptio') or contains (., '_incipit') or contains (., 'explicit'))">
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="normalize-space ($result)"/>
  </xsl:function>

  <xsl:function name="cap:string-pad" as="xs:string">
    <xsl:param name="padCount" as="xs:integer"/>
    <xsl:param name="padString" as="xs:string?"/>
    <xsl:sequence select="string-join (for $i in 1 to $padCount return $padString)"/>
  </xsl:function>

  <!-- xsl templates -->

  <xsl:template name="collect">
    <!-- Collect the whole text of a chapter that may be spread over multiple
         <ab next="">s and/or <milestone spanTo="">s. -->
    <xsl:choose>
      <xsl:when test="local-name (.) = 'ab'">
        <ab>
          <xsl:copy-of select="node()|@*" />
          <xsl:for-each select="key ('id', substring-after (@next, '#'))">
            <!-- recurse -->
            <xsl:call-template name="collect" />
          </xsl:for-each>
        </ab>
      </xsl:when>
      <xsl:when test="local-name (.) = 'milestone'">
        <milestone>
          <xsl:copy-of select="@*" />
        </milestone>
        <xsl:variable name="to"  select="substring-after (concat (@spanTo, @next), '#')" />
        <xsl:copy-of select="following-sibling::node ()[(following-sibling::*|self::*)[@xml:id = $to]]" />
        <xsl:for-each select="key ('id', $to)">
          <!-- recurse -->
          <xsl:call-template name="collect" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- not interested -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

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
    <xsl:param name="class" select="'internal'"/>
    <xsl:param name="title"  select="''"/>
    <xsl:param name="target" select="''"/>

    <xsl:call-template name="if-visible-then-else">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="then">
        <a class="{$class}" href="{$href}">
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

  <xsl:template name="downloads">
    <xsl:param name="url" />

    <div id="downloads">
      <h5>[:de]Download[:en]Downloads[:]</h5>
      <ul class="downloads">
        <li class="download-icon">
          <a class="screen-only ssdone" href="{$url}"
             title='[:de]Rechtsklick zum "Speichern unter"[:en]right button click to save file[:]'>
            <xsl:text>[:de]Datei in XML[:en]File in XML[:]</xsl:text>
          </a>
          <div class="print-only">
            <xsl:text>[:de]Datei in XML[:en]File in XML[:] </xsl:text>
            <xsl:value-of select="$url"/>
          </div>
        </li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="cite_as">
    <xsl:param name="author" />
    <xsl:param name="title">
      <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']" />
    </xsl:param>

    <div class="citation">
      <h5>[:de]Empfohlene Zitierweise[:en]How to cite[:]</h5>
      <div>
        <xsl:if test="normalize-space ($author)">
          <span class='author'><xsl:value-of select="normalize-space ($author)"/></span>,
        </xsl:if>
        <xsl:if test="normalize-space ($title)">
          <span class='title'><xsl:value-of select="normalize-space ($title)"/></span>,
        </xsl:if>
        [:de]
        in: Capitularia. Edition der fränkischen Herrschererlasse,
        bearb. von Karl Ubl und Mitarb., Köln 2014 ff.
        URL: [permalink] (abgerufen am [current_date])
        [:en]
        in: Capitularia. Edition of the Frankish Capitularies,
        ed. by Karl Ubl and collaborators, Cologne 2014 ff.
        URL: [permalink] (accessed on [current_date])
        [:]
      </div>
    </div>
  </xsl:template>

  <!-- Verlinkungen zu Resourcen -->
  <xsl:template name="make-link-to-resource">
    <xsl:variable name="target" select="cap:lookup-element ($tei-ref-external-targets, @subtype)"/>
    <xsl:choose>
      <xsl:when test="$target">
        <a class="external" href="{string ($target/prefix)}{@target}{string ($target/postfix)}"
           target="_blank" title="{string ($target/caption)}">
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
        <xsl:variable name="class">
          <xsl:choose>
            <xsl:when test="normalize-space (.)">
              <xsl:text>internal</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="preceding-sibling::*">
                  <xsl:text>internal next-transcription</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>internal prev-transcription</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="title">
          <xsl:choose>
            <xsl:when test="normalize-space (.)">
              <xsl:text>[:de]Zur Handschrift[:en]To the manuscript[:]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="preceding-sibling::*">
                  <xsl:text>[:de]Zur Fortsetzung der Transkription[:en]To the next part of the transcription[:]</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[:de]Zum vorangehenden Teil der Transkription[:en]To the previous part of the transcription[:]</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="@target">
            <xsl:variable name="target">
              <!-- example target="vatikan-bav-reg-lat-980_f14rv" -->
              <xsl:value-of select="replace (@target, '_', '#')"/>
            </xsl:variable>
            <xsl:call-template name="if-visible">
              <xsl:with-param name="path"  select="substring-before (concat ('/mss/', $target, '#'), '#')"/>
              <xsl:with-param name="href"  select="concat ('/mss/', $target)"/>
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="class" select="$class"/>
              <xsl:with-param name="text">
                <xsl:apply-templates />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="@subtype='capit'">
        <a class="internal" href="{$capit}{@target}" title="[:de]Zum Kapitular[:en]To the respective capitulary[:]">
          <xsl:apply-templates/>
        </a>
      </xsl:when>

      <xsl:when test="@subtype='mom'">
        <a class="internal mom" href="{$blog}{@target}">
          <xsl:text>
            [:de]Zum Artikel in der Rubrik "Handschrift des Monats"
            [:en]To the "Manuscript of the Month" blogpost
            [:]
          </xsl:text>
        </a>
      </xsl:when>

      <xsl:when test="@subtype='com'">
        <a class="internal com" href="{$blog}{@target}">
          <xsl:text>
            [:de]Zum Artikel in der Rubrik "Kapitular des Monats"
            [:en]To the "Capitulary of the Month" blogpost
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
