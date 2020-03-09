<?xml version="1.0" encoding="UTF-8"?>

<!--

This stylesheet splits one TEI manuscript into its @correps.
It reassembles @corresps split into multiple <ab>s and <milestone>s.

Sometimes there are more than one copy of the same capitular in a manuscript. In
this case each copy gets its own section.

Plain text versions are generated along the TEI versions. These are already
preprocessed for collation and fulltext search.

Sections are gathered by following @next links through <ab>s and/or from
<milestone>s to <anchor>s.  For the details, see:
https://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402

Transforms: $(MSS_DIR)/%.xml -> $(CACHE_DIR)/extracted/%.xml

Scrape: extracted $(CACHE_DIR)/extracted/%.xml

Target: extraction $(CACHE_DIR)/extracted/%.xml

-->

<stylesheet
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

  <xsl:include href="common-3.xsl"/>

  <template name="collect">
    <!-- Collect the whole text of a chapter that may be spread over multiple
         <ab next="">s and/or <milestone spanTo="">s. -->
    <choose>
      <when test="local-name (.) = 'ab'">
        <tei:ab>
          <copy-of select="node()|@*" />
          <for-each select="key ('id', substring-after (@next, '#'))">
            <!-- recurse -->
            <call-template name="collect" />
          </for-each>
        </tei:ab>
      </when>
      <when test="local-name (.) = 'milestone'">
        <tei:milestone>
          <copy-of select="@*" />
        </tei:milestone>
        <variable name="to"  select="substring-after (concat (@spanTo, @next), '#')" />
        <copy-of select="following-sibling::node ()[(following-sibling::*|self::*)[@xml:id = $to]]" />
        <for-each select="key ('id', $to)">
          <!-- recurse -->
          <call-template name="collect" />
        </for-each>
      </when>
      <otherwise>
        <!-- not interested -->
      </otherwise>
    </choose>
  </template>

  <template match="/TEI">
    <tei:TEI>
      <copy-of select="@*"/>
      <tei:list>
        <variable name="body" select="text/body" />
        <variable name="all_corresps" select="string-join ($body//@corresp, ' ')" />

        <for-each-group select="tokenize (normalize-space ($all_corresps), ' ')" group-by="." >
          <sort select="cap:natsort (.)"/>

          <variable name="corresp" select="current-grouping-key ()"/>

          <!-- iterate over multiple copies of the same @corresp -->
          <iterate
              select="$body//tei:ab[contains-token (@corresp, $corresp)][not (@prev)][not (.//tei:milestone[@corresp][@unit='span'])] |
                      $body//tei:milestone[contains-token (@corresp, $corresp)][not (@prev)][@unit='span']">
            <param name="n" select="1" as="xs:integer" />

            <variable name="extracted">
              <call-template name="collect" />
            </variable>

            <text>&#x0a;</text>
            <text>&#x0a;</text>
            <tei:item corresp="{$corresp}_{$n}" cap:hands="{cap:hands ($extracted)}">
              <copy-of select="$extracted"/>
            </tei:item>

            <!-- go to the next corresp -->

            <next-iteration>
              <with-param name="n" select="$n + 1"/>
            </next-iteration>
          </iterate>
        </for-each-group>
      </tei:list>
    </tei:TEI>
  </template>

  <template match="@*|node ()">
    <copy>
      <apply-templates select="@*|node()" />
    </copy>
  </template>

</stylesheet>
