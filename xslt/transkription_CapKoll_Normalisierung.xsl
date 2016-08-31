<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:my="my" version="1.0" exclude-result-prefixes="exslt msxsl">
    
    <xsl:template name="tTextNormalisierung">
        <xsl:param name="pText"/>
        
        <xsl:variable name="vNormBuchstaben">
            <xsl:call-template name="tTextBuchstabenNormalisieren">
                <xsl:with-param name="pText" select="$pText"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vNormInterpunktion">
            <xsl:call-template name="tTextOhneInterpunktion">
                <xsl:with-param name="pText" select="$vNormBuchstaben"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vNormInterpunktion"/>
    </xsl:template>
    
    <xsl:template name="tTextBuchstabenNormalisieren">
        <xsl:param name="pText"/>
        <!-- Angleichung von Buchstabenvariationen zur einfacheren Kollation -->
        <!--
            
			* ae/e(caudata) => e
			* v => u
			* ci => ti (deaktiviert)
			
		-->
        
        <xsl:variable name="vTextREPLACED">
            <xsl:variable name="vTextREPLACEDae_lc">
                <xsl:call-template name="string-replace">
                    <xsl:with-param name="string" select="$pText"/>
                    <xsl:with-param name="replace" select="'ae'"/>
                    <xsl:with-param name="with" select="'e'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="vTextREPLACEDae_uc">
                <xsl:call-template name="string-replace">
                    <xsl:with-param name="string" select="$vTextREPLACEDae_lc"/>
                    <xsl:with-param name="replace" select="'AE'"/>
                    <xsl:with-param name="with" select="'E'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="vTextREPLACEDecaudata_lc">
                <xsl:call-template name="string-replace">
                    <xsl:with-param name="string" select="$vTextREPLACEDae_uc"/>
                    <xsl:with-param name="replace" select="'ę'"/>
                    <xsl:with-param name="with" select="'e'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="vTextREPLACEDecaudata_uc">
                <xsl:call-template name="string-replace">
                    <xsl:with-param name="string" select="$vTextREPLACEDecaudata_lc"/>
                    <xsl:with-param name="replace" select="'Ę'"/>
                    <xsl:with-param name="with" select="'E'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="vTextREPLACEDv_lc">
                <xsl:call-template name="string-replace">
                    <xsl:with-param name="string" select="$vTextREPLACEDecaudata_uc"/>
                    <xsl:with-param name="replace" select="'v'"/>
                    <xsl:with-param name="with" select="'u'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="vTextREPLACEDv_uc">
                <xsl:call-template name="string-replace">
                    <xsl:with-param name="string" select="$vTextREPLACEDv_lc"/>
                    <xsl:with-param name="replace" select="'V'"/>
                    <xsl:with-param name="with" select="'U'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <!--			<xsl:variable name="vTextREPLACEDci_lc">
				<xsl:call-template name="string-replace">
					<xsl:with-param name="string" select="$vTextREPLACEDv_uc"/>
					<xsl:with-param name="replace" select="'ci'"/>
					<xsl:with-param name="with" select="'ti'"/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vTextREPLACEDci_uc">
				<xsl:call-template name="string-replace">
					<xsl:with-param name="string" select="$vTextREPLACEDci_lc"/>
					<xsl:with-param name="replace" select="'CI'"/>
					<xsl:with-param name="with" select="'TI'"/>
				</xsl:call-template>
			</xsl:variable>-->
            
            <!--<xsl:value-of select="$vTextREPLACEDci_uc"/>-->
            <xsl:value-of select="$vTextREPLACEDv_uc"/>
            
        </xsl:variable>
        
        <xsl:value-of select="$vTextREPLACED"/>
    </xsl:template>
    
    <xsl:template name="tTextOhneInterpunktion">
        <xsl:param name="pText"/>
        
        <xsl:variable name="vTextREPLACED_Punkt">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$pText"/>
                <xsl:with-param name="replace" select="'.'"/>
                <xsl:with-param name="with" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vTextREPLACED_Komma">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vTextREPLACED_Punkt"/>
                <xsl:with-param name="replace" select="','"/>
                <xsl:with-param name="with" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vTextREPLACED_Doppelpunkt">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vTextREPLACED_Komma"/>
                <xsl:with-param name="replace" select="':'"/>
                <xsl:with-param name="with" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vTextREPLACED_Semikolon">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vTextREPLACED_Doppelpunkt"/>
                <xsl:with-param name="replace" select="';'"/>
                <xsl:with-param name="with" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vTextREPLACED_Ausrufezeichen">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vTextREPLACED_Semikolon"/>
                <xsl:with-param name="replace" select="'!'"/>
                <xsl:with-param name="with" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vTextREPLACED_Sternchen">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vTextREPLACED_Ausrufezeichen"/>
                <xsl:with-param name="replace" select="'*'"/>
                <xsl:with-param name="with" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vTextREPLACED_Sternchen"/>
        
    </xsl:template>
    
</xsl:stylesheet>