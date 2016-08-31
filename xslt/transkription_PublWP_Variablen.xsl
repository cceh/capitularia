<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0" exclude-result-prefixes="exslt msxsl tei xhtml my">

	<!-- ########## INCLUDES ########## -->

        <xsl:include href="xsl-output.xsl"/>
	
	<!-- ########## /INCLUDES ########## -->

	<!-- author: NG -->

	<!-- Funktion node-set() per Namespace "exslt" implementieren -->
	<msxsl:script language="JScript" implements-prefix="exslt">
		this['node-set'] =  function (x) {
		return x;
		}
	</msxsl:script>


	<xsl:key name="kSubst_Liste" match="//tei:subst" use="generate-id(.)"/>
	<xsl:key name="kAdd_Liste" match="//tei:add" use="generate-id(.)"/>
	<xsl:key name="kDel_Liste" match="//tei:del" use="generate-id(.)"/>
	<xsl:key name="kMod_Liste" match="//tei:mod" use="generate-id(.)"/>
	<xsl:key name="kSic_Liste" match="//tei:sic" use="generate-id(.)"/>
	<xsl:key name="kSpace_Liste" match="//tei:space" use="generate-id(.)"/>
	<xsl:key name="kChoice_Liste" match="//tei:choice" use="generate-id(.)"/>

	<!-- all <subst> -->
	<xsl:variable name="vSubst_Liste">
		<xsl:for-each select="//tei:subst">
			<xsl:copy>
				<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
				<xsl:for-each select="@*">
					<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:for-each>
				<xsl:for-each select="./*">
					<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
				</xsl:for-each>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable>

	<!-- <subst> -->
	<!-- <subst> with a <note> -->
	<xsl:variable name="Subst_mNote">
		<xsl:for-each select="//tei:subst">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vSubst_mNote" select="key('kSubst_Liste',exslt:node-set($Subst_mNote)/*/@id)"/>

	<!-- <subst> without a <note> -->
	<xsl:variable name="Subst_oNote">
		<xsl:for-each select="//tei:subst">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vSubst_oNote" select="key('kSubst_Liste',exslt:node-set($Subst_oNote)/*/@id)"></xsl:variable>
	<!-- </subst> -->

	<!-- <add> -->
	<!-- <add> with a <note> -->
	<xsl:variable name="Add_mNote">
		<xsl:for-each select="//tei:add[parent::*[local-name(.)!='subst']]">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vAdd_mNote" select="key('kAdd_Liste',exslt:node-set($Add_mNote)/*/@id)"></xsl:variable>

	<!-- <add> without a <note> -->
	<xsl:variable name="Add_oNote">
		<xsl:for-each select="//tei:add[parent::*[local-name(.)!='subst']]">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vAdd_oNote" select="key('kAdd_Liste',exslt:node-set($Add_oNote)/*/@id)"></xsl:variable>
	<!-- </add> -->

	<!-- <del> -->
	<!-- <del> with a <note> -->
	<xsl:variable name="Del_mNote">
		<xsl:for-each select="//tei:del[parent::*[local-name(.)!='subst']][count(./node())>0]">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vDel_mNote" select="key('kDel_Liste',exslt:node-set($Del_mNote)/*/@id)"></xsl:variable>

	<!-- <del> without a <note> -->
	<xsl:variable name="Del_oNote">
		<xsl:for-each select="//tei:del[parent::*[local-name(.)!='subst']][count(./node())>0]">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vDel_oNote" select="key('kDel_Liste',exslt:node-set($Del_oNote)/*/@id)"></xsl:variable>
	<!-- </del> -->

	<!-- <mod> -->
	<!-- <mod> with a <note> -->
	<xsl:variable name="Mod_mNote">
		<xsl:for-each select="//tei:mod">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vMod_mNote" select="key('kMod_Liste',exslt:node-set($Mod_mNote)/*/@id)"></xsl:variable>

	<!-- <mod> without a <note> -->
	<xsl:variable name="Mod_oNote">
		<xsl:for-each select="//tei:mod">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vMod_oNote" select="key('kMod_Liste',exslt:node-set($Mod_oNote)/*/@id)"></xsl:variable>
	<!-- </mod> -->

	<!-- <sic> -->
	<!-- <sic> with a <note> -->
	<xsl:variable name="Sic_mNote">
		<xsl:for-each select="//tei:sic">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vSic_mNote" select="key('kSic_Liste',exslt:node-set($Sic_mNote)/*/@id)"></xsl:variable>

	<!-- <sic> without a <note> -->
	<xsl:variable name="Sic_oNote">
		<xsl:for-each select="//tei:sic">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vSic_oNote" select="key('kSic_Liste',exslt:node-set($Sic_oNote)/*/@id)"></xsl:variable>
	<!-- </sic> -->

	<!-- <space> -->
	<!-- <space> with a <note> -->
	<xsl:variable name="Space_mNote">
		<xsl:for-each select="//tei:space">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vSpace_mNote" select="key('kSpace_Liste',exslt:node-set($Space_mNote)/*/@id)"></xsl:variable>

	<!-- <space> without a <note> -->
	<xsl:variable name="Space_oNote">
		<xsl:for-each select="//tei:space">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vSpace_oNote" select="key('kSpace_Liste',exslt:node-set($Space_oNote)/*/@id)"></xsl:variable>
	<!-- </space> -->

	<!-- <mod> -->
	<!-- <choice> with a <note> -->
	<xsl:variable name="Choice_mNote">
		<xsl:for-each select="//tei:choice">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vChoice_mNote" select="key('kChoice_Liste',exslt:node-set($Choice_mNote)/*/@id)"></xsl:variable>

	<!-- <choice> without a <note> -->
	<xsl:variable name="Choice_oNote">
		<xsl:for-each select="//tei:choice">
			<xsl:variable name="vNoteFolgt">
				<xsl:call-template name="tNoteFolgt">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="vNumNoteFolgt">
				<xsl:choose>
					<xsl:when test="ancestor::tei:num">
						<xsl:call-template name="tNoteFolgt">
							<xsl:with-param name="pNode" select="ancestor::tei:num[1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
				<xsl:copy>
					<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:for-each select="./*">
						<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="vChoice_oNote" select="key('kChoice_Liste',exslt:node-set($Choice_oNote)/*/@id)"></xsl:variable>
	<!-- </mod> -->

	<!-- VARIABLEN für Fußnoten(-index) -->
	<xsl:variable name="funoSic" select="$vSic_oNote"/>
	<xsl:variable name="funoNote" select="//tei:note[@type='editorial'][ancestor::tei:body]"/>
	<xsl:variable name="funoNoteComment" select="//tei:note[@type='comment'][ancestor::tei:body]"/>
	<xsl:variable name="funoSubst" select="$vSubst_oNote"/>
	<xsl:variable name="funoDel" select="$vDel_oNote"/>
	<xsl:variable name="funoAdd" select="$vAdd_oNote"/>
	<xsl:variable name="funoSpace" select="$vSpace_oNote"/>
	<xsl:variable name="funoUnclear" select="//tei:unclear[count(tei:gap)>0]"/>
	<xsl:variable name="funoMod" select="$vMod_oNote"/>
	<xsl:variable name="funoChoice" select="$vChoice_oNote"/>
	<xsl:variable name="funoHandShift" select="//tei:handShift"/>

	<xsl:variable name="funoNumerisch" select="$funoNote|$funoSubst|$funoDel|$funoAdd|$funoSpace|$funoSpace|$funoMod|$funoChoice|$funoHandShift|$funoNoteComment"/>


</xsl:stylesheet>
