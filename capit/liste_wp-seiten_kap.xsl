<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs tei" version="1.0">
    <xsl:output method="xml"/>

    <xsl:template match="/">
        <list xml:id="kap">
            <head>Liste der Kapitularien Ludwigs des Frommen</head>
            <xsl:for-each select="//tei:body//tei:item">
                <cap>
                    <title>
                        <xsl:if test="contains(@corresp, 'BK')">
                            <xsl:text>BK Nr. </xsl:text>
                            <xsl:value-of select="substring-after(@corresp,'BK.')"/><xsl:text>: </xsl:text>
                        </xsl:if>
                        <xsl:if test="contains(@corresp, 'Mordek')">
                            <xsl:text>Mordek Nr. </xsl:text>
                            <xsl:value-of select="substring-after(@corresp,'Mordek.')"/><xsl:text>: </xsl:text>
                        </xsl:if>
                        <xsl:if test="not(@corresp)">
                            <xsl:text>o.N.: </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="tei:title"/>
                    </title>
                    <slug>
                        <xsl:if test="contains(@corresp, 'BK')">
                            <xsl:text>bk-nr-</xsl:text>
                            <xsl:value-of select="substring-after(@corresp,'BK.')"/>
                        </xsl:if>
                        <xsl:if test="contains(@corresp, 'Mordek')">
                            <xsl:text>mordek-</xsl:text>
                            <xsl:value-of select="substring-after(@corresp,'Mordek.')"/>
                        </xsl:if>
                    </slug>
                    <filename>
                        <xsl:if test="contains(@corresp, 'BK')">
                            <xsl:text>bk-nr-</xsl:text>
                            <xsl:value-of select="substring-after(@corresp,'BK.')"/>
                        </xsl:if>
                        <xsl:if test="contains(@corresp, 'Mordek')">
                            <xsl:text>mordek-</xsl:text>
                            <xsl:value-of select="substring-after(@corresp,'Mordek.')"/>
                        </xsl:if>
                        <xsl:text>.xml</xsl:text>
                    </filename>
                </cap>
            </xsl:for-each>
        </list>
    </xsl:template>
</xsl:stylesheet>
