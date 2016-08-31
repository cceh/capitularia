<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:my="my" version="1.0"
	exclude-result-prefixes="exslt msxsl tei xhtml my">

        <xsl:include href="xsl-output.xsl"/>

	<!-- author: NG -->
	<xsl:include href="allgFunktionen.xsl"/>
	<!-- allgemeine Funktionen (string-replace etc.) -->
	<xsl:include href="transkription_ZusatzFunktionen.xsl"/>
	<!-- zusätzliche Funktionen (tNoteFolgt etc.) -->
	<xsl:include href="transkription_LesEdi_Variablen.xsl"/>
	<!-- globale Variablen -->
	<xsl:include href="transkription_LesEdi_Style.xsl"/>
	<!-- CSS für Darstellung der Ausgabe -->
	<xsl:include href="transkription_LesEdi_Fussnoten.xsl"/>
	<!-- Verarbeitung/Darstellung der Fußnoten(-Texte) -->

<!--	<!-\- Funktion node-set() per Namespace "exslt" implementieren -\->
	<msxsl:script language="JScript" implements-prefix="exslt"> this['node-set'] = function (x) {
		return x; } </msxsl:script>-->

	<xsl:key name="kSubst_Liste" match="//tei:subst" use="generate-id(.)"/>
	<xsl:key name="kAdd_Liste" match="//tei:add" use="generate-id(.)"/>
	<xsl:key name="kDel_Liste" match="//tei:del" use="generate-id(.)"/>
	<xsl:key name="kMod_Liste" match="//tei:mod" use="generate-id(.)"/>

	<xsl:key name="kSic_Liste" match="//tei:sic" use="generate-id(.)"/>

	<xsl:key name="kSpace_Liste" match="//tei:space" use="generate-id(.)"/>

	<xsl:template match="/">

		<HTML lang="de">
			<HEAD>
				<meta charset="utf-8"/>
				<TITLE>
					<xsl:value-of select="//tei:title"/>
				</TITLE>

				<!-- <style> übernehmen -->
				<xsl:copy-of select="$vStyle"/>

			</HEAD>
			<BODY>

				<div class="transkr" align="justify">
					<!-- Ersatz für <body> -->

					<xsl:if test="count(//tei:div[@xml:id='divContent'])>0">
						<div id="inhaltsverzeichnis" style="display: none">

							<xsl:text>Inhaltsverzeichnis:</xsl:text>
							<br/>

							<xsl:apply-templates select="//tei:div[@xml:id='divContent']" mode="toc"
							/>
						</div>
					</xsl:if>


					<span class="textItalic">
						<xsl:text>(Leseversion für die Editoren)</xsl:text>
					</span>
					<hr/>

					<!-- TITLE -->
					<div class="meta">
						<p>
							<xsl:apply-templates select="//tei:teiHeader"/>
						</p>
					</div>

					<br/>
					<!-- ??? für Abstand zwischen Header und Body -->
					<br/>
					<!-- ??? für Abstand zwischen Header und Body -->


					<!-- TEXT -->
					<div id="EditorischeVorbemerkung">
						<!--					<span style="font-weight: bold;">
						<xsl:text>Editorische Vorbemerkung zur Transkription</xsl:text>
					</span>
					<br/>
					<br/>-->
						<span class="encodingDesc">
							<xsl:apply-templates
								select="//tei:text/tei:front/tei:div[count(./node())>0]"/>
						</span>
					</div>

					<!-- Seitenumbruch -->
					<span class="page-break">
						<xsl:text> </xsl:text>
						<!-- <span> muss gefüllt sein, sonst landet der restliche Output des Templates darin (Wieso auch immer...) / Wird nur beim Druck ausgegeben! => Hier vllt sowas wie "BK_..." ausgeben lassen, um Orientierung mit Ausdrucken zu erleichtern?! -->
					</span>

					<xsl:call-template name="back-to-top-hr"/>

					<!-- BODY -->
					<div class="text">
						<xsl:apply-templates select="//tei:body"/>
					</div>


					<br/>
					<br/>


					<!-- Seitenumbruch -->
					<span class="page-break">
						<xsl:text> </xsl:text>
						<!-- <span> muss gefüllt sein, sonst landet der restliche Output des Templates darin (Wieso auch immer...) / Wird nur beim Druck ausgegeben! => Hier vllt sowas wie "BK_..." ausgeben lassen, um Orientierung mit Ausdrucken zu erleichtern?! -->
					</span>

					<xsl:call-template name="back-to-top-hr"/>

					<!-- Fußnoten -->

					<!-- alphabetische Fußnoten -->
<!--					<ol type="a" class="alphabetisch">
						<xsl:for-each select="$funoAlphabetisch">
							<xsl:variable name="vFunoText">
								<xsl:call-template name="tFunoText_alphabetisch">
									<xsl:with-param name="pNode" select="."/>
								</xsl:call-template>
							</xsl:variable>

							<li id="{generate-id()}">
								<!-\-<xsl:value-of select="$vFunoText"/>-\->
								<xsl:copy-of select="exslt:node-set($vFunoText)"/>
								<xsl:text> </xsl:text>
								<a href="#{generate-id()}-L" class="noteBack">&#x2934;</a>
							</li>

						</xsl:for-each>
					</ol>


					<br/>-->

					<!-- numerische Fußnoten -->
					<!--<ol type="1" class="numerisch">-->
					<ol type="1" class="numerisch">
						<xsl:for-each select="$funoNumerisch">
							<xsl:variable name="vFunoText">
								<xsl:call-template name="tFunoText_numerisch">
									<xsl:with-param name="pNode" select="."/>
								</xsl:call-template>
							</xsl:variable>

							<li id="{generate-id()}" type="1">
								<!--<xsl:apply-templates select="./node()"/>-->
								<xsl:copy-of select="exslt:node-set($vFunoText)"/>
								<a href="#{generate-id()}-L" class="noteBack">&#x2934;</a>
							</li>
						</xsl:for-each>
					</ol>

					<xsl:call-template name="back-to-top-hr"/>
				</div>

			</BODY>
		</HTML>
	</xsl:template>

	<!--
    #############################################################################################
      -->


	<!-- Das strukturierte Inhaltsverzeichnis in der Sidebar wird
	     vorläufig aus einem nur zu diesem Zwecke angelegten div
	     erzeugt.  TODO: Struktur irgendwie aus dem Haupttext
	     ableiten. -->

	<xsl:template match="tei:div[@xml:id='divContent']//tei:list" mode="toc">
		<ul>
			<xsl:apply-templates select="tei:item" mode="toc"/>
		</ul>
	</xsl:template>

	<xsl:template match="tei:div[@xml:id='divContent']//tei:item" mode="toc">
		<li>
			<a href="{tei:ptr/@target}">
				<xsl:value-of select="text()"/>
			</a>
			<xsl:apply-templates select="tei:list" mode="toc"/>
		</li>
	</xsl:template>

	<xsl:template match="tei:body">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:title"> </xsl:template>

	<xsl:template match="tei:title[@type='main']">
		<h4>
			<xsl:text>Transkription</xsl:text>
		</h4>

		<br/>
<!--		<span class="PublikationAenderung">
			<xsl:text>(</xsl:text>
			<xsl:apply-templates select="//tei:publicationStmt/tei:date"/>
			<xsl:apply-templates select="//tei:revisionDesc/tei:change[last()]"/>
			<!-\-<xsl:apply-templates select="//tei:revisionDesc/tei:change"/>-\->
			<xsl:text>)</xsl:text>
		</span>-->
	</xsl:template>


	<xsl:template match="tei:front/tei:div[count(./node())>0]">
		<!--
- <front>:
	Die einzelnen <div>s sollten noch Überschriften bekommen (selbe Schriftart, aber fett; danach einfacher Zeilenumbruch):
		scribe = Schreiber
		lett = Buchstabenformen
		abbr = Abkürzungen
		punct = Interpunktion
		struct = Gliederungsmerkmale
		other = Sonstiges
-->

		<!-- Zeilenumbruch nur für nachfoglende Elemente, um den Abstand nach oben zu verkürzen -->
		<xsl:if test="count(preceding-sibling::tei:div)>0">
			<br/>
		</xsl:if>


		<xsl:choose>
			<xsl:when test="@type='scribe'">
				<span class="frontDiv">
					<xsl:text>Schreiber</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='lett' or @type='letters'">
				<span class="frontDiv">
					<xsl:text>Buchstabenformen</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='abbr' or @type='abbreviation' or @type='abbreviations'">
				<span class="frontDiv">
					<xsl:text>Abkürzungen</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='punct' or @type='punctuation'">
				<span class="frontDiv">
					<xsl:text>Interpunktion</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='struct' or @type='structure'">
				<span class="frontDiv">
					<xsl:text>Gliederungsmerkmale</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='other'">
				<span class="frontDiv">
					<xsl:text>Sonstiges</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='mshist'">
				<span class="frontDiv">
					<xsl:text>Zur Handschrift</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:when test="@type='annotations'">
				<span class="frontDiv">
					<xsl:text>Benutzungsspuren</xsl:text>
				</span>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<!--  -->
			</xsl:otherwise>
		</xsl:choose>

		<xsl:for-each select="tei:p">
			<span class="textItalic">
				<xsl:apply-templates select="node()"/>
			</span>
			<br/>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="tei:mentioned[not(ancestor::tei:front)]">
		<span class="textMentioned">
			<xsl:value-of select="node()"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:mentioned/text()[ancestor::tei:front]">
		<span class="frontMentioned">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="tei:publicationStmt/tei:date">

		<xsl:variable name="vDatum_isYYY-MM-DD">
			<xsl:call-template name="tDate_isYYYY-MM-DD">
				<xsl:with-param name="pDate" select="@when"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:text>Veröffentlicht am </xsl:text>
		<!--<xsl:value-of select="@when"/>-->

		<xsl:choose>
			<xsl:when test="$vDatum_isYYY-MM-DD='true'">
				<xsl:variable name="vDatum">
					<xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
						<xsl:with-param name="pDate_YYYY-MM-DD" select="@when"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="vDatumSlashes">
					<xsl:value-of select="translate($vDatum,'-','/')"/>
				</xsl:variable>

				<!--<xsl:value-of select="$vDatum"/>-->
				<xsl:value-of select="$vDatumSlashes"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@when"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:revisionDesc/tei:change">
		<xsl:variable name="vDatum_isYYY-MM-DD">
			<xsl:call-template name="tDate_isYYYY-MM-DD">
				<xsl:with-param name="pDate" select="@when"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vDatum_ChangeNachPubl">
			<xsl:call-template name="tDate_Vergleich_1vor2">
				<xsl:with-param name="pDate1_YYYY-MM-DD"
					select="//tei:publicationStmt/tei:date/@when"/>
				<xsl:with-param name="pDate2_YYYY-MM-DD" select="@when"/>
			</xsl:call-template>
		</xsl:variable>

		<!--<xsl:text>{</xsl:text><xsl:value-of select="$vDatum_ChangeNachPubl"/><xsl:text>}</xsl:text>-->

		<xsl:if test="$vDatum_ChangeNachPubl='true'">
			<xsl:text>, letzte Änderung: </xsl:text>
			<xsl:choose>
				<xsl:when test="$vDatum_isYYY-MM-DD='true'">
					<xsl:variable name="vDatum">
						<xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
							<xsl:with-param name="pDate_YYYY-MM-DD" select="@when"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="vDatumSlashes">
						<xsl:value-of select="translate($vDatum,'-','/')"/>
					</xsl:variable>

					<!--<xsl:value-of select="$vDatum"/>-->
					<xsl:value-of select="$vDatumSlashes"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@when"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template match="tei:publisher">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="tei:encodingDesc">
		<br/>

		<span class="encodingDesc">
			<xsl:apply-templates select="node()"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:encodingDesc//text()">
		<span class="textItalic">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="tei:encodingDesc/tei:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="tei:encodingDesc/tei:p/tei:mentioned">
		<!-- BAUSTELLE ??? -->
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="tei:projectDesc"/>
	<xsl:template match="tei:editorialDecl"/>
	<xsl:template match="tei:revisionDesc"/>

	<!-- zusätzliche Formatierung -->
	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="./tei:titleStmt/tei:title"/>
		<br/>
	</xsl:template>

	<xsl:template match="tei:respStmt">
		<br/>
		<xsl:value-of select="./tei:resp"/>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="./tei:name"/>
	</xsl:template>
	<!-- /zusätzliche Formatierung -->


	<!--
    #############################################################################################
        <body>:

    -->


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

	<xsl:template match="tei:body/tei:ab[@type='text']">

		<xsl:if test="count(@corresp)>0">
			<!-- @corresp vorhanden => filtern und ausgeben -->

			<xsl:variable name="vCorresp">
<!--				<xsl:call-template name="tCorrespFiltern">
					<xsl:with-param name="pCorresp" select="@corresp"/>
				</xsl:call-template>-->
				<xsl:value-of select="@corresp"/>
			</xsl:variable>

			<!-- Ausgabe -->
			<xsl:if test="string-length(normalize-space($vCorresp)) &gt; 0">
				<!-- nicht leer -->
				<div class="corresp">
					<xsl:text>[</xsl:text>
					<xsl:value-of select="$vCorresp"/>
					<xsl:text>]</xsl:text>
				</div>
			</xsl:if>

		</xsl:if>

		<span class="abTEXT" lang="la">
			<xsl:apply-templates/>
		</span>
		<br/>

		<span class="page-break">
			<xsl:text> </xsl:text>
			<!-- <span> muss gefüllt sein, sonst landet der restliche Output des Templates darin (Wieso auch immer...) / Wird nur beim Druck ausgegeben! => Hier vllt sowas wie "BK_..." ausgeben lassen, um Orientierung mit Ausdrucken zu erleichtern?! -->
		</span>

	</xsl:template>
	<xsl:template match="tei:body/tei:ab[@type='meta-text']">

		<br/>
		<xsl:if test="count(@corresp)>0">
			<!-- @corresp vorhanden => filtern und ausgeben -->

			<xsl:variable name="vCorresp">
<!--				<xsl:call-template name="tCorrespFiltern">
					<xsl:with-param name="pCorresp" select="@corresp"/>
				</xsl:call-template>-->
				<xsl:value-of select="@corresp"/>
			</xsl:variable>

			<!-- Ausgabe -->
			<xsl:if test="string-length(normalize-space($vCorresp)) &gt; 0">
				<!-- nicht leer -->
				<div class="corresp">
					<xsl:text>[</xsl:text>
					<xsl:value-of select="$vCorresp"/>
					<xsl:text>]</xsl:text>
				</div>
			</xsl:if>

		</xsl:if>

		<span class="abMETA" lang="la">
			<xsl:attribute name="id">
				<xsl:value-of select="@xml:id"/>
			</xsl:attribute>


			<xsl:choose>
				<xsl:when test="@rend='red'">
					<span class="rendRed">
						<xsl:apply-templates/>
					</span>
				</xsl:when>
				<xsl:when test="@rend='default'">
					<span class="rendBlack">
						<xsl:apply-templates/>
					</span>
				</xsl:when>
				<xsl:when test="not(@rend)">
					<span class="rendBlack">
						<xsl:apply-templates/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>

		</span>
		<!--<br/>-->
	</xsl:template>

	<!--<xsl:template match="//tei:seg[@type[.='titulus' or .='numDenom' or .='num']][@rend[.='majuscule red']]"> 19.12.2014-->
	<!--<xsl:template match="//tei:seg[@type[.='titulus' or .='numDenom' or .='num']][@rend[.='red']]"> 19.12.2014-->

	<xsl:template match="//tei:seg[@type[.='numDenom' or .='num']]">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:lb">
		<!-- <lb> ignorieren ?!? -->
	</xsl:template>
	<xsl:template match="tei:lb[parent::node()[@place='margin']]"> </xsl:template>

	<xsl:template match="tei:cb">
		<xsl:if test="not(current()[@break='no'])">
			<xsl:text> </xsl:text>
		</xsl:if>
		<span class="folio">
			<xsl:choose>
				<xsl:when test="string-length(translate(@n,'r',''))!=string-length(@n)">
					<!-- recto -->
					<xsl:text>[fol. </xsl:text>
					<xsl:value-of select="./@n"/>
					<xsl:text>]</xsl:text>
				</xsl:when>
				<!--<xsl:when test="substring(@n,2,1)='v'">-->
				<xsl:when test="string-length(translate(@n,'v',''))!=string-length(@n)">
					<!-- verso -->
					<xsl:text>[fol. </xsl:text>
					<xsl:value-of select="./@n"/>
					<xsl:text>]</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!-- sonst -->
					<xsl:text>[p. </xsl:text>
					<xsl:value-of select="./@n"/>
					<xsl:text>]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		<xsl:if test="not(current()[@break='no'])">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:milestone">

<!-- 21.10.2015 => milestones nicht anzeigen
		<span class="milestone">
			<xsl:attribute name="id">
				<!-\-<xsl:value-of select="translate(translate(translate(@n,'.','_'),'[',''),']','')"/>-\->
				<!-\-<xsl:value-of select="translate(@n,'.','_')"/>-\->
				<xsl:value-of select="@n"/>
			</xsl:attribute>
			<!-\- Marcello 2015-10-02
			     Warum wird im "id" ein . durch _ ersetzt?
			     Ich kopiere mir mal das Original weil ich es für die Sidebar brauche. -\->
			<xsl:attribute name="data-tei-n">
				<xsl:value-of select="@n"/>
			</xsl:attribute>
			<!-\- Ende Marcello-\->
			<xsl:text> [</xsl:text>
			<xsl:value-of select="translate(translate(./@n,'.',' '),'_',' ')"/>
			<xsl:text>] </xsl:text>
		</span>
-->

		<!-- "leere" <span> als Anker für Sidebar -->
		<span class="milestone">
			<xsl:attribute name="id">
				<xsl:value-of select="@n"/>
			</xsl:attribute>
			<xsl:attribute name="data-tei-n">
				<xsl:value-of select="@n" />
			</xsl:attribute>

			<!-- leer -->
			<xsl:comment></xsl:comment>
		</span>

	</xsl:template>


	<!-- Typ-Unterscheidung hinzufügen!!! -->
	<!--
            Die einzelnen Typen sollen optisch unterscheidbar sein, ohne daß man Farbe verwenden muß.
            Alle größer und fett; zusätzlich zur Unterscheidung verschiedene Größen/Schrifttypen?
        -->
	<!--<xsl:template match="//tei:seg[substring-before(@type,'-')='initial']">-->
	<!--<xsl:template match="//tei:seg[string-length(translate(@type,'initial',''))!=string-length(@type)]">-->
	<xsl:template match="tei:seg[@type='initial']">
		<xsl:element name="span">
			<!-- div vs. span?! -->
			<xsl:attribute name="class">initial</xsl:attribute>


			<xsl:attribute name="title">
				<xsl:text>Initiale</xsl:text>
				<xsl:if test="contains(@type,'-')">
					<xsl:text>, Typ </xsl:text>
					<xsl:value-of select="substring-after(@type, '-')"/>
				</xsl:if>
			</xsl:attribute>



			<!--			<xsl:element name="span">
				<xsl:attribute name="class">initialTYP</xsl:attribute>

				<xsl:value-of select="substring-after(@type, '-')"/>
			</xsl:element>-->
			<xsl:element name="span">
				<xsl:attribute name="class">initialABC</xsl:attribute>
				<!--<xsl:value-of select="."/>-->

				<xsl:choose>
					<xsl:when test="@rend='red'">
						<span style="color: #b92900;">
							<xsl:apply-templates select="node()"/>
						</span>
					</xsl:when>
					<xsl:when test="@rend='default'">
						<span style="color: black;">
							<xsl:apply-templates select="node()"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="node()"/>
					</xsl:otherwise>
				</xsl:choose>


			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tei:seg[@type='versalie']">
		<!-- BAUSTELLE: VERSALIEN => Gibt es bisher noch nicht?! -->
		<span class="versalie">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="tei:cit">
		<xsl:apply-templates select="tei:quote"/>
		<xsl:apply-templates select="tei:ref"/>
	</xsl:template>

	<xsl:template match="tei:cit/tei:quote">
		<span class="quote">
			<xsl:text>&#8222;</xsl:text>
		</span>
		<xsl:apply-templates select="./node()"/>
		<span class="quote">
			<xsl:text>&#8220;</xsl:text>
		</span>

	</xsl:template>

	<xsl:template match="tei:cit/tei:ref">
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="//tei:cit/tei:ref"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>

		<!--		<span class="annotation">
			<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="annotation-link ssdone">
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</a>
			<div class="annotation-content">
				<a class="ssdone" href="#{generate-id($vBezug)}">
<!-\-					<xsl:value-of select="$vIndex"/>
					<xsl:if test="$vIndex=''">
						<xsl:text>{NoIndex}</xsl:text>
					</xsl:if>
					<xsl:text>: </xsl:text>-\->
					<xsl:call-template name="tTooltip">
						<xsl:with-param name="pNode" select="."/>
					</xsl:call-template>
				</a>
			</div>
		</span>-->

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink" title="{.}">
			<!--<sup>[<xsl:value-of select="$refIndex"/>]</sup>-->
			<sup>
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</sup>
		</a>
	</xsl:template>

	<!-- Hinzufügung durch DT am 27.08.2014, um auf externe Ressourcen wie die dMGH verlinken zu können (modifiziert durch NG am 04.09.2014: um mehrdeutige Regeln zu beseitigen => [@type] => tei:ref auf type-Attribut prüfen - Template muss möglicherweise noch ansich mit anderem ref-Template abgeglichen/angepasst werden)  -->
	<xsl:template match="tei:ref[@type]">
		<xsl:choose>
			<xsl:when test="@type='external'">
				<a>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:attribute name="title">Externer Link</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="@target"/>
					</xsl:attribute>
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<!-- mögliche andere Fälle wären Personen oder Orte - Normdaten! -->
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:handShift">

		<xsl:call-template name="tFunoVerweis_alphabetisch">
			<xsl:with-param name="pBezug" select="."/>
		</xsl:call-template>

	</xsl:template>


	<!--<xsl:template match="//tei:note[not(@type='editorial')]">-->
	<xsl:template match="tei:note[not(@type='editorial')][ancestor::tei:body]">
<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->

		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>
		<!--
		<span class="annotation">
			<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="annotation-link ssdone">
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</a>
			<div class="annotation-content">
				<a class="ssdone" href="#{generate-id($vBezug)}">
					<xsl:call-template name="tTooltip">
						<xsl:with-param name="pNode" select="."/>
					</xsl:call-template>
				</a>
			</div>
		</span>-->

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tTooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
			<sup>
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</sup>
		</a>
	</xsl:template>

	<!--<xsl:template match="//tei:note[@type='editorial'][not(@target)]">-->
	<xsl:template match="tei:note[@type='editorial'][not(@target)][ancestor::tei:body]">
<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->

		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>

		<!--		<span class="annotation">
			<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="annotation-link ssdone">
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</a>
			<div class="annotation-content">
				<a class="ssdone" href="#{generate-id($vBezug)}">
					<xsl:call-template name="tTooltip">
						<xsl:with-param name="pNode" select="."/>
					</xsl:call-template>
				</a>
			</div>
		</span>-->

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tTooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
			<sup>
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex(note)}</xsl:text>
				</xsl:if>
			</sup>
		</a>
	</xsl:template>

	<xsl:template match="tei:note[@type='editorial'][@target]">
		<!-- als Teil von "Erstreckungsfußnote" -->
<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vPrecSeg" select="preceding-sibling::node()[1][name()='span'][@xml:id]"/>
		<xsl:variable name="vBezug">
			<xsl:value-of select="$vPrecSeg/text()[1]"/>
			<xsl:value-of select="$vPrecSeg/tei:add"/>
			<xsl:value-of select="substring-before($vPrecSeg/text()[last()],' ')"/>
			<xsl:text>...</xsl:text>
			<xsl:value-of select="substring-after($vPrecSeg/text()[last()],' ')"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="."/>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<!--								<xsl:call-template name="tTooltip">
					<xsl:with-param name="pNode" select="$vBezug"/>
				</xsl:call-template>-->
			</xsl:attribute>
			<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
			<sup>
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</sup>
		</a>
	</xsl:template>


	<xsl:template match="tei:note[@type='comment']">
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>
		<!--
		<span class="annotation">
			<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="annotation-link ssdone">
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</a>
			<div class="annotation-content">
				<a class="ssdone" href="#{generate-id($vBezug)}">
					<xsl:call-template name="tTooltip">
						<xsl:with-param name="pNode" select="."/>
					</xsl:call-template>
				</a>
			</div>
		</span>-->

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tTooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<sup>
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</sup>
		</a>

	</xsl:template>

	<xsl:template match="tei:sic">

		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!--<xsl:value-of select="."/>-->
		<xsl:apply-templates select="./node()"/>
		<xsl:text> [!]</xsl:text>

	</xsl:template>

	<!-- <subst> -->

	<xsl:template match="tei:subst">

		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="."/>

		<!-- Text für Tooltip erstellen -->
		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Position ermitteln -->
<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>-->
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<!--<span class="debug"><xsl:text>{subst}</xsl:text></span>-->

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

				<xsl:call-template name="tFunoVerweis_alphabetisch">
					<xsl:with-param name="pBezug" select="$vBezug"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:add[parent::tei:subst]">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:del[parent::tei:subst]">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- </subst> -->

	<!-- <add> -->

	<xsl:template
		match="tei:add[not(parent::*[local-name(.)='subst'] and not(parent::*[local-name(.)='num']))]">
		<!--<xsl:text>{add-oP}</xsl:text> <!-\- TESTWEISE -\->-->

		<xsl:variable name="vNoteFolgt">
			<!-- ermittelt, ob eine <note> angehängt ist -->
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vLeerzeichenDavor">
			<!-- Leerzeichen vor Element? -->
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="current()"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLeerzeichenDanach">
			<!-- Leerzeichen nach Element? -->
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="current()"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="."/>

		<!-- Text für Tooltip erstellen -->
		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Position ermitteln -->
<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>-->
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- <note> folgt => Fußnote wird bereits gesetzt -->

<!--
				<xsl:if
					test="not(string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,'')))">
					<xsl:apply-templates select="node()"/>
				</xsl:if>
-->

				<xsl:choose>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- Hand XYZ -->

						<xsl:if test="parent::tei:ab">
							<!-- tei:ab ist parent => Platzhalter/Anker setzen, falls ganz am Anfang -->
							<xsl:choose>
								<xsl:when test="count(preceding-sibling::node())=0">
									<!-- Element ist 1. node() -->
									<!--<xsl:text>#</xsl:text>-->
								</xsl:when>
								<xsl:when test="count(preceding-sibling::*)>0">
									<!-- Element ist nicht erstes Element -->
								</xsl:when>
								<xsl:otherwise>
									<!-- Element is erstes Element (nach text()) -->
									<xsl:if
										test="normalize-space(preceding-sibling::node())=''">
										<!-- vorher nur Whitespace -->
										<!--<xsl:text>#</xsl:text>-->
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

					</xsl:when>
					<xsl:otherwise>
						<!-- nicht Hand XYZ -->
						<xsl:apply-templates select="node()"/>
					</xsl:otherwise>
				</xsl:choose>

				<!--<span class="debug"><xsl:text>{!funoFolgt!}</xsl:text></span> <!-\- TESTWEISE -\->-->

			</xsl:when>
			<xsl:otherwise>
				<!-- es folgt keine <note> = automatische Fußnote wird generiert -->

				<xsl:choose>
					<xsl:when test="not(@hand)">
						<!-- keine Hand -->

						<xsl:choose>
							<xsl:when
								test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:otherwise>
								<span class="debug">
									<xsl:text>{TEST-add-FEHLER-hand0-lz:</xsl:text>
									<xsl:text>$vLeerzeichenDavor=</xsl:text>
									<xsl:value-of select="$vLeerzeichenDavor"/>
									<xsl:text>|</xsl:text>
									<xsl:text>$vLeerzeichenDanach=</xsl:text>
									<xsl:value-of select="$vLeerzeichenDanach"/>
									<xsl:text>###</xsl:text>
									<xsl:value-of select="preceding-sibling::text()[1]"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="following-sibling::text()[1]"/>
									<xsl:text>}</xsl:text>
								</span>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- entspricht "normaler" Hand -->

						<xsl:choose>
							<xsl:when
								test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->

								<xsl:apply-templates select="./node()"/>

							</xsl:when>
							<xsl:otherwise>
								<span class="debug">
									<xsl:text>{TEST-add-FEHLER-handABC-lz}</xsl:text>
								</span>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- entspricht "spezieller" Hand -->

						<xsl:if test="parent::tei:ab">
							<!-- tei:ab ist parent => Platzhalter/Anker setzen, falls ganz am Anfang -->
							<xsl:choose>
								<xsl:when test="count(preceding-sibling::node())=0">
									<!-- Element ist 1. node() -->
									<!--<xsl:text>#</xsl:text>-->
								</xsl:when>
								<xsl:when test="count(preceding-sibling::*)>0">
									<!-- Element ist nicht erstes Element -->
								</xsl:when>
								<xsl:otherwise>
									<!-- Element is erstes Element (nach text()) -->
									<xsl:if
										test="normalize-space(preceding-sibling::node())=''">
										<!-- vorher nur Whitespace -->
										<!--<xsl:text>#</xsl:text>-->
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

						<xsl:choose>
							<xsl:when
								test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:when
								test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:otherwise>
								<span class="debug">
									<xsl:text>{TEST-add-FEHLER-handXYZ-lz}</xsl:text>
								</span>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:when>
					<xsl:otherwise>
						<span class="debug">
							<xsl:text>{TEST-add-FEHLER-hand?}</xsl:text>
						</span>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- </add> -->

	<!-- <mod> -->

	<xsl:template match="tei:mod">
		<!--<xsl:text>{mod}</xsl:text> <!-\- TESTWEISE -\->-->

		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="."/>

		<!-- Text für Tooltip erstellen -->
		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>-->
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates select="node()"/>

		<xsl:if test="$vNoteFolgt='false'">

			<xsl:call-template name="tFunoVerweis_alphabetisch">
				<xsl:with-param name="pBezug" select="$vBezug"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<!-- </mod> -->


	<xsl:template match="tei:num">
		<!--<xsl:text>{ab_num}</xsl:text> <!-\- TESTWEISE -\->-->
		<!--		<xsl:value-of select="text()"/>
		<xsl:apply-templates select="tei:add"/>-->
		<xsl:apply-templates select="current()/node()"/>
		<!--<xsl:text>{/ab_num}</xsl:text> <!-\- TESTWEISE -\->-->
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


		<!--		<!-\- TESTWEISE -\->
		<xsl:if test="current()='h'">
			<xsl:variable name="test" select="''"></xsl:variable>
		</xsl:if>-->


		<xsl:choose>
			<xsl:when test="count(node())=0">
				<!-- Sonderfall bei <del>:  leeres Element -->
				<!-- Bezugsknoten -->

				<xsl:call-template name="tPrintXtimes">
					<xsl:with-param name="pPrintWhat" select="'+'"/>
					<xsl:with-param name="pPrintHowManyTimes" select="current()/@quantity"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- Note folgt => Fußnote wird darüber erzeugt -->

				<!--
				<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
					<xsl:apply-templates select="node()"/>
				</xsl:if>
-->
				<xsl:choose>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<xsl:apply-templates select="node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="parent::tei:ab">
							<!-- tei:ab ist parent => Platzhalter/Anker setzen, falls ganz am Anfang -->
							<xsl:choose>
								<xsl:when test="count(preceding-sibling::node())=0">
									<!-- Element ist 1. node() -->
									<!--<xsl:text>#</xsl:text>-->
								</xsl:when>
								<xsl:when test="count(preceding-sibling::*)>0">
									<!-- Element ist nicht erstes Element -->
								</xsl:when>
								<xsl:otherwise>
									<!-- Element is erstes Element (nach text()) -->
									<xsl:if
										test="normalize-space(preceding-sibling::node())=''">
										<!-- vorher nur Whitespace -->
										<!--<xsl:text>#</xsl:text>-->
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>



			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not(@hand)">
						<!-- ohne Hand -->

						<xsl:if test="parent::tei:ab">
							<!-- tei:ab ist parent => Platzhalter/Anker setzen, falls ganz am Anfang -->
							<xsl:choose>
								<xsl:when test="count(preceding-sibling::node())=0">
									<!-- Element ist 1. node() -->
									<!--<xsl:text>#</xsl:text>-->
								</xsl:when>
								<xsl:when test="count(preceding-sibling::*)>0">
									<!-- Element ist nicht erstes Element -->
								</xsl:when>
								<xsl:otherwise>
									<!-- Element is erstes Element (nach text()) -->
									<xsl:if
										test="normalize-space(preceding-sibling::node())=''">
										<!-- vorher nur Whitespace -->
										<!--<xsl:text>#</xsl:text>-->
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

						<!-- Bezugsknoten -->
						<xsl:variable name="vBezug" select="."/>

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- normale Hand -->

						<xsl:if test="parent::tei:ab">
							<!-- tei:ab ist parent => Platzhalter/Anker setzen, falls ganz am Anfang -->
							<xsl:choose>
								<xsl:when test="count(preceding-sibling::node())=0">
									<!-- Element ist 1. node() -->
									<!--<xsl:text>#</xsl:text>-->
								</xsl:when>
								<xsl:when test="count(preceding-sibling::*)>0">
									<!-- Element ist nicht erstes Element -->
								</xsl:when>
								<xsl:otherwise>
									<!-- Element is erstes Element (nach text()) -->
									<xsl:if
										test="normalize-space(preceding-sibling::node())=''">
										<!-- vorher nur Whitespace -->
										<!--<xsl:text>#</xsl:text>-->
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

						<!-- Bezugsknoten -->
						<xsl:variable name="vBezug" select="."/>

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when
						test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- spezielle Hand -->
						<xsl:apply-templates select="current()/node()"/>

						<!-- Bezugsknoten -->
						<xsl:variable name="vBezug" select="."/>

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:otherwise>
						<span class="debug">
							<xsl:text>{FEHLER in del}</xsl:text>
						</span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:abbr">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:choice">

		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates select="./tei:expan/node()"/>


		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- manuelle Fußnote -->
			</xsl:when>
			<xsl:otherwise>
				<!-- automatische Fußnote anhängen -->

				<xsl:call-template name="tFunoVerweis_alphabetisch">
					<xsl:with-param name="pBezug" select="."/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template match="tei:choice">

		<span title="{tei:abbr/text()}">
			<xsl:apply-templates select="tei:expan/node()"/>
			<xsl:text> (</xsl:text>
			<xsl:apply-templates select="tei:abbr/node()"/>
			<xsl:text>.)</xsl:text>
		</span>

	</xsl:template>

	<xsl:template match="tei:unclear[count(tei:gap)>0]">
		<xsl:text>...</xsl:text>


		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="."/>

		<!-- Text für Tooltip erstellen -->
		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

<!--		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>-->
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="tFunoVerweis_alphabetisch">
			<xsl:with-param name="pBezug" select="$vBezug"/>
		</xsl:call-template>

		<!--		<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tTooltip">
					<xsl:with-param name="pNode" select="exslt:node-set($vFunoText)"/>
				</xsl:call-template>
			</xsl:attribute>
			<sup><xsl:value-of select="$vIndex"/><xsl:if test="$vIndex=''"><xsl:text>{NoIndex}</xsl:text></xsl:if></sup>
		</a>-->
	</xsl:template>

	<xsl:template match="tei:unclear[count(tei:gap)=0]">
		<!--		<span class="unclear" title="{following-sibling::*[1][name()='note']}">
			<xsl:apply-templates select="node()"/>
		</span>-->
		<!-- 16.04.2015
			<u>
			<xsl:apply-templates select="node()"/>
		</u>-->

		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="node()"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="tei:gap">
		<!--<xsl:text>...</xsl:text>-->

		<xsl:text>[</xsl:text>
		<xsl:call-template name="tPrintXtimes">
			<xsl:with-param name="pPrintWhat" select="' .'"/>
			<xsl:with-param name="pPrintHowManyTimes" select="current()/@quantity"/>
		</xsl:call-template>
		<xsl:text> ]</xsl:text>



		<!-- 16.04.2015
		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>


		<xsl:variable name="vLeerzeichenDavor">
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLeerzeichenDanach">
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vLeerzeichenDavor=$vLeerzeichenDanach and $vLeerzeichenDavor='true'">

				<!-\-
					-	wenn <gap> alleinstehendes Element, d.h. Leerzeichen vor und hinter <gap>:
						Fußnotenzeichen an „…“ hängen, Wortlaut der Anmerkung:
							„ca. [n] Buchstaben [unit=“chars“] / Worte [unit=“words“] unleserlich“  (bei n>1); bzw.
							„ca. 1 Buchstabe [unit=“chars“] / Wort [unit=“words“] unleserlich“ (bei n=1).
				-\->

				<xsl:choose>
					<xsl:when test="$vNoteFolgt='true'">

					</xsl:when>
					<xsl:otherwise>
						<!-\- Index mit Hyperlink auf Fußnote anhängen -\->

						<!-\- Bezugsknoten -\->
						<xsl:variable name="vBezug" select="."/>

						<!-\- Text für Tooltip erstellen -\->
						<xsl:variable name="vFunoText">
							<xsl:call-template name="tFunoText_alphabetisch">
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:variable name="vIndex">
							<xsl:call-template name="indexOf_a">
								<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
								<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>

						<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="noteLink">
							<xsl:attribute name="title">
								<xsl:call-template name="tTooltip">
									<xsl:with-param name="pNode" select="exslt:node-set($vFunoText)"/>
								</xsl:call-template>
							</xsl:attribute>
							<sup><xsl:value-of select="$vIndex"/><xsl:if test="$vIndex=''"><xsl:text>{NoIndex}</xsl:text></xsl:if></sup>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>

				<!-\-
					-	wenn <gap> innerhalb eines Wortes steht: An der Stelle von <gap> „…“ in das Wort hineinsetzen (ohne Leerzeichenabstand) und Fußnote an dieses Wort anhängen:
						„ca. [n] Buchstabe[n] am unleserlich“
				-\->
				<xsl:text>...</xsl:text>

				<!-\- ACHTUNG: Link für Fußnote muss über nachfolgenden text() erzeugt werden! -\->
			</xsl:otherwise>
		</xsl:choose>

-->


	</xsl:template>

	<xsl:template match="tei:expan">
		<span class="textItalic">
			<xsl:apply-templates select="node()"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:ex">
		<span class="textItalic">
			<xsl:apply-templates select="node()"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:space">

		<xsl:variable name="vNoteFolgt">
			<!-- ermittelt, ob eine <note> angehängt ist -->
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:text> - - - </xsl:text>

		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true'">
				<!-- kein Verweis, falls noch <note> (=eigener Verweis) folgt -->
			</xsl:when>
			<xsl:otherwise>

				<xsl:call-template name="tFunoVerweis_alphabetisch">
					<xsl:with-param name="pBezug" select="."/>
				</xsl:call-template>

				<!--
				<!-\- Index mit Hyperlink auf Fußnote anhängen -\->
				<!-\- Bezugsknoten -\->
				<xsl:variable name="vBezug" select="."/>

				<!-\- Text für Tooltip erstellen -\->
				<xsl:variable name="vFunoText">
					<xsl:call-template name="tFunoText_alphabetisch">
						<xsl:with-param name="pNode" select="$vBezug"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="vIndex">
					<xsl:call-template name="indexOf_a">
						<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
						<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
						<xsl:with-param name="pNode" select="$vBezug"/>
					</xsl:call-template>
				</xsl:variable>

				<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="noteLink">
					<xsl:attribute name="title">
						<xsl:call-template name="tTooltip">
							<xsl:with-param name="pNode" select="exslt:node-set($vFunoText)"/>
						</xsl:call-template>
					</xsl:attribute>
					<sup><xsl:value-of select="$vIndex"/><xsl:if test="$vIndex=''"><xsl:text>{NoIndex}</xsl:text></xsl:if></sup>
				</a>
-->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:date">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:locus">
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

	<xsl:template match="text()[ancestor::tei:ab][not(ancestor::tei:note)][not(ancestor::tei:ref)]">
		<!-- Umwandlung Platzhalter (Mittelpunkt etc.) -->

		<xsl:variable name="tText">
			<xsl:call-template name="tPlatzhalterVerarbeiten">
				<xsl:with-param name="pText" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$tText"/>
	</xsl:template>

	<xsl:template match="tei:metamark">
		<!-- metamark vorerst ignorieren -->
	</xsl:template>

	<xsl:template match="tei:hi[@rend='super']">
		<!--  -->
		<span class="hiSuper">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<!--	<xsl:template match="//tei:seg[@xml:id]">
		<!-\- "Erstreckungsfußnoten" -\->

		<xsl:variable name="before">
			<xsl:sequence select="normalize-space(substring-before(text()[last()],' '))"/>
		</xsl:variable>
		<xsl:variable name="after">
			<xsl:sequence select="substring-after(text()[last()],' ')"/>
		</xsl:variable>

		<xsl:value-of select="node()[1]"/>
		<xsl:apply-templates select="tei:add"/>
		<xsl:value-of select="$before"/>
		<xsl:apply-templates select="following-sibling::node()[1][name()='note']"/>
		<xsl:value-of select="$after"/>

	</xsl:template>-->
	<xsl:template match="tei:span[@xml:id]">
		<!-- "Erstreckungsfußnoten" -->

		<xsl:variable name="before">
			<!--<xsl:sequence select="normalize-space(substring-before(text()[last()],' '))"/>-->
			<xsl:value-of select="normalize-space(substring-before(text()[last()],' '))"/>
		</xsl:variable>
		<xsl:variable name="after">
			<!--<xsl:sequence select="substring-after(text()[last()],' ')"/>-->
			<xsl:value-of select="substring-after(text()[last()],' ')"/>
		</xsl:variable>

		<xsl:value-of select="node()[1]"/>
		<xsl:apply-templates select="tei:add"/>
		<xsl:value-of select="$before"/>
		<xsl:apply-templates select="following-sibling::node()[1][name()='note']"/>
		<xsl:value-of select="$after"/>

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
