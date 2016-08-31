<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="xs date msxsl"
	version="1.0">

	<msxsl:script language="JScript" implements-prefix="date">
		<![CDATA[
	function date(){
		var oDate = new Date();
		var ret = "";
		var m = oDate.getMonth() + 1;
	    var mm = m < 10 ? "0" + m : m;
		ret = ret + mm + "/";
		var d = oDate.getDate();
		var dd = d < 10 ? "0" + d : d;
		ret = ret + dd + "/";
		ret = ret + oDate.getFullYear();
		return ret;
		}
	]]>
	</msxsl:script>


	<!-- Funktion node-set() per Namespace "exslt" implementieren -->
	<msxsl:script language="JScript" implements-prefix="exslt">
		this['node-set'] =  function (x) {
		return x;
		}
	</msxsl:script>

	<xsl:template name="tCurrentDate">
		<xsl:variable name="vDateRaw">
			<xsl:value-of select="date:date()"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($vDateRaw) &gt; 10">
				<!-- enthält mehr als YYYY-MM-DD -->
				<xsl:value-of select="substring($vDateRaw,1,10)"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- enthält nur YYYY-MM-DD -->
				<xsl:value-of select="$vDateRaw"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="string-replace">
		<xsl:param name="string" />
		<xsl:param name="replace" />
		<xsl:param name="with" />

		<xsl:choose>
			<xsl:when test="contains($string, $replace)">
				<xsl:value-of select="substring-before($string, $replace)" />
				<xsl:value-of select="$with" />
				<xsl:call-template name="string-replace">
					<xsl:with-param name="string" select="substring-after($string,$replace)" />
					<xsl:with-param name="replace" select="$replace" />
					<xsl:with-param name="with" select="$with" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="indexOf">
		<!-- Zahl -->
		<xsl:param name="pSeq"/>
		<xsl:param name="pNode"/>

		<xsl:for-each select="$pSeq">
			<xsl:if test="generate-id(current())=generate-id($pNode)">
				<xsl:number value="position()" format="1"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="indexOf_a">
		<!-- Buchstabe -->
		<xsl:param name="pSeq"/>
		<xsl:param name="pNode"/>

		<xsl:for-each select="$pSeq">
			<xsl:if test="generate-id(current())=generate-id($pNode)">
				<xsl:number value="position()" format="a"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="string-join">
		<xsl:param name="pSequence" select="''"/>
		<xsl:param name="pSeparator" select="','"/>

		<xsl:for-each select="$pSequence">
			<xsl:choose>
				<xsl:when test="position()=1">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($pSeparator,.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="tDeepCopy">
		<xsl:param name="pNode"/>

		<xsl:copy>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:for-each select="./*">
				<!--<xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>-->
				<xsl:call-template name="tDeepCopy">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="tBeginntMitVokal">
		<xsl:param name="pText"/>
		<xsl:variable name="vTextLC">
			<xsl:call-template name="tLowerCase">
				<xsl:with-param name="pText" select="$pText"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<!--<xsl:when test="substring($pText,1,1)='a' or substring($pText,1,1)='e' or substring($pText,1,1)='i' or substring($pText,1,1)='o' or substring($pText,1,1)='u' or substring($pText,1,1)='A' or substring($pText,1,1)='E' or substring($pText,1,1)='I' or substring($pText,1,1)='O' or substring($pText,1,1)='U'">-->
			<xsl:when test="substring($vTextLC,1,1)='a' or substring($vTextLC,1,1)='e' or substring($vTextLC,1,1)='i' or substring($vTextLC,1,1)='o' or substring($vTextLC,1,1)='u' ">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tUpperCase">
		<xsl:param name="pText"/>

		<xsl:variable name="lowercase" select="abcdefghijklmnopqrstuvwxyzäöü"/>
		<xsl:variable name="uppercase" select="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ"/>

		<xsl:variable name="vUpperCase" select="translate($pText,$lowercase,$uppercase)"/>
	</xsl:template>
	<xsl:template name="tLowerCase">
		<xsl:param name="pText"/>

		<xsl:variable name="lowercase" select="abcdefghijklmnopqrstuvwxyzäöü"/>
		<xsl:variable name="uppercase" select="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ"/>

		<xsl:variable name="vLowerCase" select="translate($pText,$uppercase,$lowercase)"/>
	</xsl:template>

	<xsl:template name="tLastSubstringAfter">
		<!-- sucht hinter erstem Fund des Zeichens noch weiter in Zeichenkette und liefert den zuletzt gefundenen substring-after() -->
		<xsl:param name="pString"/>
		<xsl:param name="pCharacter"/>

		<xsl:variable name="vSubstringAfter" select="substring-after($pString,$pCharacter)"/>

		<xsl:choose>
			<xsl:when test="string-length($vSubstringAfter)>0">
				<!-- Zeichen/Zeichenkette in String gefunden -->
				<xsl:variable name="vLastSubstringAfter">
					<!-- Rekursion -->
					<xsl:call-template name="tLastSubstringAfter">
						<xsl:with-param name="pString" select="$vSubstringAfter"/>
						<xsl:with-param name="pCharacter" select="$pCharacter"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="string-length($vLastSubstringAfter)>0">
						<!-- Zeichen/Zeichenkette nochmals in String gefunden -->
						<xsl:value-of select="$vLastSubstringAfter"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$vSubstringAfter"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$pString"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

    <xsl:template name="back-to-top">
      <div class="back-to-top">
	<a class="ssdone" title="Zum Seitenanfang" href="#top"></a>
      </div>
    </xsl:template>

    <xsl:template name="back-to-top-hr">
      <div class="back-to-top back-to-top-with-rule">
	<a class="ssdone" title="Zum Seitenanfang" href="#top"></a>
      </div>
    </xsl:template>

    <xsl:template name="back-to-top-compact">
      <div class="back-to-top back-to-top-compact">
	<a class="ssdone" title="Zum Seitenanfang" href="#top"></a>
      </div>
    </xsl:template>

    <xsl:template name="page-break">
      <div class="page-break" />
    </xsl:template>

    <xsl:template name="hr">
      <div class="hr" />
    </xsl:template>
	
    <xsl:template name="tNormalizeString">
        <xsl:param name="pString"/>
        <!-- returns kinda normalization of pString -->
        <!-- 
            currently included (keep this list updated for a quick look-up):
            tUmlaute: äöüÄÖÜ => ae, Ae etc.
            tAkzente: éèêÉÈÊíìîÍÌÎóòôÓÒÔáàâÁÀÂúùûÚÙÛ => eacute, Eacute etc.
            tSonstige: ßç => ss, ccedil etc.
        -->
        
        <!--
        <!-\-for testing purposes:-\->    
        <xsl:variable name="vUmlaute" select="'äöüÄÖÜ'"/>
        <xsl:variable name="vAkzente" select="'éèêÉÈÊíìîÍÌÎóòôÓÒÔáàâÁÀÂúùûÚÙÛ'"/>
        <xsl:variable name="vSonstige" select="'ßç'"/>
        -->
        
        
        <xsl:variable name="vOhneUmlaute">
            <xsl:call-template name="tUmlaute">
                <xsl:with-param name="pString" select="$pString"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vOhneAkzente">
            <xsl:call-template name="tAkzente">
                <xsl:with-param name="pString" select="$vOhneUmlaute"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="vOhneSonstige">
            <xsl:call-template name="tSonstige">
                <xsl:with-param name="pString" select="$vOhneAkzente"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vOhneSonstige"/>
        
    </xsl:template>
    
    <xsl:template name="tUmlaute">
        <xsl:param name="pString"/>
        <xsl:variable name="vUml" select="$pString"/>
        
        <xsl:variable name="vUml1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml"/>
                <xsl:with-param name="replace" select="'ä'"/>
                <xsl:with-param name="with" select="'ae'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml1"/>
                <xsl:with-param name="replace" select="'Ä'"/>
                <xsl:with-param name="with" select="'Ae'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml3">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml2"/>
                <xsl:with-param name="replace" select="'ö'"/>
                <xsl:with-param name="with" select="'oe'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml4">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml3"/>
                <xsl:with-param name="replace" select="'Ö'"/>
                <xsl:with-param name="with" select="'Oe'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml5">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml4"/>
                <xsl:with-param name="replace" select="'ü'"/>
                <xsl:with-param name="with" select="'ue'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml6">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml5"/>
                <xsl:with-param name="replace" select="'Ü'"/>
                <xsl:with-param name="with" select="'Ue'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml7">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml6"/>
                <xsl:with-param name="replace" select="'ë'"/>
                <xsl:with-param name="with" select="'ee'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vUml8">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vUml7"/>
                <xsl:with-param name="replace" select="'Ë'"/>
                <xsl:with-param name="with" select="'Ee'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vUml8"/>
    </xsl:template>
    
    <xsl:template name="tAkzente">
        <xsl:param name="pString"/>
        
        <xsl:variable name="vAkz1">
            <xsl:call-template name="tAkzenteA">
                <xsl:with-param name="pString" select="$pString"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz2">
            <xsl:call-template name="tAkzenteE">
                <xsl:with-param name="pString" select="$vAkz1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz3">
            <xsl:call-template name="tAkzenteO">
                <xsl:with-param name="pString" select="$vAkz2"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz4">
            <xsl:call-template name="tAkzenteU">
                <xsl:with-param name="pString" select="$vAkz3"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz5">
            <xsl:call-template name="tAkzenteI">
                <xsl:with-param name="pString" select="$vAkz4"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vAkz5"/>
    </xsl:template>
    
    <xsl:template name="tAkzenteE">
        <xsl:param name="pString"/>
        <xsl:variable name="vAkz" select="$pString"/>
        
        <xsl:variable name="vAkz1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz"/>
                <xsl:with-param name="replace" select="'é'"/>
                <xsl:with-param name="with" select="'eacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz1"/>
                <xsl:with-param name="replace" select="'É'"/>
                <xsl:with-param name="with" select="'Eacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz3">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz2"/>
                <xsl:with-param name="replace" select="'è'"/>
                <xsl:with-param name="with" select="'egrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz4">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz3"/>
                <xsl:with-param name="replace" select="'È'"/>
                <xsl:with-param name="with" select="'Egrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz5">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz4"/>
                <xsl:with-param name="replace" select="'ê'"/>
                <xsl:with-param name="with" select="'ecirc'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz6">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz5"/>
                <xsl:with-param name="replace" select="'Ê'"/>
                <xsl:with-param name="with" select="'Ecirc'"/>
            </xsl:call-template>
        </xsl:variable>
 
        <xsl:value-of select="$vAkz6"/>
    </xsl:template>
    
    <xsl:template name="tAkzenteA">
        <xsl:param name="pString"/>
        <xsl:variable name="vAkz" select="$pString"/>
        
        <xsl:variable name="vAkz1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz"/>
                <xsl:with-param name="replace" select="'á'"/>
                <xsl:with-param name="with" select="'aacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz1"/>
                <xsl:with-param name="replace" select="'Á'"/>
                <xsl:with-param name="with" select="'Aacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz3">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz2"/>
                <xsl:with-param name="replace" select="'à'"/>
                <xsl:with-param name="with" select="'agrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz4">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz3"/>
                <xsl:with-param name="replace" select="'À'"/>
                <xsl:with-param name="with" select="'Agrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz5">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz4"/>
                <xsl:with-param name="replace" select="'â'"/>
                <xsl:with-param name="with" select="'acirc'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz6">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz5"/>
                <xsl:with-param name="replace" select="'Â'"/>
                <xsl:with-param name="with" select="'Acirc'"/>
            </xsl:call-template>
        </xsl:variable>
        
        
        <xsl:value-of select="$vAkz6"/>
    </xsl:template>
    
    <xsl:template name="tAkzenteO">
        <xsl:param name="pString"/>
        <xsl:variable name="vAkz" select="$pString"/>
        
        <xsl:variable name="vAkz1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz"/>
                <xsl:with-param name="replace" select="'ó'"/>
                <xsl:with-param name="with" select="'oacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz1"/>
                <xsl:with-param name="replace" select="'Ó'"/>
                <xsl:with-param name="with" select="'Oacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz3">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz2"/>
                <xsl:with-param name="replace" select="'ò'"/>
                <xsl:with-param name="with" select="'ograve'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz4">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz3"/>
                <xsl:with-param name="replace" select="'Ò'"/>
                <xsl:with-param name="with" select="'Ograve'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz5">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz4"/>
                <xsl:with-param name="replace" select="'ô'"/>
                <xsl:with-param name="with" select="'ocirc'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz6">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz5"/>
                <xsl:with-param name="replace" select="'Ô'"/>
                <xsl:with-param name="with" select="'Ocirc'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vAkz6"/>
    </xsl:template>
    
    <xsl:template name="tAkzenteU">
        <xsl:param name="pString"/>
        <xsl:variable name="vAkz" select="$pString"/>
        
        <xsl:variable name="vAkz1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz"/>
                <xsl:with-param name="replace" select="'ú'"/>
                <xsl:with-param name="with" select="'uacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz1"/>
                <xsl:with-param name="replace" select="'Ú'"/>
                <xsl:with-param name="with" select="'Uacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz3">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz2"/>
                <xsl:with-param name="replace" select="'ù'"/>
                <xsl:with-param name="with" select="'ugrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz4">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz3"/>
                <xsl:with-param name="replace" select="'Ù'"/>
                <xsl:with-param name="with" select="'Ugrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz5">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz4"/>
                <xsl:with-param name="replace" select="'û'"/>
                <xsl:with-param name="with" select="'ucirc'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz6">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz5"/>
                <xsl:with-param name="replace" select="'Û'"/>
                <xsl:with-param name="with" select="'Ucirc'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vAkz6"/>
    </xsl:template>
    
    <xsl:template name="tAkzenteI">
        <xsl:param name="pString"/>
        <xsl:variable name="vAkz" select="$pString"/>
        
        <xsl:variable name="vAkz1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz"/>
                <xsl:with-param name="replace" select="'í'"/>
                <xsl:with-param name="with" select="'iacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz1"/>
                <xsl:with-param name="replace" select="'Í'"/>
                <xsl:with-param name="with" select="'Iacute'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz3">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz2"/>
                <xsl:with-param name="replace" select="'ì'"/>
                <xsl:with-param name="with" select="'igrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz4">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz3"/>
                <xsl:with-param name="replace" select="'Ì'"/>
                <xsl:with-param name="with" select="'Igrave'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz5">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz4"/>
                <xsl:with-param name="replace" select="'î'"/>
                <xsl:with-param name="with" select="'icirc'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vAkz6">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vAkz5"/>
                <xsl:with-param name="replace" select="'Î'"/>
                <xsl:with-param name="with" select="'Icirc'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vAkz6"/>
    </xsl:template>
    
    <xsl:template name="tSonstige">
        <xsl:param name="pString"/>
        
        <xsl:variable name="vSonst" select="$pString"/>
        
        <xsl:variable name="vSonst1">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vSonst"/>
                <xsl:with-param name="replace" select="'ß'"/>
                <xsl:with-param name="with" select="'ss'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vSonst2">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$vSonst1"/>
                <xsl:with-param name="replace" select="'ç'"/>
                <xsl:with-param name="with" select="'ccedil'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$vSonst2"/>
    </xsl:template>

</xsl:stylesheet>
