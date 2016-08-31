<?xml version="1.0" encoding="UTF-8"?>
<?oxygen RNGSchema="../tei_ms.rng" type="xml"?>
<xsl:stylesheet exclude-result-prefixes="tei" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="//tei:item">
        <xsl:if test="@xml:id">
            <xsl:for-each select=".">
                <xsl:variable name="url">
                    <xsl:value-of select="child::tei:name/@ref"/>
                </xsl:variable>
                <xsl:result-document href="kapitularien/{$url}.xml">
                    <TEI xml:lang="de" xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="$url"/>
                        </xsl:attribute>
                        <!--<xsl:attribute name="n">
                            <xsl:number count="tei:msDesc"/>
                        </xsl:attribute>-->
                        <teiHeader>
                            <fileDesc>
                                <titleStmt>
                                    <title type="main" xml:lang="ger">                                        
                                        <xsl:value-of select="tei:name"></xsl:value-of>
                                        <xsl:text>" [</xsl:text>
                                        <xsl:value-of select="substring-before(@xml:id,'_')"/>
                                        <xsl:text> </xsl:text><xsl:value-of select="substring-after(@xml:id,'_')"></xsl:value-of>
                                        <xsl:text>]</xsl:text>
                                    </title>
                                    <respStmt>
                                        <persName key="KU">
                                            <forename>Karl</forename>
                                            <surname>Ubl</surname>
                                        </persName>
                                        <resp xml:lang="ger">Projektleitung</resp>
                                        <resp xml:lang="eng">Project lead</resp>
                                    </respStmt>
                                    <respStmt>                                        
                                        <persName key="DT">
                                            <forename>Dominik</forename>
                                            <surname>Trump</surname>
                                        </persName>
                                        <resp xml:lang="ger">Aufbau der Kapitularienliste</resp>
                                        <resp xml:lang="eng">Aggregation of list</resp>
                                    </respStmt>
                                    
                                    <respStmt>
                                        <persName key="DS">
                                            <forename>Daniela</forename>
                                            <surname>Schulz</surname>
                                        </persName>
                                        <resp xml:lang="ger">Weiterverarbeitung und Transformation</resp>
                                        <resp xml:lang="eng">transformation</resp>
                                    </respStmt>
                                    <funder>Akademie der Wissenschaften und Künste
                                        Nordrhein-Westfalen</funder>
                                </titleStmt>
                                <publicationStmt>
                                    <publisher>
                                        <persName>Karl Ubl</persName>
                                        <orgName xml:lang="ger">Historisches Institut, Lehrstuhl für
                                            Geschichte des Mittelalters, Universität zu
                                            Köln</orgName>
                                        <orgName xml:lang="eng">History Department, Chair for
                                            Medieval History, Cologne University</orgName>
                                        <address xml:lang="ger">
                        <addrLine>Albertus-Magnus-Platz</addrLine>
                        <addrLine>50923 <settlement>Köln</settlement></addrLine>
                        <addrLine>Philosophikum Raum 4.009</addrLine>
                        <addrLine>0221-470 2717</addrLine> 
                        <country>Deutschland</country>
                    </address>
                                        <address xml:lang="eng">
                        <addrLine>Albertus-Magnus-Platz</addrLine>
                        <addrLine>50923 <settlement>Cologne</settlement></addrLine>
                        <addrLine>Philosophikum Room 4.009</addrLine>
                        <addrLine>+49 221-470 2717</addrLine> 
                        <country>Germany</country>
                    </address>
                                    </publisher>
                                    <availability>
                                        <p xml:lang="ger">Die Inhalte sind frei zugänglich und
                                            nicht-kommerziell. Einige Digitalisate und Texte sind
                                            aus rechtlichen Gründen jedoch Mitarbeitern
                                            vorbehalten.</p>
                                        <p xml:lang="eng">Content is freely available on a
                                            non-commercial basis. Some digital images and texts are
                                            only available to staff due to copyright issues.</p>
                                    </availability>
                                    <date when="2015-10-07">07.10.2015</date>
                                </publicationStmt>
                                <xsl:element name="sourceDesc"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:element name="p">born digital</xsl:element>
                                </xsl:element>
                            </fileDesc>
                            <encodingDesc>
                                <projectDesc>
                                    <p xml:lang="ger">Capitularia. Edition der fränkischen
                                        Herrschererlasse: <ptr type="trl"
                                            target="http://capitularia.uni-koeln.de/projekt/ueber-das-projekt/"
                                        /></p>
                                    <p xml:lang="eng">Capitularia. Edition of the Frankish
                                        capitularies: <ptr type="trl"
                                            target="http://capitularia.uni-koeln.de/projekt/ueber-das-projekt/"
                                        /></p>
                                </projectDesc>
                            </encodingDesc>
                            <xsl:element name="revisionDesc" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:element name="change" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="when">2015-09-13</xsl:attribute>
                                    <xsl:attribute name="who">Daniela Schulz</xsl:attribute>
                                    <xsl:text>Erstellt aus der Kapitularienliste</xsl:text>
                                </xsl:element>
                            </xsl:element>
                        </teiHeader>                        
                        <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element name="body" inherit-namespaces="yes"><xsl:element inherit-namespaces="yes" name="div">
                                <xsl:apply-templates select="tei:name"></xsl:apply-templates>
                                <xsl:copy-of select="tei:note[@type='annotation']" copy-namespaces="no"></xsl:copy-of>    
                                <xsl:copy-of select="tei:note[@type='titles']" copy-namespaces="no"></xsl:copy-of>
                                <xsl:copy-of select="tei:note[@type='date']" copy-namespaces="no"></xsl:copy-of>
                                <xsl:copy-of select="tei:list[@type='transmission']" copy-namespaces="no"></xsl:copy-of>
                                <xsl:copy-of select="tei:listBibl[@type='literature']" copy-namespaces="no"></xsl:copy-of>
                                <xsl:copy-of select="tei:listBibl[@type='translation']" copy-namespaces="no"></xsl:copy-of></xsl:element></xsl:element>
                        </xsl:element>
                    </TEI>
                </xsl:result-document>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:name">
        <xsl:element name="head" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="substring-before(ancestor::tei:item/@xml:id,'_')"/>
            <xsl:text> Nr. </xsl:text><xsl:value-of select="substring-after(ancestor::tei:item/@xml:id,'_')"></xsl:value-of>
            <xsl:text>: </xsl:text>
            <xsl:apply-templates/></xsl:element>
    </xsl:template>
</xsl:stylesheet>
