<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:template match="/">
        <div class="xsl-output">
            <style type="text/css">
                div#meta{
                    font-size:90%;
                }
                div.handschriften{
                    font-size:90%;
                    list-style-type:none;
                    line-height:90%;
                }</style>
            <!-- Abbildung der Liste mit einer Zeile für jedes <msDesc> -->
            <!-- <br/>
                <hr/>
            <br/>
                <a id="top"/>
                <div class="align-center">
		  <a href="#A">A</a> | <a href="#B">B</a> | <a href="#C">C</a> |
                  <a href="#D">D</a> | <a href="#F">F</a> | <a href="#G">G</a> | <a
                  href="#H">H</a> | <a href="#I">I</a> | <a href="#K">K</a> | <a href="#L"
                  >L</a> | <a href="#M">M</a> | <a href="#N">N</a> | <a href="#O">O</a> | <a
                  href="#P">P</a> | <a href="#R">R</a> | <a href="#S">S</a> | <a href="#T"
                  >T</a> | <a href="#V">V</a> | <a href="#W">W</a> | <a href="#Z"
                  >Z</a><br/>
		</div><br/>-->
            <div id="meta">[:de] <p>Die folgende, alphabetisch geordnete Liste führt alle bei
                Mordek 1995 genannten Kapitularienhandschriften auf. Weitere, bei Mordek nicht
                verzeichnete Handschriften mit Kapitularien wurden ergänzt.</p>[:en]<p>This table
                lists - in alphabetical order - all manuscripts recorded in Mordek 1995 which contain
                capitularies. Further manuscripts containing capitularies which were not recorded by Mordek
                have been added.</p>[:]</div> 
        <div class="handschriften"><xsl:apply-templates
                    select="//tei:div[@type='manuscripts']"/></div>
        </div>
    </xsl:template>

    <xsl:template match="tei:div[@type='manuscripts']">
        <!--        <ul>
            <xsl:apply-templates/>
        </ul>
        <hr/>

        -->

        <!-- Only for the sidebar the menu.
	<h4 id="table-top" style="display: none">Nach Anfangsbuchstaben</h4> -->

        <xsl:apply-templates select="tei:milestone"/>
    </xsl:template>
    <xsl:template match="tei:div[@type='manuscripts']/tei:milestone">
        <table>

            <thead>
                <tr>
                    <th id="{@n}">
                        <xsl:value-of select="@n"/>
                    </th>
                </tr>
            </thead>

            <tbody>
                <xsl:for-each
                    select="following-sibling::tei:msDesc[generate-id(preceding-sibling::tei:milestone[1])=generate-id(current())]">
                    <tr>
                        <td>
                            <xsl:apply-templates select="tei:head[@type='shelfmark']"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
        <!--
	<xsl:call-template name="back-to-top-compact" />-->
    </xsl:template>

    <xsl:template match="tei:msDesc[@xml:id]">
        <xsl:for-each select=".">
            <!--<li>-->
            <xsl:apply-templates select="tei:head[@type='shelfmark']"/>
            <!--</li>-->

        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:head[@type='shelfmark']">
        <xsl:choose>
            <xsl:when test="parent::tei:msDesc[@status]">
                <!--<a>
            <xsl:attribute name="href"><xsl:value-of select="$mss"/><xsl:value-of select="../@xml:id"/></xsl:attribute><img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                title="Zur Handschrift" alt="->"/>
        </a><xsl:text> </xsl:text>-->
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/>
                        <xsl:value-of select="../@xml:id"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="text()"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="text()"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="tei:note[@type='siglum'][not(text()='')]">
            <xsl:text> [</xsl:text>
            <i>
                <xsl:apply-templates select="tei:note[@type='siglum']"/>
            </i>
            <xsl:text>]</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:milestone">
        <xsl:call-template name="back-to-top-hr"/>
        <h4>
            <xsl:attribute name="id">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:value-of select="@n"/>
        </h4>
    </xsl:template>
</xsl:stylesheet>
