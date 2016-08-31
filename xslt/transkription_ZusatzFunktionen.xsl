<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0" exclude-result-prefixes="exslt msxsl tei xhtml my">

	<!-- author: NG -->

	<!-- ################################# zusätzliche "Funktionen"/Templates -->
<!--
	<xsl:template name="tMengenangabe">
		<!-\- Deklination Singular/Plural -\->
		<xsl:param name="pNode"/>

		<!-\- BSP: "5 Wörter"/"1 Buchstabe"/"2 Einheiten" -\->
		<xsl:value-of select="$pNode/@quantity"/>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="$pNode/@unit='chars'">
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<xsl:text>Buchstabe</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Buchstaben</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$pNode/@unit='words'">
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<xsl:text>Wort</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Wörter</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<xsl:text>Einheit</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Einheiten</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->

	<xsl:template name="tLeerzeichenDavorOderDanach">
		<!-- check whether there are blanks before OR after $pNode -->
		<xsl:param name="pNode"/>

		<xsl:variable name="vLeerzeichenDavor">
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLeerzeichenDanach">
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vLeerzeichenDavor='true'">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="$vLeerzeichenDanach='true'">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tLeerzeichenDavorUndDanach">
		<!-- check whether there are blanks before AND after $pNode -->
		<xsl:param name="pNode"/>

		<xsl:variable name="vLeerzeichenDavor">
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLeerzeichenDanach">
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tSubstringAfterLast">
		<!-- get the last substring -->
		<xsl:param name="pString"/>
		<xsl:param name="pString2"/>

		<xsl:choose>
			<xsl:when test="contains($pString,$pString2)">
				<!-- pString2 in pString enthalten -->

				<xsl:variable name="vSubstringAfter" select="substring-after($pString,$pString2)"/>
				<xsl:choose>
					<xsl:when test="contains($vSubstringAfter,$pString2)">
						<!-- weiterer pString2 in pString bzw. vSubstringAfter enthalten -->
						<!-- => Rekursion => tSubstringAfterLast nochmals mit gekürztem String aufrufen -->
						<xsl:call-template name="tSubstringAfterLast">
							<xsl:with-param name="pString" select="$vSubstringAfter"/>
							<xsl:with-param name="pString2" select="$pString2"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- letzter SubstringAfter erreicht -->
						<xsl:value-of select="$vSubstringAfter"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<!-- falls pString2 gar nicht in pString enthalten ist -->
				<!-- ??? wie wird das in der normalen Substring-After Funktion gelöst?! => entsprechend anapssen? => empty string -->
				<xsl:text></xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tNoteFolgt">
		<!-- check if there's a following <note> that belongs to $pNode -->
		<xsl:param name="pNode"/>
		<!-- WICHTIG: Zu Node/Element zugehörige <note> hängt am Ende des Wortes oder Elements => Es gibt dazwischen im text() kein Leerzeichen (=' ')! -->
		<xsl:choose>
			<xsl:when test="local-name($pNode/following-sibling::node()[local-name(.)!='lb'][1])='note'">
				<!-- <note> folgt direkt -->
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="(string-length($pNode/following-sibling::node()[local-name(.)!='lb'][1])=string-length(translate($pNode/following-sibling::node()[local-name(.)!='lb'][1],' ',''))) and (local-name($pNode/following-sibling::*[local-name(.)!='lb'][1])='note')">
				<!-- BAUSTELLE: explizit!!! text() als erste node() -->
				<!-- nächstes node() ist Text ohne Leerzeichen, darauf folgt als erstes * direkt <note> -->
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- BAUSTELLE: <note> direkt nach text() ohne Leerzeichen wird nicht erkannt!! (Wieso auch immer?!?) => bisherige Notlösung: 2. when-Klausel eingefügt, die diesen Fall abdeckt => ABER: nicht optimal! Algorithmus sollte auch so funktionieren?! -->
				<xsl:variable name="vTextNachKnoten" select="$pNode/following-sibling::text()[generate-id($pNode)=generate-id(./preceding-sibling::*[local-name(.)='subst' or local-name(.)='add' or local-name(.)='del' or local-name(.)='mod'][1])]"/>
				<xsl:variable name="vTextNachKnotenSTR" select="string($vTextNachKnoten)"/>

				<xsl:variable name="vTextNachKnotenVorNote">
					<xsl:for-each select="$vTextNachKnoten[following-sibling::tei:note[generate-id($pNode)=generate-id(preceding-sibling::*[local-name(.)='subst' or local-name(.)='add' or local-name(.)='del' or local-name(.)='mod'][1])]]">

						<xsl:if test="string-length(.)>0">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="string-length($vTextNachKnotenVorNote)>0 and string-length($vTextNachKnotenVorNote)=string-length(translate($vTextNachKnotenVorNote,' ',''))">
						<!-- Zeichenkettte nach dem Ersetzen von ' ' durch '' gleich lang => kein ' ' in Zeichenkette vorhanden -->
						<!-- => nächste <note> gehört zu Knoten -->
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- ' ' in Zeichenkette vorhanden -->
						<!-- => nächste <note> gehört nicht zu Knoten -->
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="tLeerzeichenFolgt">
		<!-- check whether a blank follows -->
		<xsl:param name="pNode"/>

		<xsl:variable name="vFollText1" select="$pNode/following-sibling::text()[1]"/>

		<xsl:choose>
			<xsl:when test="substring($vFollText1,1,1)=' '">
				<!-- Leerzeichen ist erstes nachfolgendes Zeichen -->
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Wortrest folgt -->
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tLeerzeichenDanach">
		<!-- check whether a blank follows directly/right after $pNode -->
		<xsl:param name="pNode"/>

		<xsl:variable name="vFollText1" select="$pNode/following-sibling::text()[1]"/>

		<xsl:variable name="vFollText1FirstLetter" select="substring($vFollText1,1,1)"/>

		<xsl:choose>
			<xsl:when test="count($vFollText1/node())=0 and string-length($vFollText1) &lt; 1">
				<!-- gar kein node() enthalten (z.B. wenn der zuvor geprüfte Knoten gar keine siblings mehr hat -->
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="contains($vFollText1,' ')='true' or contains($vFollText1,'&#xA;')='true'">
				<xsl:choose>
					<xsl:when test="$vFollText1FirstLetter=' ' or $vFollText1FirstLetter='&#xA;'">
						<!-- Leerzeichen oder Zeilenumbruch (=Leerzeichen) ist erstes nachfolgendes Zeichen -->
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- Wortrest folgt -->
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- text() enthält gar kein Leerzeichen => muss in einem späteren text() folgen -->
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>


	</xsl:template>

	<xsl:template name="tLeerzeichenDavor">
		<!-- check whether a blank precedes directly/right before $pNode -->
		<xsl:param name="pNode"/>

		<xsl:variable name="vPrecText1" select="$pNode/preceding-sibling::text()[1]"/>

		<xsl:variable name="vPrecText1LastLetter" select="substring($vPrecText1,string-length($vPrecText1),1)"/>

		<xsl:choose>
			<xsl:when test="count($vPrecText1/node())=0 and string-length($vPrecText1) &lt; 1">
				<!-- gar kein node() enthalten (z.B. wenn der zuvor geprüfte Knoten gar keine siblings mehr hat -->
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="contains($vPrecText1,' ')='true' or contains($vPrecText1,'&#xA;')='true'">
				<xsl:choose>
					<xsl:when test="$vPrecText1LastLetter=' ' or $vPrecText1LastLetter='&#xA;'">
						<!-- Leerzeichen oder Zeilenumbruch (=Leerzeichen) ist erstes vorhergehendes Zeichen -->
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- Wortrest folgt -->
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<!-- text() enthält gar kein Leerzeichen => muss in einem früheren text() folgen -->
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tRend">
		<!-- @rend ins Deutsche übersetzen -->
		<xsl:param name="pAttribut"/>

		<xsl:choose>
			<xsl:when test="$pAttribut='scratched'">
				<xsl:text>radiert</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='expunged'">
				<xsl:text>expungiert</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='strikethrough'">
				<xsl:text>gestrichen</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='underlined'">
				<xsl:text>durch Unterstreichung getilgt</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tUnit">
		<!-- @unit ins Deutsche übersetzen -->
		<xsl:param name="pAttribut"/>

		<xsl:choose>
			<xsl:when test="$pAttribut='chars'">
				<xsl:text>Buchstaben</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='pages'">
				<xsl:text>Seiten</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='words'">
				<xsl:text>Wörter</xsl:text>
			</xsl:when>
			<!-- etc. -->
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tPlace">
		<!-- @place ins Deutsche übersetzen -->
		<xsl:param name="pAttribut"/>

		<xsl:choose>
			<xsl:when test="$pAttribut='above'">
				<xsl:text>über der Zeile</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='margin'">
				<xsl:text>am Rand</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='inline'">
				<xsl:text>in der Zeile</xsl:text>
			</xsl:when>
			<xsl:when test="$pAttribut='inspace'">
				<xsl:text>in der Zeile in frei gelassenem Raum</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tPrintXtimes">
		<!-- output $pPrintWhat as often as $pPrintHowManyTimes -->
		<xsl:param name="pPrintWhat"/>
		<xsl:param name="pPrintHowManyTimes"/>
		<xsl:param name="pCounter_UseDefault" select="1"/>

		<xsl:choose>
			<xsl:when test="$pCounter_UseDefault &lt; $pPrintHowManyTimes">
				<!-- $pCounter < $pPrintHowManyTimes -->

				<!-- print -->
				<xsl:value-of select="$pPrintWhat"/>

				<!-- call the template once more ... until $pPrintHowManyTimes is reached -->
				<xsl:call-template name="tPrintXtimes">
					<xsl:with-param name="pPrintWhat" select="$pPrintWhat"/>
					<xsl:with-param name="pPrintHowManyTimes" select="$pPrintHowManyTimes"/>
					<xsl:with-param name="pCounter_UseDefault" select="$pCounter_UseDefault+1"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:when test="$pCounter_UseDefault = $pPrintHowManyTimes">
				<!-- $pCounter = $pPrintHowManyTimes -->

				<!-- one last print -->
				<xsl:value-of select="$pPrintWhat"/>

			</xsl:when>
			<xsl:otherwise>
				<!-- $pCounter > $pPrintHowManyTimes -->

				<!-- ...this shouldn't happen... -->

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
		<!-- convert YYYY-MM-DD to DD-MM-YYYY -->
		<xsl:param name="pDate_YYYY-MM-DD"/>
		<xsl:param name="pDelimiter" select="'/'"/>

		<xsl:variable name="vDay">
			<xsl:value-of select="substring($pDate_YYYY-MM-DD,9)"/>
		</xsl:variable>
		<xsl:variable name="vMonth">
			<xsl:value-of select="substring($pDate_YYYY-MM-DD,6,2)"/>
		</xsl:variable>
		<xsl:variable name="vYear">
			<xsl:value-of select="substring($pDate_YYYY-MM-DD,1,4)"/>
		</xsl:variable>

		<xsl:value-of select="$vDay"/>
		<xsl:value-of select="$pDelimiter"/>
		<xsl:value-of select="$vMonth"/>
		<xsl:value-of select="$pDelimiter"/>
		<xsl:value-of select="$vYear"/>
	</xsl:template>

	<xsl:template name="tDate_isYYYY-MM-DD">
		<!-- check whether format is YYYY-MM-DD -->
		<xsl:param name="pDate"/>
		<xsl:param name="pDelimiter" select="'-'"/>

		<xsl:choose>
			<xsl:when test="substring($pDate,5,1)=$pDelimiter and substring($pDate,8,1)=$pDelimiter">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Wird jetzt in footnotes-post-processor.php verarbeitet.
	<xsl:template name="tPlatzhalterVerarbeiten">
			convert placeholders:
				.: 	=> &#x2234;
				;. 	=> ·,·
				. 	=> ·
				! 	=> .'
				.: 	=> &#x2234;
				* 	=> ˙
		<xsl:param name="pText"/>

		<xsl:variable name="vApos">'</xsl:variable>

		<xsl:variable name="vText1">
			<xsl:call-template name="string-replace">
				<xsl:with-param name="string" select="$pText"/>
				<xsl:with-param name="replace" select="'.:'"/>
				<xsl:with-param name="with" select="'&#x2234;'"/>
				<!- -<xsl:with-param name="with" select="'.·.'"/>- ->
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vText2">
			<xsl:call-template name="string-replace">
				<xsl:with-param name="string" select="$vText1"/>
				<xsl:with-param name="replace" select="';.'"/>
				<xsl:with-param name="with" select="'·,·'"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vText3">
			<xsl:call-template name="string-replace">
				<xsl:with-param name="string" select="$vText2"/>
				<xsl:with-param name="replace" select="'.'"/>
				<xsl:with-param name="with" select="'·'"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vText4">
			<xsl:call-template name="string-replace">
				<xsl:with-param name="string" select="$vText3"/>
				<xsl:with-param name="replace" select="'!'"/>
				<xsl:with-param name="with" select="concat('.',$vApos)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vText5">
			<xsl:value-of select="translate($vText4,'*','˙')"/>
		</xsl:variable>

		<xsl:value-of select="$vText5"/>


	</xsl:template>
	-->

	<xsl:template name="tDate_Vergleich_1vor2">
		<!-- check whether Date1 is dated to before Date2 -->
		<xsl:param name="pDate1_YYYY-MM-DD"/>
		<xsl:param name="pDate2_YYYY-MM-DD"/>

		<xsl:variable name="vDate1_isYYY-MM-DD">
			<xsl:call-template name="tDate_isYYYY-MM-DD">
				<xsl:with-param name="pDate" select="$pDate1_YYYY-MM-DD"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vDate2_isYYY-MM-DD">
			<xsl:call-template name="tDate_isYYYY-MM-DD">
				<xsl:with-param name="pDate" select="$pDate2_YYYY-MM-DD"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vDay1">
			<xsl:value-of select="substring($pDate1_YYYY-MM-DD,9)"/>
		</xsl:variable>
		<xsl:variable name="vMonth1">
			<xsl:value-of select="substring($pDate1_YYYY-MM-DD,6,2)"/>
		</xsl:variable>
		<xsl:variable name="vYear1">
			<xsl:value-of select="substring($pDate1_YYYY-MM-DD,1,4)"/>
		</xsl:variable>

		<xsl:variable name="vDay2">
			<xsl:value-of select="substring($pDate2_YYYY-MM-DD,9)"/>
		</xsl:variable>
		<xsl:variable name="vMonth2">
			<xsl:value-of select="substring($pDate2_YYYY-MM-DD,6,2)"/>
		</xsl:variable>
		<xsl:variable name="vYear2">
			<xsl:value-of select="substring($pDate2_YYYY-MM-DD,1,4)"/>
		</xsl:variable>


		<xsl:choose>
			<xsl:when test="$vDate1_isYYY-MM-DD='true' and $vDate2_isYYY-MM-DD='true'">
				<xsl:choose>
					<xsl:when test="$vYear1 &lt; $vYear2">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:when test="$vYear1 = $vYear2">
						<xsl:choose>
							<xsl:when test="$vMonth1 &lt; $vMonth2">
								<xsl:value-of select="true()"/>
							</xsl:when>
							<xsl:when test="$vMonth1 = $vMonth2">
								<xsl:choose>
									<xsl:when test="$vDay1 &lt; $vDay2">
										<xsl:value-of select="true()"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="false()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="false()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{Fehler in tDate_Vergleich_1vor2: Bitte übergebene Werte prüfen! (</xsl:text>
					<xsl:value-of select="$pDate1_YYYY-MM-DD"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$pDate2_YYYY-MM-DD"/>
					<xsl:text>)}</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="tGetWord_subst">
		<!-- get the whole word that belongs to $pNode (=everything between the preceding blank and the following blank) -->
		<xsl:param name="pNode"/> <!-- the <subst> -->
		<xsl:param name="pWortMitte"/> <!-- choose <del> or <add> for output -->
		<xsl:param name="pSubstitute"><xsl:text>[+]</xsl:text></xsl:param> <!-- choose substitute for empty elements => empty string for "no substitute" -->

		<!-- fetches the preceding part of the word -->
		<xsl:variable name="vPrecedingPart">
			<xsl:call-template name="tPrecedingPart">
				<xsl:with-param name="pPrecedingTextThis" select="$pNode/preceding::text()[1]"/>
				<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- fetches the following part of the word -->
		<xsl:variable name="vFollowingPart">
			<xsl:call-template name="tFollowingPart">
				<xsl:with-param name="pFollowingTextThis" select="$pNode/following::text()[1]"/>
				<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$vPrecedingPart"/> <!-- preceding part of word -->
		<xsl:choose> <!-- get the middle of the word -->
			<xsl:when test="count($pWortMitte/*)>0">
				<!-- there are elements encapsulated in del/add -->
				<xsl:apply-templates select="$pWortMitte/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- only text() in del/add -->
				<xsl:choose>
					<xsl:when test="count($pWortMitte/node())=0">
						<!-- is empty => give back some sort of "anchor" (optionally => see pSubstitute) -->
						<xsl:value-of select="$pSubstitute"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- not empty => give out del/add text() -->
						<xsl:value-of select="$pWortMitte"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$vFollowingPart"/> <!-- following part of word -->
	</xsl:template>

	<xsl:template name="tPrecedingPart">
		<!-- fetches text() preceding the given node until the first occurence of ' ' -->
		<xsl:param name="pPrecedingTextThis"/>
		<xsl:param name="pPrecedingTextBeforeNode"/>

		<xsl:choose>
			<xsl:when test="contains($pPrecedingTextThis,' ')">

				<xsl:variable name="vSubstringAfterLast">
					<xsl:call-template name="tSubstringAfterLast">
						<xsl:with-param name="pString" select="$pPrecedingTextThis"/>
						<xsl:with-param name="pString2" select="' '"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:value-of select="$vSubstringAfterLast"/>
				<xsl:value-of select="$pPrecedingTextBeforeNode"/>
			</xsl:when>
			<xsl:when test="contains($pPrecedingTextThis,'&#xa;')">
				<!-- line feed / new line -->
				<xsl:variable name="vSubstringAfterLast">
					<xsl:call-template name="tSubstringAfterLast">
						<xsl:with-param name="pString" select="$pPrecedingTextThis"/>
						<xsl:with-param name="pString2" select="'&#xa;'"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:value-of select="$vSubstringAfterLast"/>
				<xsl:value-of select="$pPrecedingTextBeforeNode"/>
			</xsl:when>
			<xsl:otherwise>

				<!-- can't be "produced" in with-param...for unknown reason -->
				<xsl:variable name="vPrecedingTextBeforeNode">
					<xsl:choose>
						<xsl:when test="count($pPrecedingTextThis/node())>0">
							<xsl:apply-templates select="$pPrecedingTextThis/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pPrecedingTextThis"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="$pPrecedingTextBeforeNode"/>
				</xsl:variable>

				<xsl:call-template name="tPrecedingPart">
					<xsl:with-param name="pPrecedingTextThis" select="$pPrecedingTextThis/preceding::text()[local-name(.)!='note'][1]"/>
					<xsl:with-param name="pPrecedingTextBeforeNode" select="$vPrecedingTextBeforeNode"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tFollowingPart">
		<!-- fetches text() following the given node until the first occurence of ' ' -->
		<xsl:param name="pFollowingTextThis"/>
		<xsl:param name="pFollowingTextBeforeNode"/>

		<xsl:choose>
			<xsl:when test="contains($pFollowingTextThis,' ')">
				<xsl:variable name="vSubstringBefore">
					<xsl:value-of select="normalize-space(substring-before($pFollowingTextThis,' '))"/>
				</xsl:variable>

				<xsl:value-of select="$pFollowingTextBeforeNode"/>
				<xsl:value-of select="$vSubstringBefore"/>
			</xsl:when>
			<xsl:when test="contains($pFollowingTextThis,'&#xa;')">
				<!-- line feed / new line -->
				<xsl:variable name="vSubstringBefore">
					<xsl:value-of select="normalize-space(substring-before($pFollowingTextThis,'&#xa;'))"/>
				</xsl:variable>

				<xsl:value-of select="$pFollowingTextBeforeNode"/>
				<xsl:value-of select="$vSubstringBefore"/>
			</xsl:when>
			<xsl:otherwise>

				<!-- can't be "produced" in with-param...for unknown reason -->
				<xsl:variable name="vFollowingTextBeforeNode">
					<xsl:value-of select="$pFollowingTextBeforeNode"/>
					<xsl:choose>
						<xsl:when test="count($pFollowingTextThis/node())>0">
							<xsl:apply-templates select="$pFollowingTextThis/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pFollowingTextThis"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:call-template name="tFollowingPart">
					<xsl:with-param name="pFollowingTextThis" select="$pFollowingTextThis/following::text()[local-name(.)!='note'][1]"/>
					<xsl:with-param name="pFollowingTextBeforeNode" select="$vFollowingTextBeforeNode"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>




	<xsl:template name="tGetWord">
		<!-- get the whole word belonging to the part that is in pNode (=everything from the preceding blank to the following blank) -->
		<xsl:param name="pNode"/>
		<xsl:param name="pWortMitte"/>
		<xsl:param name="pSubstitute"><xsl:text>#</xsl:text></xsl:param> <!-- choose substitute for empty elements => empty string for "no substitute" -->

		<!-- get the preceding part -->
		<xsl:variable name="vPrecedingPart">
			<xsl:call-template name="tPrecedingPart">
				<xsl:with-param name="pPrecedingTextThis" select="$pNode/preceding::text()[1]"/>
				<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- get the following part -->
		<xsl:variable name="vFollowingPart">
			<xsl:call-template name="tFollowingPart">
				<xsl:with-param name="pFollowingTextThis" select="$pNode/following::text()[1]"/>
				<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- put the parts together => get that word as whole -->
		<xsl:value-of select="$vPrecedingPart"/>
		<xsl:if test="string-length($pWortMitte)>0">
			<!-- pWortMitte contains some text -->
			<xsl:choose>
				<xsl:when test="count($pWortMitte/*)>0">
					<!-- pWortMitte contains elements -->
					<!-- => apply templates to those elements -->
					<xsl:apply-templates select="$pWortMitte/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- pWortMitte does not contain elements => maybe only text() -->
					<xsl:choose>
						<xsl:when test="count($pWortMitte/node())=0">
							<!-- pWortMitte is empty -->
							<!-- => placeholder/substitute -->
							<xsl:value-of select="$pSubstitute"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- pWortMitte is not empty = contains some text -->
							<!-- => output that text -->
							<xsl:value-of select="$pWortMitte"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:value-of select="$vFollowingPart"/>
	</xsl:template>

</xsl:stylesheet>
