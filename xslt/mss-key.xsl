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
    <div class="mss-key-xsl">
      <p class="intro">
        [:de]In dieser Konkordanz werden die in Mordek 1995 vergebenen Siglen
        den ausführlichen Handschriftensignaturen zugeordnet. Die Siglen Mordeks
        werden auch in der neuen Edition weiterhin verwendet. Im Rahmen der
        Editionsarbeiten neu vergebene Siglen sind mit dem Zusatz "(NEU)"
        gekennzeichnet.

        [:en]This concordance gives the shelfmarks of the sigla assigned in
        Mordek 1995 with the shelfmarks of the respective manuscripts.  The new
        edition will continue to use Mordek’s sigla.  New sigla assigned by our
        editorial team are marked with "(NEW)".

        [:]
      </p>

      <div>
        <table>
          <thead>
            <tr>
              <th class="siglum">[:de]Sigle      [:en]Sigla     [:]</th>
              <th class="mss"   >[:de]Handschrift[:en]Manuscript[:]</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="list[@id='sigla']/item|list[@id='newsigla']/item">
              <!-- horrible hack to sort P, P1, P2, P10, ...
                   instead of P, P1, P10, P2, ... in XSLT 1.0 -->
              <xsl:sort select="translate (sigle, '0123456789', '')"/>
              <xsl:sort select="number (substring (sigle, 2))" data-type="number" />
              <xsl:sort select="number (substring (sigle, 3))" data-type="number" />
              <xsl:sort select="mss"/>
            </xsl:apply-templates>
          </tbody>
        </table>
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
        <table>
          <tbody>
	        <xsl:apply-templates select="list[@id='nosigla']/item" />
          </tbody>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="item">
    <tr>
      <xsl:choose>
        <xsl:when test="parent::list[@id='sigla']">
          <td class="siglum">
            <xsl:apply-templates select="sigle"/>
          </td>
        </xsl:when>
        <xsl:when test="parent::list[@id='newsigla']">
          <td class="siglum">
            <xsl:apply-templates select="sigle"/>
            <xsl:text> [:de](NEU)[:en](NEW)[:]</xsl:text>
          </td>
        </xsl:when>
      </xsl:choose>
      <td>
        <xsl:apply-templates select="mss"/>
      </td>
    </tr>
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="mss">
    <xsl:call-template name="if-visible">
      <xsl:with-param name="path" select="concat ('/mss/', ../url)"/>
      <xsl:with-param name="text" select="text()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
