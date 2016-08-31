<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:template match="/">
        <div class="xsl-output">

                <style type="text/css">
                    body{
                        font-size:small;
                    }
                    table{
                        table-layout:fixed;
                    }
                    td.shelfmark{
                        width:26%;
                    }
                    td.capit{
                        width:37%;
                    }
                    td.origin{
                        width:37%;
                    }</style>

                        <!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <item> -->


                <a id="top"/>
                <div class="align-center"><a href="#A">A</a> | <a href="#B">B</a> | <a href="#C">C</a> | D | <a
                    href="#E">E</a> | F | <a href="#G">G</a> | <a href="#H">H</a> | <a
                    href="#I">I</a> | J | <a href="#K">K</a> | <a href="#L">L</a> | <a href="#M">M</a> | <a
                    href="#N">N</a> | <a href="#O">O</a> | <a href="#P">P</a> | Q | <a href="#R">R</a> | <a
                    href="#S">S</a> | T | U | <a href="#V">V</a> | <a href="#W">W</a> | X | Y | Z</div>
                <br/>
                <hr/>
                <br/>
                <div id="content">
                    <table rules="all">
                        <thead>
                            <tr valign="top">
                                <th class="shelfmark">Signatur</th>
                                <th class="capit">Enthaltene Kapitularien</th>
                                <th class="origin">Herkunft, Datierung</th> </tr>
                        </thead>
                        <xsl:apply-templates select="//tei:list[@xml:id]"/>
                    </table>
                </div>

        </div>
    </xsl:template>

    <!-- "Füllen" der einzelnen Spalten mit den entsprechenden Angaben (Signatur; Inhalt; Datierung; Literatur) -->

    <xsl:template match="tei:list[@xml:id]">

        <xsl:apply-templates/>


        <!-- Signatur, bzw. Signaturen -->
    </xsl:template>
    <xsl:template match="tei:item[@xml:id]">
        <xsl:if test="descendant::tei:bibl[@corresp='#Mordek1995']">
            <xsl:for-each select=".">
            <tr>
                <td class="shelfmark">
                    <span style="font-size:small;">
                        <xsl:if test="tei:note[@type='research']"><strong><xsl:apply-templates select="tei:idno[@type='main']"/></strong></xsl:if>
                        <xsl:if test="not(tei:note[@type='research'])"><xsl:apply-templates select="tei:idno[@type='main']"/></xsl:if>
                    </span>
                    <span style="font-size:x-small;">
                        <xsl:if test="tei:idno[@type='alt']">
                            <br/>
                            <xsl:apply-templates select="tei:idno[@type='alt']"/>
                        </xsl:if>
                        <br/>
                        <em>
                            <xsl:apply-templates
                                select="tei:note[@type='alt']"/>
                        </em>
                    </span>
                </td>
                <td class="leges">
                    <span style="font-size:x-small;">
                        <xsl:apply-templates select="tei:list[@type='content']"/>
                    </span>
                </td>
                <td class="origin">
                    <span style="font-size:x-small;">
                        <xsl:apply-templates select="tei:note[@type='history']"/>
                    </span>
                </td>
            </tr>
        </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:idno[@type='main']">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="../@xml:id"/>
            </xsl:attribute>
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
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:note[@type='additional']"/>



    <!-- Anmerkungen für die letzte Spalte -->
    <xsl:template match="tei:note[@type='annotation']">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Angaben zu Datierung und Herkunft -->
    <xsl:template match="tei:note[@type='history']">
        <xsl:apply-templates select="tei:placeName"/>
        <xsl:apply-templates select="tei:date"/>
    </xsl:template>

    <!-- Einträge zum Inhalt der Handschrift -->
    <xsl:template match="tei:list[@type='content']/tei:item">

    </xsl:template>
    <xsl:template match="tei:item">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:locus">
        <strong>
            <xsl:text>[</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>]</xsl:text>
        </strong>
    </xsl:template>
    <xsl:template match="tei:note/tei:placeName">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:placeName">
                <xsl:value-of select="."/>
                <xsl:if test="@resp">
                    <xsl:text> [nach </xsl:text><xsl:value-of select="@resp"
                    /><xsl:text>]</xsl:text></xsl:if>, </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
                <xsl:if test="@resp">
                    <xsl:text> [nach </xsl:text>
                    <xsl:value-of select="@resp"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text> - </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:note/tei:date">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:date">
                <xsl:value-of select="."/>
                <xsl:if test="@resp">
                    <xsl:text> [nach </xsl:text><xsl:value-of select="@resp"
                    /><xsl:text>]</xsl:text>,</xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
                <xsl:if test="@resp">
                    <xsl:text> [nach </xsl:text>
                    <xsl:value-of select="@resp"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Buchstaben -->

    <xsl:template match="tei:milestone">
        <tr>
          <td bgcolor="#8c8c8c" colspan="3">
	    <xsl:call-template name="back-to-top-compact" />

                <span style="font-weight:bold; color:#FFFFFF;">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@n"/>
                    </xsl:attribute>
                    <xsl:value-of select="@n"/>
                </span>
            </td>
        </tr>



    </xsl:template>

    <!-- Formatierungsangaben -->
    <xsl:template match="tei:emph">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="tei:quote">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <!-- ##### Verlinkungen zu Resourcen #####-->

    <!-- Verlinkungen zur Bibliographie -->

    <xsl:template match="tei:bibl">
        <xsl:if test="parent::tei:listBibl">
            <xsl:choose>
                <xsl:when test="following-sibling::tei:bibl">
                    <a>
                        <xsl:attribute name="title">Bibliographie</xsl:attribute>
                        <xsl:attribute name="target">_blank</xsl:attribute>
                        <xsl:attribute name="href">/../register/bibliographie<xsl:value-of
                                select="@corresp"/></xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                    <xsl:text>;</xsl:text>
                    <br/>
                </xsl:when>
                <xsl:otherwise>
                    <a>
                        <xsl:attribute name="title">Bibliographie</xsl:attribute>
                        <xsl:attribute name="target">_blank</xsl:attribute>
                        <xsl:attribute name="href">/../register/bibliographie<xsl:value-of
                                select="@corresp"/></xsl:attribute>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="parent::tei:note">
            <a>
                <xsl:attribute name="title">Bibliographie</xsl:attribute>
                <xsl:attribute name="target">_blank</xsl:attribute>
                <xsl:attribute name="href">/../register/bibliographie<xsl:value-of select="@corresp"
                    /></xsl:attribute>
            </a>
        </xsl:if>
    </xsl:template>

    <!-- Verlinkungen zu internen und externen Resourcen -->
    <xsl:template match="tei:ref">
        <xsl:apply-templates/>

        <!--  <xsl:if test="@type='person'">
            <a>
                <xsl:attribute name="title">Personenregister</xsl:attribute>
                <xsl:attribute name="href">/../register/personen<xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>

        <xsl:if test="@type='place'">
            <a>
                <xsl:attribute name="title">Ortsregister</xsl:attribute>
                <xsl:attribute name="href">/../register/orte<xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>-->

        <xsl:if test="@type='external'">
            <a>
                <xsl:attribute name="target">_blank</xsl:attribute>
                <xsl:attribute name="title">Externer Link</xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
