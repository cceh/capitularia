<?xml version="1.0" encoding="UTF-8"?>

<!--

Output URL: /mss/capit/
Input file: cap/publ/mss/lists/mss_by_cap.xml
Old name:   tabelle_cap_mss.xsl

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

  <!-- With this key we simulate the XSL 2.0 distinct-values () function. -->
  <xsl:key name="id" match="/Kapitularien/Eintrag" use="Kapitular/@id" />

  <xsl:template match="/Kapitularien">
    <div class="mss-capit-xsl">
      <p class="intro">
        [:de]Die folgende, nach den Nummern der Boretius/Krause-Edition (BK) geordnete Liste führt
        alle Handschriften auf, die das jeweilige Kapitular enthalten. Grundlage hierfür ist das
        „Verzeichnis der Kapitularien und kapitulariennahen Texte“ in Mordek 1995,
        S. 1079-1111. Werden dort einzelne Nummern der Boretius/Krause-Edition nicht behandelt,
        tauchen sie auch hier nicht auf. Die Kapitulariensammlung des Ansegis (ediert von Gerhard
        Schmitz bei den <a title="MGH"
        href="http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._II" target="_blank">MGH</a>)
        wurde dagegen in die Übersicht aufgenommen, obwohl sie nicht Teil des Editionsprojektes ist.

        [:en]This table of capitularies, ordered by their number in the edition by Boretius/Krause,
        records all manuscripts containing the respective capitulary. It is based on Mordek 1995,
        pp. 1079-1111 (“Verzeichnis der Kapitularien und kapitulariennahen Texte”).  Capitularies
        not listed there but edited by Boretius/Krause have been omitted here, too. However the
        collection of capitularies by Ansegis (edited by Gerhard Schmitz for the <a title="MGH"
        href="http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._II" target="_blank">MGH</a>)
        has been included despite not being part of the current project.

        [:]
      </p>

      <div id="content">

        <h4 id="BK">
          [:de]Von Boretius/Krause edierte Kapitularien
          [:en]Capitularies edited by Boretius/Krause
          [:]
        </h4>

        <table class="handschriften">
          <thead valign="top" id="BK">
            <th class="capit"><h5>[:de]Titel        [:en]Caption    [:]</h5></th>
            <th class="mss"  ><h5>[:de]Handschriften[:en]Manuscripts[:]</h5></th>
          </thead>
          <tbody>
            <xsl:for-each select="Eintrag[starts-with (Kapitular/@id, 'BK')]">
              <xsl:sort select="substring-after (Kapitular/@id, '.')" data-type="number"/>
              <xsl:call-template name="eintrag">
                <xsl:with-param name="prefix" select="'bk-nr-'"/>
              </xsl:call-template>
            </xsl:for-each>
          </tbody>
        </table>

        <h4 id="Mordek">
          [:de]Bei Mordek (Anhang I) gedruckte neue Texte
          [:en]New texts as printed in Mordek appendix I
          [:]
        </h4>

        <table class="handschriften">
          <thead valign="top" id="Mordek">
            <th class="capit"><h5>[:de]Titel        [:en]Caption    [:]</h5></th>
            <th class="mss"  ><h5>[:de]Handschriften[:en]Manuscripts[:]</h5></th>
          </thead>
          <tbody>
            <xsl:for-each select="Eintrag[starts-with (Kapitular/@id, 'Mordek')]">
              <xsl:sort select="substring-after (Kapitular/@id, '.')" data-type="number"/>
              <xsl:call-template name="eintrag">
                <xsl:with-param name="prefix" select="'mordek-nr-'"/>
              </xsl:call-template>
            </xsl:for-each>
          </tbody>
        </table>

        <h4 id="Rest">
          [:de]Weitere bei Mordek erwähnte Kapitularien und Ansegis
          [:en]Further capitularies mentioned by Mordek and Ansegis
          [:]
        </h4>

        <table class="handschriften">
          <thead valign="top" id="Rest">
            <th class="capit"><h5>[:de]Titel        [:en]Caption    [:]</h5></th>
            <th class="mss"  ><h5>[:de]Handschriften[:en]Manuscripts[:]</h5></th>
          </thead>
          <tbody>
            <xsl:for-each select="Eintrag[not (contains (Kapitular/@id, '.'))]">
              <xsl:sort select="Kapitular" />
              <xsl:call-template name="eintrag">
                <xsl:with-param name="prefix" select="''"/>
              </xsl:call-template>
            </xsl:for-each>
          </tbody>
        </table>

      </div>
    </div>
  </xsl:template>

  <xsl:template name="eintrag">
    <xsl:param name="prefix"/>

    <!-- simulate distinct-values () -->
    <xsl:if test="generate-id () = generate-id (key ('id', Kapitular/@id))">

      <xsl:variable name="path">
        <xsl:text>/capit</xsl:text>
        <xsl:choose>
          <xsl:when test="Kapitular[@list='pre814']">
            <xsl:value-of select="'/pre814'"/>
          </xsl:when>
          <xsl:when test="Kapitular[@list='post840']">
            <xsl:value-of select="'/post840'"/>
          </xsl:when>
          <xsl:when test="Kapitular[@list='undated']">
            <xsl:value-of select="'/undated'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'/ldf'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="concat ('/', $prefix, substring-after (Kapitular/@id, '.'))"/>
      </xsl:variable>

      <xsl:text>&#x0a;&#x0a;</xsl:text>
      <tr>
        <td class="capit"> <!-- id="Kapitular/@id" data-cap-dyn-menu-caption="{Kapitular}" -->
          <xsl:choose>
            <xsl:when test="$prefix">
              <xsl:call-template name="if-visible">
                <xsl:with-param name="path" select="$path"/>
                <xsl:with-param name="text">
                  <xsl:apply-templates select="Kapitular"/>
                </xsl:with-param>
              </xsl:call-template>

              <xsl:apply-templates select="note"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="Kapitular"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="Kapitular" mode="id"/>
        </td>
        <xsl:text>&#x0a;&#x0a;</xsl:text>

        <td class="mss">
          <ul class="bare">
            <xsl:for-each select="key ('id', Kapitular/@id)">
              <xsl:sort select="hss"/>
              <li>
                <xsl:call-template name="if-visible">
                  <xsl:with-param name="path" select="concat ('/mss/', hss/@url)"/>
                  <xsl:with-param name="text">
                    <xsl:apply-templates select="hss"/>
                  </xsl:with-param>
                </xsl:call-template>
              </li>
              <xsl:text>&#x0a;&#x0a;</xsl:text>
            </xsl:for-each>
          </ul>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Kapitular" mode="id">
    <xsl:if test="contains (@id, '.')">
      <div class="mss-capit-capitular-siglum">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="cap:human-readable-siglum (@id)"/>

        <xsl:if test="normalize-space (@id1)">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="cap:human-readable-siglum (@id1)"/>
        </xsl:if>

        <xsl:text>]</xsl:text>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note">
    <div class="note">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="ref[@type='external']">
    <a title="Externer Link" href="{@target}" target="_blank">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="ref[@type='internal']">
    <a title="Interner Link" href="{@target}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

</xsl:stylesheet>
