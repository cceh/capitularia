<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:template match="/">
        <div class="xsl-output">
            <style type="text/css">
                td.resp{
                    width:30%;
                }
                td.value{
                    width:70%;
                }</style>
            <!-- Darstellung eines einzelnen Kapitulars -->


            <a id="top"/>
            <div id="content" align="justify" style="font-size:95%;">
                <xsl:apply-templates select="//tei:body"/>
            </div>

        </div>
    </xsl:template>

    <xsl:template match="tei:div">
        <xsl:if test="//tei:note[@type='annotation']">
            <xsl:apply-templates select="tei:note[@type='annotation']"/>
        </xsl:if>
        <xsl:apply-templates select="tei:note[@type='titles']"/>
        <xsl:apply-templates select="tei:note[@type='date']"/>
        <xsl:apply-templates select="tei:list[@type='transmission']"/>
        <xsl:apply-templates select="tei:listBibl[@type='literature']"/>
        <xsl:apply-templates select="tei:listBibl[@type='translation']"/>

        <xsl:call-template name="back-to-top"/>
    </xsl:template>

    <xsl:template match="tei:note[@type='annotation']">
        <xsl:text/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <xsl:template match="tei:note[@type='titles']">
        <table id="titles" class="handschriften">
            <thead>
                <tr>
                    <td colspan="2">
                        <h4 id="editions">[:de]Titel in älteren Editionen[:en]Captions used in older
                            editions[:]</h4>
                    </td>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="tei:name">
        <xsl:for-each select=".">
            <tr>
                <xsl:if test="@resp!='bk'">
                    <td class="resp">
                        <xsl:text>[:de]bei[:en]by[:] </xsl:text>
                        <xsl:value-of select="@resp"/>
                    </td>
                    <td class="value">
                        <xsl:apply-templates/>
                    </td>
                </xsl:if>
                <xsl:if test="@resp='bk'">
                    <td class="resp">
                        <xsl:text>[:de]bei[:en]by[:] </xsl:text>
                        <xsl:text>Boretius/Krause</xsl:text>
                    </td>
                    <td class="value">
                        <xsl:apply-templates/>
                    </td>
                </xsl:if>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:note[@type='date']">
        <table id="date">
            <thead>
                <tr>
                    <td>
                        <h4 id="origin">[:de]Datierung[:en]Origin[:]</h4>
                    </td>
                    <td/>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
        <!--<xsl:choose>
                <xsl:when test="child::tei:date">
                   <!-\- <xsl:apply-templates/>-\->
                </xsl:when>
                <xsl:otherwise>
                    <li>
                        <xsl:apply-templates/>
                    </li>
                </xsl:otherwise>
            </xsl:choose>-->
    </xsl:template>
    <xsl:template match="tei:date">
        <xsl:if test="parent::tei:note[@type='date']">
            <xsl:for-each select=".">
                <tr>
                    <xsl:if test="@resp!='bk'">
                        <td class="resp">
                            <xsl:text>[:de]bei[:en]by[:] </xsl:text>
                            <xsl:value-of select="@resp"/>
                        </td>
                        <td class="value">
                            <xsl:apply-templates/>
                        </td>
                    </xsl:if>
                    <xsl:if test="@resp='bk'">
                        <td class="resp">
                            <xsl:text>[:de]bei[:en]by[:] </xsl:text>
                            <xsl:text>Boretius/Krause</xsl:text>
                        </td>
                        <td class="value">
                            <xsl:apply-templates/>
                        </td>
                    </xsl:if>
                </tr>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="not(parent::tei:note[@type='date'])">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:list[@type='transmission']">
        <table id="transmission" class="handschriften">
            <thead>
                <tr>
                    <td>
                        <h4 id="transmission">[:de]Überlieferung[:en]Transmission[:]</h4>
                    </td>
                    <td style="font-size:80%;text-align:right;"
                        >[:de]Transkription<br/>vorhanden?[:en]Transcription<br/>available?[:]</td>
                </tr>
            </thead>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="tei:item">
        <xsl:for-each select=".">
            <tr>
                <td class="value">
                    <xsl:if test="@corresp">
                        <!--<a class="ssdone">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$mss"/>
                                <xsl:value-of select="@corresp"/>
                            </xsl:attribute>
                            <img
                                src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                                title="Zur Handschrift"/>
                        </a>
                        <xsl:text> </xsl:text>-->
                        <a class="ssdone">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$mss"/>
                                <xsl:value-of select="@corresp"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="text()"/>
                        </a>
                    </xsl:if>
                    <xsl:if test="not(@corresp)">
                        <xsl:apply-templates/>
                    </xsl:if>
                </td>
                <td class="resp" align="right">
                    <xsl:apply-templates select="tei:ptr"/>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:listBibl[@type='literature']">
        <table id="literature">
            <thead>
                <tr>
                    <td>
                        <h4 id="lit">[:de]Literatur[:en]References[:]</h4>
                    </td>
                </tr>
            </thead>
            <xsl:apply-templates select="tei:bibl"/>
        </table>
    </xsl:template>
    <xsl:template match="tei:listBibl[@type='translation']">
        <table id="translations">
            <thead>
                <tr>
                    <td>
                        <h4 id="translations">[:de]Übersetzungen[:en]Translations[:]</h4>
                    </td>
                </tr>
            </thead>
            <xsl:apply-templates select="tei:bibl"/>
        </table>
    </xsl:template>
    <xsl:template match="tei:bibl">
        <xsl:for-each select=".">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:if test="@type='external'">
            <xsl:choose>
                <xsl:when test="@subtype='BK1'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$BK1"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Boretius/Krause I (dMGH)[:en]Go to Boretius/Krause I (dmgh)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='BK2'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$BK2"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Boretius/Krause II (dMGH)[:en]Go to Boretius/Krause II (dmgh)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='Gallica'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Gallica</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='dmgh'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$dmgh"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur dMGH[:en]Go to dMGH[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='Pertz1'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Pertz1"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Pertz (dMGH)[:en]Go to Pertz' edition (dMGH)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <!-- Pertz2 musste geändert werden, weil MGH-eigene Permalinks nicht funktonieren! -->
                <xsl:when test="@subtype='Pertz2'">
                    <!-- <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Pertz (dMGH)[:en]Go to Pertz' edition (dMGH)[:]</xsl:text>
                        </xsl:attribute>-->
                    <xsl:apply-templates/>
                    <!--</a>-->
                </xsl:when>
                <xsl:when test="@subtype='Ansegis'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Ansegis"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Ansegis-Edition (dMGH)[:en]Go to Ansegis (dMGH)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='BSB'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Digitale Sammlungen - BSB</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='Benedictus'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Benedictus"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition der falschen Kapitularien des
Benedictus Levita[:en]Go to Benedictus Levita website[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@type='internal'">

            <xsl:choose>
                <xsl:when test="@subtype='capit'">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$capit"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">[:de]Zum Kapitular[:en]To the
                            capitulary[:]</xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
            </xsl:choose>


        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:ptr">
        <xsl:if test="@type='transcr'">
            <a class="ssdone">
                <xsl:attribute name="href">
                    <xsl:value-of select="$mss"/>
                    <xsl:value-of select="parent::tei:item/@corresp"/>
                    <xsl:text>#</xsl:text>
                    <xsl:if test="contains(preceding::tei:head,'BK')">
                        <xsl:choose>
                            <xsl:when test="contains(preceding::tei:head,'185')">
                                <xsl:text>BK.185A</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>BK.</xsl:text>
                                <xsl:value-of
                                    select="substring-before(substring-after(preceding::tei:head,'Nr. '),':')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="contains(preceding::tei:head,'Mordek')">
                        <xsl:text>BK.</xsl:text>
                        <xsl:value-of select="substring-after(preceding::tei:head,'Nr. ')"/>
                    </xsl:if>

                    <!--<xsl:if test="ancestor::tei:item[@xml:id='BK.185']">
                        <xsl:value-of select="@target"/>
                    </xsl:if>-->
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_self</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="title"> [:de]Zur Transkription[:en]Go to transcription[:] </xsl:attribute>
                <img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                    title="Zur Transkription"/>
            </a>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:bibl">
        <tr>
            <td colspan="2">
                <xsl:if test="@corresp">
                    <xsl:apply-templates/>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$biblio"/>

                            <!-- zuvor - NG, 11.02.16 -->
                            <xsl:value-of select="@corresp"/>
                            <!-- zuvor - NG, 11.02.16 -->
                            <!--<!-\- hinzugefügt - NG, 11.02.16 -\->
                            <xsl:variable name="vNormCorresp">
                                <xsl:call-template name="tNormalizeString">
                                    <xsl:with-param name="pString" select="@corresp"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:value-of select="$vNormCorresp"/>
                            <!-\- hinzugefügt - NG, 11.02.16 -\->-->
                        </xsl:attribute>
                        <xsl:attribute name="title">[:de]Zum bibliographischen Eintrag[:en]Go to
                            bibliography[:]</xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img align="bottom" alt="Zur Bibliographie"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"/>
                    </xsl:element>
                </xsl:if>
            </td>
        </tr>
        <td colspan="2">
            <xsl:if test="not(@corresp)">
                <xsl:apply-templates/>
            </xsl:if>
        </td>
    </xsl:template>
</xsl:stylesheet>
