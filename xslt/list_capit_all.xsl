<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>
    
    <xsl:include href="xsl-output.xsl"/>
    
    <xsl:include href="allgFunktionen.xsl"/>
    <xsl:key name="number" match="tei:item" use="tei:item/@xml:id"/>
    
    <xsl:template match="/">
        <div>
            
            <!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <item> -->
            <style type="text/css">
                td.new_id{
                width:15%;
                
                background-color:#F2F2F2;
                }
                td.title{
                width:65%;
                
                }
                td.BK{
                width:20%;
                
                }
                td.Mordek{
                width:20%;
                
                }
                td.rest{
                width:20%;
                
                }
                td.title{
                width:65%;
                
                }</style>
            
            <a id="top"/>
            
            <div class="handschriften">
                <xsl:apply-templates select="//tei:div"/>
            </div>
            
        </div>
    </xsl:template>
    <xsl:template match="tei:div">
        <h4 id="BK">[:de]Bei Boretius/Krause (BK) verzeichnete Kapitularien[:en]Capitularies
            mentioned by Boretius/Krause (BK)[:]</h4>
        <table style="font-size:95%;">
            <thead>
                <tr>
                    <!--<td class="BK">-->
                    <th>
                        <!--<h6>-->[:de]Nummer[:en]No.[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!--<td class="title">-->
                    <th>
                        <!--<h6>-->[:de]Titel[:en]Caption[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!--<td class="new_id">-->
                    <th>
                        <!--<h6>-->[:de]Projektinterne Nummerierung[:en]New (project)
                        number[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!-- Zukünftig kanonische Nummerierung -->
                </tr>
            </thead>                        
            <xsl:apply-templates select="//tei:item[starts-with(@xml:id,'BK')]"/>
        </table>        
        <xsl:call-template name="back-to-top-compact"/>
        <h4 id="rest">[:de]Weitere Kapitularien und Ansegis[:en]Further capitularies and
            Ansegis[:]</h4>
        <table style="font-size:95%;">
            <thead>
                <tr>
                    <!--<td class="BK">-->
                    <th>
                        <!--<h6>-->[:de]Nummer[:en]No.[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!--<td class="title">-->
                    <th>
                        <!--<h6>-->[:de]Titel[:en]Caption[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!--<td class="new_id">-->
                    <th>
                        <!--<h6>-->[:de]Projektinterne Nummerierung[:en]New (project)
                        number[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!-- Zukünftig kanonische Nummerierung -->
                </tr>
            </thead>
            <xsl:apply-templates select="descendant::tei:item[not(@xml:id)][not(parent::tei:list[@type='transmission'])]"/>
        </table><xsl:call-template name="back-to-top-compact"/>
        <h4 id="Mordek">[:de]Neuentdeckte Kapitularien (Mordek Anhang I)[:en]Newly discovered
            capitularies (Mordek appendix I)[:]</h4>
        <table style="font-size:95%;">
            <thead>
                <tr>
                    <!--<td class="Mordek">-->
                    <th>
                        <!--<h6>-->[:de]Nummer[:en]No.[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!--<td class="title_mordek">-->
                    <th>
                        <!--<h6>-->[:de]Titel[:en]Caption[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!--<td class="new_id">-->
                    <th>
                        <!--<h6>-->[:de]Projektinterne Nummerierung[:en]New (project)
                        number[:]<!--</h6>-->
                    </th>
                    <!--</td>-->
                    <!-- Zukünftig kanonische Nummerierung -->
                </tr>
            </thead>      
            <xsl:for-each select="tei:list">
                <xsl:sort select="//tei:item/@xml:id"/>
            </xsl:for-each> 
            <xsl:apply-templates select="//tei:item[starts-with(@xml:id,'Mordek_')]"/>
        </table>
        
        <xsl:call-template name="back-to-top-compact"/>
    </xsl:template>
    
    <xsl:template match="tei:item[starts-with(@xml:id,'BK')]" >
        <xsl:if test="not(contains(@xml:id,'ltr.'))"><xsl:for-each select=".">            
            <tr style="font-size:95%;">
                <td class="BK">
                    <xsl:if test="starts-with(@xml:id,'BK_0')"><xsl:choose>
                        <xsl:when test="starts-with(@xml:id,'BK_00')"><xsl:value-of select="(substring-after(@xml:id,'BK_00'))"/></xsl:when>                        
                        <xsl:otherwise><xsl:value-of select="(substring-after(@xml:id,'BK_0'))"/></xsl:otherwise></xsl:choose></xsl:if>
                    <xsl:if test="not(starts-with(@xml:id,'BK_0'))">
                        <xsl:value-of select="(substring-after(@xml:id,'BK_'))"/>
                    </xsl:if>
                </td>
                <td class="title" style="font-style:italic;">
                    <xsl:apply-templates select="tei:name"/>
                </td>
                <td>
                    <xsl:if test="@corresp">
                        <xsl:value-of select="@corresp"/>
                    </xsl:if>
                </td>
            </tr>
        </xsl:for-each></xsl:if>
    </xsl:template>
    <xsl:template match="tei:item[not(@xml:id)]">
        <xsl:for-each select=".">
            <xsl:sort select="@xml:id"/>
            <tr>
                <td class="rest">
                    <xsl:text>-</xsl:text>
                </td>
                <td class="title" style="font-style:italic;">
                    <xsl:apply-templates select="tei:name"/>
                </td>
                <td>
                    <xsl:if test="@corresp">
                        <xsl:value-of select="@corresp"/>
                    </xsl:if>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:item[starts-with(@xml:id,'Mordek_')]">
        <xsl:if test="not(contains(@xml:id,'ltr.'))"><xsl:for-each select=".">
            <tr>
                <td class="Mordek">
                    <xsl:choose>
                        <xsl:when test="starts-with(@xml:id,'Mordek_0')"><xsl:value-of select="(substring-after(@xml:id,'Mordek_0'))"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="(substring-after(@xml:id,'Mordek_'))"/></xsl:otherwise>
                    </xsl:choose>
                </td>
                <td class="title" style="font-style:italic;">
                    <xsl:apply-templates select="tei:name"/>
                </td>
                <td>
                    <xsl:if test="@corresp">
                        <xsl:value-of select="@corresp"/>
                    </xsl:if>
                </td>
            </tr>
        </xsl:for-each></xsl:if>
    </xsl:template>
    <xsl:template match="tei:name[parent::tei:item]">
        <xsl:choose>
            <xsl:when test="parent::tei:item/@n='publ'">
                <a class="ssdone">
                    <xsl:attribute name="title">
                        <xsl:text>[:de]Zu Nr.[:en]Go to no.[[:] </xsl:text>
                        <xsl:value-of select="substring-after(parent::tei:item/@corresp,'.')"/>
                        <xsl:text> [:de]nach[:en]by[:] </xsl:text>
                        <xsl:if test="contains(parent::tei:item/@corresp,'BK')">
                            <xsl:text>Boretius-Kause</xsl:text>
                        </xsl:if>
                        <xsl:if test="contains(parent::tei:item/@corresp,'Mordek')">
                            <xsl:text>Mordek</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$capit"/>                        
                        <xsl:value-of select="@ref"/>
                    </xsl:attribute>
                    <i><xsl:value-of select="."/></i>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
