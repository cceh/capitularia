<?xml version="1.0" encoding="UTF-8"?>
<?oxygen RNGSchema="../tei_ms.rng" type="xml"?>
<xsl:stylesheet exclude-result-prefixes="tei" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>   
    <xsl:template match="TEI">
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="teiHeader" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="fileDesc" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="titleStmt" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:text>Kritischer Text von Capitulare 137</xsl:text>
                        </xsl:element>
                        <xsl:element name="editor" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:text>Karl Ubl</xsl:text>
                        </xsl:element>
                        <xsl:element name="respStmt" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="key">KU</xsl:attribute>
                                <xsl:element name="forename" namespace="http://www.tei-c.org/ns/1.0"
                                    >Karl</xsl:element>
                                <xsl:element name="surname" namespace="http://www.tei-c.org/ns/1.0"
                                    >Ubl</xsl:element>
                            </xsl:element>
                            <xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">ger</xsl:attribute>Projektleitung </xsl:element>
                            <xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">eng</xsl:attribute>Project lead </xsl:element>
                            <xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">ger</xsl:attribute>Erstellung des
                                kritischen Texts im CTE; Projektleitung </xsl:element>
                            <xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">eng</xsl:attribute>Creation of
                                critical text within the CTE; Project lead </xsl:element>
                        </xsl:element>
                        <xsl:element name="respStmt" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="key">DS</xsl:attribute>
                                <xsl:element name="forename" namespace="http://www.tei-c.org/ns/1.0"
                                    >Daniela</xsl:element>
                                <xsl:element name="surname" namespace="http://www.tei-c.org/ns/1.0"
                                    >Schulz</xsl:element>
                            </xsl:element>
                            <xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">ger</xsl:attribute>
                                Technische Umsetzung, Überführung des
                                CTE-Outputs
                                
                            </xsl:element>
                            <xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">eng</xsl:attribute>
                                technical support, conversion of CTE-output
                                
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="funder" namespace="http://www.tei-c.org/ns/1.0">Akademie
                            der Wissenschaften und Künste Nordrhein-Westfalen</xsl:element>
                    </xsl:element>
                    <xsl:element name="publicationStmt" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="publisher" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="persName"
                                >Karl Ubl</xsl:element>
                            <xsl:element name="orgName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">ger</xsl:attribute>Historisches
                                Institut, Lehrstuhl für Geschichte des Mittelalters, Universität zu
                                Köln</xsl:element>
                            <xsl:element name="orgName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">eng</xsl:attribute>History
                                Department, Chair for Medieval History, Cologne
                                University</xsl:element>
                            <xsl:element name="address" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">ger</xsl:attribute>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0"
                                    >Albertus-Magnus-Platz</xsl:element>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0"
                                    >50923 <xsl:element name="settlement"
                                        namespace="http://www.tei-c.org/ns/1.0"
                                        >Köln</xsl:element></xsl:element>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0">Philosophikum Raum 4.108</xsl:element>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0">0221-470 2717</xsl:element>
                                <xsl:element name="country" namespace="http://www.tei-c.org/ns/1.0">Deutschland</xsl:element>                                
                            </xsl:element>
                            <xsl:element name="address" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:lang">en</xsl:attribute>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0"
                                    >Albertus-Magnus-Platz</xsl:element>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0"
                                    >50923 <xsl:element name="settlement"
                                        namespace="http://www.tei-c.org/ns/1.0"
                                        >Cologne</xsl:element></xsl:element>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0">Philosophikum Room 4.108</xsl:element>
                                <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0">+49 221-470 2717</xsl:element>
                                <xsl:element name="country" namespace="http://www.tei-c.org/ns/1.0">Germany</xsl:element>                                
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="availability" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="p">
                                <xsl:attribute name="xml:lang">ger</xsl:attribute>Vorabversion des kritischen Textes zur
                                Veröffentlichung auf der Capitularia-Webseite</xsl:element>
                        </xsl:element>
                        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="when">2016-08-28</xsl:attribute>28.08.2016</xsl:element><xsl:comment>Datum anpassen</xsl:comment>
                    </xsl:element>
                    <xsl:element name="sourceDesc" namespace="http://www.tei-c.org/ns/1.0"><xsl:comment>Hier werden die verwendeten Textzeugen (Hss und weitere, z.B. Editionen) genannt: @n = im Apparat verwendete Sigle; @xml:id = Slug der Hs;
                            Die weiteren Textzeugen bekommen kein @xml:id</xsl:comment>
                        <xsl:element name="listWit" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="n">BK.137</xsl:attribute><xsl:comment>Anpassen: Der @n-Wert sollte die BK-Nummer in der Form sein, in der sie in den Milestones verwendet werden</xsl:comment>
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="witness">
                                <xsl:attribute name="n">Ko</xsl:attribute>
                                <xsl:attribute name="xml:id">kopenhagen-kb-1943-4</xsl:attribute>
                                <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">Kopenhagen, Kongelige Bibliotek, Gl. Kgl. Saml. 1943. 4°</xsl:element>
                            </xsl:element>
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="witness">
                                <xsl:attribute name="n">P4</xsl:attribute>
                                <xsl:attribute name="xml:id">paris-bn-lat-2718</xsl:attribute>
                                <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">Paris, Bibliothèque Nationale, Lat. 2718</xsl:element>
                            </xsl:element>
                            <xsl:comment>Ab hier Drucke</xsl:comment>
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="witness">
                                <xsl:attribute name="n">Carp.</xsl:attribute> 
                                <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">Carpentier, Alphabetum Tironianum S. 3 f.</xsl:element>
                            </xsl:element>                            
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="witness">
                                <xsl:attribute name="n">Schmitz</xsl:attribute> 
                                <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">Schmitz, Monumenta Tachygraphica S. 45-47</xsl:element>
                            </xsl:element>
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="witness">
                                <xsl:attribute name="n">Bor.</xsl:attribute> 
                                <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">Boretius 1, S. 273-275</xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="body"><xsl:apply-templates/></xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="teiHeader"/>
    <xsl:template match="//body/p[@rend='text-indent:0mm;line-height:13.9pt;-cte-line-height:fixed;']">
        <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="ab">
            <xsl:attribute name="type">text</xsl:attribute><xsl:apply-templates></xsl:apply-templates></xsl:element>
    </xsl:template>   
    <xsl:template match="//body/p[@rend='text-indent:0mm;line-height:13.9pt;-cte-line-height:fixed;font-size:12pt;']">
        <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="ab">
            <xsl:attribute name="type">text</xsl:attribute><xsl:apply-templates></xsl:apply-templates></xsl:element>
    </xsl:template>  
    
    <xsl:template match="p[parent::note]">        
        <xsl:apply-templates/>        
    </xsl:template>
    
    <xsl:template match="hi">
        <xsl:choose>
            <xsl:when test="@rend='font-style:italic;'">
                <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rend">italic</xsl:attribute><xsl:apply-templates></xsl:apply-templates></xsl:element>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates></xsl:apply-templates></xsl:otherwise>
        </xsl:choose>           
    </xsl:template>
    <xsl:template match="seg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="abbr">
        <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">internal</xsl:attribute>
            <xsl:attribute name="subtype">witness</xsl:attribute>
            <xsl:attribute name="target"><xsl:value-of select="."/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="note">
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:choose>
                <xsl:when test="@type='a1'">
                    <xsl:attribute name="type">textcrit</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type">comment</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>            
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mentioned">
        <xsl:element name="mentioned" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
