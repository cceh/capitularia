<?xml version="1.0" encoding="UTF-8"?>

<stylesheet
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xsl xs fn tei cap"
    version="3.0">

  <key name="id" match="*" use="@xml:id" />

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

         <stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:fn="http://www.w3.org/2005/xpath-functions"
              xmlns:cap="http://cceh.uni-koeln.de/capitularia"
              exclude-result-prefixes="xsl fn cap"
              version="3.0">

         <for-each select="ms">
           <sort select="cap:natsort (@xml:id)" />
           <tr><td><value-of select="@xml:id" /></td></tr>
         </for-each>
  -->

  <function name="cap:natsort">
    <param name="s"/>

    <variable name="r">
      <!-- match either a string of digits in group 1 or a string of not-digits in group 2 -->
      <for-each select="analyze-string (string ($s), '0*([0-9]+)|([^0-9]+)')/fn:match">
        <if test="fn:group[@nr=1]">
          <value-of select="string (string-length (fn:group[@nr=1]))" />
          <value-of select="fn:group[@nr=1]" />
        </if>
        <if test="fn:group[@nr=2]">
          <value-of select="fn:group[@nr=2]" />
        </if>
      </for-each>
    </variable>
    <value-of select="string-join ($r)"/>
  </function>

  <function name="cap:hands">
    <!-- Return a sequence of all hands used inside element e

    -->
    <param name="e" />

    <sequence>
      <if test="$e//@hand">
        <for-each-group select="$e//@hand" group-by=".">
          <sort select="." />
          <value-of select="current-grouping-key ()"/>
        </for-each-group>
      </if>
    </sequence>
  </function>

  <function name="cap:non-empty">
    <!--
        Test if there is any non-whitespace text in the parameter.
    -->
    <param name="elems"/>

    <sequence select="normalize-space (string-join ($elems))" />
  </function>

  <function name="cap:make-id">
    <!--
        Replace characters that are invalid in a HTML id.

        Also remove characters that need escaping in jQuery selectors.
    -->
    <param name="id"/>
    <value-of select="translate ($id, ' .:,;!?+', '________')" />
  </function>

  <function name="cap:lookup-element">
    <!--
        Lookup an element in a `table´.

        The `table´ is a variable that contains a sequence of <item> elements.  Each <item> has a
        @key attribute and contains the element to return.
    -->
    <param name="table"/>
    <param name="key"/>

    <copy-of select="$table/root/item[@key=string ($key)]" />
  </function>

  <function name="cap:lookup-value">
    <!--
        Lookup a value in a `table´.

        The `table´ is a variable that contains a sequence of <item> elements.  Each <item> has a
        @key attribute and a @value attribute, which is returned.
    -->
    <param name="table"/>
    <param name="key"/>
    <value-of select="$table/root/item[@key=string ($key)]/@value"/>
  </function>

  <function name="cap:human-readable-siglum">
    <!--
        Make a siglum human-readable.

        "BK.001"   => "BK 1"
        "BK_020a"  => "BK 20a"
        "Mordek_7" => "Mordek 7"
    -->
    <param name="siglum"/>

    <value-of select="replace ($siglum, '[_.]0*', '&#xa0;')" />
  </function>

  <function name="cap:get-rend">
    <!--
        Get the nearest @rend attribute.

        The effective @rend attribute is the one on the nearest ancestor.
    -->
    <param name="e" />

    <sequence>
      <choose>
        <when test="$e/@rend">
          <value-of select="$e/@rend"/>
        </when>
        <when test="$e/self::body or not ($e/parent::*)">
          <!-- don't look higher than the <body> -->
          <value-of select="''" />
        </when>
        <otherwise>
          <value-of select="cap:get-rend ($e/parent::*)" />
        </otherwise>
      </choose>
    </sequence>
  </function>

  <function name="cap:get-rend-class">
    <param name="e" />

    <!-- returns a leading space! -->
    <variable name="classes">
      <for-each select="tokenize (cap:get-rend ($e), '\s+')">
        <value-of select="concat (' rend-', .)"/>
      </for-each>
    </variable>

    <sequence select="string-join ($classes)" />
  </function>

  <function name="cap:replace-multi" as="xs:string?">
    <param name="arg"        as="xs:string?"/>
    <param name="changeFrom" as="xs:string*"/>
    <param name="changeTo"   as="xs:string*"/>

    <sequence select="
       if (count ($changeFrom) > 0) then
            cap:replace-multi (
               replace ($arg, $changeFrom[1], $changeTo[1]),
               $changeFrom[position() > 1],
               $changeTo[position() > 1]
            )
            else $arg
     "/>

  </function>

  <function name="cap:make-human-readable-bk" as="xs:string">
    <!-- Make a human readable BK string.

         Transform the @corresp:

           BK.123          => BK 123
           BK.123_a        => BK 123 Abschnitt A
           BK.123_4        => BK 123 c. 4
           BK.123_a_4      => BK 123 Abschnitt A c. 4
           BK.258a_1       => BK 258a c. 1
           BK_266_prolog   => BK 266 Prolog
           BK_273_b_prolog => BK 273 Abschnitt B Prolog

           Benedictus.Levita.1_279 => Benedictus Levita 1,279
           Benedictus.Levita.1,279 => Benedictus Levita
    -->

    <param name="corresp" as="xs:string?" />

    <variable name="hr" expand-text="yes">
      <for-each select="tokenize ($corresp, '\s+')">
        <!-- BK, Mordek -->
        <for-each select="analyze-string (.,
                          '^(\w+)[._](\d+[ABab]?)(?:_([a-z]))?(?:_(\d+))?(?:_(\w)(\w+)(?:_(\d+))?)?$')/fn:match">
          <value-of select="fn:group[@nr=1]" />
          <text> </text>
          <value-of select="fn:group[@nr=2]" />

          <if test="normalize-space (fn:group[@nr=3])">
            <text> Abschnitt {upper-case (fn:group[@nr=3])}</text>
          </if>
          <if test="normalize-space (fn:group[@nr=4])">
            <text> c. {fn:group[@nr=4]}</text>
          </if>
          <if test="normalize-space (fn:group[@nr=5])">
            <text> {upper-case (fn:group[@nr=5])}{fn:group[@nr=6]}</text>
          </if>
          <if test="normalize-space (fn:group[@nr=7])">
            <text> {fn:group[@nr=7]}</text>
          </if>
          <text> </text>
        </for-each>
        <!-- Benedictus Levita -->
        <for-each select="analyze-string (., '^Benedictus[.]Levita[.](\d+)_(\d+)$')/fn:match">
          <text>Benedictus Levita </text>
          <value-of select="fn:group[@nr=1]" />
          <text>,</text>
          <value-of select="fn:group[@nr=2]" />
          <text> </text>
        </for-each>
        <for-each select="analyze-string (., '^Benedictus[.]Levita$')/fn:match">
          <text>Benedictus Levita </text>
        </for-each>
      </for-each>
    </variable>

    <sequence select="normalize-space ($hr)"/>
  </function>

  <function name="cap:strip-ignored-corresp" as="xs:string">
    <!-- Remove @corresp tokens containing '_inscriptio' '_incipit', and 'explicit'.
    -->

    <param name="corresp" as="xs:string?" />

    <variable name="result">
      <for-each select="tokenize ($corresp, '\s+')">
        <if test="not (contains (., '_inscriptio') or contains (., '_incipit') or contains (., 'explicit'))">
          <value-of select="."/>
          <text> </text>
        </if>
      </for-each>
    </variable>

    <sequence select="normalize-space ($result)"/>
  </function>

  <function name="cap:string-pad" as="xs:string?">
    <!-- Credit: http://exslt.org/str/functions/padding/str.padding.function.xsl -->
    <param name="length" as="xs:integer" />
    <param name="chars"  as="xs:string?" />
    <choose>
      <when test="not ($length) or not ($chars)">
        <sequence select="''"/>
      </when>
      <otherwise>
        <variable name="string" select="concat ($chars, $chars, $chars, $chars)"/>
        <choose>
          <when test="string-length ($string) >= $length">
            <sequence select="substring ($string, 1, $length)"/>
          </when>
          <otherwise>
            <sequence select="cap:string-pad ($length, $string)"/>
          </otherwise>
        </choose>
      </otherwise>
    </choose>
  </function>

  <!-- xsl templates -->

  <template name="handle-rend">
    <param name="extra-class" />

    <variable name="class">
      <value-of select="normalize-space (string-join ((@class, $extra-class, cap:get-rend-class (.)), ' '))" />
    </variable>

    <if test="$class">
      <attribute name="class" select="$class" />
    </if>
  </template>

</stylesheet>
