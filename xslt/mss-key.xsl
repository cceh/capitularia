<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL: /mss/key/
Input file: cap/publ/mss/lists/sigle.xml
Old name:   IdnoSynopse.xsl

-->

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
  <!-- libexslt does not support the regexp extension ! -->

  <xsl:include href="common.xsl"/>

  <xsl:template match="/lists">
    <div class="mss-key">
      <p class="intro">
        [:de]In dieser Konkordanz werden die in Mordek 1995 vergebenen Siglen den ausführlichen
        Handschriftensignaturen zugeordnet. Die Siglen Mordeks werden auch in der neuen Edition
        weiterhin verwendet.
        [:en]This concordance gives the shelfmarks of the sigla assigned in Mordek 1995 with the
        shelfmarks of the respective manuscripts.  The new edition will continue to use Mordek’s
        sigla.
        [:]
      </p>

      <div>
        <h4 id="sigla">
          [:de]Handschriften, denen Mordek eine Sigle zugewiesen hat
          [:en]Manuscripts with sigla (allocated by Mordek)
          [:]
        </h4>
	    <xsl:apply-templates select="list[@id='sigla']"/>
      </div>

      <div>
        <h4 id="newsigla">
          [:de]Handschriften, denen im Rahmen der Neuedition eine Sigle zugewiesen wurde
          [:en]Manuscripts with new sigla (allocated by the editors)
          [:]
        </h4>
        <xsl:apply-templates select="list[@id='newsigla']"/>
      </div>

      <div>
        <h4 id="no_sigla">
          [:de]Handschriften ohne Sigle
          [:en]Manuscripts without sigla
          [:]
        </h4>
        <p>
          [:de]Bei den folgenden Codices handelt es sich entweder um Neufunde oder um
          Handschriften, die Mordek zwar erwähnt, ihnen aber keine Sigle zuwies.
          [:en]Listed below are manuscripts that were either newly discovered or that were
          mentioned by Mordek, but with no sigla attributed to them.
          [:]
        </p>
	    <xsl:apply-templates select="list[@id='nosigla']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="list[item[normalize-space (sigle)]]">
    <table>
      <thead>
        <tr>
          <th class="siglum">[:de]Sigle      [:en]Sigla     [:]</th>
          <th class="mss"   >[:de]Handschrift[:en]Manuscript[:]</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates mode="with-sigla"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="list">
    <table>
      <tbody>
        <xsl:apply-templates/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="item" mode="with-sigla">
    <tr>
      <td class="siglum">
        <xsl:apply-templates select="sigle"/>
      </td>
      <td class="mss">
        <xsl:apply-templates select="mss"/>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="item">
    <tr>
      <td>
        <xsl:apply-templates select="mss"/>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="mss">
    <xsl:call-template name="if-published">
      <xsl:with-param name="path" select="concat ('/mss/', ../url)"/>
      <xsl:with-param name="text" select="text()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
