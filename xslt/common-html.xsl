<?xml version="1.0" encoding="UTF-8"?>

<!-- Templates that output elements with null namespace URI.

     To output html elements without spurious namespace attributes they have to
     be in the "null namespace".  There's no way to bind the "null namespace" to
     an explicit namespace prefix, like eg. <html:div>, it must be bound to the
     empty prefix.  That forces us to litter the rest of the source with ugly
     and useless "xsl:" prefixes.  Boy, what a crap!

     See: https://www.w3.org/TR/xslt-xquery-serialization-30/#serialize-as-HTML
          https://www.oxygenxml.com/archives/xsl-list/200503/msg01066.html
-->

<xsl:stylesheet
    xmlns=""
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xhtml xsl xs fn tei cap"
    version="3.0">

  <xsl:include href="config-3.xsl"/> <!-- $tei-ref-external-targets -->

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
             title="[:de]Rechtsklick zum &quot;Speichern unter&quot;[:en]right button click to save file[:]">
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
          <span class="author"><xsl:value-of select="normalize-space ($author)"/></span>,
        </xsl:if>
        <xsl:if test="normalize-space ($title)">
          <span class="title"><xsl:value-of select="normalize-space ($title)"/></span>,
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

      <xsl:when test="@subtype='collom'">
        <a class="internal collom" href="{$blog}{@target}">
          <xsl:text>
            [:de]Zum Artikel in der Rubrik "Sammlung des Monats"
            [:en]To the "Collection of the Month" blogpost
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
