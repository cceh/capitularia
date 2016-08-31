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

        <xsl:include href="xsl-output.xsl"/>

	<!-- author: NG -->
	<xsl:include href="allgFunktionen.xsl"/>                 <!-- allgemeine Funktionen (string-replace etc.) -->
	<xsl:include href="transkription_ZusatzFunktionen.xsl"/> <!-- zusätzliche Funktionen (tNoteFolgt etc.) -->
	<xsl:include href="transkription_PublWP_Variablen.xsl"/> <!-- globale Variablen -->
	<xsl:include href="transkription_PublWP_Style.xsl"/>     <!-- CSS für Darstellung der Ausgabe -->
	<xsl:include href="transkription_PublWP_Fussnoten.xsl"/> <!-- Verarbeitung/Darstellung der Fußnoten(-Texte) -->
	<xsl:include href="base_variables.xsl"/> <!--  -->

	<xsl:key name="kSubst_Liste" match="//tei:subst" use="generate-id(.)"/>
	<xsl:key name="kAdd_Liste" match="//tei:add" use="generate-id(.)"/>
	<xsl:key name="kDel_Liste" match="//tei:del" use="generate-id(.)"/>
	<xsl:key name="kMod_Liste" match="//tei:mod" use="generate-id(.)"/>

	<xsl:key name="kSic_Liste" match="//tei:sic" use="generate-id(.)"/>

	<xsl:key name="kSpace_Liste" match="//tei:space" use="generate-id(.)"/>

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
							<xsl:if test="//tei:msDesc"><h5 id="editorial-preface" data-cap-dyn-menu-caption="[:de]Editorische Vorbemerkung[:en]Editorial Preface[:]">[:de]Editorische Vorbemerkung zur Transkription[:en]Editorial Preface to the Transcription[:]</h5></xsl:if>
							<div class="encodingDesc">
								<xsl:apply-templates select="//tei:text/tei:front/tei:div[normalize-space (.)]"/>
							</div>
							<xsl:apply-templates select="//tei:sourceDesc"/>
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

<!--		<span class="PublikationAenderung">
			<xsl:text>(</xsl:text>
			<xsl:apply-templates select="//tei:publicationStmt/tei:date"/>
			<xsl:apply-templates select="//tei:revisionDesc/tei:change[last()]"/>
			<!-\-<xsl:apply-templates select="//tei:revisionDesc/tei:change"/>-\->

			<xsl:text> - HTML generiert am </xsl:text>
			<xsl:variable name="vCurrentDate_DD-MM-YYYY">
				<xsl:variable name="vCurrentDate_YYY-MM-DD">
					<xsl:call-template name="tCurrentDate"/>
				</xsl:variable>

				<xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
					<xsl:with-param name="pDate_YYYY-MM-DD" select="$vCurrentDate_YYY-MM-DD"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$vCurrentDate_DD-MM-YYYY"/>
			<xsl:text>)</xsl:text>
		</span>-->
	</xsl:template>


	<xsl:template match="tei:front/tei:div[normalize-space (.)]">
	  <div class="italic tei-front-div">
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
				<xsl:with-param name="pDate1_YYYY-MM-DD" select="//tei:publicationStmt/tei:date/@when"/>
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
	  <div class="italic tei-encodingDesc">
	    <xsl:apply-templates />
	  </div>
	</xsl:template>

	<xsl:template match="tei:p">
	  <p class="tei-p">
	    <xsl:apply-templates/>
	  </p>
	</xsl:template>

	<xsl:template match="tei:projectDesc"/>
	<xsl:template match="tei:editorialDecl"/>
	<xsl:template match="tei:revisionDesc"/>
	<xsl:template match="tei:sourceDesc"/>

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

		<div class="abTEXT" lang="la" data-shortcuts="1">
			<xsl:attribute name="id">
				<xsl:value-of select="@xml:id"/>
			</xsl:attribute>

			<xsl:apply-templates/>
		</div>

		<!-- The post-processing php script will move all
		     preceding footnotes into this container. -->
		<div class="footnotes-wrapper" lang="la" />

		<xsl:call-template name="page-break" />

	</xsl:template>

	<xsl:template match="tei:body/tei:ab[@type='meta-text']">
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

		<div class="abMETA" lang="la" data-shortcuts="1">
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

	<!--<xsl:template match="//tei:seg[@type[.='titulus' or .='numDenom' or .='num']][@rend[.='majuscule red']]"> 19.12.2014-->
	<!--<xsl:template match="//tei:seg[@type[.='titulus' or .='numDenom' or .='num']][@rend[.='red']]"> 19.12.2014-->

	<xsl:template match="//tei:seg[@type[.='numDenom' or .='num']]">
		<xsl:apply-templates/>
	</xsl:template>

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

		<span class="folio" data-shortcuts="0">
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
	  <span id="{@n}" class="milestone"><span style="display: none"><xsl:value-of select="str:replace (substring-before (concat (@n, '_'), '_'), '.', ' ')"/></span></span>
	</xsl:template>


	<!-- Typ-Unterscheidung hinzufügen!!! -->
	<!--
            Die einzelnen Typen sollen optisch unterscheidbar sein, ohne daß man Farbe verwenden muß.
            Alle größer und fett; zusätzlich zur Unterscheidung verschiedene Größen/Schrifttypen?
        -->
	<!--<xsl:template match="//tei:seg[substring-before(@type,'-')='initial']">-->
	<!--<xsl:template match="//tei:seg[string-length(translate(@type,'initial',''))!=string-length(@type)]">-->
	<xsl:template match="tei:seg[@type='initial']">
		<span class="initial">
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
			<span class="initialABC">
				<!--<xsl:value-of select="."/>-->
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

	<xsl:template match="tei:seg[@type='num'][not(@rend)]">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tei:cit">
		<xsl:apply-templates select="tei:quote"/>
		<xsl:apply-templates select="tei:ref"/>
	</xsl:template>

	<xsl:template match="tei:cit/tei:quote">
<!--	06.01.2016	<span class="quote">
			<xsl:text>&#8222;</xsl:text>
		</span>
		<xsl:apply-templates select="./node()"/>
		<span class="quote">
			<xsl:text>&#8220;</xsl:text>
		</span>-->

		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:cit/tei:ref">
<!--	06.01.2016	<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="//tei:cit/tei:ref"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>

		<span class="annotation annotation-cit-ref">
		  <xsl:call-template name="footnote" />
		</span>-->
	</xsl:template>

	<!-- Hinzufügung durch DT am 27.08.2014, um auf externe Ressourcen wie die dMGH verlinken zu können (modifiziert durch NG am 04.09.2014: um mehrdeutige Regeln zu beseitigen => [@type] => tei:ref auf type-Attribut prüfen - Template muss möglicherweise noch ansich mit anderem ref-Template abgeglichen/angepasst werden)  -->
	<xsl:template match="tei:ref[@type='external']">
	  <a>
	    <xsl:attribute name="target">_blank</xsl:attribute>
	    <xsl:attribute name="title">Externer Link</xsl:attribute>
	    <xsl:attribute name="href">
	      <xsl:value-of select="@target"/>
	    </xsl:attribute>
	    <xsl:apply-templates/>
	  </a>
	</xsl:template>

	<xsl:template match="tei:ref[@type='internal' and @subtype='mss']">
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
	</xsl:template>

	<xsl:template match="tei:handShift">

		<xsl:call-template name="tFunoVerweis_alphabetisch">
			<xsl:with-param name="pBezug" select="."/>
		</xsl:call-template>

	</xsl:template>


	<!--<xsl:template match="//tei:note[not(@type='editorial')]">-->
	<xsl:template match="//tei:body//tei:note[not(@type='editorial')]">
		<xsl:variable name="vIndex">
<!--			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>-->
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>

		<span class="annotation annotation-not-editorial">
		  <xsl:call-template name="footnote"/>
		</span>

	</xsl:template>

	<!--<xsl:template match="//tei:note[@type='editorial'][not(@target)]">-->
	<xsl:template match="//tei:body//tei:note[@type='editorial'][not(@target)]">
		<xsl:variable name="vIndex">
<!--			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>-->
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>

		<span class="annotation annotation-editorial">
		  <xsl:call-template name="footnote"/>
		</span>

	</xsl:template>

	<xsl:template match="tei:note[@type='editorial'][@target]">
		<!-- als Teil von "Erstreckungsfußnote" -->
		<xsl:variable name="vIndex">
<!--			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>-->
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

		<xsl:call-template name="footnote-ref" />
	</xsl:template>


	<xsl:template match="tei:note[@type='comment']">
		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vBezug" select="."/>

		<span class="annotation annotation-comment">
		  <xsl:call-template name="footnote"/>
		</span>

	</xsl:template>

	<xsl:template match="tei:sic">
	  <xsl:apply-templates />
	  <span class="tei-sic" data-shortcuts="0">
	    <xsl:text> [!]</xsl:text>
	  </span>
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
<!-\-			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>-\->
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<!--<span class="debug"><xsl:text>{subst}</xsl:text></span>-->


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
<!--				<xsl:choose>
					<xsl:when test="tei:add/@rend='coloured'">
						<span class="rend-coloured">
							<xsl:apply-templates select="tei:add"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:add"/>
					</xsl:otherwise>
				</xsl:choose>-->
			</xsl:when>
			<xsl:when test="string-length(tei:add/@hand)!=string-length(translate(tei:add/@hand,$vHandABC,''))">
				<!-- entspricht "normaler" Hand -->
				<xsl:copy-of select="$vAddRendColour"/>
<!--				<xsl:choose>
					<xsl:when test="tei:add/@rend='coloured'">
						<span class="rend-coloured">
							<xsl:apply-templates select="tei:add"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:add"/>
					</xsl:otherwise>
				</xsl:choose>-->
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


				<xsl:call-template name="tFunoVerweis_alphabetisch">
					<xsl:with-param name="pBezug" select="$vBezug"/>
				</xsl:call-template>
				<!--
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
					<xsl:when test="$vNumNoteFolgt='true'">
						<!-\- falls innerhalb von <num> && <note> folgt diesem <num> => keine Funo erzeugen und normal verarbeiten! -\->
							<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
								<xsl:apply-templates select="tei:del"/>
							</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-\- nicht in <num> oder in <num> ohne <note> => Funo erzeugen -\->
						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>-->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:subst/tei:add">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:subst/tei:del">
		<!--<xsl:apply-templates/>-->

		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<!-- string-length(@hand)!=string-length(translate(@hand,$vHandABC,'')) -->

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

<!--		<xsl:choose>
			<xsl:when test="count(node())=0">
				<!-\- <del/> -\->

				<!-\- TESTWEISE -\->
				<xsl:text>{del/}</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space(node())=''">
				<!-\- <del></del> -\->

				<!-\- TESTWEISE -\->
				<xsl:text>{del/del}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-\- <del>[...]</del> -\->
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>-->
	</xsl:template>

	<!-- </subst> -->

	<!-- <add> -->

	<xsl:template match="tei:add[not(parent::*[local-name(.)='subst'] and not(parent::*[local-name(.)='num']))]">
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
<!-\-			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>-\->
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->

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


<!--				<xsl:if test="not(string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,'')))">
					<xsl:apply-templates select="node()"/>
				</xsl:if>-->


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
						<xsl:copy-of select="$vAddRendColour"/>
<!--						<xsl:choose>
							<xsl:when test="@rend='coloured'">
								<span class="rend-coloured">
									<xsl:apply-templates select="node()"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="node()"/>
							</xsl:otherwise>
						</xsl:choose>-->
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
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->
								<xsl:copy-of select="$vAddRendColour"/>
<!--								<xsl:choose>
									<xsl:when test="@rend='coloured'">
										<span class="rend-coloured">
											<xsl:apply-templates select="node()"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="node()"/>
									</xsl:otherwise>
								</xsl:choose>-->

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->
								<xsl:copy-of select="$vAddRendColour"/>
<!--								<xsl:choose>
									<xsl:when test="@rend='coloured'">
										<span class="rend-coloured">
											<xsl:apply-templates select="node()"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="node()"/>
									</xsl:otherwise>
								</xsl:choose>-->

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- befindet sich am Wortende (Leerzeichen danach) -->
								<xsl:copy-of select="$vAddRendColour"/>
<!--								<xsl:choose>
									<xsl:when test="@rend='coloured'">
										<span class="rend-coloured">
											<xsl:apply-templates select="node()"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="node()"/>
									</xsl:otherwise>
								</xsl:choose>-->

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine (Leerzeichen davor und Leerzeichen danach) -->
								<xsl:copy-of select="$vAddRendColour"/>
<!--								<xsl:choose>
									<xsl:when test="@rend='coloured'">
										<span class="rend-coloured">
											<xsl:apply-templates select="node()"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="node()"/>
									</xsl:otherwise>
								</xsl:choose>-->

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

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>
						<!--
						<xsl:choose>
							<xsl:when test="$vNoteFolgt='true'">
								<!-\- nachfolgende <note> setzt Fußnotenverweis -\->

								<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
									<xsl:apply-templates select="tei:del"/>
								</xsl:if>

							</xsl:when>
							<xsl:otherwise>
								<!-\- keine nachfolgende <note> -\->
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
									<xsl:when test="$vNumNoteFolgt='true'">
										<!-\- falls innerhalb von <num> && <note> folgt diesem <num> => keine Funo erzeugen und normal verarbeiten! -\->
										<xsl:if test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
											<xsl:apply-templates select="tei:del"/>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<!-\- nicht in <num> oder in <num> ohne <note> => Funo erzeugen -\->
										<xsl:call-template name="tFunoVerweis_alphabetisch">
											<xsl:with-param name="pBezug" select="$vBezug"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>-->

					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
						<!-- entspricht "normaler" Hand -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- befindet sich in Wort (kein Leerzeichen davor und kein Leerzeichen danach -->

								<xsl:copy-of select="$vAddRendColour"/>

<!--								<xsl:choose>
									<xsl:when test="@rend='coloured'">
										<span class="rend-coloured">
											<xsl:apply-templates select="node()"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="node()"/>
									</xsl:otherwise>
								</xsl:choose>-->

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- befindet sich am Wortanfang (Leerzeichen davor) -->

								<xsl:copy-of select="$vAddRendColour"/>
<!--								<xsl:choose>
									<xsl:when test="@rend='coloured'">
										<span class="rend-coloured">
											<xsl:apply-templates select="node()"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="node()"/>
									</xsl:otherwise>
								</xsl:choose>-->

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

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
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
									<!-- Element ist erstes Element (nach text()) -->
									<xsl:if
										test="normalize-space(preceding-sibling::node())=''">
										<!-- vorher nur Whitespace -->
										<!--<xsl:text>#</xsl:text>-->
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

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
		<!--<xsl:text>{mod}</xsl:text> <!-\- TESTWEISE -\->-->

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

		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="."/>

		<!-- Text für Tooltip erstellen -->
<!--		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>-->

<!--		<xsl:variable name="vIndex">
<!-\-			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>-\->
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->

		<xsl:apply-templates select="node()"/>

		<xsl:if test="$vNoteFolgt='false' and $vNumNoteFolgt='false'">

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


<!--		<!-\- TESTWEISE -\->
		<xsl:if test="current()='h'">
			<xsl:variable name="test" select="''"></xsl:variable>
		</xsl:if>-->


		<xsl:choose>
			<xsl:when test="count(./node())=0">
				<!-- Sonderfall bei <del>:  leeres Element -->
				<!-- Bezugsknoten -->

				<xsl:call-template name="tPrintXtimes">
					<xsl:with-param name="pPrintWhat" select="'+'"/>
					<xsl:with-param name="pPrintHowManyTimes" select="current()/@quantity"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:when test="$vNoteFolgt='true' or $vNumNoteFolgt='true'">
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

<!--						<!-\- Text für Tooltip erstellen -\->
						<xsl:variable name="vFunoText">
							<xsl:call-template name="tFunoText_alphabetisch">
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:variable name="vIndex">
							<xsl:call-template name="indexOf_a">
								<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>-->

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandABC,''))">
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

<!--						<!-\- Text für Tooltip erstellen -\->
						<xsl:variable name="vFunoText">
							<xsl:call-template name="tFunoText_alphabetisch">
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:variable name="vIndex">
							<xsl:call-template name="indexOf_a">
								<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>-->

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when test="string-length(@hand)!=string-length(translate(@hand,$vHandXYZ,''))">
						<!-- spezielle Hand -->
						<xsl:apply-templates select="current()/node()"/>

						<!-- Bezugsknoten -->
						<xsl:variable name="vBezug" select="."/>

<!--						<!-\- Text für Tooltip erstellen -\->
						<xsl:variable name="vFunoText">
							<xsl:call-template name="tFunoText_alphabetisch">
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:variable name="vIndex">
							<xsl:call-template name="indexOf_a">
								<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
								<xsl:with-param name="pNode" select="$vBezug"/>
							</xsl:call-template>
						</xsl:variable>-->

						<xsl:call-template name="tFunoVerweis_alphabetisch">
							<xsl:with-param name="pBezug" select="$vBezug"/>
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

		<xsl:apply-templates select="./tei:expan/node()"/>


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


		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="."/>

<!--		<!-\- Text für Tooltip erstellen -\->
		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vIndex">
<!-\-			<xsl:call-template name="indexOf_a">
				<!-\\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>-\->
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="$funoNumerisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>-->

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
<!--		<i>
			<xsl:apply-templates select="node()"/>
		</i>-->
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

	<xsl:template match="tei:rs">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:rs[@type='person']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:rs[@type='place']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

<!--	persName / persPlace durch tei:rs ersetzt!

		<xsl:template match="tei:persName">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:placeName">
		<xsl:apply-templates select="node()"/>
	</xsl:template>-->

	<xsl:template match="tei:fw[@type='catch']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<!-- Umwandlung Platzhalter (Mittelpunkt etc.)
	     Wird jetzt in footnotes-post-processor.php gemacht.
	<xsl:template match="text()[ancestor::tei:ab][not(ancestor::tei:note)][not(ancestor::tei:ref)]">

		<xsl:variable name="tText">
			<xsl:call-template name="tPlatzhalterVerarbeiten">
				<xsl:with-param name="pText" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$tText"/>
	</xsl:template>
	-->

	<xsl:template match="tei:metamark">
	  <!-- metamark vorerst ignorieren -->
	</xsl:template>

	<xsl:template match="tei:hi[@rend='super']">
	  <sup class="tei-hi rend-super">
	    <xsl:apply-templates />
	  </sup>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='sub']">
	  <sub class="tei-hi rend-sub">
	    <xsl:apply-templates />
	  </sub>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='coloured']">
	  <!-- Baustelle: Klasse für "rote" span?! -->
	  <span class="tei-hi rend-coloured">
	    <xsl:apply-templates />
	  </span>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='default']">
	  <!-- Baustelle: Klasse für "default" span?! -->
	  <span class="tei-hi rend-default">
	    <xsl:apply-templates />
	  </span>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='italic']">
	  <span class="tei-hi rend-italic italic">
	    <xsl:apply-templates />
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



		<!-- BAUSTELLE/ToDo: für den Fall, dass kein @target vorhanden, dann kein Link, sondern nur Icon! -->
		<xsl:choose>
			<xsl:when test="tei:graphic/@url">
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
					<span class="dashicons dashicons-format-image"></span> <!-- WordPress-Icon setzen -->
				</a>
			</xsl:when>
			<xsl:otherwise>
				<span class="dashicons dashicons-format-image">
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
<!--		<ERROR>
			<xsl:comment>
				<xsl:text>ERROR: element '</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>' not handled</xsl:text>
			</xsl:comment>
			<xsl:apply-templates/>
			<xsl:comment>
				<xsl:value-of select="local-name()"/>
			</xsl:comment>
		</ERROR>-->

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









<!--	<xsl:template name="tSubstringAfterLast">
		<!-\- if there are more than one occurences of pString2 (e.g. a delimiter) => gives out the last substring-after in pString => kinda like substring-before() the other way around -\->
		<xsl:param name="pString"/> <!-\- the whole string which holds the substring -\->
		<xsl:param name="pString2"/> <!-\- e.g. a delimiter -\->

		<xsl:choose>
			<xsl:when test="contains($pString,$pString2)">
				<!-\- pString contains a pString2 -\->

				<!-\- get the susbtring-after() -\->
				<xsl:variable name="vSubstringAfter" select="substring-after($pString,$pString2)"/>

				<!-\- is this really the last substring-after? -\->
				<xsl:choose>
					<xsl:when test="contains($vSubstringAfter,$pString2)">
						<!-\- there's another pString2 in pString after the current pString2 => this isn't the last (=wanted) substring in pString -\->
						<!-\- => Rekursion => tSubstringAfterLast nochmals mit gekürztem String aufrufen -\->
						<!-\- => hurray for recursion -\->
						<xsl:call-template name="tSubstringAfterLast">
							<xsl:with-param name="pString" select="$vSubstringAfter"/>
							<xsl:with-param name="pString2" select="$pString2"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-\- reached the last substring-after -\->
						<xsl:value-of select="$vSubstringAfter"/> <!-\- give out the last substring-after -\->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-\- pString doesn't contain a pString2 at all -\->
				<xsl:text></xsl:text> <!-\- give out empty string -\->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->

</xsl:stylesheet>
