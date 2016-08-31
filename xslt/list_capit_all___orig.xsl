<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>    
    <xsl:template match="/">
        <html>
            <head>
                <title>Capitularia</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
                <meta content="Handschriften" name="register"/>
                <style type="text/css">
                    *{
                        font-size:small;
                    }
                    thead{
                        font-weight:bold;
                    }
                    td.new_id{
                        width:20%;
                        font-weight:bold;
                        background-color:#F2F2F2;
                    }
                    td.title{
                        width:65%;
                        font-weight:bold;
                    }
                    td.BK{
                        width:15%;
                        font-weight:bold;
                    }
                    td.Mordek{
                        width:15%;
                        font-weight:bold;
                    }
                    td.title_mordek{
                        width:65%;
                        font-weight:bold;
                    }</style>
            </head>

            <!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <item> -->

            <body>
                <a id="top"/>
                <xsl:apply-templates select="//tei:list"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="tei:list[@xml:id='Mordek_BK']">
        <div align="center">
            <xsl:apply-templates select="tei:head[@type='main'][@xml:lang='ger']"/>
            <xsl:apply-templates select="tei:head[@type='sub'][@xml:lang='ger']"/>
        </div>
        <xsl:apply-templates select="tei:note[@resp='cap'][@xml:lang='ger']"/>
        <br/>
        <table>
            <thead>
                <tr>
                    <td class="BK">
                        <h6>Nr. bei BK</h6>
                    </td>
                    <td class="title">
                        <h6>Bezeichnung nach Boretius/Krause (BK)</h6>
                    </td>
                    <td class="new_id">
                        <h6>Projektinterne Nummerierung</h6>
                    </td>
                    <!-- Zukünftig kanonische Nummerierung -->
                </tr>
            </thead>
            <xsl:apply-templates select="tei:item[ancestor::tei:list[@xml:id='Mordek_BK']]"/>
        </table>
        <hr/>
    </xsl:template>
    <xsl:template match="tei:list[@xml:id='Mordek_neu']">
        <div align="center">
            <xsl:apply-templates select="tei:head[@type='main'][@xml:lang='ger']"/>
            <xsl:apply-templates select="tei:head[@type='sub'][@xml:lang='ger']"/>
        </div>
        <br/>
        <table>
            <thead>
                <tr>
                    <td class="Mordek">
                        <h6>Nr. im Anhang I von Mordek</h6>
                    </td>
                    <td class="title_mordek">
                        <h6>Bezeichnung nach Mordek</h6>
                    </td>
                    <td class="new_id">
                        <h6>Projektinterne Nummerierung</h6>
                    </td>
                    <!-- Zukünftig kanonische Nummerierung -->
                </tr>
            </thead>
            <xsl:apply-templates select="tei:item"/>
        </table>
        <hr/>
    </xsl:template>
    <xsl:template match="tei:head[@type='main']">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="tei:head[@type='sub']">
        <h6>
            <xsl:apply-templates/>
        </h6>
    </xsl:template>
    <xsl:template match="tei:note[@resp='cap'][@xml:lang='ger']">
        <div align="justify">
            <br/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:item[ancestor::tei:list[@xml:id='Mordek_BK']]">
        <xsl:for-each select=".">
            <tr>
                <td>
                    <xsl:value-of select="(substring-after(@corresp,'BK.'))"/>
                </td>
                <td>
                    <xsl:apply-templates/>
                </td>
                <td>
                    <xsl:if test="@xml:id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:if>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:item[ancestor::tei:list[@xml:id='Mordek_neu']]">
        <xsl:for-each select=".">
            <tr>
                <td>
                    <xsl:value-of select="(substring-after(@corresp,'Mordek.'))"/>
                </td>
                <td>
                    <xsl:apply-templates/>
                </td>
                <td>
                    <xsl:if test="@xml:id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:if>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:title">
        <xsl:choose>
            <xsl:when test="@ref">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$capit"/>
                        <xsl:value-of select="@ref"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text>Zum Eintrag</xsl:text>
                    </xsl:attribute>
                    <em>
                        <xsl:apply-templates/>
                    </em>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <em>
                    <xsl:apply-templates/>
                </em>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="tei:date">
        <xsl:apply-templates/>
    </xsl:template>


</xsl:stylesheet>
