<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>
    
    <xsl:include href="xsl-output.xsl"/>
    
    <xsl:include href="allgFunktionen.xsl"/>
    <xsl:template match="/">
                <div class="xsl-output"><xsl:apply-templates select="//tei:body"/></div>
    </xsl:template>

    <xsl:template match="tei:body">        
         <xsl:apply-templates select="tei:listPlace[@type='historical']"/>
        <xsl:apply-templates select="tei:listPlace[@type='country']"/>
        <xsl:apply-templates select="tei:listPlace[@type='region_c']"/>
        <xsl:apply-templates select="tei:listPlace[@type='region_a']"/>
        <xsl:apply-templates select="tei:listPlace[@type='settlement']"/>        
       
        
    </xsl:template>

    <xsl:template match="tei:listPlace[@type='historical']">
        <h4 id="historical">[:de]Historische Regionen[:en]Historical regions[:]</h4>
        <xsl:apply-templates select="tei:place">
        </xsl:apply-templates>
        <hr/>
    </xsl:template><xsl:template match="tei:listPlace[@type='country']">
        <h4 id="countries">[:de]Länder[:en]Countries[:]</h4>
        <xsl:apply-templates select="tei:place">
            
        </xsl:apply-templates>
        <hr/>
    </xsl:template>
    <xsl:template match="tei:listPlace[@type='region_c']">
        <h4 id="region_c">[:de]Gebiete (Grundrichtungen)[:en]Cardinal regions[:]</h4>
        <xsl:apply-templates select="tei:place">           
        </xsl:apply-templates>
        <hr/>
    </xsl:template>
    <xsl:template match="tei:listPlace[@type='region_a']">
        <h4 id="region_a">[:de]Regionen[:en]Regions[:]</h4>
        <xsl:apply-templates select="tei:place">           
        </xsl:apply-templates>
        <hr/>
    </xsl:template>
    <xsl:template match="tei:listPlace[@type='settlement']">
        <h4 id="settlements">[:de]Orte[:en]Settlements[:]</h4>
        <xsl:apply-templates select="tei:place">
            </xsl:apply-templates>
        <hr/>
    </xsl:template>
    
   

    <xsl:template match="tei:place[parent::tei:listPlace[@type='country']]">
        <xsl:if test="child::tei:linkGrp[@type='mss']"><div>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <span style="font-size:small;">                
                <h5>
                    <xsl:attribute name="id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>[:de]<xsl:apply-templates select="tei:country[@xml:lang='DE']"/>[:en]<xsl:apply-templates select="tei:country[@xml:lang='EN']"/>[:]</h5>                
            </span>
            
            <xsl:if test="tei:note"><xsl:apply-templates select="tei:note"></xsl:apply-templates></xsl:if>
            
            <span style="font-size:x-small;">                
                <xsl:apply-templates select="tei:linkGrp[@type='geo']"/>
                <xsl:apply-templates select="tei:location"/> 
                <br/>
                <xsl:apply-templates select="tei:linkGrp[@type='mss']"/> 
            </span>            
            <hr/>
        </div></xsl:if>
    </xsl:template>
    <xsl:template match="tei:place[parent::tei:listPlace[@type='region_c']]">
        <xsl:if test="child::tei:linkGrp[@type='mss']"><div>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <span style="font-size:small;">                
                <h5><xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>[:de]<xsl:apply-templates select="tei:region[@xml:lang='DE'][@type='cardinal']"/>[:en]<xsl:apply-templates select="tei:region[@xml:lang='EN'][@type='cardinal']"/>[:]</h5>                
            </span>
           
            <xsl:if test="tei:note"><xsl:apply-templates select="tei:note"></xsl:apply-templates></xsl:if>
           
            <span style="font-size:x-small;">
                
                <xsl:apply-templates select="tei:linkGrp[@type='geo']"/>
                <xsl:apply-templates select="tei:location"/> 
                <br/>
                <xsl:apply-templates select="tei:linkGrp[@type='mss']"/> 
            </span>            
            <hr/>
        </div></xsl:if>
    </xsl:template> 
    <xsl:template match="tei:place[parent::tei:listPlace[@type='region_a']]">
        <xsl:if test="child::tei:linkGrp[@type='mss']"><div>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <span style="font-size:small;">                
                <h5><xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>[:de]<xsl:apply-templates select="tei:region[@xml:lang='DE'][@type='area']"/>[:en]<xsl:apply-templates select="tei:region[@xml:lang='EN'][@type='area']"/>[:]</h5>                
            </span>
           
            <xsl:if test="tei:note"><xsl:apply-templates select="tei:note"></xsl:apply-templates></xsl:if>
          
            <span style="font-size:x-small;">
                
                <xsl:apply-templates select="tei:linkGrp[@type='geo']"/>
                <xsl:apply-templates select="tei:location"/> 
                <br/>
                <xsl:apply-templates select="tei:linkGrp[@type='mss']"/> 
            </span>            
            <hr/>
        </div></xsl:if>
    </xsl:template>   
    <xsl:template match="tei:place[parent::tei:listPlace[@type='settlement']]">
        <xsl:if test="child::tei:linkGrp[@type='mss']"><div>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <span style="font-size:small;">                
                <h5><xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>[:de]<xsl:apply-templates select="tei:settlement[@xml:lang='DE']"/>[:en]<xsl:apply-templates select="tei:settlement[@xml:lang='EN']"/>[:]</h5>                
            </span>
           
            <xsl:if test="tei:note"><xsl:apply-templates select="tei:note"></xsl:apply-templates></xsl:if>
           
            <span style="font-size:x-small;">
                
                <xsl:apply-templates select="tei:linkGrp[@type='geo']"/>
                <!--<xsl:apply-templates select="tei:location"/> -->
                <br/>
                <xsl:apply-templates select="tei:linkGrp[@type='mss']"/> 
            </span>            
            <hr/>
        </div></xsl:if>
    </xsl:template>   
    <xsl:template match="tei:place[parent::tei:listPlace[@type='historical']]">
        <xsl:if test="child::tei:linkGrp[@type='mss']"><div>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <span style="font-size:small;">                
                <h5><xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>[:de]<xsl:apply-templates select="tei:region[@xml:lang='DE'][@type='historical']"/>[:en]<xsl:apply-templates select="tei:region[@xml:lang='EN'][@type='historical']"/>[:]</h5>                
            </span>
            
            <xsl:if test="tei:note"><xsl:apply-templates select="tei:note"></xsl:apply-templates></xsl:if>
           
            <span style="font-size:x-small;">                
                <xsl:apply-templates select="tei:linkGrp[@type='geo']"/>
                <xsl:apply-templates select="tei:location"/> 
                <br/>
                <xsl:apply-templates select="tei:linkGrp[@type='mss']"/> 
            </span>            
            <hr/>
        </div></xsl:if>
    </xsl:template>   
    
    <xsl:template match="tei:note">
        <br/><i><xsl:apply-templates></xsl:apply-templates></i><br/>
    </xsl:template>
    
    <xsl:template match="tei:linkGrp[@type='geo']">
        <br/>
        <span style="font-size:x-small;">
            <u><xsl:text>[:de]Information &amp; Identifikation [:en]Information &amp; identification[:]</xsl:text></u><br/>
            <xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:linkGrp[@type='mss']">
        <br/>
        <span style="font-size:x-small;">
            <u><xsl:text>[:de]Als Herkunft genannt für: [:en]Estimated origin of:[:]</xsl:text></u><br/>
        <xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:link[parent::tei:linkGrp[@type='geo']]">
        <br/>
        <xsl:if test="@type='geonames'">
            <xsl:text> - Geonames: </xsl:text>
            <a target="_blank" title="Zum Geonames-Eintrag">
                <xsl:attribute name="href">
                    <xsl:text>http://www.geonames.org/</xsl:text>
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:value-of select="@target"/>
            </a>
        </xsl:if>
        <xsl:if test="@type='gnd'">
            <xsl:text> - GND: </xsl:text>
            <a target="_blank" title="Zum GND-Eintrag">
                <xsl:attribute name="href">
                    <xsl:text>http://d-nb.info/gnd/</xsl:text>
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="@target"/>
            </a>
        </xsl:if>
        <xsl:if test="@type='viaf'">
            <xsl:text> - VIAF: </xsl:text>
            <a target="_blank" title="Zum GND-Eintrag">
                <xsl:attribute name="href">
                    <xsl:text>http://viaf.org/viaf/</xsl:text>
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="@target"/>
            </a>
        </xsl:if>
        <xsl:if test="@type='tgn'">
            <xsl:text> - TGN: </xsl:text>
            <a target="_blank" title="Zum TGN-Eintrag">
                <xsl:attribute name="href">
                    <xsl:text>http://www.getty.edu/research/tools/vocabularies/tgn/index.html?find=</xsl:text>
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="@target"/>
            </a>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:link[parent::tei:linkGrp[@type='mss']]">
        
       <!-- <a>
            <xsl:attribute name="href">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
            <xsl:attribute name="title">[:de]Zur Handschrift[:en]Go to manuscript[:]</xsl:attribute>
            <xsl:attribute name="target">_blank</xsl:attribute>-->
            <li><xsl:value-of select="@corresp"/></li>
        <!--</a>-->
    </xsl:template>
    
    <xsl:template match="tei:geo"/>
   <!--<xsl:template match="tei:location">
       <br/>
       <xsl:text> - [:de]Geokoordinaten[:en]coordinates[:]: </xsl:text><a><xsl:attribute name="href">https://www.google.de/maps/@<xsl:apply-templates select="tei:geo"></xsl:apply-templates></xsl:attribute><xsl:attribute name="title">Google Maps</xsl:attribute>
       <xsl:attribute name="target">_blank</xsl:attribute><xsl:apply-templates/>
       </a>
   </xsl:template>-->
    
    
</xsl:stylesheet>
