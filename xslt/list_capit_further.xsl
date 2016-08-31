<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>
    
    <xsl:include href="xsl-output.xsl"/>
    
    <xsl:include href="allgFunktionen.xsl"/>
    
    <xsl:template match="/">
        <div class="xsl-output">
            
            <style type="text/css">
                td.title{
                width:85%;
                }
                td.no{
                width:15%;
                }</style>
            <!-- Abbildung der Kapitularienliste further -->
            
            <div style="font-size:95%;">               
                <xsl:apply-templates select="//tei:list[@type='further']"/>
            </div>            
            
        </div>
    </xsl:template>
    <xsl:template match="tei:list[@type='pre814']"/>
    <xsl:template match="tei:list[@type='post840']"/>
    <xsl:template match="tei:list[@type='ldf']"/>
    <xsl:template match="tei:list[@type='undated']"/>
    <xsl:template match="tei:list[@type='further']">
        <h4 id="BK">[:de]Ansegis und weitere Kapitularien[:en]Ansegis and further capitularies[:]</h4>
        <table id="BK" style="font-size:95%;">
            <thead>
                <tr>
                    <th>
                        [:de]Titel[:en]Caption[:]
                    </th>
                    <!--<th>[:de]Nummer[:en]No.[:]</th>-->
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="tei:item[not(@xml:id)]"/>
            </tbody>
        </table>        
        <xsl:call-template name="back-to-top-compact"/>
    </xsl:template>   
   
    
    <xsl:template match="tei:item[not(@xml:id)]">
        <xsl:for-each select=".">
            <!--<li>--><!--<xsl:if test="contains(@xml:id,'Mordek')">-->
            <tr>
                <td class="title">
                    <xsl:if test="tei:name[@ref]"><a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$capit"/><xsl:value-of select="tei:name/@ref"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zum Kapitular[:en]To the respective capitulary[:] </xsl:text>                            
                        </xsl:attribute>
                        <i><xsl:apply-templates select="tei:name"/></i>
                    </a></xsl:if>
                    <xsl:if test="tei:name[not(@ref)]">
                        <i><xsl:apply-templates select="tei:name"/></i>
                    </xsl:if>
                </td>
               <!-- <td class="no">-
                </td>-->
            </tr><!--</xsl:if>-->
            <!--</li>-->
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:name">
        <xsl:apply-templates/>
    </xsl:template>
    
    
</xsl:stylesheet>
