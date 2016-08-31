<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:my="my" version="1.0"
	exclude-result-prefixes="exslt msxsl tei xhtml my">

        <xsl:include href="xsl-output.xsl"/>

	<xsl:preserve-space elements="tei:body body"/>

	<!-- author: NG -->

	<!-- allgemeine Funktionen (string-replace etc.) -->
	<xsl:include href="allgFunktionen.xsl"/>

	<!-- zusätzliche Funktionen (tNoteFolgt etc.) -->
	<!--<xsl:include href="transkription_ZusatzFunktionen.xsl"/>-->

	<!-- globale Variablen -->
	<xsl:include href="transkription_LesEdi_Variablen.xsl"/>

	<!-- für Fußnotentexte -->
	<!--<xsl:include href="transkription_LesEdi_Fussnoten.xsl"/>-->

	<!-- Normalisierung -->
	<xsl:include href="transkription_CapKoll_Normalisierung.xsl"/>

	<xsl:key name="kSubst_Liste" match="//tei:subst" use="generate-id(.)"/>
	<xsl:key name="kAdd_Liste" match="//tei:add" use="generate-id(.)"/>
	<xsl:key name="kDel_Liste" match="//tei:del" use="generate-id(.)"/>
	<xsl:key name="kMod_Liste" match="//tei:mod" use="generate-id(.)"/>
	<xsl:key name="kSic_Liste" match="//tei:sic" use="generate-id(.)"/>
	<xsl:key name="kSpace_Liste" match="//tei:space" use="generate-id(.)"/>



	<xsl:template match="/">
		<xsl:apply-templates select="//tei:body"/>
	</xsl:template>

	<xsl:template match="text()[not(ancestor::tei:num)]">
		<!-- Inhalte von tei:num NICHT normalisieren! -->
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:body">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:mentioned[not(ancestor::tei:front)]">
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:mentioned/text()[ancestor::tei:front]">
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:encodingDesc/tei:p/tei:mentioned">
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:title"/>
	<xsl:template match="tei:title[@type='main']"/>
	<xsl:template match="tei:front/tei:div[count(./node())>0]"/>
	<xsl:template match="tei:publicationStmt/tei:date"/>
	<xsl:template match="tei:revisionDesc/tei:change"/>
	<xsl:template match="tei:publisher"/>
	<xsl:template match="tei:encodingDesc"/>
	<xsl:template match="tei:encodingDesc//text()"/>
	<xsl:template match="tei:encodingDesc/tei:p"/>
	<xsl:template match="tei:projectDesc"/>
	<xsl:template match="tei:editorialDecl"/>
	<xsl:template match="tei:revisionDesc"/>

	<!-- zusätzliche Formatierung -->
	<xsl:template match="tei:fileDesc"/>
	<xsl:template match="tei:respStmt"/>

	<!-- /zusätzliche Formatierung -->


	<xsl:template match="tei:body/tei:ab[@type='text']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:body/tei:ab[@type='meta-text']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="//tei:seg[@type[.='numDenom' or .='num']]">
		<xsl:variable name="vOhnePunkte">
			<xsl:call-template name="string-replace">
				<xsl:with-param name="string" select="./text()"/>
				<xsl:with-param name="replace" select="'.'"/>
				<xsl:with-param name="with" select="''"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$vOhnePunkte"/>
	</xsl:template>

	<xsl:template match="tei:lb"/>
	<xsl:template match="tei:lb[parent::node()[@place='margin']]"/>
	<xsl:template match="tei:cb"/>
	<xsl:template match="tei:milestone"/>

	<xsl:template match="tei:seg[@type='initial']">
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:seg[@type='versalie']">
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:cit">
		<xsl:apply-templates select="tei:quote"/>
		<xsl:apply-templates select="tei:ref"/>
	</xsl:template>

	<xsl:template match="tei:cit/tei:quote">
		<xsl:apply-templates select="./node()"/>
	</xsl:template>

	<xsl:template match="tei:cit/tei:ref"/>
	<xsl:template match="tei:ref[@type]"/>
	<xsl:template match="tei:handShift"/>
	<xsl:template match="tei:note[not(@type='editorial')][ancestor::tei:body]"/>
	<xsl:template match="tei:note[@type='editorial'][not(@target)][ancestor::tei:body]"/>
	<xsl:template match="tei:note[@type='editorial'][@target]"/>
	<xsl:template match="tei:note[@type='comment']"/>

	<xsl:template match="tei:sic">
		<xsl:apply-templates select="./node()"/>
	</xsl:template>

	<xsl:template match="tei:subst">
		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:choose>
			<xsl:when test="not(tei:add/@hand)">
				<!-- keine Hand -->
				<xsl:apply-templates select="tei:add"/>
			</xsl:when>
			<xsl:when
				test="string-length(tei:add/@hand)!=string-length(translate(tei:add/@hand,$vHandABC,''))">
				<!-- entspricht "normaler" Hand -->
				<xsl:apply-templates select="tei:add"/>
			</xsl:when>
			<xsl:when
				test="string-length(tei:add/@hand)!=string-length(translate(tei:add/@hand,$vHandXYZ,''))">
				<!-- entspricht "spezieller" Hand -->
				<xsl:apply-templates select="tei:del"/>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- nachfolgende <note> setzt Fußnotenverweis -->
				<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
					<xsl:apply-templates select="tei:del"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:add[parent::tei:subst]">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:del[parent::tei:subst]">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template
		match="tei:add[not(parent::*[local-name(.)='subst'] and not(parent::*[local-name(.)='num']))]">

		<xsl:variable name="vNoteFolgt">
			<!-- ermittelt, ob eine <note> angehängt ist -->
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- <note> folgt => Fußnote wird bereits gesetzt -->
				<xsl:choose>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- Hand XYZ -->
					</xsl:when>
					<xsl:otherwise>
						<!-- nicht Hand XYZ -->
						<xsl:apply-templates select="node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- es folgt keine <note> = automatische Fußnote wird generiert -->
				<xsl:choose>
					<xsl:when test="not(@hand)">
						<!-- keine Hand -->
						<xsl:apply-templates select="./node()"/>
					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- entspricht "normaler" Hand -->
						<xsl:apply-templates select="./node()"/>
					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- entspricht "spezieller" Hand -->
					</xsl:when>
					<xsl:otherwise>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:mod">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:num">
		<xsl:apply-templates select="current()/node()"/>
	</xsl:template>
	<xsl:template match="tei:num/tei:hi[@rend='super']">
		<super>
			<xsl:apply-templates select="current()/node()"/>
		</super>
	</xsl:template>

	<xsl:template match="tei:del[not(parent::*[local-name(.)='subst'])]">

		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>


		<xsl:choose>
			<xsl:when test="count(node())=0">
				<!-- Sonderfall bei <del>:  leeres Element -->
				<!-- Bezugsknoten -->
			</xsl:when>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- Note folgt => Fußnote wird darüber erzeugt -->
				<xsl:choose>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<xsl:apply-templates select="node()"/>
					</xsl:when>
					<xsl:otherwise>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not(@hand)">
						<!-- ohne Hand -->
					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- normale Hand -->
					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- spezielle Hand -->
						<xsl:apply-templates select="current()/node()"/>
					</xsl:when>
					<xsl:otherwise>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:abbr">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:choice">
		<xsl:apply-templates select="./tei:expan/node()"/>
	</xsl:template>

	<xsl:template match="tei:choice">
		<xsl:call-template name="tTextNormalisierung">
			<xsl:with-param name="pText" select="./tei:expan/text()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:unclear[count(tei:gap)>0]">
		<xsl:text>...</xsl:text>
	</xsl:template>

	<xsl:template match="tei:unclear[count(tei:gap)=0]">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="node()"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="tei:gap">
		<!-- <xsl:text> </xsl:text> -->
		<xsl:call-template name="tPrintXtimes">
			<!--CapKoll<xsl:with-param name="pPrintWhat" select="' .'"/>-->
			<xsl:with-param name="pPrintWhat" select="'.'"/>
			<xsl:with-param name="pPrintHowManyTimes" select="current()/@quantity"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:expan">
			<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:ex">
			<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:space"/>

	<xsl:template match="tei:date">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:locus">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:rs">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:persName">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:placeName">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:fw[@type='catch']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:metamark"/>

	<xsl:template match="tei:hi[@rend='super']">
			<xsl:value-of select="."/>
	</xsl:template>

<!--	<xsl:template match="tei:span[@xml:id]">
		<!-\- "Erstreckungsfußnoten" -\->

		<xsl:variable name="before">
			<xsl:value-of select="normalize-space(substring-before(text()[last()],' '))"/>
		</xsl:variable>
		<xsl:variable name="after">
			<xsl:value-of select="substring-after(text()[last()],' ')"/>
		</xsl:variable>

		<xsl:value-of select="node()[1]"/>
		<xsl:apply-templates select="tei:add"/>
		<xsl:value-of select="$before"/>
		<xsl:apply-templates select="following-sibling::node()[1][name()='note']"/>
		<xsl:value-of select="$after"/>

	</xsl:template>-->

	<xsl:template match="tei:ab">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:span">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:anchor">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:div">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:head">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:p">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:hi">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:pb">
		<xsl:apply-templates/>
	</xsl:template>



	<xsl:template name="tSplitString">
		<xsl:param name="pString"/>
		<xsl:param name="pDelimiter"/>

		<xsl:variable name="vBefore">
			<!-- bis Trennzeichen -->
			<xsl:value-of select="substring-before($pString,$pDelimiter)"/>
		</xsl:variable>
		<xsl:variable name="vAfter">
			<!-- Rest -->
			<xsl:value-of select="substring-after($pString,$pDelimiter)"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not(contains($pString,$pDelimiter))">
				<!-- ist/war bereits "atomar" -->
				<item>
					<xsl:value-of select="$pString"/>
				</item>
			</xsl:when>
			<xsl:when test="contains($vAfter,$pDelimiter)">
				<!-- weiterer Teil nach Trennzeichen enthalten => weiter spalten -->
				<item>
					<xsl:value-of select="$vBefore"/>
				</item>
				<xsl:call-template name="tSplitString">
					<xsl:with-param name="pString" select="$vAfter"/>
					<xsl:with-param name="pDelimiter" select="$pDelimiter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- keine weiteren Trennzeichen -->
				<item>
					<xsl:value-of select="$vBefore"/>
				</item>
				<item>
					<xsl:value-of select="$vAfter"/>
				</item>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tCorrespFiltern">
		<xsl:param name="pCorresp"/>

		<xsl:variable name="vCorresp">
			<xsl:choose>
				<xsl:when test="not(contains(@corresp,'inscriptio')) and not(contains(@corresp,'incipit'))">
					<xsl:call-template name="string-replace">
						<xsl:with-param name="string" select="translate(@corresp,'.',' ')"/>
						<xsl:with-param name="replace" select="'_'"/>
						<xsl:with-param name="with" select="' c. '"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(@corresp,'inscriptio')">
					<!-- inscriptio entfernen -->

					<xsl:variable name="vSplitString">
						<xsl:call-template name="tSplitString">
							<xsl:with-param name="pString" select="@corresp"/>
							<xsl:with-param name="pDelimiter" select="' '"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="vSplitStringSet">
						<xsl:copy-of select="exslt:node-set($vSplitString)"/>
					</xsl:variable>

					<xsl:variable name="vSplitStringOhne">
						<xsl:for-each select="exslt:node-set($vSplitString)/*">
							<xsl:if test="not(contains(.,'inscriptio'))">
								<xsl:value-of select="."/>
							</xsl:if>
							<xsl:if test="contains(.,vSplitStringSet/*[last()])">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:variable name="vCorrespOhne2">
						<xsl:call-template name="string-replace">
							<xsl:with-param name="string" select="translate($vSplitStringOhne,'.',' ')"/>
							<xsl:with-param name="replace" select="'_'"/>
							<xsl:with-param name="with" select="' c. '"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:value-of select="$vCorrespOhne2"/>

				</xsl:when>
				<xsl:when test="contains(@corresp,'incipit')">
					<!-- incipit entfernen -->
					<!-- incipit finden, delimiter vor und anch isncriptio finden, text vor und nach delimiter übernehmen -->
					<xsl:variable name="vInscriptioBefore_mitRest">
						<xsl:value-of select="substring-before(@corresp,'incipit')"/>
					</xsl:variable>
					<xsl:variable name="vInscriptioBefore_nurRest">
						<xsl:call-template name="tLastSubstringAfter">
							<xsl:with-param name="pString" select="$vInscriptioBefore_mitRest"/>
							<xsl:with-param name="pCharacter" select="' '"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="vInscriptioBefore">
						<xsl:value-of
							select="substring($vInscriptioBefore_mitRest, 1, string-length($vInscriptioBefore_mitRest) - string-length($vInscriptioBefore_nurRest))"
						/>
					</xsl:variable>
					<xsl:variable name="vInscriptioAfter">
						<xsl:value-of
							select="substring-after(substring-after(@corresp,'incipit'),' ')"/>
					</xsl:variable>

					<xsl:variable name="vCorrespOhne">
						<!-- corresp ohne Einzel-Einträge, die "inscriptio" oder "incipit" beinhalten -->
						<xsl:value-of select="$vInscriptioBefore"/>
						<xsl:value-of select="$vInscriptioAfter"/>
					</xsl:variable>

					<xsl:variable name="vCorrespOhne2">
						<xsl:call-template name="string-replace">
							<xsl:with-param name="string" select="translate($vCorrespOhne,'.',' ')"/>
							<xsl:with-param name="replace" select="'_'"/>
							<xsl:with-param name="with" select="' c. '"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:value-of select="$vCorrespOhne2"/>

				</xsl:when>
				<xsl:otherwise>
					<!-- ??? -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="$vCorresp"/>

	</xsl:template>



	<xsl:template name="tNoteFolgt">
		<xsl:param name="pNode"/>
		<!-- WICHTIG: Zu Node/Element zugehörige <note> hängt am Ende des Wortes oder Elements => Es gibt dazwischen im text() kein Leerzeichen (=' ')! -->

		<!--<xsl:variable name="vTextNachKnotenVorNote" select="$pNode/following-sibling::text()"/>-->


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
					<!--<xsl:for-each select="$pNode/following-sibling::text()[generate-id($pNode)=generate-id(preceding-sibling::*[./name()='subst' or ./name()='add' or ./name()='del' or ./name()='mod'][1])][count(./following-sibling::tei:note)>0]">-->
					<!--<xsl:for-each select="$vTextNachKnoten[count(./following-sibling::tei:note)>0]">-->
					<!--<xsl:for-each select="$vTextNachKnoten[count(following-sibling::tei:note[generate-id($pNode)=generate-id(preceding-sibling::*[local-name(.)='subst' or local-name(.)='add' or local-name(.)='del' or local-name(.)='mod'][1])])>0]">-->
					<xsl:for-each select="$vTextNachKnoten[following-sibling::tei:note[generate-id($pNode)=generate-id(preceding-sibling::*[local-name(.)='subst' or local-name(.)='add' or local-name(.)='del' or local-name(.)='mod'][1])]]">

						<xsl:if test="string-length(.)>0">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>

					<!--<xsl:value-of select="$vTextNachKnoten[following-sibling::tei:note[generate-id($pNode)=generate-id(preceding-sibling::*[local-name(.)='subst' or local-name(.)='add' or local-name(.)='del' or local-name(.)='mod'][1])]]"/>-->
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


	<xsl:template name="tPrintXtimes">
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

	<xsl:template match="tei:rs">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*">
		<ERROR>
			<xsl:comment>
				<xsl:text>ERROR: element '</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>' not handled</xsl:text>
			</xsl:comment>
			<xsl:apply-templates/>
			<xsl:comment>
				<xsl:value-of select="local-name()"/>
			</xsl:comment>
		</ERROR>
	</xsl:template>

</xsl:stylesheet>
