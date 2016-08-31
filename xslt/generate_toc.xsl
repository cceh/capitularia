<?xml version="1.0" encoding="UTF-8"?>
<?oxygen RNGSchema="../tei_ms.rng" type="xml"?>
<xsl:stylesheet exclude-result-prefixes="tei" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" method="xml" indent="yes" xml:space="default"/>
    
    <xsl:template match="/">
        <xsl:element name="div">
            <xsl:attribute name="type">
                <xsl:text>content</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="xml:id">
                <xsl:text>divContent</xsl:text>
            </xsl:attribute><xsl:element name="list"><xsl:apply-templates/></xsl:element></xsl:element>
    </xsl:template>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:front"/>
    <xsl:template match="tei:note"/>
    <xsl:template match="//tei:del"/>
    <xsl:template match="tei:ab">
        <xsl:for-each select=".[@type='meta-text']">
            <xsl:element name="item">
                <xsl:attribute name="n">
                    <xsl:value-of select="count(preceding-sibling::tei:ab[@type='meta-text'])+1"/>
                </xsl:attribute>
                <xsl:element name="ptr">
                    <xsl:attribute name="target"><xsl:text>#</xsl:text>
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>internal</xsl:text>
                    </xsl:attribute>
                </xsl:element><xsl:apply-templates/>
                
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>