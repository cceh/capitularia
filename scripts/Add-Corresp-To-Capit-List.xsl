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

  <xsl:output method="xml" indent="no" />

  <!--
      Usage:

      cd capitularia/http/docs/cap/publ
      for src in tmp/pre814/*.xml ; do dest="capit/pre814/$(basename $src)"
        xsltproc -\-stringparam path "../capit/lists/capit_mysql.xml" transform/Add-Corresp-To-Capit-List.xsl $src > $dest
      done
  -->

  <xsl:param name="path" select="''" />

  <xsl:param name="dict" select="document ($path)" />

  <func:function name="cap:lookup">
    <!--
        Lookup a value in a mysql xml output.

        Produce the xml in this way:

        mysql -\-xml -e "select post_title, meta_value from wp_posts, wp_postmeta where post_id = ID and meta_key = 'tei-xml-id' and post_status = 'publish' order by meta_value" > $path
    -->
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <func:result select="normalize-space (exsl:node-set ($table)//row[field[@name='post_title'][normalize-space (.) = $key]]/field[@name='meta_value'])" />
  </func:function>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//tei:list[@type='transmission']/tei:item[not (@corresp)]">
    <xsl:variable name="corresp">
      <xsl:value-of select="cap:lookup ($dict, normalize-space (.))" />
    </xsl:variable>
    <xsl:copy>
      <xsl:if test="normalize-space ($corresp)">
        <xsl:attribute name="corresp">
          <xsl:value-of select="$corresp" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
