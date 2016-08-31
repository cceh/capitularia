<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:regexp="http://exslt.org/regular-expressions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:my="my"
    version="1.0"
    exclude-result-prefixes="exslt tei xhtml my">

	<!-- 22.2. DS #### Achtung: aus Testzwecken wg. Anpassung an TRL geändert: @rend="red" zu @rend="coloured" #### - funktioniert! -->

	<!-- author: NG -->
	
	<!-- ########## INCLUDES ########## -->
	
	<xsl:include href="xsl-output.xsl"/>
	
	<!-- allgemeine Funktionen (string-replace etc.) -->
	<xsl:include href="allgFunktionen.xsl"/>
	<!-- zusätzliche Funktionen (tNoteFolgt etc.) -->
	<xsl:include href="transkription_ZusatzFunktionen.xsl"/>
	<!-- globale Variablen -->
	<xsl:include href="transkription_PublWP_Variablen.xsl"/>
	<!-- CSS für Darstellung der Ausgabe -->
	<xsl:include href="transkription_PublWP_Style.xsl"/>
	<!-- Verarbeitung/Darstellung der Fußnoten(-Texte) -->
	<xsl:include href="transkription_PublWP_Fussnoten.xsl"/>
	<!-- Pfade etc. -->
	<xsl:include href="base_variables.xsl"/>
	
	<!-- ########## /INCLUDES ########## -->
	
	<!-- ########## PARAMETERS ########## -->
	
	<!-- set line-height (=Zeilenabstand) in <ab> (insert "-1" for default line-height)-->
	<xsl:param name="pLineHeight">3</xsl:param>
	<!-- show comments in <ab>: y/n-->
	<xsl:param name="pShowComments">y</xsl:param>
	<!-- insert page-breaks after every <ab>: y/n -->
	<xsl:param name="pPageBreaks">n</xsl:param>
	<!-- set placeholder icon for <tei:figure> -->
	<xsl:param name="pFigureIcon">dashicons dashicons-format-image</xsl:param>
	
	<!-- ########## /PARAMETERS ########## -->

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="//tei:text">
				<!-- nur wenn Transkription vorhanden -->

				<div class="transkription-body">
					<!-- <style> übernehmen -->
					<xsl:copy-of select="$vStyle"/>

					<div class="transkr"> <!-- Ersatz für <body> -->

						<!-- TITLE -->
						<div class="meta">
							<xsl:apply-templates select="//tei:teiHeader"/>
						</div>

						<!-- TEXT -->
						<div id="EditorischeVorbemerkung">
							<h5 id="editorial-preface" data-cap-dyn-menu-caption="[:de]Editorische Vorbemerkung[:en]Editorial Preface[:]">[:de]Editorische Vorbemerkung zur Transkription[:en]Editorial Preface to the Transcription[:]</h5>
							<div class="encodingDesc">
								<xsl:apply-templates select="//tei:text/tei:front/tei:div[normalize-space (.)]"/>
							</div>
						</div>

						<xsl:call-template name="page-break" />

						<div id="inhaltsverzeichnis" style="display: none">
							<h5 id="contents-rubrics">[:de]Inhalt (Rubriken)[:en]Contents (Rubrics)[:]</h5>
							<xsl:apply-templates select="//tei:div[@xml:id='divContent']" mode="toc"/>
						</div>

						<!-- BODY -->
						<div class="text">
							<h5 id="contents-bknos" style="display: none">[:de]Inhalt (BK-Nummern)[:en]Contents (BK-Nos.)[:]</h5>
							<xsl:apply-templates select="//tei:body"/>
						</div>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>

				<!-- wennn keine Transkription vorhanden -->
			</xsl:otherwise>
		</xsl:choose>
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
	  <li class="toc">
	    <xsl:variable name="level" select="count (ancestor::tei:item)" />
	    <a href="{tei:ptr/@target}" data-level="{$level}"><xsl:value-of select="text()"/></a>
            <xsl:apply-templates select="tei:list" mode="toc"/>
	  </li>
	</xsl:template>

	<xsl:template match="tei:teiHeader">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:body">
	  <xsl:apply-templates/>

	  <!-- The post-processing php script will move all
	       preceding footnotes into this container. -->
	  <div class="footnotes-wrapper" lang="la" />
	</xsl:template>

	<xsl:template match="tei:title">
	</xsl:template>

	<xsl:template match="tei:title[@type='main']">
	  <h4 id="transcription">[:de]Transkription[:en]Transcription[:]</h4>

	</xsl:template>


	<xsl:template match="tei:front/tei:div[normalize-space (.)]">
	  <div class="italic tei-front-div">
	    <h6>
	      <xsl:choose>
		<xsl:when test="@type='scribe'">                       Schreiber</xsl:when>
 		<xsl:when test="@type='lett' or @type='letters'">      Buchstabenformen</xsl:when>
		<xsl:when test="@type='abbr' or @type='abbreviation' or @type='abbreviations'">Abkürzungen</xsl:when>
		<xsl:when test="@type='punct' or @type='punctuation'"> Interpunktion</xsl:when>
		<xsl:when test="@type='struct' or @type='structure'">  Gliederungsmerkmale</xsl:when>
		<xsl:when test="@type='other'">                        Sonstiges</xsl:when>
		<xsl:when test="@type='mshist'">                       Zur Handschrift</xsl:when>
		<xsl:when test="@type='annotations'">                  Benutzungsspuren</xsl:when>
	      </xsl:choose>
	    </h6>

	    <xsl:apply-templates select="tei:p"/>
	  </div>
	</xsl:template>

	<xsl:template match="tei:mentioned">
	  <span class="regular tei-mentioned"><xsl:apply-templates /></span>
	</xsl:template>

	<xsl:template match="//tei:body//tei:mentioned">
	  <span class="italic tei-mentioned"><xsl:apply-templates /></span>
	</xsl:template>

	<xsl:template match="tei:publicationStmt/tei:date">
		<xsl:variable name="vDatum_isYYYY-MM-DD">
			<!-- prüft, ob das Datum im Format YYYY-MM-DD hinterlegt ist -->
			<xsl:call-template name="tDate_isYYYY-MM-DD">
				<xsl:with-param name="pDate" select="@when"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:text>Veröffentlicht am </xsl:text>
		<xsl:choose>
			<xsl:when test="$vDatum_isYYYY-MM-DD='true'">
				<!-- Datum im Format YYYY-MM-DD => umwandeln in DD-MM-YYYY -->
				<xsl:variable name="vDatum">
					<xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
						<xsl:with-param name="pDate_YYYY-MM-DD" select="@when"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="vDatumSlashes">
					<!-- '-' in '/' umwandeln -->
					<xsl:value-of select="translate($vDatum,'-','/')"/>
				</xsl:variable>

				<!-- Datum ausgeben -->
				<xsl:value-of select="$vDatumSlashes"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Datum unverändert ausgeben -->
				<xsl:value-of select="@when"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:revisionDesc/tei:change">
		<xsl:variable name="vDatum_isYYYY-MM-DD">
			<!-- prüft, ob das Datum im Format YYYY-MM-DD hinterlegt ist -->
			<xsl:call-template name="tDate_isYYYY-MM-DD">
				<xsl:with-param name="pDate" select="@when"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vDatum_ChangeNachPubl">
			<!-- prüft, ob der Change nach Veröffentlichung stattfand -->
			<xsl:call-template name="tDate_Vergleich_1vor2">
				<xsl:with-param name="pDate1_YYYY-MM-DD" select="//tei:publicationStmt/tei:date/@when"/>
				<xsl:with-param name="pDate2_YYYY-MM-DD" select="@when"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="$vDatum_ChangeNachPubl='true'">
			<!-- Change fand nach Veröffentlichung statt -->
			<xsl:text>, letzte Änderung: </xsl:text>
			<xsl:choose>
				<xsl:when test="$vDatum_isYYYY-MM-DD='true'">
					<!-- Datum im Format YYYY-MM-DD => umwandeln in DD-MM-YYYY -->
					<xsl:variable name="vDatum">
						<xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
							<xsl:with-param name="pDate_YYYY-MM-DD" select="@when"/>
						</xsl:call-template>
					</xsl:variable>

					<!-- '-' in '/' umwandeln -->
					<xsl:variable name="vDatumSlashes">
						<xsl:value-of select="translate($vDatum,'-','/')"/>
					</xsl:variable>

					<!-- Datum asgeben -->
					<xsl:value-of select="$vDatumSlashes"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- Datum unverändert ausgeben -->
					<xsl:value-of select="@when"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template match="tei:publisher">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="tei:encodingDesc">
	  <div class="italic tei-encodingDesc">
	    <xsl:apply-templates />
	  </div>
	</xsl:template>

	<xsl:template match="tei:p">
	  <p class="tei-p">
	    <xsl:apply-templates/>
	  </p>
	</xsl:template>

	<!-- Inahlte nicht ausgeben -->
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
		<!-- Zeichenkette teilen -->
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
		<!-- wandelt Inhalt von @corresp in gewünschte Form um -->
		<!--
			1) "inscriptio" entfernen
			2) "incipit" entfernen
		-->
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
				<xsl:call-template name="tCorrespFiltern">
					<xsl:with-param name="pCorresp" select="@corresp"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- Ausgabe -->
			<xsl:if test="string-length(normalize-space($vCorresp)) &gt; 0">
				<!-- nicht leer -->
				<div class="corresp">
					<xsl:text>[</xsl:text>
					<xsl:value-of select="normalize-space($vCorresp)"/>
					<xsl:text>]</xsl:text>
				</div>
			</xsl:if>

		</xsl:if>

		<div class="abTEXT" lang="la">
			<!-- sofern ein Zeilenabstand größer 0 angegeben wurde, wird der Zeilenabstand entsprechend geändert/angepasst -->
			<xsl:if test="$pLineHeight!=-1">
				<!-- ändere line-height (=Zeilenabstand) -->
				<xsl:attribute name="style">
					<xsl:text>line-height: </xsl:text>
					<xsl:value-of select="$pLineHeight"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="id">
				<xsl:value-of select="@xml:id"/>
			</xsl:attribute>

			<xsl:apply-templates/>
		</div>

		<!-- The post-processing php script will move all
		     preceding footnotes into this container. -->
		<div class="footnotes-wrapper" lang="la" />

		<xsl:if test="$pPageBreaks='y'">
			<xsl:call-template name="page-break" />	
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="comment()">
		<!-- template for comments -->
		<!-- BAUSTELLE: (für HTML) problematische Sonderzeichen maskieren?! -->
		<div class="comment" style="font-size: 70%; font-style: italic;">
			<xsl:choose>
				<xsl:when test="ancestor::tei:ab">
					<!-- @xml:id des <ab> ausgeben / In welchem <ab> befindet sich der Kommentar? -->
					<span class="comment_ab_id"><xsl:value-of select="ancestor::tei:ab/@xml:id"/></span>
					<!-- "Pfad" innerhalb des <ab> zum Kommentar ausgeben -->
					<xsl:call-template name="tParentsFromUntil">
						<xsl:with-param name="pFrom" select="." />
						<xsl:with-param name="pUntil" select="ancestor::tei:ab" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- parent des Kommentars ausgeben / In welchem Element befindet sich der Kommentar? -->
					<xsl:value-of select="local-name(parent::*)"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>: </xsl:text>
			
			<!-- Inhalt des Kommentars ausgeben -->
			<span class="comment_content">
				<xsl:value-of select="."/>
			</span>
		</div>
	</xsl:template>
	
	<xsl:template name="tParentsFromUntil">
		<!-- gibt alle parents von pFrom bis pUntil aus -->
		<xsl:param name="pFrom" />
		<xsl:param name="pUntil" />
		<!-- ACHTUNG: pUntil muss ancestor::* von pFrom sein! -->
		
		<xsl:choose>
			<xsl:when test="local-name($pFrom)=local-name($pUntil)">
				<!-- nichts -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="tParentsFromUntil">
					<xsl:with-param name="pFrom" select="$pFrom/parent::*" />
					<xsl:with-param name="pUntil" select="$pUntil" />
				</xsl:call-template>
				<xsl:if test="local-name($pFrom)!=''">
					<xsl:text>/</xsl:text><xsl:value-of select="local-name($pFrom)"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="tei:body/tei:ab[@type='meta-text']">
		<xsl:if test="count(@corresp)>0">
			<!-- @corresp vorhanden => filtern und ausgeben -->

			<!-- @corresp anpassen -->
			<xsl:variable name="vCorresp">
				<xsl:call-template name="tCorrespFiltern">
					<xsl:with-param name="pCorresp" select="@corresp"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- Ausgabe -->
			<xsl:if test="string-length(normalize-space($vCorresp)) &gt; 0">
				<!-- nicht leer -->
				<div class="corresp">
					<xsl:text>[</xsl:text>
					<xsl:value-of select="normalize-space($vCorresp)"/>
					<xsl:text>]</xsl:text>
				</div>
			</xsl:if>

		</xsl:if>

		<div class="abMETA" lang="la">
			<xsl:if test="$pLineHeight!=-1">
				<!-- ändere line-height (=Zeilenabstand) -->
				<xsl:attribute name="style">
					<xsl:text>line-height: </xsl:text>
					<xsl:value-of select="$pLineHeight"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="id">
				<xsl:value-of select="@xml:id"/>
			</xsl:attribute>

			<xsl:choose>
			  <xsl:when test="@rend='coloured'"><!-- Änderung von Wert red auf coloured wg. Anpassung an TRL # DS 22.02.16 -->
			    <xsl:attribute name="class">abMETA rend-red</xsl:attribute>
			  </xsl:when>
			  <xsl:when test="@rend='default'">
			    <xsl:attribute name="class">abMETA rend-default</xsl:attribute>
			  </xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

<!--<!-\- ambig1 -\-> <!-\- ambig2 -\->
	<xsl:template match="//tei:seg[@type[.='numDenom' or .='num']]">
		<xsl:apply-templates/>
	</xsl:template>-->

	<xsl:template match="tei:lb">
		<!-- <lb> ignorieren ?!? -->
	</xsl:template>
	<xsl:template match="tei:lb[parent::node()[@place='margin']]">
	</xsl:template>

	<xsl:template match="tei:cb">
		<xsl:if test="not(current()[@break='no'])">
			<xsl:text> </xsl:text>
		</xsl:if>

		<xsl:variable name="cb_prefix">
		  <xsl:choose>
		    <!-- recto -->
		    <xsl:when test="contains (@n, 'r')">
		      <xsl:text>fol.</xsl:text>
		    </xsl:when>
		    <!-- verso -->
		    <xsl:when test="contains (@n, 'v')">
		      <xsl:text>fol.</xsl:text>
		    </xsl:when>
		    <!-- other -->
		    <xsl:otherwise>
		      <xsl:text>p.</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:variable>

		<span class="folio">
		  <xsl:text>[cap_image_server id="</xsl:text><xsl:value-of select="/tei:TEI/@xml:id" /><xsl:text>" n="</xsl:text><xsl:value-of select="@n" /><xsl:text>"]</xsl:text>
		  <xsl:value-of select="concat ('[', $cb_prefix, ' ', @n, ']')"/>
		  <xsl:text>[/cap_image_server]</xsl:text>
		</span>

		<xsl:if test="not(current()[@break='no'])">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:milestone">
	  <!-- wird vom Sidebar-Menu benützt -->
	  <span id="{@n}" class="milestone"><span style="display: none"><xsl:value-of select="str:replace (substring-before (concat (@n, '_'), '_'), '.', ' ')"/></span></span> <!-- !FINDMICH! => auskommentieren für offline-Nutzung -->
	</xsl:template>

	<xsl:template match="tei:seg[@type='initial']">
		<span class="initial">
		  <xsl:attribute name="title">
		    <xsl:text>Initiale</xsl:text>
		    <xsl:if test="contains(@type,'-')">
		      <xsl:text>, Typ </xsl:text>
		      <xsl:value-of select="substring-after(@type, '-')"/>
		    </xsl:if>
		  </xsl:attribute>

			<span class="initialABC">
				<xsl:choose>
					<xsl:when test="@rend='coloured'"><!-- Änderung von Wert red auf coloured wg. Anpassung an TRL # DS 22.02.16 -->
				    <xsl:attribute name="class">initialABC rend-red</xsl:attribute>
				  </xsl:when>
				  <xsl:when test="@rend='default'">
				    <xsl:attribute name="class">initialABC rend-default</xsl:attribute>
				  </xsl:when>
				</xsl:choose>
				<xsl:apply-templates select="node()"/>
			</span>
		</span>
	</xsl:template>

	<xsl:template match="tei:seg[@type='versalie']">
		<!-- BAUSTELLE: VERSALIEN => Gibt es bisher noch nicht?! -->
		<span class="versalie">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="tei:seg[@type='numDenom'][@rend='coloured']">
		<span class="rend-coloured">
			<xsl:apply-templates />
		</span>
	</xsl:template>

	<xsl:template match="tei:seg[@type='numDenom'][@rend='default']">
		<span class="rend-default">
			<xsl:apply-templates />
		</span>
	</xsl:template>

<!-- ambig1 -->
	<xsl:template match="tei:seg[@type='numDenom'][not(@rend)]">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tei:seg[@type='num'][@rend='coloured']">
		<span class="rend-coloured">
			<xsl:apply-templates />
		</span>
	</xsl:template>

	<xsl:template match="tei:seg[@type='num'][@rend='default']">
		<span class="rend-default">
			<xsl:apply-templates />
		</span>
	</xsl:template>

<!-- ambig2 -->
	<xsl:template match="tei:seg[@type='num'][not(@rend)]">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tei:cit">
		<xsl:apply-templates select="tei:quote"/>
		<xsl:apply-templates select="tei:ref"/>
	</xsl:template>

	<xsl:template match="tei:cit/tei:quote">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<!-- nicht verarbeiten -->
	<xsl:template match="tei:cit/tei:ref" />
	

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
			<xsl:when test="@type='internal' and @subtype='mss'">
				<a>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:attribute name="title">Interner Link</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$mss"/>
						<xsl:value-of select="@target"/>
					</xsl:attribute>
					<xsl:apply-templates/>
					<xsl:if test="string-length(node())=0">
						<xsl:text>→</xsl:text>
					</xsl:if>
				</a>
			</xsl:when>
			<!-- mögliche andere Fälle wären Personen oder Orte - Normdaten! -->
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:handShift">
		<!-- Verweis/Hyperlink auf Fußnote setzen -->
		<xsl:call-template name="tFunoVerweis_alphabetisch">
			<xsl:with-param name="pBezug" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="//tei:body//tei:note[not(@type='editorial')]">
		<span class="annotation annotation-not-editorial">
		  <xsl:call-template name="footnote"/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:body//tei:note[@type='editorial'][not(@target)]">
		<span class="annotation annotation-editorial">
		  <xsl:call-template name="footnote"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:note[@type='editorial'][@target]">
		<!-- als Teil von "Erstreckungsfußnote" -->
		<xsl:call-template name="footnote-ref" />
	</xsl:template>


	<xsl:template match="tei:note[@type='comment']">
		<span class="annotation annotation-comment">
		  <xsl:call-template name="footnote"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:sic">

		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates select="node()"/>
		<xsl:text> [!]</xsl:text>

	</xsl:template>

	<!-- <subst> -->

	<xsl:template match="tei:subst">

		<!-- prüft, ob <note> folgt -->
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

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:variable name="vAddRendColour">
			<xsl:choose>
				<xsl:when test="tei:add/@rend='coloured'">
					<span class="rend-coloured">
						<xsl:apply-templates select="tei:add"/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="tei:add"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not(tei:add/@hand)">
				<!-- keine Hand -->
				<xsl:copy-of select="$vAddRendColour"/>
			</xsl:when>
			<xsl:when test="string-length(tei:add/@hand)!=string-length(translate(tei:add/@hand,$vHandABC,''))">
				<!-- entspricht "normaler" Hand -->
				<xsl:copy-of select="$vAddRendColour"/>
			</xsl:when>
			<xsl:when test="string-length(tei:add/@hand)!=string-length(translate(tei:add/@hand,$vHandXYZ,''))">
				<!-- entspricht "spezieller" Hand -->
				<xsl:apply-templates select="tei:del"/>
			</xsl:when>
		</xsl:choose>

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

		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<!-- nachfolgende <note> setzt Fußnotenverweis -->

				<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
					<xsl:apply-templates select="tei:del"/>
				</xsl:if>

			</xsl:when>
			<xsl:otherwise>
				<!-- keine nachfolgende <note> -->

				<!-- Verweis/Hyperlink auf Fußnote setzen -->
				<xsl:call-template name="tFunoVerweis_alphabetisch">
					<xsl:with-param name="pBezug" select="$vBezug"/>
				</xsl:call-template>
		
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:subst/tei:add">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:subst/tei:del">

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:choose>
			<xsl:when test="string-length(parent::tei:subst/tei:add/@hand)!=string-length(translate(parent::tei:subst/tei:add/@hand,$vHandABC,''))">
				<!-- entspricht normaler Hand -->

				<xsl:apply-templates/>

			</xsl:when>
			<xsl:when test="string-length(parent::tei:subst/tei:add/@hand)!=string-length(translate(parent::tei:subst/tei:add/@hand,$vHandXYZ,''))">
				<!-- entspricht spezieller Hand -->

				<!-- => Platzhalter einfügen, falls <del> leer ist -->

				<xsl:choose>
					<xsl:when test="count(node())=0">
						<!-- <del/> -->
						<xsl:text>[+]</xsl:text>
					</xsl:when>
					<xsl:when test="normalize-space(node())=''">
						<!-- <del></del> -->
						<xsl:text>[+]</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- <del>[...]</del> -->
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- keine Hand angegeben -->

				<xsl:apply-templates/>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- </subst> -->

	<!-- <add> -->

	<xsl:template match="tei:add[not(parent::*[local-name(.)='subst'] and not(parent::*[local-name(.)='num']))]">

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

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

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

		<xsl:variable name="vAddRendColour">
			<xsl:choose>
				<xsl:when test="@rend='coloured'">
					<span class="rend-coloured">
						<xsl:apply-templates select="node()"/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<!-- <note> folgt => Fußnote wird bereits gesetzt -->

				<xsl:choose>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- Hand XYZ -->

					</xsl:when>
					<xsl:otherwise>
						<!-- nicht Hand XYZ -->
						<xsl:copy-of select="$vAddRendColour"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<!-- es folgt keine <note> = automatische Fußnote wird generiert -->

				<xsl:choose>
					<xsl:when test="not(@hand)">
						<!-- keine Hand -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->
								<xsl:copy-of select="$vAddRendColour"/>
							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->
								<xsl:copy-of select="$vAddRendColour"/>
							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->
								<xsl:copy-of select="$vAddRendColour"/>
							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->
								<xsl:copy-of select="$vAddRendColour"/>
							</xsl:when>
							<xsl:otherwise>
								<span class="debug">
									<xsl:text>{TEST-add-FEHLER-hand0-lz:</xsl:text>
									<xsl:text>$vLeerzeichenDavor=</xsl:text><xsl:value-of select="$vLeerzeichenDavor"/>
									<xsl:text>|</xsl:text>
									<xsl:text>$vLeerzeichenDanach=</xsl:text><xsl:value-of select="$vLeerzeichenDanach"/>
									<xsl:text>###</xsl:text>
									<xsl:value-of select="preceding-sibling::text()[1]"/>
									<xsl:text>|</xsl:text>
									<xsl:value-of select="following-sibling::text()[1]"/>
									<xsl:text>}</xsl:text>
								</span>
							</xsl:otherwise>
						</xsl:choose>

						<!-- Verweis/Hyperlink auf Fußnote setzen -->
						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- entspricht "normaler" Hand -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->

								<xsl:copy-of select="$vAddRendColour"/>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->

								<xsl:copy-of select="$vAddRendColour"/>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->
								<xsl:copy-of select="$vAddRendColour"/>
							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->
								<xsl:copy-of select="$vAddRendColour"/>
							</xsl:when>
							<xsl:otherwise>
								<span class="debug"><xsl:text>{TEST-add-FEHLER-handABC-lz}</xsl:text></span>
							</xsl:otherwise>
						</xsl:choose>

						<!-- Verweis/Hyperlink auf Fußnote setzen -->
						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- entspricht "spezieller" Hand -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->

								<xsl:call-template name="tFunoVerweis_alphabetisch">
									<xsl:with-param name="pBezug" select="$vBezug"/>
								</xsl:call-template>

							</xsl:when>
							<xsl:otherwise>
								<span class="debug"><xsl:text>{TEST-add-FEHLER-handXYZ-lz}</xsl:text></span>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:when>
					<xsl:otherwise>
						<span class="debug"><xsl:text>{TEST-add-FEHLER-hand?}</xsl:text></span>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- </add> -->

	<!-- <mod> -->

	<xsl:template match="tei:mod">
		<!-- prüfen, ob <note> folgt -->
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

		<xsl:apply-templates select="node()"/>

		<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">
			<!-- Fußnote wird nicht durch <note> übernommen => Verweis/Hyperlink auf Fußnote setzen -->
			<xsl:call-template name="tFunoVerweis_alphabetisch">
				<xsl:with-param name="pBezug" select="."/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<!-- </mod> -->


	<xsl:template match="tei:num">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
<!--	<!-\- ambig3 -\->
	<xsl:template match="tei:num/tei:hi[@rend='super']">
		<super>
			<xsl:apply-templates select="node()"/>
		</super>
	</xsl:template>-->

	<xsl:template match="tei:del[not(parent::*[local-name(.)='subst'])]">

		<!-- prüfen, ob <note> folgt -->
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

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:choose>
			<xsl:when test="count(node())=0">
				<!-- Sonderfall bei <del>:  leeres Element -->

				<!-- "+" entsprechend @quantity ausgeben -->
				<xsl:call-template name="tPrintXtimes">
					<xsl:with-param name="pPrintWhat" select="'+'"/>
					<xsl:with-param name="pPrintHowManyTimes" select="current()/@quantity"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:when test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<!-- Note folgt => Fußnote wird darüber erzeugt -->

				<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
					<xsl:apply-templates select="node()"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not(@hand)">
						<!-- ohne Hand -->

						<!-- Verweis/Hyperlink auf Fußnote setzen -->
						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="."/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- normale Hand -->
						
						<!-- Verweis/Hyperlink auf Fußnote setzen -->
						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="."/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- spezielle Hand -->
						<xsl:apply-templates select="current()/node()"/>

						<!-- Verweis/Hyperlink auf Fußnote setzen -->
						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="."/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<span class="debug"><xsl:text>{FEHLER in del}</xsl:text></span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:abbr">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:choice">

		<!-- prüfen, ob ein <note> folgt -->
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

		<!-- Inhalt von <expan> ausgeben -->
		<xsl:apply-templates select="tei:expan/node()"/>


		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
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

	<xsl:template match="tei:unclear[count(tei:gap)>0]">
		<xsl:text>...</xsl:text>

		<!-- Verweis/Hyperlink auf Fußnote setzen -->
		<xsl:call-template name="tFunoVerweis_alphabetisch">
			<xsl:with-param name="pBezug" select="."/>
		</xsl:call-template>

	</xsl:template>

	<xsl:template match="tei:unclear[count(tei:gap)=0]">
		<xsl:text>[</xsl:text>
			<xsl:apply-templates select="node()"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="tei:gap">
		<!-- erzeugt "[ . . . ]" mit Anzahl "." entsprechend @quantity -->
		<xsl:text>[</xsl:text>
		<xsl:call-template name="tPrintXtimes">
			<xsl:with-param name="pPrintWhat" select="' .'"/>
			<xsl:with-param name="pPrintHowManyTimes" select="current()/@quantity"/>
		</xsl:call-template>
		<xsl:text> ]</xsl:text>
	</xsl:template>

	<xsl:template match="tei:expan">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:ex">
		<span class="italic">
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

		<xsl:text> - - - </xsl:text>

		<xsl:choose>
			<xsl:when test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
				<!-- kein Verweis, falls noch <note> (=eigener Verweis) folgt -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="tFunoVerweis_alphabetisch">
					<xsl:with-param name="pBezug" select="."/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:date">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:locus">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:rs">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:rs[@type='person']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:rs[@type='place']">
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

<!-- ambig3 -->
	<xsl:template match="tei:hi[@rend='super']">
		<sup class="tei-super">
			<xsl:apply-templates />
		</sup>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='coloured']">
		<span class="rend-coloured">
			<!-- Baustelle: Klasse für "rote" span?! -->
			<xsl:apply-templates />
		</span>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='default']">
		<!-- Baustelle: Klasse für "default" span?! -->
		<span class="rend-default">
			<xsl:apply-templates />
		</span>
	</xsl:template>

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

	<!-- 27.01.16: neues Element "figure" -->
	<xsl:template match="tei:figure">
		<!--
		Neues Element: figure; wie verarbeiten? (bm 21.01.16) – Markiert eine Stelle, an der eine Miniatur/Illustration in der Handschrift steht.
		Kommt nur selten vor; kann leer sein (evtl. mit graphic url) oder mit Text, der als Fußnote ausgegeben werden soll.
		Eigentlich brauchen wir nur ein Symbol für “Bild”, das an der entsprechenden Stelle erscheint. (bm 26.01.16)
		(NG, 27.01.16: Gibt es hierbei auch die “Hand-X-Problematik”?)
		-->
<!--		<span title="WIP: Platzhalter für Bild">
			<xsl:text>{Bild}</xsl:text> <!-\- testweise/Platzhalter -\->
		</span>-->
<!--		<span title="WIP: Platzhalter für Bild">
			<span class="dashicons dashicons-format-image"></span> <!-\- WordPress-Icon setzen -\->
		</span>-->
		
		<xsl:variable name="vIcon">
			<xsl:value-of select="$pFigureIcon"/>
		</xsl:variable>


		<xsl:choose>
			<xsl:when test="tei:graphic/@url">
				<!-- @url vorhanden => Link erzeugen -->
				<a>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:attribute name="title">
						<xsl:choose>
							<xsl:when test="tei:figDesc">
								<xsl:value-of select="tei:figDesc"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Platzhalter für Bild</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="tei:graphic/@url"/>
					</xsl:attribute>
					<span>
						<xsl:attribute name="class">
							<xsl:value-of select="$vIcon"/>
						</xsl:attribute>
					</span> <!-- WordPress-Icon setzen -->
				</a>
			</xsl:when>
			<xsl:otherwise>
				<!-- keine @url vorhanden => nur Icon setzen -->
				<span>
					<xsl:attribute name="class">
						<xsl:value-of select="$vIcon"/>
					</xsl:attribute>
					<xsl:attribute name="title">
						<xsl:choose>
							<xsl:when test="tei:figDesc">
								<xsl:value-of select="tei:figDesc"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Platzhalter für Bild</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</span> <!-- WordPress-Icon setzen -->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="*">
		<!-- für bisher unverarbeitete Elemente -->
		
		<!-- Fehler auswerfen: Element, Parent und gegebenenfalls Attribute -->
		<ERROR>
			<xsl:comment>
				<xsl:text>ERROR: element '</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>' not handled</xsl:text>
				<!-- parent ausgeben -->
				<xsl:text> (parent:</xsl:text>
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(parent::*)"/>
				<xsl:text>)</xsl:text>
				<!-- gegebenenfalls Attribute mit Werten ausgeben -->
				<xsl:if test="@*">
					<xsl:text> (attributes:</xsl:text>
					<xsl:for-each select="@*">
						<xsl:text> </xsl:text>
						<xsl:value-of select="local-name()"/>
						<xsl:text>=</xsl:text>
						<xsl:value-of select="."/>
					</xsl:for-each>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:comment>
			<xsl:apply-templates/>
			<xsl:comment>
				<xsl:value-of select="local-name()"/>
			</xsl:comment>
		</ERROR>
	</xsl:template>

</xsl:stylesheet>
