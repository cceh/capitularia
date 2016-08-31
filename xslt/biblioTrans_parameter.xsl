<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:str="http://exslt.org/strings"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- allgemeine Funktionen -->
	<xsl:include href="allgFunktionen.xsl"/>

	<!-- allgemeine Parameter -->
	<xsl:variable name="vParams" select="document('biblioParams.xml')"/>

	<!-- use values: all/published/unpublished -->
	<xsl:param name="pShow">all</xsl:param>
	
	<!-- use values: y/n -->
	<xsl:param name="pEmbedded">y</xsl:param>
	
	<!-- use values: y/n -->
	<xsl:param name="pIdnoAsShortcode">y</xsl:param>
	
	<!-- use values: y/n -->
	<xsl:param name="pPublic">y</xsl:param>
	
	<!-- use values: all/edi/lit/cat -->
	<xsl:param name="pCategory">all</xsl:param>

	<!-- use values: [chunk number].[chunk size] default: 0.0 (=show all) -->
	<xsl:param name="pSplit">0.0</xsl:param>
	
	<!-- change for local use (e.g. in oxygen) => str:encode-uri wrapped in if-clause -->
	<xsl:param name="pUseLocally">no</xsl:param>

	<xsl:variable name="vDigitalisatePfad">
		<!--<xsl:text>../hss-scans</xsl:text>-->
		<xsl:value-of
			select="$vParams/list[@xml:id='paths']/item[./title/text()='Digitalisate']/path/text()"
		/>
	</xsl:variable>
	<xsl:variable name="vTransformationenPfad">
		<!--<xsl:text>../hss-scans</xsl:text>-->
		<xsl:value-of
			select="$vParams/list[@xml:id='paths']/item[./title/text()='Transformationen']/path/text()"
		/>
	</xsl:variable>


	<!-- short_title als key! -->
	<xsl:key name="kEditionen" match="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']]" use="tei:monogr/tei:idno[@type='short_title'] | tei:analytic/tei:idno[@type='short_title']"/>
	<xsl:key name="kLiteratur" match="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']]" use="tei:monogr/tei:idno[@type='short_title'] | tei:analytic/tei:idno[@type='short_title']"/>
	<xsl:key name="kHandschriftenkataloge" match="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]" use="tei:monogr/tei:idno[@type='short_title'] | tei:analytic/tei:idno[@type='short_title']"/>
	<xsl:key name="kSonstige" match="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']]" use="tei:monogr/tei:idno[@type='short_title'] | tei:analytic/tei:idno[@type='short_title']"/>


	<!-- Variablen für die einzelnen Kategorien -->
	<xsl:variable name="vEditionen_L"
		select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']]" />
	<xsl:variable name="vLiteratur_L"
		select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']]" />
	<xsl:variable name="vHandschriftenkataloge_L"
		select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]" />
	<xsl:variable name="vSonstige_L"
		select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']]" />
	



<!-- BAUSTELLEN/ToDO:
	* leere Elemente (text()='' OR text()='-') behandeln! => pubPlace='-', biblScope='-'
	* xsl:key einbauen?! notwendig??
	* ...
	-->


	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$pEmbedded='y'">
				<div id="bibliographie">
					<xsl:call-template name="tBibliographie"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<html>
					<head>

						<title>Bibliographie Capitularia</title>
						<meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
						<meta content="Bibliographie" name="Eintraege"/>

					</head>
					<body>
						<xsl:call-template name="tBibliographie"/>
					</body>
				</html>
			</xsl:otherwise>
		</xsl:choose>



	</xsl:template>


	<xsl:template name="tBibliographie">
		<!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <biblStruct> -->

		
		<!-- calculate chunk size, chunk start position & end position (first & last item) -->
		<xsl:variable name="vChunkSize">
			<xsl:choose>
				<xsl:when test="$pSplit='0.0'">
					<!-- calculate some sort of maximum size... (REMINDER: find a better way to calculate an appropriate maximum size!) -->
					<!--<xsl:value-of select="count(//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']])+count(//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']])+count(//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])])+count(//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']])"/>-->
					<xsl:value-of select="count(//tei:text/tei:body/tei:listBibl/tei:biblStruct)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after($pSplit,'.')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="vChunkStart">
			<xsl:choose>
				<xsl:when test="$pSplit='0.0'">
					<xsl:value-of select="1" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$vChunkSize * (substring-before($pSplit,'.') - 1) + 1" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="vChunkEnd">
			<xsl:choose>
				<xsl:when test="$pSplit='0.0'">
					<xsl:value-of select="$vChunkSize" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$vChunkSize * substring-before($pSplit,'.')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- variables/lists according to/depending on chunk size -->
		<xsl:variable name="vEditionen"
			select="$vEditionen_L[(position() = $vChunkStart or position() &gt; $vChunkStart) and (position() = $vChunkEnd or position() &lt; $vChunkEnd)]" />
		<xsl:variable name="vLiteratur"
			select="$vLiteratur_L[(position() = $vChunkStart or position() &gt; $vChunkStart) and (position() = $vChunkEnd or position() &lt; $vChunkEnd)]" />
		<xsl:variable name="vHandschriftenkataloge"
			select="$vHandschriftenkataloge_L[(position() = $vChunkStart or position() &gt; $vChunkStart) and (position() = $vChunkEnd or position() &lt; $vChunkEnd)]" />
		<xsl:variable name="vSonstige"
			select="$vSonstige_L[(position() = $vChunkStart or position() &gt; $vChunkStart) and (position() = $vChunkEnd or position() &lt; $vChunkEnd)]" />


		
		<xsl:choose>
			<xsl:when test="$pCategory='all'">
				<!-- alle Kategorien ausgeben -->
				
				<!-- Einträge der einzelnen Kategorien ausgeben -->
				<xsl:call-template name="tEdi">
					<xsl:with-param name="pEdi" select="$vEditionen" />
				</xsl:call-template>
				<xsl:call-template name="tLit">
					<xsl:with-param name="pLit" select="$vLiteratur" />
				</xsl:call-template>
				<xsl:call-template name="tCat">
					<xsl:with-param name="pCat" select="$vHandschriftenkataloge" />
				</xsl:call-template>
				
				<!-- Einträge ausgeben, die nicht den vorigen 3 Kategorien zugeordnet werden konnten -->
				<xsl:if test="count($vSonstige)>0">
					<br/>
					<br/>
					<br/>
					<xsl:call-template name="tRest">
						<xsl:with-param name="pRest" select="$vSonstige"/>
					</xsl:call-template>
				</xsl:if>
				
			</xsl:when>
			<xsl:when test="$pCategory='edi'">
				<!-- nur Editionen ausgeben -->
				<xsl:call-template name="tEdi">
					<xsl:with-param name="pEdi" select="$vEditionen" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$pCategory='lit'">
				<!-- nur Literatur ausgeben -->
				<xsl:call-template name="tLit">
					<xsl:with-param name="pLit" select="$vLiteratur" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$pCategory='cat'">
				<!-- nur Handschriftenkataloge ausgeben -->
				<xsl:call-template name="tCat">
					<xsl:with-param name="pCat" select="$vHandschriftenkataloge" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- ??? -->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template> <!-- tBibliographie -->
	
	
	
	<!-- Templates der einzelnen Kategorien -->
	<xsl:template name="tEdi">
		<xsl:param name="pEdi"/>

		<xsl:call-template name="tCategory">
			<xsl:with-param name="pNodes" select="$pEdi" />
			<xsl:with-param name="pH4_id">edition</xsl:with-param>
			<xsl:with-param name="pH4_text">[:de]Editionen und Übersetzungen[:en]Editions and translations[:]</xsl:with-param>
			<xsl:with-param name="pDiv_id">top_Edition</xsl:with-param>
			<xsl:with-param name="pA_href">Edition</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="tLit">
		<xsl:param name="pLit"/>
		
		<xsl:call-template name="tCategory">
			<xsl:with-param name="pNodes" select="$pLit" />
			<xsl:with-param name="pH4_id">lit</xsl:with-param>
			<xsl:with-param name="pH4_text">[:de]Literatur[:en]Literature[:]</xsl:with-param>
			<xsl:with-param name="pDiv_id">top_Literatur</xsl:with-param>
			<xsl:with-param name="pA_href">Literatur</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="tCat">
	<xsl:param name="pCat"/>
		
		<xsl:call-template name="tCategory">
			<xsl:with-param name="pNodes" select="$pCat" />
			<xsl:with-param name="pH4_id">cat</xsl:with-param>
			<xsl:with-param name="pH4_text">[:de]Handschriftenkataloge[:en]Manuscript catalogues[:]</xsl:with-param>
			<xsl:with-param name="pDiv_id">top_Handschriftenkataloge</xsl:with-param>
			<xsl:with-param name="pA_href">Handschriftenkataloge</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="tRest">
		<xsl:param name="pRest"/>
		
		<xsl:call-template name="tCategory">
			<xsl:with-param name="pNodes" select="$pRest" />
			<xsl:with-param name="pH4_id">rest</xsl:with-param>
			<xsl:with-param name="pH4_text">[:de]Sonstige[:en]Rest[:]</xsl:with-param>
			<xsl:with-param name="pDiv_id">top_Sonstige</xsl:with-param>
			<xsl:with-param name="pA_href">Sonstige</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- /Templates der einzelnen Kategorien -->
	
	<!-- Tabellenstruktur/Template für Ausgabestruktur -->
	<xsl:template name="tCategory">
		<xsl:param name="pNodes"/>
		<xsl:param name="pH4_id"/>
		<xsl:param name="pH4_text"/>
		<xsl:param name="pDiv_id"/>
		<xsl:param name="pA_href"/>
		
		<h4 id="{$pH4_id}" align="center">
			<xsl:value-of select="$pH4_text"/>
		</h4>
		<div id="{$pDiv_id}" align="center">
			<xsl:for-each select="$pNodes">
				<xsl:variable name="buchstabe">
					<xsl:call-template name="tGetIdnoFirstLetter">
						<xsl:with-param name="pBiblStruct" select="."/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="buchstabePreceding">
					<xsl:call-template name="tGetIdnoFirstLetter">
						<xsl:with-param name="pBiblStruct" select="preceding-sibling::tei:biblStruct[1]"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:if test="$buchstabePreceding!=$buchstabe">
					<a href="#{$buchstabe}_{$pA_href}">
						<xsl:value-of select="$buchstabe"/>
					</a>
					<xsl:variable name="buchstabeLast">
						<xsl:call-template name="tGetIdnoFirstLetter">
							<xsl:with-param name="pBiblStruct" select="$pNodes[last()]"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$buchstabeLast!=$buchstabe">
						<xsl:text> | </xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</div>
		<div id="content">
			<table rules="all">
				<xsl:for-each select="$pNodes">
					<xsl:variable name="buchstabe">
						<xsl:call-template name="tGetIdnoFirstLetter">
							<xsl:with-param name="pBiblStruct" select="."/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="buchstabePreceding">
						<xsl:call-template name="tGetIdnoFirstLetter">
							<xsl:with-param name="pBiblStruct" select="preceding-sibling::tei:biblStruct[1]"/>
						</xsl:call-template>
					</xsl:variable>
					
					<xsl:if
						test="$buchstabePreceding!=$buchstabe">
						<tr>
							<th id="{$buchstabe}_{$pA_href}" class="dyn-menu-h5">
								<xsl:value-of select="$buchstabe"/>
							</th>
						</tr>
					</xsl:if>
					
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="tei:listBibl">

		<xsl:choose>
			<xsl:when test="$pShow='all'">
				<!-- published & unpublished anzeigen -->
				<xsl:apply-templates select="tei:biblStruct">
					<xsl:sort select="//tei:idno[1]"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:when test="$pShow='published'">
				<!-- nur published anzeigen -->
				<xsl:apply-templates select="tei:biblStruct[@status='published']">
					<xsl:sort select="//tei:idno[1]"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:when test="$pShow='unpublished'">
				<!-- nur unpublished anzeigen -->
				<xsl:apply-templates select="tei:biblStruct[not(@status='published')]">
					<xsl:sort select="//tei:idno[1]"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:otherwise>
				<!-- Fehler! -->
				<xsl:text>Es ist ein Fehler aufgetreten! Bitte überprüfen Sie die richtige Übergabe des Parameters "pShow".</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='main'][ancestor::tei:biblStruct[@type='webPublication']]">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='main'][ancestor::tei:biblStruct[@type='book']]">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='main'][ancestor::tei:biblStruct[@type='journalArticle']]">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='main'][ancestor::tei:biblStruct[@type='bookSection']]">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='sub'][text()!='']">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='sub'][text()!='']">
			<xsl:text>. </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:series/tei:title">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="node()"/>

		<xsl:if test="parent::tei:series/tei:biblScope[@unit='volume'][text()!='-']">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@unit='volume'][text()!='' and text()!='-']"/>
<!--		<xsl:text> </xsl:text>-->
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@unit='issue']"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="tei:series/tei:biblScope[@unit='volume'][text()!='-']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:series/tei:biblScope[@unit='issue']">
		<xsl:if test="preceding-sibling::tei:biblScope[not(text()='-')]">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="tei:series/tei:biblScope[@unit='issue'][text()='-']" />

	<xsl:template match="tei:monogr/tei:imprint/tei:pubPlace[text()!='' and text()!='-']">
		<xsl:if test="preceding-sibling::tei:pubPlace">
			<xsl:text> - </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="node()"/>
		<xsl:text> </xsl:text>
	</xsl:template>


	<xsl:template match="tei:monogr/tei:edition[number(@n)>1]">
		<sup>
			<xsl:value-of select="@n"/>
		</sup>
	</xsl:template>
	<xsl:template match="tei:monogr/tei:edition[number(@n)=1]" />

	<xsl:template match="tei:monogr/tei:imprint/tei:date">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="tei:note[@type='notes']">
		<xsl:text> [</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:idno[@type='URL']">
		<br/>
		<xsl:text>URL: </xsl:text>
		<a target="_blank" href="{.}">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>


	<!-- bookSection -->

	<xsl:template match="tei:analytic/tei:title[@type='main']">
		<xsl:apply-templates select="node()"/>

		<!-- Komma zwischen gleichwertige Titel -->
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:analytic/tei:title[@type='sub'][text()!='']">
		<xsl:apply-templates select="node()"/>

		<xsl:if test="following-sibling::tei:title[@type='sub'][text()!='']">
			<xsl:text>. </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:editor/tei:note[@type='role']">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="node()"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="tei:author/tei:note[@type='role']">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="node()"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="tei:persName" mode="forenameFirst">
		<!-- "[forename] [surname]" -->
		<xsl:if test="tei:forename">
			<span class="forename">
				<xsl:apply-templates select="tei:forename"/>
			</span>
		</xsl:if>
		<xsl:text> </xsl:text>
		<span class="surname">
			<xsl:apply-templates select="tei:surname"/>
		</span>
	</xsl:template>

	<xsl:template match="tei:persName" mode="surnameFirst">
		<!-- "[surname], [forename]" -->
		<span class="surname">
			<xsl:apply-templates select="tei:surname"/>
		</span>
		<xsl:if test="tei:forename">
			<xsl:text>, </xsl:text>
			<span class="forename">
				<xsl:apply-templates select="tei:forename"/>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tei:surname">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tei:forename">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tei:forename[preceding-sibling::tei:forename]">
		<!-- middlename / second forename -->
		<xsl:variable name="vFirstLetter">
			<xsl:value-of select="substring(node(),1,1)"/>
		</xsl:variable>

		<xsl:text> </xsl:text>
		<xsl:value-of select="$vFirstLetter"/>
		<xsl:text>.</xsl:text>
	</xsl:template>

	<xsl:template match="tei:analytic/tei:idno[@type='URL']">
		<br/>
		<xsl:text>URL: </xsl:text>
		<a target="_blank" href="{.}">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>
	
	<xsl:template match="tei:imprint/tei:biblScope[@unit='volume'][text()!='-']">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tei:imprint/tei:biblScope[@unit='page'][text()!='-']">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tei:author" mode="forenameFirst">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:author">
					<xsl:text> / </xsl:text>
				</xsl:if>

				<xsl:apply-templates select="tei:persName" mode="forenameFirst"/>

				<xsl:apply-templates select="tei:note[@type='role']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:author" mode="surnameFirst">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:author">
					<xsl:text> / </xsl:text>
				</xsl:if>

				<xsl:apply-templates select="tei:persName" mode="surnameFirst"/>

				<xsl:apply-templates select="tei:note[@type='role']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:editor" mode="forenameFirst">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:editor">
					<xsl:text> / </xsl:text>
				</xsl:if>

				<xsl:apply-templates select="tei:persName" mode="forenameFirst"/>

				<xsl:apply-templates select="tei:note[@type='role']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:editor" mode="surnameFirst">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:editor">
					<xsl:text> / </xsl:text>
				</xsl:if>

				<xsl:apply-templates select="tei:persName" mode="surnameFirst"/>

				<xsl:apply-templates select="tei:note[@type='role']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:author" mode="forenameFirst_noRole">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:author">
					<xsl:text> / </xsl:text>
				</xsl:if>
				
				<xsl:apply-templates select="tei:persName" mode="forenameFirst"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:author" mode="surnameFirst_noRole">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:author">
					<xsl:text> / </xsl:text>
				</xsl:if>
				
				<xsl:apply-templates select="tei:persName" mode="surnameFirst"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:editor" mode="forenameFirst_noRole">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:editor">
					<xsl:text> / </xsl:text>
				</xsl:if>
				
				<xsl:apply-templates select="tei:persName" mode="forenameFirst"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:editor" mode="surnameFirst_noRole">
		<xsl:choose>
			<xsl:when test="text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::tei:editor">
					<xsl:text> / </xsl:text>
				</xsl:if>
				
				<xsl:apply-templates select="tei:persName" mode="surnameFirst"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='super']">
		<sup>
			<xsl:apply-templates select="node()"/>
		</sup>
	</xsl:template>

	<xsl:template name="gesVorname">
		<xsl:param name="pErster"/>

		<xsl:value-of select="$pErster"/>
		<xsl:if test="count($pErster/following-sibling::tei:forename)>0">
			<xsl:text> </xsl:text>
		</xsl:if>

		<xsl:for-each select="$pErster/following-sibling::tei:forename">
			<xsl:value-of select="substring(.,1,1)"/>
			<xsl:text>.</xsl:text>
			<xsl:if test="count(following-sibling::tei:forename)>0">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--<xsl:template match="tei:biblStruct//tei:idno[1]">-->
	<!--<xsl:template match="tei:idno[@type='short_title'][parent::tei:monogr or parent::tei:analytic][1]">-->
	<xsl:template match="tei:idno[@type='short_title'][parent::tei:monogr or parent::tei:analytic]">

		<xsl:variable name="vlinkID">
			<xsl:value-of select="substring(.,1,1)"/>
			<xsl:text>_</xsl:text>
			<!--<xsl:value-of select="ancestor::tei:biblStruct/@type"/>-->
			<!--<xsl:value-of select="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()"/>-->

			<xsl:choose>
				<xsl:when
					test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Edition'">
					<xsl:text>Edition</xsl:text>
				</xsl:when>
				<xsl:when
					test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Literatur'">
					<xsl:text>Literatur</xsl:text>
				</xsl:when>
				<xsl:when
					test="ancestor::tei:biblStruct/tei:note[@type='rel_text'][not(text()='Literatur') and not(text()='Edition')]">
					<!--<xsl:text>Bibliothekskataloge</xsl:text>-->
					<xsl:text>Handschriftenkataloge</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Sonstige</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="vNoUnderlineIDNO">
			<xsl:call-template name="string-replace">
				<xsl:with-param name="string" select="."/>
				<xsl:with-param name="replace">
					<xsl:text>_</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="with">
					<xsl:text> </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>



		<xsl:choose>
			<xsl:when test="$pPublic='y'">
				<xsl:variable name="vNormID">
					<!-- normalize (see template in allgFunktionen.xsl for further information) string -->
					<xsl:call-template name="tNormalizeString">
						<xsl:with-param name="pString" select="."/>
					</xsl:call-template>
				</xsl:variable>
				<span>
					<!-- Hinzufügung short_title als name für Verlinkung - DS 09.09.2015 -->
					<xsl:attribute name="id">
						<xsl:value-of select="."/>
						<!--<xsl:value-of select="$vNormID"/>-->
					</xsl:attribute>

					<xsl:choose>
						<xsl:when test="$pIdnoAsShortcode='y'">
							<!-- Shortcode ausgeben => URL && Alternative -->

							<!--<span id="{$vlinkID}">-->

								<xsl:choose>
									<xsl:when test="./ancestor::tei:biblStruct//tei:note/@target">
										<xsl:variable name="vTarget">
											<xsl:value-of select="./ancestor::tei:biblStruct//tei:note/@target"/>
										</xsl:variable>

										<xsl:variable name="vDigitalisatePfadUnterordner">
											<xsl:choose>
												<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Edition'">
													<!--<xsl:text>Edition</xsl:text>-->
													<xsl:text>q</xsl:text>
												</xsl:when>
												<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Literatur'">
													<!--<xsl:text>Literatur</xsl:text>-->
													<xsl:text>lit</xsl:text>
												</xsl:when>
												<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text'][not(text()='Literatur') and not(text()='Edition')]">
													<!--<xsl:text>Bibliothekskataloge</xsl:text>-->
													<xsl:text>kat</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>Sonstige</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>

										<xsl:text>[logged_in]</xsl:text> <!-- SHORTCODE Inhalt nur an eingeloggte User gezeigt. -->

										<xsl:variable name="url">
											<xsl:value-of select="$vDigitalisatePfad"/>
											<xsl:text>/</xsl:text>
											<xsl:value-of select="$vDigitalisatePfadUnterordner"/>
											<xsl:text>/</xsl:text>
											<xsl:if test="$pUseLocally='no'">
												<xsl:value-of select="str:encode-uri(./ancestor::tei:biblStruct//tei:note/@target, true())"/> <!-- => beim lokalen Testen auskommentieren => !FINDMICH! -->
											</xsl:if>
									    </xsl:variable>

										<a href="{$url}" target="_blank"><xsl:value-of select="$vNoUnderlineIDNO" /></a>

										<xsl:text>[/logged_in]</xsl:text>

										<xsl:text>[logged_out]</xsl:text> <!-- SHORTCODE Inhalt nur an nicht eingeloggte User gezeigt. -->

										<span class="semibold"><xsl:value-of select="$vNoUnderlineIDNO" /></span>

										<xsl:text>[/logged_out]</xsl:text>

									</xsl:when>
									<xsl:otherwise>
										<!-- keine URL vorhanden => Titel wird einfach so (fett) ausgegeben -->
										<span class="semibold">
											<xsl:value-of select="$vNoUnderlineIDNO"/>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							<!--</span>-->

						</xsl:when>
						<xsl:otherwise>
							<!-- keinen Shortcode verwenden => "fett" darstellen -->
							<span style="font-weight: bold">
								<xsl:value-of select="$vNoUnderlineIDNO"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</span>
			</xsl:when>
			<xsl:otherwise>

				<!--<span id="{$vlinkID}">-->

					<xsl:choose>
						<xsl:when test="./ancestor::tei:biblStruct//tei:note/@target">
							<xsl:variable name="vTarget">
								<xsl:value-of select="./ancestor::tei:biblStruct//tei:note/@target"/>
							</xsl:variable>

							<xsl:variable name="vDigitalisatePfadUnterordner">
								<xsl:choose>
									<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Edition'">
										<!--<xsl:text>Edition</xsl:text>-->
										<xsl:text>q</xsl:text>
									</xsl:when>
									<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Literatur'">
										<!--<xsl:text>Literatur</xsl:text>-->
										<xsl:text>lit</xsl:text>
									</xsl:when>
									<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text'][not(text()='Literatur') and not(text()='Edition')]">
										<!--<xsl:text>Bibliothekskataloge</xsl:text>-->
										<xsl:text>kat</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Sonstige</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:value-of select="$vDigitalisatePfad"/>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="$vDigitalisatePfadUnterordner"/>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="./ancestor::tei:biblStruct//tei:note/@target"/>
									<!--<xsl:value-of select="$vTargetAusgabe"/>-->
								</xsl:attribute>
								<xsl:attribute name="target">
									<!-- Link in neuem Fenster/Tab öffnen -->
									<xsl:text>_blank</xsl:text>
								</xsl:attribute>
								<!--<xsl:value-of select="."/>-->
								<xsl:value-of select="$vNoUnderlineIDNO"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<span style="font-weight: bold">
								<xsl:value-of select="$vNoUnderlineIDNO"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>

				<!--</span>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="//tei:hi[@rend='italic']">
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>

	<xsl:template match="*">
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
	
	<xsl:template match="tei:biblStruct[@type='webPublication']">
		<tr>
			<td class="Lit">
				<!-- Kurztitel -->
				<xsl:apply-templates select="tei:monogr/tei:idno[@type='short_title']"/>
				<br/>
				
				<!-- Namengruppe & Funktion -->
				<xsl:apply-templates select="tei:monogr/tei:author" mode="surnameFirst"/> <!-- ??? -->
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Titelgruppe -->
					<!-- Haupttitel -->
				<xsl:apply-templates select="tei:monogr/tei:title[@type='main']" />
				<xsl:variable name="vPassendesTrennzeichen">
					<xsl:variable name="vBezug" select="tei:monogr/tei:title[@type='main'][last()]"/>
					<xsl:variable name="vGnsf"><xsl:text>"</xsl:text></xsl:variable> <!-- "Gänsefüsschen" -->
					<xsl:variable name="vLetztesZeichen" select="substring($vBezug,string-length($vBezug))" />
					<xsl:variable name="vVorletztesZeichen" select="substring($vBezug,string-length($vBezug)-1,1)" />
					
					<!-- Komma statt Punkt, falls Satzzeichen am Ende des letztens Titels; Punkt auslassen, falls Punkt letztes Zeichen -->
					<xsl:choose>
						<xsl:when test="$vLetztesZeichen='?' or $vLetztesZeichen='!'">
							<!--<xsl:text>, </xsl:text>	-->	
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen=$vGnsf and $vVorletztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
					<!-- Bandnummer -->
				<xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
					<xsl:value-of select="$vPassendesTrennzeichen"/>
					<xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']" />
				</xsl:if>
					<!-- Untertitel -->
				<xsl:if test="tei:monogr/tei:title[@type='sub'][text()!='']">
					<xsl:choose>
						<xsl:when test="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
							<xsl:text>. </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$vPassendesTrennzeichen"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="tei:monogr/tei:title[@type='sub'][text()!='']" />
				</xsl:if>
				
				<!-- keine Druckangabe -->
				
				<!-- Anmerkungen -->
				<xsl:apply-templates select="tei:note[@type='notes']"/>
				
				<!-- URL -->
				<xsl:apply-templates select="tei:monogr/tei:idno[@type='URL']"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="tei:biblStruct[@type='book']">
		<tr>
			<td class="Lit">
				<!-- Kurztitel -->
				<xsl:apply-templates select="tei:monogr/tei:idno[@type='short_title']"/>
				<br/>
				
				<!-- Namengruppe & Funktion -->
				<xsl:apply-templates select="tei:monogr/tei:author" mode="surnameFirst"/>
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Titelgruppe -->
					<!-- Haupttitel -->
				<xsl:apply-templates select="tei:monogr/tei:title[@type='main']" />
				<xsl:variable name="vPassendesTrennzeichen">
					<xsl:variable name="vBezug" select="tei:monogr/tei:title[@type='main'][last()]"/>
					<xsl:variable name="vGnsf"><xsl:text>"</xsl:text></xsl:variable> <!-- "Gänsefüsschen" -->
					<xsl:variable name="vLetztesZeichen" select="substring($vBezug,string-length($vBezug))" />
					<xsl:variable name="vVorletztesZeichen" select="substring($vBezug,string-length($vBezug)-1,1)" />
					
					<!-- Komma statt Punkt, falls Satzzeichen am Ende des letztens Titels; Punkt auslassen, falls Punkt letztes Zeichen -->
					<xsl:choose>
						<xsl:when test="$vLetztesZeichen='?' or $vLetztesZeichen='!'">
							<!--<xsl:text>, </xsl:text>	-->	
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen=$vGnsf and $vVorletztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- Bandnummer -->
				<xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
					<xsl:value-of select="$vPassendesTrennzeichen"/>
					<xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']" />
				</xsl:if>
				<!-- Untertitel -->
				<xsl:if test="tei:monogr/tei:title[@type='sub'][text()!='']">
					<xsl:choose>
						<xsl:when test="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
							<xsl:text>. </xsl:text>	
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$vPassendesTrennzeichen"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="tei:monogr/tei:title[@type='sub'][text()!='']" />
				</xsl:if>

				<!-- Sonderfall: Reihenangabe -->
				<xsl:if test="tei:series/tei:title">
					<!--<xsl:text>, </xsl:text>-->
					<!-- Titel & Nummer -->
					<xsl:apply-templates select="tei:series/tei:title" />
					<!--<xsl:apply-templates select="tei:series/tei:biblScope" />-->
					<!-- /Sonderfall: Reihenangabe -->					
				</xsl:if>
				
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Druckangabe -->
					<!-- Verlagsort -->
				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:pubPlace[text()!='' and text()!='-']" />
				<xsl:text> </xsl:text>
					<!-- Edition/Bandnummer -->
				<xsl:apply-templates select="tei:monogr/tei:edition" />
					<!-- Erscheinungsdatum -->
				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:date" />
				
				
				<!-- Anmerkungen -->
				<xsl:apply-templates select="tei:note[@type='notes']"/>
				
				<!-- URL -->
				<xsl:apply-templates select="tei:monogr/tei:idno[@type='URL']"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="tei:biblStruct[@type='journalArticle']">
		<tr>
			<td class="Lit">
				<!-- Kurztitel -->
				<xsl:apply-templates select="tei:analytic/tei:idno[@type='short_title']"/>
				<br/>
		
				<!-- Namengruppe & Funktion -->
				<xsl:apply-templates select="tei:analytic/tei:author" mode="surnameFirst"/>
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Titelgruppe -->
					<!-- Haupttitel -->
				<xsl:apply-templates select="tei:analytic/tei:title[@type='main']" />
				<xsl:variable name="vPassendesTrennzeichen">
					<xsl:variable name="vBezug" select="tei:analytic/tei:title[@type='main'][last()]"/>
					<xsl:variable name="vGnsf"><xsl:text>"</xsl:text></xsl:variable> <!-- "Gänsefüsschen" -->
					<xsl:variable name="vLetztesZeichen" select="substring($vBezug,string-length($vBezug))" />
					<xsl:variable name="vVorletztesZeichen" select="substring($vBezug,string-length($vBezug)-1,1)" />
					
					<!-- Komma statt Punkt, falls Satzzeichen am Ende des letztens Titels; Punkt auslassen, falls Punkt letztes Zeichen -->
					<xsl:choose>
						<xsl:when test="$vLetztesZeichen='?' or $vLetztesZeichen='!'">
							<!--<xsl:text>, </xsl:text>		-->
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen=$vGnsf and $vVorletztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				
					<!-- Bandnummer -->
				<xsl:if test="tei:analytic/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
					<xsl:value-of select="$vPassendesTrennzeichen" />
					<xsl:apply-templates select="tei:analytic/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']" />
				</xsl:if>					
					<!-- Untertitel -->
				<xsl:if test="tei:analytic/tei:title[@type='sub'][text()!='']">
					<xsl:choose>
						<xsl:when test="tei:analytic/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
							<xsl:text>. </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$vPassendesTrennzeichen" />							
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="tei:analytic/tei:title[@type='sub'][text()!='']" />
				</xsl:if>
				
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Druckangabe -->
				<xsl:text>in: </xsl:text>
					<!-- Zeitschriftentitel -->
				<xsl:apply-templates select="tei:monogr/tei:title[@type='main']" />
				<xsl:text> </xsl:text>
					<!-- Bandnummer -->
				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']" />
					<!-- Untertitel -->
				<xsl:if test="tei:monogr/tei:title[@type='sub'][text()!='']">
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="tei:monogr/tei:title[@type='sub'][text()!='']" />	
				</xsl:if>
				
				<xsl:text> </xsl:text>
					<!-- Erscheinungsdatum -->
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:date" />
				<xsl:text>)</xsl:text>
					<!-- Seitenangabe -->
				<xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='page'][text()!='' and text()!='-']">
					<xsl:text> S. </xsl:text>
					<xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='page'][text()!='' and text()!='-']" />
				</xsl:if>
				
				<!-- Anmerkungen -->
				<xsl:apply-templates select="tei:note[@type='notes']"/>
				
				<!-- URL -->
				<xsl:apply-templates select="tei:analytic/tei:idno[@type='URL']"/>
			</td>
		</tr>
		
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='bookSection']">
		<tr>
			<td class="Lit">
				<!-- Kurztitel -->
				<xsl:apply-templates select="tei:analytic/tei:idno[@type='short_title']"/>
				<br/>
				
				<!-- Namengruppe & Funktion -->
				<xsl:apply-templates select="tei:analytic/tei:author" mode="surnameFirst"/>
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Titelgruppe -->
					<!-- Haupttitel -->
				<xsl:apply-templates select="tei:analytic/tei:title[@type='main']" />
				<xsl:variable name="vPassendesTrennzeichen">
					<xsl:variable name="vBezug" select="tei:analytic/tei:title[@type='main'][last()]"/>
					<xsl:variable name="vGnsf"><xsl:text>"</xsl:text></xsl:variable> <!-- "Gänsefüsschen" -->
					<xsl:variable name="vLetztesZeichen" select="substring($vBezug,string-length($vBezug))" />
					<xsl:variable name="vVorletztesZeichen" select="substring($vBezug,string-length($vBezug)-1,1)" />
					
					<!-- Komma statt Punkt, falls Satzzeichen am Ende des letztens Titels; Punkt auslassen, falls Punkt letztes Zeichen -->
					<xsl:choose>
						<xsl:when test="$vLetztesZeichen='?' or $vLetztesZeichen='!'">
							<!--<xsl:text>, </xsl:text>		-->
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen=$vGnsf and $vVorletztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
					<!-- Bandnummer -->
				<xsl:if test="tei:analytic/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
					<xsl:value-of select="$vPassendesTrennzeichen"/>
					<xsl:apply-templates select="tei:analytic/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']" />
				</xsl:if>
					<!-- Untertitel -->
				<xsl:if test="tei:analytic/tei:title[@type='sub'][text()!='']">
					<xsl:choose>
						<xsl:when test="tei:analytic/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
							<xsl:text>. </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$vPassendesTrennzeichen"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="tei:analytic/tei:title[@type='sub'][text()!='']" />
				</xsl:if>
				<xsl:text>, </xsl:text> <!-- Komma nach Ende -->
				
				<!-- Druckangabe... -->
				<xsl:text>in: </xsl:text>
				
				<!-- Namengruppe 2 => forenameFirst -->
				<xsl:choose>
					<xsl:when test="(tei:monogr/tei:author and tei:monogr/tei:author/text()!='Unbekannt') and (tei:monogr/tei:editor and tei:monogr/tei:editor/text()!='Unbekannt')">
						<!-- author & editor gemischt => Namensgruppe 2 nur author, Namensgruppe 3 nur editor -->
						<xsl:apply-templates select="tei:monogr/tei:author" mode="forenameFirst" />
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:when test="tei:monogr/tei:author and tei:monogr/tei:author/text()!='Unbekannt'">
						<!-- nur author(s) vorhanden -->
						<xsl:apply-templates select="tei:monogr/tei:author" mode="forenameFirst" />
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:when test="tei:monogr/tei:editor and tei:monogr/tei:editor/text()!='Unbekannt'">
						<!-- nur editor(s) vorhanden -->
						<xsl:apply-templates select="tei:monogr/tei:editor" mode="forenameFirst" />
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- ??? -->
					</xsl:otherwise>
				</xsl:choose>
<!--				<xsl:if test="tei:monogr/tei:author and tei:monogr/tei:author/text()!='Unbekannt'">
					<xsl:apply-templates select="tei:monogr/tei:author" mode="forenameFirst" />
					<xsl:text>, </xsl:text>
				</xsl:if>-->
				
				<!-- Titelgruppe 2 (=> Reihentitel???)-->
					<!-- Haupttitel -->
				<xsl:apply-templates select="tei:monogr/tei:title[@type='main']" />
				<xsl:variable name="vPassendesTrennzeichen2">
					<xsl:variable name="vBezug" select="tei:monogr/tei:title[@type='main'][last()]"/>
					<xsl:variable name="vGnsf"><xsl:text>"</xsl:text></xsl:variable> <!-- "Gänsefüsschen" -->
					<xsl:variable name="vLetztesZeichen" select="substring($vBezug,string-length($vBezug))" />
					<xsl:variable name="vVorletztesZeichen" select="substring($vBezug,string-length($vBezug)-1,1)" />
					
					<!-- Komma statt Punkt, falls Satzzeichen am Ende des letztens Titels; Punkt auslassen, falls Punkt letztes Zeichen -->
					<xsl:choose>
						<xsl:when test="$vLetztesZeichen='?' or $vLetztesZeichen='!'">
							<!--<xsl:text>, </xsl:text>		-->
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:when test="$vLetztesZeichen=$vGnsf and $vVorletztesZeichen='.'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
					<!-- Untertitel -->
				<xsl:if test="tei:monogr/tei:title[@type='sub'][text()!='']">
					<xsl:value-of select="$vPassendesTrennzeichen2"/>
					<xsl:apply-templates select="tei:monogr/tei:title[@type='sub'][text()!='']" />
				</xsl:if>
				<xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']">
					<xsl:value-of select="$vPassendesTrennzeichen2"/>
					<xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][text()!='' and text()!='-']" />
				</xsl:if>
				<xsl:if test="not(tei:series/tei:title)"> <!-- BAUSTELLE: sinnvoll? -->
					<xsl:text>, </xsl:text>
				</xsl:if>
				<!--<xsl:text>, </xsl:text>-->
				
				<!-- Namengruppe 3 -->
				<xsl:if test="(tei:monogr/tei:author and tei:monogr/tei:author/text()!='Unbekannt') and (tei:monogr/tei:editor and tei:monogr/tei:editor/text()!='Unbekannt')">
					<xsl:if test="tei:series/tei:title"> <!-- BAUSTELLE: sinnvoll? -->
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text>hg. v. </xsl:text>
					<xsl:apply-templates select="tei:monogr/tei:editor" mode="forenameFirst_noRole" />
					<!--<xsl:text>, </xsl:text>-->
				</xsl:if>
<!--				<xsl:if test="tei:monogr/tei:editor and tei:monogr/tei:editor/text()!='Unbekannt'">
					<xsl:text>hg. v. </xsl:text>
					<xsl:apply-templates select="tei:monogr/tei:editor" mode="forenameFirst" />
					<xsl:text>, </xsl:text>
				</xsl:if>-->

				<!-- Sonderfall: Reihenangabe -->
				<xsl:if test="tei:series/tei:title">
					<!-- Titel & Nummer -->
					<xsl:apply-templates select="tei:series/tei:title" />
					<!--<xsl:apply-templates select="tei:series/tei:biblScope" />-->
					<xsl:text>, </xsl:text>
				</xsl:if>
				<!-- /Sonderfall: Reihenangabe -->

				
				<!-- Druckangabe -->
					<!-- Verlagsort -->
				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:pubPlace[text()!='' and text()!='-']" />
				<xsl:text> </xsl:text>
					<!-- Erscheinungsdatum -->
				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:date" />
					<!-- Seitenangabe -->
				<xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='page'][text()!='' and text()!='-']">
					<xsl:text>, </xsl:text>
					<xsl:text>S. </xsl:text>
					<xsl:apply-templates select="tei:monogr/tei:imprint/tei:biblScope[@unit='page'][text()!='' and text()!='-']" />
				</xsl:if>
				
				<!-- Anmerkungen -->
				<xsl:apply-templates select="tei:note[@type='notes']"/>
				
				<!-- URL -->
				<xsl:apply-templates select="tei:analytic/tei:idno[@type='URL']"/>
			</td>
		</tr>
	</xsl:template>
	
	
	<xsl:template name="tGetIdnoFirstLetter">
		<xsl:param name="pBiblStruct"/>
		<!-- get the first letter of the tei:idno[@type='short_title'] in a biblStruct -->
		
		<xsl:value-of select="substring($pBiblStruct/tei:monogr/tei:idno[@type='short_title'] | $pBiblStruct/tei:analytic/tei:idno[@type='short_title'],1,1)"/>
	</xsl:template>
	

</xsl:stylesheet>
