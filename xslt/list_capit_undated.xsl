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
            <!-- Abbildung der Kapitularienliste undated -->
            
            <div style="font-size:95%;">
               
                <xsl:apply-templates select="//tei:div"/>
            </div>
        </div>
    </xsl:template>
  
    <xsl:template match="tei:div">
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
                <xsl:apply-templates select="descendant::tei:item[not(starts-with(@xml:id,'Mordek'))][starts-with(child::tei:name/@ref,'undated')]"/>
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
                <xsl:apply-templates select="descendant::tei:item[starts-with(@xml:id,'Mordek')]"/>
            </tbody>
        </table>
        
        <xsl:call-template name="back-to-top-compact"/>
    </xsl:template>
    
        
    <xsl:template match="//tei:item[@xml:id]">
        <xsl:for-each select=".">
            <!--<li>--><!--<xsl:if test="contains(@xml:id,'Mordek')">-->
            <xsl:if test="starts-with(tei:name/@ref,'undated')"><tr>
                <td class="title">
                    <xsl:choose>
                        <xsl:when test="@n='publ'"><xsl:if test="tei:name[@ref]"><a class="ssdone">
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
                            </xsl:if></xsl:when>
                        <xsl:otherwise><i><xsl:apply-templates select="tei:name"/></i></xsl:otherwise>
                    </xsl:choose>
                    
                </td>
                <td class="no">
                    <xsl:choose>
                        <xsl:when test="starts-with(@xml:id,'BK_')">
                            <xsl:if test="starts-with(@xml:id,'BK_0')">
                                <xsl:choose>
                                    <xsl:when test="starts-with(@xml:id,'BK_00')"><xsl:value-of select="(substring-after(@xml:id,'BK_00'))"/></xsl:when>                        
                                    <xsl:otherwise><xsl:value-of select="(substring-after(@xml:id,'BK_0'))"/></xsl:otherwise></xsl:choose>
                            </xsl:if>
                            <xsl:if test="not(starts-with(@xml:id,'BK_0'))"><xsl:value-of select="(substring-after(@xml:id,'BK_'))"/></xsl:if>
                        </xsl:when>
                        <xsl:when test="starts-with(@xml:id,'Mordek_')">
                            <xsl:choose>                        
                                <xsl:when test="starts-with(@xml:id,'Mordek_0')"><xsl:value-of select="(substring-after(@xml:id,'Mordek_0'))"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="(substring-after(@xml:id,'Mordek_'))"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    
                </td>
            </tr></xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:name">
        <xsl:apply-templates/>
    </xsl:template>
    
    
</xsl:stylesheet>
