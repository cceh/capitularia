<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:key name="capit" match="Eintrag" use="Kapitular/@id"/>


    <xsl:template match="/">
        <div class="xsl-output">

            <style type="text/css">
                div.meta{
                    font-size:90%;
                }
                table{
                    table-layout:auto;
                    font-size:81%;
                }
                td.capit{
                    width:35%;
                    padding:2%;
                    line-height:110%;
                    align:left;
                }
                td.mss{
                    width:65%;
                    padding:2%;
                    line-height:120%;
                }
                ul{
                    line-height:130%;
                }</style>

            <a id="top"/>
            <!--                <div align="center"><a href="#BK">Von Boretius/Krause edierte Kapitularien</a><br/><a
                        href="#Mordek">Bei Mordek (Anhang I) gedruckte neue Texte</a><br/><a
                        href="#Rest">Weitere bei Mordek erwähnte Kapitularien und Ansegis</a>
                </div>-->

            <!--<div class="pager kapitularien-pager" style="font-size:95%;">
                    <ul>
                        <li>
                            <a class="ssdone" href="#BK">
                                Von Boretius/Krause<br/> edierte Kapitularien
                            </a>
                        </li>
                        <li>
                            <a class="ssdone" href="#Mordek">
                                Bei Mordek (Anhang I)<br/> gedruckte neue Texte
                            </a>
                        </li>
                        <li>
                            <a class="ssdone" href="#Rest">
                                Weitere <!-\-bei Mordek erwähnte-\-> Kapitularien<br/> und Ansegis
                            </a>
                        </li>
                    </ul>
                </div>-->
            <div id="meta">[:de]<p>Die folgende, nach den Nummern der Boretius/Krause-Edition (BK)
                    geordnete Liste führt alle Handschriften auf, die das jeweilige Kapitular
                    enthalten. Grundlage hierfür ist das „Verzeichnis der Kapitularien und
                    kapitulariennahen Texte“ in Mordek 1995, S. 1079-1111. Werden dort einzelne
                    Nummern der Boretius/Krause-Edition nicht behandelt, tauchen sie auch hier nicht
                    auf. Die Kapitulariensammlung des Ansegis (ediert von Gerhard Schmitz bei den <a
                        title="MGH" href="http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._II"
                        target="_blank">MGH</a>) wurde dagegen in die Übersicht aufgenommen, obwohl
                    sie nicht Teil des Editionsprojektes ist.</p>[:en]<p>This table of capitularies,
                    ordered by their number in the edition by Boretius/Krause, records all
                    manuscripts containing the respective capitulary. It is based on Mordek 1995,
                    pp. 1079-1111 (“Verzeichnis der Kapitularien und kapitulariennahen Texte”).
                    Capitularies not listed there but edited by Boretius/Krause have been omitted
                    here, too. However the collection of capitularies by Ansegis (edited by Gerhard
                    Schmitz for the <a title="MGH"
                        href="http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._II"
                        target="_blank">MGH</a>) has been included despite not being part of the
                    current project.</p>[:]</div>
            <div id="content">
                <!--<table rules="all" class="kapitularien">-->
                <h4 id="BK">[:de]Von Boretius/Krause edierte Kapitularien[:en]Capitularies edited by
                    Boretius/Krause[:]</h4>
                <table class="handschriften">
                    <thead valign="top" id="BK">
                        <th class="capit">
                            <h5>[:de]Titel[:en]Caption[:]</h5>
                        </th>
                        <th class="mss">
                            <h5>[:de]Handschriften[:en]Manuscripts[:]</h5>
                        </th>
                    </thead>
                    <xsl:apply-templates select="Kapitularien" mode="bk"/>
                </table>
                <xsl:call-template name="back-to-top-compact"/>
                <h4 id="Mordek">[:de]Bei Mordek (Anhang I) gedruckte neue Texte[:en]New texts as
                    printed in Mordek appendix I[:]</h4>
                <table class="handschriften">
                    <thead valign="top" id="Mordek">
                        <th class="capit">
                            <h5>[:de]Titel[:en]Caption[:]</h5>
                        </th>
                        <th class="mss">
                            <h5>[:de]Handschriften[:en]Manuscripts[:]</h5>
                        </th>
                    </thead>
                    <xsl:apply-templates select="Kapitularien" mode="mordek"/>
                </table>
                <xsl:call-template name="back-to-top-compact"/>
                <h4 id="Rest">[:de]Weitere bei Mordek erwähnte Kapitularien und Ansegis[:en]Further
                    capitularies mentioned by Mordek and Ansegis[:]</h4>
                <table class="handschriften">
                    <thead valign="top" id="Rest">
                        <th class="capit">
                            <h5>[:de]Titel[:en]Caption[:]</h5>
                        </th>
                        <th class="mss">
                            <h5>[:de]Handschriften[:en]Manuscripts[:]</h5>
                        </th>
                    </thead>
                    <xsl:apply-templates select="Kapitularien" mode="rest"/>
                </table>
                <xsl:call-template name="back-to-top-compact"/>

            </div>
        </div>
    </xsl:template>

    <!-- "Füllen" der einzelnen Spalten mit den entsprechenden Angaben (Signatur; Inhalt; Datierung; Literatur) -->

    <xsl:template match="Kapitularien" mode="bk">
        <xsl:call-template name="bk"/>
    </xsl:template>
    <xsl:template match="Kapitularien" mode="mordek">
        <xsl:call-template name="mordek"/>

    </xsl:template>
    <xsl:template match="Kapitularien" mode="rest">
        <xsl:call-template name="rest"/>

    </xsl:template>

    <xsl:template name="bk" match="Kapitularien">
        <xsl:for-each select="Eintrag[count(. | key('capit', Kapitular/@id)[1]) = 1]">
            <xsl:sort select="substring-after(Kapitular/@id,'BK.')" case-order="lower-first"
                order="ascending" data-type="number"/>
            <xsl:if test="starts-with(descendant::Kapitular/@id,'BK.')">
                <tr>
                    <td class="capit" align="left">
                        <!--                        <i>
                            <xsl:apply-templates select="Kapitular"/>
                        </i>-->
                        <xsl:choose>
                            <xsl:when test="descendant::Kapitular[@status='publ']">
                                <!--<a><xsl:attribute name="href">
                                <xsl:value-of select="$capit_ldf"/><xsl:text>bk-nr-</xsl:text><xsl:value-of select="substring-after(descendant::Kapitular/@id,'.')"/>
                            </xsl:attribute><img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                                title="Zum Kapitular" alt="->"/></a><xsl:text> </xsl:text>-->
                                <a class="ssdone">
                                    <xsl:attribute name="href">
                                        <xsl:choose>
                                    <xsl:when test="descendant::Kapitular[not(@list)]">
                                        <xsl:value-of select="$capit_ldf"/>
                                        <xsl:text>bk-nr-</xsl:text>
                                        <xsl:value-of
                                            select="substring-after(descendant::Kapitular/@id,'.')"
                                        />                                    
                                    </xsl:when>
                                            <xsl:when test="descendant::Kapitular[@list='pre814']">
                                                <xsl:value-of select="$capit_pre"/>
                                                <xsl:text>bk-nr-</xsl:text>
                                                <xsl:value-of
                                                    select="substring-after(descendant::Kapitular/@id,'.')"
                                                />    
                                            </xsl:when>
                                            <xsl:when test="descendant::Kapitular[@list='post840']">
                                                <xsl:value-of select="$capit_post"/>
                                                <xsl:text>bk-nr-</xsl:text>
                                                <xsl:value-of
                                                    select="substring-after(descendant::Kapitular/@id,'.')"
                                                />    
                                            </xsl:when>
                                            <xsl:when test="descendant::Kapitular[@list='undated']">
                                                <xsl:value-of select="$capit_undated"/>
                                                <xsl:text>bk-nr-</xsl:text>
                                                <xsl:value-of
                                                    select="substring-after(descendant::Kapitular/@id,'.')"
                                                />    
                                            </xsl:when>
                                </xsl:choose></xsl:attribute>
                                
                                        
                                    <xsl:apply-templates select="Kapitular"/>
                                    <xsl:if test="contains(Kapitular/@id,'.')">
                                        <br/>
                                        <span style="font-size:85%;font-style:normal;">
                                            <xsl:text> [</xsl:text>
                                            <xsl:value-of
                                                select="substring-before(Kapitular/@id, '.')"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:choose>
                                                <xsl:when test="starts-with(Kapitular/@id,'BK.00')"><xsl:value-of
                                                    select="substring-after(Kapitular/@id, '.00')"/></xsl:when>
                                                <xsl:when test="starts-with(Kapitular/@id,'BK.0')"><xsl:value-of
                                                    select="substring-after(Kapitular/@id, '.0')"/></xsl:when>
                                                <xsl:otherwise><xsl:value-of
                                                    select="substring-after(Kapitular/@id, '.')"/></xsl:otherwise>
                                            </xsl:choose>
                                           
                                            
                                            <xsl:if test="Kapitular/@id1">
                                                <xsl:text>, BK </xsl:text>
                                                <xsl:value-of
                                                  select="substring-after(Kapitular/@id1, '.')"/>
                                            </xsl:if>
                                            <xsl:text>]</xsl:text>
                                        </span>
                                    </xsl:if>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul class="bare">
                                    <li style="font-style:italic;">
                                        <xsl:apply-templates select="Kapitular"/>
                                        <xsl:if test="contains(Kapitular/@id,'.')">
                                            <br/>
                                            <span style="font-size:85%;font-style:normal;">
                                                <xsl:text> [</xsl:text>
                                                <xsl:value-of
                                                  select="substring-before(Kapitular/@id, '.')"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of
                                                  select="substring-after(Kapitular/@id, '.')"/>
                                                <xsl:if test="Kapitular/@id1">
                                                  <xsl:text>, BK </xsl:text>
                                                  <xsl:value-of
                                                  select="substring-after(Kapitular/@id1, '.')"/>
                                                </xsl:if>
                                                <xsl:text>]</xsl:text>
                                            </span>
                                        </xsl:if>
                                    </li>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>

                        <span style="font-size:85%; font-style:normal;line-height:100%;padding:2 4;">
                            <xsl:apply-templates select="note"/>
                        </span>

                    </td>
                    <td class="mss">
                        <ul class="bare">
                            <xsl:for-each select="key('capit', Kapitular/@id)">
                                <xsl:sort select="hss"/>

                                <li>
                                    <xsl:choose>
                                        <xsl:when test="descendant::hss[@status='publ']">
                                            <!--<a><xsl:attribute name="href"><xsl:value-of select="$mss"/><xsl:value-of select="descendant::hss/@url"/></xsl:attribute><img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                                       title="Zur Handschrift" alt="->"/></a><xsl:text> </xsl:text>-->
                                            <a class="ssdone">
                                                <xsl:attribute name="href">
                                                  <xsl:value-of select="$mss"/>
                                                  <xsl:value-of select="descendant::hss/@url"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="hss"/>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="hss"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="mordek">
        <xsl:for-each select="Eintrag[count(. | key('capit', Kapitular/@id)[1]) = 1]">
            <xsl:sort select="substring-after(Kapitular/@id,'Mordek.')" case-order="lower-first"
                order="ascending" data-type="number"/>
            <xsl:if test="starts-with(descendant::Kapitular/@id,'Mordek.')">

                <tr>
                    <td class="capit" align="left">
                        <!--                        <i>
                            <xsl:apply-templates select="Kapitular"/>
                        </i>-->
                        <xsl:choose>
                            <xsl:when test="descendant::Kapitular[@status='publ']">
                                <!-- <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$capit_ldf"/><xsl:text>mordek-nr-</xsl:text><xsl:value-of select="substring-after(descendant::Kapitular/@id,'.')"/>
                                </xsl:attribute><img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                                title="Zum Kapitular" alt="->"/></a><xsl:text> </xsl:text>-->
                                <a class="ssdone">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="$capit_ldf"/>
                                        <xsl:text>mordek-nr-</xsl:text>
                                        <xsl:value-of
                                            select="substring-after(descendant::Kapitular/@id,'.')"
                                        />
                                    </xsl:attribute>
                                    <xsl:apply-templates select="Kapitular"/>
                                    <xsl:if test="contains(Kapitular/@id,'.')">
                                        <br/>
                                        <span style="font-size:85%;font-style:normal;">
                                            <xsl:text> [</xsl:text>
                                            <xsl:value-of
                                                select="substring-before(Kapitular/@id, '.')"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of
                                                select="substring-after(Kapitular/@id, '.')"/>
                                            <xsl:if test="Kapitular/@id1">
                                                <xsl:text>, BK </xsl:text>
                                                <xsl:value-of
                                                  select="substring-after(Kapitular/@id1, '.')"/>
                                            </xsl:if>
                                            <xsl:text>]</xsl:text>
                                        </span>
                                    </xsl:if>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul class="bare">
                                    <li style="font-style:italic;">
                                        <xsl:apply-templates select="Kapitular"/>
                                        <xsl:if test="contains(Kapitular/@id,'.')">
                                            <br/>
                                            <span style="font-size:85%;font-style:normal;">
                                                <xsl:text> [</xsl:text>
                                                <xsl:value-of
                                                  select="substring-before(Kapitular/@id, '.')"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of
                                                  select="substring-after(Kapitular/@id, '.')"/>
                                                <xsl:if test="Kapitular/@id1">
                                                  <xsl:text>, BK </xsl:text>
                                                  <xsl:value-of
                                                  select="substring-after(Kapitular/@id1, '.')"/>
                                                </xsl:if>
                                                <xsl:text>]</xsl:text>
                                            </span>
                                        </xsl:if>
                                    </li>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>

                        <span style="font-size:85%; font-style:normal;">
                            <xsl:apply-templates select="note"/>
                        </span>
                    </td>
                    <td class="mss">
                        <ul class="bare">
                            <xsl:for-each select="key('capit', Kapitular/@id)">
                                <xsl:sort select="hss"/>
                                <!--<li>-->
                                <xsl:choose>
                                    <xsl:when test="descendant::hss[@status='publ']">
                                        <!--<a><xsl:attribute name="href"><xsl:value-of select="$mss"/><xsl:value-of select="descendant::hss/@url"/></xsl:attribute><img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                                        title="Zur Handschrift" alt="->"/></a><xsl:text> </xsl:text>-->
                                        <a class="ssdone">
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="$mss"/>
                                                <xsl:value-of select="descendant::hss/@url"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="hss"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <xsl:value-of select="hss"/>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!--</li>-->
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="rest">
        <xsl:for-each select="Eintrag[count(. | key('capit', Kapitular/@id)[1]) = 1]">
            <!--<xsl:sort select="substring-after(Kapitular/@id,'BK.')" case-order="lower-first" order="ascending" data-type="number"/>
                <xsl:sort select="substring-after(Kapitular/@id,'Mordek.')" case-order="lower-first" order="ascending" data-type="number"/>
                -->
            <xsl:sort select="Kapitular" case-order="lower-first" order="ascending" data-type="text"/>
            <xsl:if test="not(contains(descendant::Kapitular/@id,'.'))">
                <tr>
                    <td class="capit" align="left">
                        <!--                        <i>
                            <xsl:value-of select="Kapitular"/>
                        </i>-->
                        <ul class="bare">
                            <li style="font-style:italic;">
                                <xsl:value-of select="Kapitular"/>
                            </li>
                        </ul>
                        <span style="font-size:85%; font-style:normal;padding:2 4;">
                            <xsl:apply-templates select="note"/>
                        </span>

                    </td>
                    <td class="mss">
                        <ul class="bare">
                            <xsl:for-each select="key('capit', Kapitular/@id)">
                                <xsl:sort select="hss"/>
                                <!--<li>-->
                                <xsl:choose>
                                    <xsl:when test="descendant::hss[@status='publ']">
                                        <!--<a><xsl:attribute name="href"><xsl:value-of select="$mss"/><xsl:value-of select="descendant::hss/@url"/></xsl:attribute><img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                                    title="Zur Handschrift" alt="->"/></a><xsl:text> </xsl:text>-->
                                        <li>
                                            <a class="ssdone">
                                                <xsl:attribute name="href">
                                                  <xsl:value-of select="$mss"/>
                                                  <xsl:value-of select="descendant::hss/@url"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="hss"/>
                                            </a>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <xsl:value-of select="hss"/>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!--</li>-->
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="note">
        <div style="text-align:justify;">
            <br/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="ref[@type]">
        <xsl:choose>
            <xsl:when test="@type='external'">
                <a class="none">
                    <xsl:attribute name="target">_blank</xsl:attribute>
                    <xsl:attribute name="title">Externer Link</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ref[@type]">
        <xsl:choose>
            <xsl:when test="@type='internal'">
                <a class="none">
                    <xsl:attribute name="title">Interner Link</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
