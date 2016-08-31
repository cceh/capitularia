<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>

    <xsl:include href="xsl-output.xsl"/>

    <xsl:template match="/">
        <div class="xsl-output">
            <!-- Abbildung der Kapitularienliste ldf -->


            <a id="top"/>
            <!--<div align="center"><a href="#A">A</a> | <a href="#B">B</a> | <a href="#C">C</a> | D | <a
                    href="#E">E</a> | F | <a href="#G">G</a> | <a href="#H">H</a> | <a
                        href="#I">I</a> | J | <a href="#K">K</a> | <a href="#L">L</a> | <a href="#M">M</a> | <a
                            href="#N">N</a> | <a href="#O">O</a> | <a href="#P">P</a> | Q | <a href="#R">R</a> | <a
                                href="#S">S</a> | T | U | <a href="#V">V</a> | <a href="#W">W</a> | X | Y | Z</div>-->
            <xsl:apply-templates select="//tei:list[@type='ldf']"/>

        </div>
    </xsl:template>

    <xsl:template match="tei:list[@type='ldf']">

        <!--        <ul>
            <xsl:apply-templates/>
        </ul>-->


        <table>
            <tbody>
                <tr>
                    <xsl:apply-templates/>
                </tr>
            </tbody>
        </table>


    </xsl:template>

    <xsl:template match="tei:item[@xml:id]">
        <xsl:for-each select=".">
            <!--<li>-->
            <td>
                <a>
                    <xsl:attribute name="class">ssdone</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$capit"/>
                        <xsl:value-of select="tei:name/@ref"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text>[:de]Zur Kapitularienseite[:en]To capitulary[:]</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="substring-before(@xml:id,'.')"/>
                    <xsl:text> [:de]Nr.[:en]No[:] </xsl:text>
                    <xsl:value-of select="substring-after(@xml:id,'.')"/>
                    <xsl:text>: </xsl:text>
                    <i>
                        <xsl:value-of select="child::tei:name"/>
                    </i>
                </a>
            </td>
            <!--</li>-->
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:idno[@type='main']">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="$mss"/>
                <xsl:value-of select="../@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="title">[:de]Zur Handschriftenbeschreibung[:en]To codex[:]</xsl:attribute>
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
        <hr/>
        <div align="right" style="font-size:x-small;">
            <a href="#top">[^]</a>
        </div>
        <h4>
            <xsl:attribute name="id">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:value-of select="@n"/>
        </h4>


    </xsl:template>
</xsl:stylesheet>
