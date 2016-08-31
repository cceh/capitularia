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
            <!-- Abbildung der Kapitularienliste Lothars -->
            
            <div style="font-size:95%;">
                <!--<div align="center" class="pager kapitularien-pager"
                        style="padding-top:3%;font-size:95%;">
                        <ul>
                            <li>
                                <a class="ssdone" href="#BK"> Bei Boretius/Krause (BK)
                                    <br/>verzeichnete Kapitularien </a>
                            </li>
                            <li>
                                <a class="ssdone" href="#Mordek"> Neuentdeckte Kapitularien <br/>(in
                                    Anhang I bei Mordek verzeichnet) </a>
                            </li>
                        </ul>
                    </div>-->
                <xsl:apply-templates select="//tei:list[@type='ltr']"/>
            </div>
            
            
        </div>
    </xsl:template>
    <xsl:template match="tei:list[@type='pre814']"/>
    <xsl:template match="tei:list[@type='post840']"/>
    <xsl:template match="tei:list[@type='undated']"/>
    <xsl:template match="tei:list[@type='further']"/>
    <xsl:template match="tei:list[@type='ldf']"/>
    <xsl:template match="tei:list[@type='ltr']">
        <h4 id="BK">[:de]Bei Boretius/Krause (BK) verzeichnete Kapitularien[:en]Capitularies mentioned by Boretius/Krause (BK)[:]</h4>
        <table id="BK" style="font-size:95%;">
            <thead>
                <tr>
                    <th>
                        [:de]Titel[:en]Caption[:]
                    </th>
                    <th>[:de]Nummer[:en]No.[:]</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="tei:item[not(starts-with(@xml:id,'ltr.Mordek'))]"/>
            </tbody>
        </table>
        
        <xsl:call-template name="back-to-top-compact"/>
        <h4 id="Mordek">[:de]Neuentdeckte Kapitularien (in Anhang I bei Mordek verzeichnet)[:en]Newly discovered capitularies (Mordek appendix I)[:]</h4>
        <table id="Mordek" style="font-size:95%;">
            <thead>                        
                <tr>
                    <th>
                        [:de]Titel[:en]Caption[:]
                    </th>
                    <th>[:de]Nummer[:en]No.[:]</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="tei:item[starts-with(@xml:id,'ltr.Mordek')]"/>
            </tbody>
        </table>
        
        <xsl:call-template name="back-to-top-compact"/>
        
        
        <!--        <ul class="kapitularien-uebersicht">
            <xsl:apply-templates/>
        </ul>
                <p  style="padding-top:3%;font-size:95%;"><table>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table></p>-->
        
    </xsl:template>
    
    <!--<xsl:template match="tei:item[@xml:id]" name="BK">
        <!-\-<xsl:if test="not(starts-with(@xml:id,'Mordek'))">-\-><xsl:for-each select=".">
            <tr>
                <td class="title">
                    <a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$capit"/><xsl:value-of select="tei:name/@ref"/>addasda
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Zur Kapitularienseite</xsl:text>
                        </xsl:attribute>
                        <i><xsl:apply-templates select="tei:name"/>gaewwetwr</i>
                    </a>
                </td>
                <td class="no"><xsl:value-of select="substring-before(@xml:id,'.')"/><xsl:text> Nr. </xsl:text><xsl:value-of select="substring-after(@xml:id,'.')"/>
                </td></tr>
            <!-\-</li>-\->
        </xsl:for-each><!-\-</xsl:if>-\->
    </xsl:template>-->
    
    <xsl:template match="tei:item[@xml:id]">
        <xsl:for-each select=".">
            <!--<li>--><!--<xsl:if test="contains(@xml:id,'Mordek')">-->
            <!--<xsl:if test="not(@sortKey='other')">--><tr>
                <td class="title">
                    <xsl:if test="tei:name[@ref]"><a class="ssdone">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$capit"/><xsl:value-of select="tei:name/@ref"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zu Nr.[:en]To no.[:] </xsl:text>
                            <xsl:value-of select="substring-after(@xml:id,'_')"/><xsl:text> [:de]nach[:en]by[:] </xsl:text>
                            <xsl:if test="contains(@xml:id,'BK')"><xsl:text>Boretius-Kause</xsl:text></xsl:if>
                            <xsl:if test="contains(@xml:id,'Mordek')"><xsl:text>Mordek</xsl:text></xsl:if>
                            
                            <!--<xsl:text>Zur Kapitularienseite</xsl:text>-->
                        </xsl:attribute>
                        <i><xsl:apply-templates select="tei:name"/></i>
                    </a></xsl:if>
                    <xsl:if test="tei:name[not(@ref)]">
                        <i><xsl:apply-templates select="tei:name"/></i>
                    </xsl:if>
                </td>
                <td class="no"><!--<xsl:value-of select="substring-before(@xml:id,'_')"/><xsl:text> Nr. </xsl:text>--><xsl:value-of select="substring-after(@xml:id,'_')"/>
                </td>
            </tr><!--</xsl:if>--><!--</xsl:if>-->
            <!--</li>-->
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:name">
        <xsl:apply-templates/>
    </xsl:template>
    
    
</xsl:stylesheet>
