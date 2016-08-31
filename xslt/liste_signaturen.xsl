<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:template match="/">
        <div class="xsl-output">

            <!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <item> -->

            <style type="text/css">
                ul{
                font-size:small;
                list-style-type:square;
                }</style>
                <a id="top"/>
                <!--<div align="center"><a href="#A">A</a> | <a href="#B">B</a> | <a href="#C">C</a> | D | <a
                    href="#E">E</a> | F | <a href="#G">G</a> | <a href="#H">H</a> | <a
                        href="#I">I</a> | J | <a href="#K">K</a> | <a href="#L">L</a> | <a href="#M">M</a> | <a
                            href="#N">N</a> | <a href="#O">O</a> | <a href="#P">P</a> | Q | <a href="#R">R</a> | <a
                                href="#S">S</a> | T | U | <a href="#V">V</a> | <a href="#W">W</a> | X | Y | Z</div>-->
                <xsl:apply-templates select="//tei:list[@xml:id]"/>

        </div>
    </xsl:template>

    <xsl:template match="tei:list[@xml:id]">
        <ul class="bare">
            <xsl:apply-templates/>
        </ul>
        <hr/>
    </xsl:template>

    <xsl:template match="tei:item[@xml:id]">
        <xsl:if test="descendant::tei:bibl[@corresp='#Mordek1995']"><xsl:for-each select=".">
            <li>
                <xsl:if test="tei:note[@type='research']"><strong><xsl:apply-templates select="tei:idno[@type='main']"/></strong></xsl:if>
                <xsl:if test="not(tei:note[@type='research'])"><xsl:apply-templates select="tei:idno[@type='main']"/></xsl:if>

                <xsl:if test="tei:idno[@type='alt']">
                    <xsl:text> - </xsl:text>
                    <xsl:apply-templates select="tei:idno[@type='alt']"/>
                </xsl:if>

                <em>
                    <xsl:apply-templates
                        select="tei:note[@type='alt']"
                    />
                </em>
            </li>
        </xsl:for-each></xsl:if>
    </xsl:template>

    <xsl:template match="tei:idno[@type='main']">
        <a>
            <xsl:attribute name="href">http://www.leges.uni-koeln.de/mss/handschrift/<xsl:value-of
                    select="../@xml:id"/></xsl:attribute>
            <xsl:attribute name="title">Zur Handschriftenbeschreibung</xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="tei:idno[@type='alt']">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>


    <!-- verschiedene Arten von Notes (zugehörig zu Signatur, etc.) -->

    <xsl:template match="tei:note[@type='alt']">
        <xsl:text> - </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:note[@type='additional']">
        <xsl:text> - </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:milestone">
	<xsl:call-template name="back-to-top-hr" />

        <h4>
            <xsl:attribute name="id">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:value-of select="@n"/>
        </h4>


    </xsl:template>
</xsl:stylesheet>
