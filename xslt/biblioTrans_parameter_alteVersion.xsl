<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:str="http://exslt.org/strings"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="allgFunktionen.xsl"/>

	<xsl:variable name="vParams" select="document('biblioParams.xml')"/>

	<xsl:param name="pShow">all</xsl:param>
	<xsl:param name="pEmbedded">y</xsl:param>
	<xsl:param name="pIdnoAsShortcode">y</xsl:param>
	<xsl:param name="pPublic">y</xsl:param>

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



<!-- BAUSTELLEN/ToDO:
	* Satzzeichen am Ende von Titeln: ?, !, ?"
	* forenameFirst/surnameFirst für tei:editor / tei:author auf ebendieser EBene bearbeiten (nicht erst ab persName!)
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
						<!--                <style type="text/css">
                    body{
                        font-size:small;
                    }
                    table{
                        table-layout:fixed;
                    }


                	td.Lit{
                		<!-\-width:90%-\->
                	}
<!-\-                	td.id{
                		width:10%;
                	}-\->


                	span.surname{ font-variant: small-caps}
                	span.forename{}

                	span.titleBookMonogr{}
                	span.titleJournalArticle{}

                	span.date{}
                	span.place{}

                </style>-->

						<style type="text/css">
							span.sup{
							    vertical-align:top;
							    font-size:60%
							}</style>

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

		<xsl:variable name="vEditionen"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']]"/>
		<xsl:variable name="vLiteratur"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']]"/>
<!--		<xsl:variable name="vBibliothekskataloge"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]"/>-->
		<xsl:variable name="vHandschriftenkataloge"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]"/>
		<!--<xsl:variable name="vSonstige" select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]"/>-->
		<xsl:variable name="vSonstige"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']]"/>


		<!--<h1 id="top" align="center">Bibliographie</h1>-->
		<!-- 09.09.2015 DS -->

		<!--<xsl:value-of select="$vParams//tei:note"/>-->
		<!--
            	<u><b><xsl:text>Testdaten/-Parameter</xsl:text></b></u>
            	<br/>
            	<xsl:text>vDigitalisatePfad: </xsl:text><i><xsl:value-of select="$vDigitalisatePfad"/></i>
            	<br/>
            	<xsl:text>vTransformationenPfad: </xsl:text><i><xsl:value-of select="$vTransformationenPfad"/></i>
            	-->


		<!--
		<table rules="all" align="center" id="top">
			<tr>
				<td align="center">
					<a href="#top_Edition">Editionen und Übersetzungen</a>
				</td>
			</tr>
			<tr>
				<td align="center">
					<a href="#top_Literatur">Literatur</a>
				</td>
			</tr>
			<tr>
				<td align="center">
					<a href="#top_Bibliothekskataloge">Bibliothekskataloge</a>
				</td>
			</tr>
			<xsl:if test="count($vSonstige)>0">
				<tr>
					<td align="center">
						<a href="#top_Sonstige">Sonstige</a>
					</td>
				</tr>
			</xsl:if>
			</table>
			-->

		<!--<h3 align="center">Editionen</h3>-->
		<h4 id="edition" align="center">[:de]Editionen und Übersetzungen[:en]Editions and translations[:]</h4>
		<div id="top_Edition" align="center">
			<xsl:for-each select="$vEditionen">
				<xsl:variable name="buchstabe"
					select="substring(.//tei:idno[@type='short_title'],1,1)"/>
				<xsl:if
					test="not(following::tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
					<a href="#{$buchstabe}_Edition">
						<xsl:value-of select="$buchstabe"/>
					</a>
					<xsl:if test="position()!=last()"> | </xsl:if>
				</xsl:if>

			</xsl:for-each>
			<!--			<a href="#A_Edition">A</a> | <a href="#B_Edition">B</a> | <a href="#C_Edition">C</a> | <a href="#D_Edition">D</a>
            		| <a href="#E_Edition">E</a> | <a href="#F_Edition">F</a> | <a href="#G_Edition">G</a> | <a href="#H_Edition"
            			>H</a> | <a href="#I_Edition">I</a> | <a href="#J_Edition">J</a> | <a href="#K_Edition">K</a> | <a href="#L_Edition">L</a> |
            		<a href="#M_Edition">M</a> | <a href="#N_Edition">N</a> | <a href="#O_Edition">O</a> | <a href="#P_Edition"
            			>P</a> | <a href="#Q_Edition">Q</a> | <a href="#R_Edition">R</a> | <a href="#S_Edition">S</a> | <a href="#T_Edition">T</a> |
            		<a href="#U_Edition">U</a> | <a href="#V_Edition">V</a> | <a href="#W_Edition">W</a> | <a href="#X_Edition">X</a> | <a href="#Y_Edition">Y</a> | <a href="#Z_Edition">Z</a> -->
		</div>
		<div id="content">
			<table rules="all">
				<!--<xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='book']"/>-->
				<!--<xsl:apply-templates select="$vEditionen"/>-->


				<xsl:for-each select="$vEditionen">
					<xsl:variable name="buchstabe"
						select="substring(.//tei:idno[@type='short_title'],1,1)"/>
					<xsl:if
						test="not(preceding::tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
						<tr>
							<th id="{$buchstabe}_Edition" class="dyn-menu-h5">
							  <xsl:value-of select="$buchstabe"/>
							</th>
						</tr>

					</xsl:if>

					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>

		<h4 id="lit" align="center">[:de]Literatur[:en]Literature[:]</h4>
		<div id="top_Literatur" align="center">

			<xsl:for-each select="$vLiteratur">
				<xsl:variable name="buchstabe"
					select="substring(.//tei:idno[@type='short_title'],1,1)"/>
				<xsl:if
					test="not(following::tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
					<a href="#{$buchstabe}_Literatur">
						<xsl:value-of select="$buchstabe"/>
					</a>
					<xsl:if test="position()!=last()"> | </xsl:if>
				</xsl:if>
			</xsl:for-each>

			<!--            		<a href="#A_Literatur">A</a> | <a href="#B_Literatur">B</a> | <a href="#C_Literatur">C</a> | <a href="#D_Literatur">D</a>
            		| <a href="#E_Literatur">E</a> | <a href="#F_Literatur">F</a> | <a href="#G_Literatur">G</a> | <a href="#H_Literatur"
            			>H</a> | <a href="#I_Literatur">I</a> | <a href="#J_Literatur">J</a> | <a href="#K_Literatur">K</a> | <a href="#L_Literatur">L</a> |
            		<a href="#M_Literatur">M</a> | <a href="#N_Literatur">N</a> | <a href="#O_Literatur">O</a> | <a href="#P_Literatur"
            			>P</a> | <a href="#Q_Literatur">Q</a> | <a href="#R_Literatur">R</a> | <a href="#S_Literatur">S</a> | <a href="#T_Literatur">T</a> |
            		<a href="#U_Literatur">U</a> | <a href="#V_Literatur">V</a> | <a href="#W_Literatur">W</a> | <a href="#X_Literatur">X</a> | <a href="#Y_Literatur">Y</a> | <a href="#Z_Literatur">Z</a>-->
		</div>
		<div id="content">
			<table rules="all">
				<!--<xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='book']"/>-->
				<!--<xsl:apply-templates select="$vLiteratur"/>-->


				<xsl:for-each select="$vLiteratur">
					<xsl:variable name="buchstabe"
						select="substring(.//tei:idno[@type='short_title'],1,1)"/>
					<xsl:if
						test="not(preceding::tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
						<tr>
							<th id="{$buchstabe}_Literatur" class="dyn-menu-h5">
							  <xsl:value-of select="$buchstabe"/>
							</th>
						</tr>

					</xsl:if>

					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>

		<!--<h4 id="cat" align="center">[:de]Bibliothekskataloge[:en]Library Catalogs[:]</h4>-->
		<h4 id="cat" align="center">[:de]Handschriftenkataloge[:en]Manuscript catalogues[:]</h4>
		<div id="top_Handschriftenkataloge" align="center">
			            		<!--08.04.2015: needs debugging...-->
            		<xsl:for-each select="$vHandschriftenkataloge">
            			<xsl:variable name="buchstabe" select="substring(.//tei:idno[@type='short_title'],1,1)"/>
            			<xsl:if test="not(following::tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
            				<a href="#{$buchstabe}_Handschriftenkataloge"><xsl:value-of select="$buchstabe"/></a>
            				<xsl:if test="position()!=last()"> | </xsl:if>
            			</xsl:if>
            		</xsl:for-each>

		</div>
		<div id="content">
			<table rules="all">
				<!--<xsl:apply-templates select="$vBibliothekskataloge"/>-->


				<xsl:for-each select="$vHandschriftenkataloge">
					<xsl:variable name="buchstabe"
						select="substring(.//tei:idno[@type='short_title'],1,1)"/>
					<xsl:if
						test="not(preceding::tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
						<tr>
							<th id="{$buchstabe}_Handschriftenkataloge" class="dyn-menu-h5">
							  <xsl:value-of select="$buchstabe"/>
							</th>
						</tr>

					</xsl:if>

					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>

		<xsl:if test="count($vSonstige)>0">
			<br/>
			<br/>
			<br/>

			<h4 id="rest" align="center">Sonstige</h4>
			<div id="top_Sonstige" align="center"><a href="#A_Sonstige">A</a> | <a
					href="#B_Sonstige">B</a> | <a href="#C_Sonstige">C</a> | <a href="#D_Sonstige"
					>D</a> | <a href="#E_Sonstige">E</a> | <a href="#F_Sonstige">F</a> | <a
					href="#G_Sonstige">G</a> | <a href="#H_Sonstige">H</a> | <a href="#I_Sonstige"
					>I</a> | <a href="#J_Sonstige">J</a> | <a href="#K_Sonstige">K</a> | <a
					href="#L_Sonstige">L</a> | <a href="#M_Sonstige">M</a> | <a href="#N_Sonstige"
					>N</a> | <a href="#O_Sonstige">O</a> | <a href="#P_Sonstige">P</a> | <a
					href="#Q_Sonstige">Q</a> | <a href="#R_Sonstige">R</a> | <a href="#S_Sonstige"
					>S</a> | <a href="#T_Sonstige">T</a> | <a href="#U_Sonstige">U</a> | <a
					href="#V_Sonstige">V</a> | <a href="#W_Sonstige">W</a> | <a href="#X_Sonstige"
					>X</a> | <a href="#Y_Sonstige">Y</a> | <a href="#Z_Sonstige">Z</a></div>
			<div id="content">
				<table rules="all">
					<!--<xsl:apply-templates select="$vSonstige"/>-->



					<xsl:for-each select="$vSonstige">
						<xsl:variable name="buchstabe"
							select="substring(.//tei:idno[@type='short_title'],1,1)"/>
						<xsl:if
							test="not(preceding::tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
							<tr>
								<td>
									<span id="{$buchstabe}_Sonstige" style="font-weight: bold">
										<xsl:value-of select="$buchstabe"/>
									</span>
								</td>
							</tr>

						</xsl:if>

						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</table>
			</div>

		</xsl:if>

	</xsl:template>



	<!-- "Füllen" der einzelnen Spalten mit den entsprechenden Angaben  -->

	<!--    <xsl:template match="//tei:listBibl">
        <xsl:apply-templates/>
    </xsl:template>-->

	<xsl:template match="//tei:listBibl">

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



	<!--<xsl:template match="tei:biblStruct[not(@status=$pShow)]"/>-->

	<xsl:template match="tei:biblStruct[@type='book']">
		<tr>
			<td class="Lit">

				<xsl:apply-templates select="tei:monogr/tei:idno[@type='short_title']"/>
				<!--				<br/>
				<xsl:text>(</xsl:text><xsl:value-of select="@type"/><xsl:text>)</xsl:text>-->

				<!--<br/>-->
				<br/>

				<xsl:choose>
					<xsl:when test="count(tei:monogr/tei:author)=0">
						<!-- ohne Autor -->
						<xsl:apply-templates select="tei:monogr/tei:editor" mode="surnameFirst"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:monogr/tei:author" mode="surnameFirst"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>
				<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>

				<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]"/>

				<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
					<xsl:text>. </xsl:text>
				</xsl:if>


				<xsl:apply-templates select="tei:monogr/tei:title[@type='sub']"/>

				<xsl:apply-templates select="tei:series/tei:title[@type='main']"/>

				<xsl:choose>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='main'])>0 and count(tei:monogr/tei:title[@type='sub'])=0 and count(tei:series/tei:title)=0">
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='main'])>0 and count(tei:monogr/tei:title[@type='sub'])>0 and count(tei:series/tei:title)=0">
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='sub'])=0 and count(tei:series/tei:title)=0"> </xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='sub'])>0 and count(tei:series/tei:title)>0">
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='sub'])=0 and count(tei:series/tei:title)>0">
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!--<xsl:text>, </xsl:text>-->
					</xsl:otherwise>
				</xsl:choose>


				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:pubPlace[.!='' and .!='-']"/>

				<xsl:apply-templates select="tei:monogr/tei:edition"/>

				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:date"/>

				<xsl:apply-templates select="tei:note[@type='notes']"/>

				<xsl:apply-templates select="tei:monogr/tei:idno[@type='URL']"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='main'][ancestor::tei:biblStruct[@type='webPublication']]">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>

		<xsl:if test="following-sibling::tei:title[@type='sub']">
			<xsl:variable name="vSZeichenAmEnde">
				<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
					<xsl:with-param name="pString" select="."/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="$vSZeichenAmEnde='true'">
					<xsl:text>, </xsl:text>
				</xsl:when>
				<xsl:when test="substring(.,string-length(.))='.'">
					<!-- nichts? -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>. </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

<!--		<xsl:if test="following-sibling::tei:title[@type='sub']">
			<xsl:text>. </xsl:text>
		</xsl:if>-->


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

<!--	<xsl:template match="tei:monogr/tei:title[@type='main']">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>-->

	<xsl:template match="tei:biblStruct[@type='book']//tei:biblScope[@unit='volume'][not(ancestor::tei:series)]">
		<xsl:text>. </xsl:text>
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="tei:monogr/tei:title[@type='sub']">
		<xsl:apply-templates select="node()"/>
		<xsl:if test="following-sibling::tei:title[@type='sub']">
			<xsl:text>. </xsl:text>
		</xsl:if>
	</xsl:template>

<!--	<xsl:template match="tei:series">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="tei:title[@type='main']"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@type='volume']"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@type='issue']"/>
		<xsl:text>)</xsl:text>
	</xsl:template>-->

	<xsl:template match="tei:series/tei:title">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="node()"/>

		<xsl:if test="parent::tei:series/tei:biblScope[@unit='volume' and text()!='-']">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@unit='volume']"/>
<!--		<xsl:text> </xsl:text>-->
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@unit='issue']"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="tei:series/tei:biblScope[not(@unit='volume')][text()='-']"/>

	<xsl:template match="tei:series/tei:biblScope[@unit='volume'][not(text()='-')]">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="tei:series/tei:biblScope[@unit='volume'][text()='-']"/>

	<xsl:template match="tei:series/tei:biblScope[@unit='issue']">
		<xsl:if test="preceding-sibling::tei:biblScope[not(text()='-')]">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="tei:series/tei:biblScope[@unit='issue'][text()='-']"/>

<!--	<xsl:template match="tei:series/tei:title">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<!-\-<xsl:apply-templates select="node()"/>-\->
		<xsl:apply-templates select=""
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@type='volume']"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="parent::tei:series/tei:biblScope[@type='issue']"/>
		<xsl:text>)</xsl:text>
	</xsl:template>-->

<!--	<xsl:template match="tei:series/tei:biblScope">
		<xsl:if test="not(.='-')">
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="node()"/>
		</xsl:if>
	</xsl:template>-->

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

		<xsl:if test="following-sibling::tei:title[@type='main']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:analytic/tei:title[@type='sub']">
		<xsl:apply-templates select="node()"/>

		<xsl:if test="following-sibling::tei:title[@type='sub']">
			<xsl:text>. </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='bookSection']/tei:monogr/tei:editor[.='Unbekannt']">
		<xsl:call-template name="EditorAlternativ">
			<xsl:with-param name="pEditor" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='bookSection']/tei:monogr/tei:editor[.!='Unbekannt']">
		<xsl:apply-templates select="tei:persName" mode="forenameFirst"/>
		<!--<xsl:text> </xsl:text>-->
		<xsl:apply-templates select="tei:note[@type='role']"/>
		<xsl:choose>
			<xsl:when test="following-sibling::tei:editor">
				<xsl:text> / </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>, </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
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
<!--		<xsl:text> </xsl:text>-->
	</xsl:template>

	<xsl:template match="tei:forename[preceding-sibling::tei:forename]">
		<xsl:variable name="vFirstLetter">
			<xsl:value-of select="substring(node(),1,1)"/>
		</xsl:variable>

		<xsl:text> </xsl:text>
		<xsl:value-of select="$vFirstLetter"/>
		<xsl:text>.</xsl:text>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='bookSection']">
		<tr>
			<td class="Lit">

				<xsl:apply-templates select="tei:analytic/tei:idno[@type='short_title']"/>
				<br/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:author)=0">
						<!-- ohne Autor -->
						<xsl:apply-templates select="tei:analytic/tei:editor" mode="surnameFirst"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:analytic/tei:author" mode="surnameFirst"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>
				<xsl:apply-templates select="tei:analytic/tei:title[@type='main']"/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:title[@type='sub'])>0">

<!--						<!-\- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -\->

-->

						<xsl:variable name="vSZeichenAmEnde">
							<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
								<xsl:with-param name="pString" select="tei:analytic/tei:title[@type='main'][last()]"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="$vSZeichenAmEnde='true'">
								<xsl:text>, </xsl:text>
							</xsl:when>
							<xsl:when test="substring(tei:analytic/tei:title[@type='main'][last()],string-length(tei:analytic/tei:title[@type='main'][last()]))='.'">
								<!-- nichts? -->
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>. </xsl:text>
							</xsl:otherwise>
						</xsl:choose>

						<!--<xsl:text>. </xsl:text>-->
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>, in: </xsl:text>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="tei:analytic/tei:title[@type='sub']"/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:title[@type='sub'])>0">
						<xsl:text>, in: </xsl:text>
					</xsl:when>
				</xsl:choose>


				<xsl:choose>
					<xsl:when
						test="count(tei:monogr/tei:editor)>0 and count(tei:monogr/tei:author)>0">
						<!--<xsl:apply-templates select="tei:monogr/tei:author"/>-->
						<xsl:apply-templates select="tei:monogr/tei:author" mode="forenameFirst"/> <!-- BAUSTELLE: templtes zu editor/author überarbeiten! (Ambiguitäten beseitigen! => klare Aufteilung in fornameFirst/surnameFirst! -->
						<xsl:text>, </xsl:text>

						<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>

						<xsl:choose>
							<xsl:when
								test="count(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][not(.='')])>0">



								<xsl:text>. </xsl:text>
								<xsl:value-of
									select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/>
								<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">

									<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->


									<xsl:variable name="vSZeichenAmEnde">
										<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
											<xsl:with-param name="pString" select="tei:monogr/tei:title[@type='main'][last()]"/>
										</xsl:call-template>
									</xsl:variable>

									<xsl:choose>
										<xsl:when test="$vSZeichenAmEnde='true'">
											<xsl:text>, </xsl:text>
										</xsl:when>
										<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
											<!-- nichts? -->
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>. </xsl:text>
										</xsl:otherwise>
									</xsl:choose>

									<!--<xsl:text>.</xsl:text>-->
								</xsl:if>
							</xsl:when>
							<!--							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)=0)">
								<xsl:text>, </xsl:text>
							</xsl:when>-->
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])>0">

								<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->


								<xsl:variable name="vSZeichenAmEnde">
									<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
										<xsl:with-param name="pString" select="tei:monogr/tei:title[@type='main'][last()]"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:choose>
									<xsl:when test="$vSZeichenAmEnde='true'">
										<xsl:text>, </xsl:text>
									</xsl:when>
									<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
										<!-- nichts? -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>. </xsl:text>
									</xsl:otherwise>
								</xsl:choose>

								<!--<xsl:text>. </xsl:text>-->
							</xsl:when>
							<!--							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)>0)">
							</xsl:when>-->
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])=0">
								<xsl:text>, </xsl:text>
							</xsl:when>
						</xsl:choose>



						<xsl:apply-templates select="tei:monogr/tei:title[@type='sub']"/>

						<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
							<xsl:text>, </xsl:text>
						</xsl:if>

						<xsl:text> hg. v. </xsl:text>

						<!--<xsl:apply-templates select="tei:monogr/tei:editor"/>-->

						<xsl:for-each select="tei:monogr/tei:editor">
							<xsl:call-template name="EditorAlternativ">
								<xsl:with-param name="pEditor" select="."/>
								<!--<xsl:with-param name="pMode" select="'forenameFirst'"/>-->
							</xsl:call-template>
						</xsl:for-each>

						<xsl:if test="count(tei:series/tei:title)=0">
							<xsl:text>, </xsl:text>
						</xsl:if>

					</xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:editor)=0 and count(tei:monogr/tei:author)>0">
						<!--<xsl:apply-templates select="tei:monogr/tei:author"/>-->
						<xsl:apply-templates select="tei:monogr/tei:author" mode="forenameFirst"/> <!-- BAUSTELLE: templtes zu editor/author überarbeiten! (Ambiguitäten beseitigen! => klare Aufteilung in fornameFirst/surnameFirst! -->
						<xsl:text>, </xsl:text>

						<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>

						<xsl:choose>
							<xsl:when
								test="count(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][not(.='')])>0">

								<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->

								<xsl:variable name="vSZeichenAmEnde">
									<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
										<xsl:with-param name="pString" select="tei:monogr/tei:title[@type='main'][last()]"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:choose>
									<xsl:when test="$vSZeichenAmEnde='true'">
										<xsl:text>, </xsl:text>
									</xsl:when>
									<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
										<!-- nichts? -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>. </xsl:text>
									</xsl:otherwise>
								</xsl:choose>

								<!--<xsl:text>. </xsl:text>-->
								<xsl:value-of
									select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/>
								<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">


									<xsl:choose>
										<xsl:when test="$vSZeichenAmEnde='true'">
											<xsl:text>, </xsl:text>
										</xsl:when>
										<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
											<!-- nichts? -->
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>. </xsl:text>
										</xsl:otherwise>
									</xsl:choose>

									<!--<xsl:text>.</xsl:text>-->
								</xsl:if>
							</xsl:when>
							<!--							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)=0)">
								<xsl:text>, </xsl:text>
							</xsl:when>-->
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])>0">

								<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->

								<xsl:variable name="vSZeichenAmEnde">
									<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
										<xsl:with-param name="pString" select="tei:monogr/tei:title[@type='main'][last()]"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:choose>
									<xsl:when test="$vSZeichenAmEnde='true'">
										<xsl:text>, </xsl:text>
									</xsl:when>
									<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
										<!-- nichts? -->
									</xsl:when>
									<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
										<!-- nichts? -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>. </xsl:text>
									</xsl:otherwise>
								</xsl:choose>

								<!--<xsl:text>. </xsl:text>-->
							</xsl:when>
							<!--							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)>0)">
							</xsl:when>-->
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])=0">
								<xsl:text>, </xsl:text>
							</xsl:when>
						</xsl:choose>

						<xsl:apply-templates select="tei:monogr/tei:title[@type='sub']"/>

						<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
							<xsl:text>, </xsl:text>
						</xsl:if>

					</xsl:when>
					<xsl:otherwise>

						<!--<xsl:apply-templates select="tei:monogr/tei:editor[.!='Unbekannt']"/>-->
						<xsl:apply-templates select="tei:monogr/tei:editor[.!='Unbekannt']" mode="forenameFirst"/> <!-- BAUSTELLE: templtes zu editor/author überarbeiten! (Ambiguitäten beseitigen! => klare Aufteilung in fornameFirst/surnameFirst! -->

						<xsl:if test="tei:monogr/tei:editor[.!='Unbekannt']">
							<xsl:text>, </xsl:text>
						</xsl:if>

						<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>

						<xsl:choose>
							<xsl:when
								test="count(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][not(.='')])>0">

								<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->


								<xsl:variable name="vSZeichenAmEnde">
									<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
										<xsl:with-param name="pString" select="tei:monogr/tei:title[@type='main'][last()]"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:choose>
									<xsl:when test="$vSZeichenAmEnde='true'">
										<xsl:text>, </xsl:text>
									</xsl:when>
									<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
										<!-- nichts? -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>. </xsl:text>
									</xsl:otherwise>
								</xsl:choose>

								<!--<xsl:text>. </xsl:text>-->
								<xsl:value-of
									select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/>
<!--								<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
									<xsl:text>.</xsl:text>
								</xsl:if>-->

								<xsl:choose>
									<xsl:when test="count(tei:monogr/tei:title[@type='sub'])>0">

										<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->

										<xsl:choose>
											<xsl:when test="$vSZeichenAmEnde='true'">
												<xsl:text>, </xsl:text>
											</xsl:when>
											<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
												<!-- nichts? -->
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>. </xsl:text>
											</xsl:otherwise>
										</xsl:choose>

										<!--<xsl:text>.</xsl:text>-->
									</xsl:when>
									<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)=0)">
										<xsl:text>,</xsl:text>
									</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when
								test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)=0)">
								<xsl:text>, </xsl:text>
							</xsl:when>
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])>0">

								<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->


								<xsl:variable name="vSZeichenAmEnde">
									<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
										<xsl:with-param name="pString" select="tei:monogr/tei:title[@type='main'][last()]"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:choose>
									<xsl:when test="$vSZeichenAmEnde='true'">
										<xsl:text>, </xsl:text>
									</xsl:when>
									<xsl:when test="substring(tei:monogr/tei:title[@type='main'][last()],string-length(tei:monogr/tei:title[@type='main'][last()]))='.'">
										<!-- nichts? -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>. </xsl:text>
									</xsl:otherwise>
								</xsl:choose>



								<!--<xsl:text>. </xsl:text>-->
							</xsl:when>
							<xsl:when
								test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)>0)"
							> </xsl:when>
						</xsl:choose>

						<xsl:text> </xsl:text>

						<xsl:apply-templates select="tei:monogr/tei:title[@type='sub']"/>

						<xsl:choose>
							<xsl:when
								test="(count(tei:monogr/tei:title[@type='sub'])>0) and (count(tei:series/tei:title)=0)">
								<xsl:text>, </xsl:text>
							</xsl:when>
						</xsl:choose>

					</xsl:otherwise>
					<!--					<xsl:when test="count(tei:monogr/tei:editor)>0 and tei:monogr/tei:editor!='Unbekannt'">
						<xsl:apply-templates select="tei:monogr/tei:editor"/>
						<xsl:text>, </xsl:text>
					</xsl:when>-->
				</xsl:choose>

				<xsl:apply-templates select="tei:series/tei:title[1]"/>

				<xsl:choose>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='sub'])=0 and count(tei:series/tei:title)=0"> </xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='sub'])>0 and count(tei:series/tei:title)>0">
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:when
						test="count(tei:monogr/tei:title[@type='sub'])=0 and count(tei:series/tei:title)>0">
						<xsl:text>, </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!--<xsl:text>, </xsl:text>-->
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:pubPlace[.!='' and .!='-']"/>

				<xsl:apply-templates select="tei:monogr/tei:edition[number(@n)>1]"/>

				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:date"/>

				<xsl:choose>
					<xsl:when test="tei:monogr/tei:imprint/tei:biblScope[@unit='page']!='-'">
						<xsl:text>, </xsl:text>
						<xsl:text>S. </xsl:text>
						<xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='page']"/>
					</xsl:when>
					<xsl:when test="tei:monogr/tei:imprint/tei:biblScope[@unit='chapter']!=''">
						<xsl:text>, </xsl:text>
						<xsl:text>Kap. </xsl:text>
						<xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='chapter']"
						/>
					</xsl:when>
					<xsl:otherwise> </xsl:otherwise>
				</xsl:choose>


				<xsl:apply-templates select="tei:note[@type='notes']"/>

				<xsl:apply-templates select="tei:monogr/tei:idno[@type='URL']"/>

			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tei:analytic/tei:idno[@type='URL']">
		<br/>
		<xsl:text>URL: </xsl:text>
		<a target="_blank" href="{.}">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='journalArticle']">
		<tr>
			<td class="Lit">
				<xsl:apply-templates select="tei:analytic/tei:idno[@type='short_title']"/>
				<br/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:author)=0">
						<!-- ohne Autor -->
						<xsl:apply-templates select="tei:analytic/tei:editor" mode="surnameFirst"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:analytic/tei:author" mode="surnameFirst"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>

				<xsl:apply-templates select="tei:analytic/tei:title[@type='main']"/>

				<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)][not(ancestor::tei:imprint)]"/>

				<xsl:choose>
					<!--<xsl:when test="count(current()/following-sibling::tei:title[@type='sub'])>0">-->
					<xsl:when test="count(descendant::tei:title[@type='sub'])>0">

						<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->



						<xsl:variable name="vSZeichenAmEnde">
							<xsl:call-template name="tPruefeObSatzzeichenAmEnde">
								<xsl:with-param name="pString" select="tei:analytic/tei:title[@type='main'][last()]"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="$vSZeichenAmEnde='true'">
								<xsl:text>, </xsl:text>
							</xsl:when>
							<xsl:when test="substring(tei:analytic/tei:title[@type='main'][last()],string-length(tei:analytic/tei:title[@type='main'][last()]))='.'">
								<!-- nichts? -->
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>. </xsl:text>
							</xsl:otherwise>
						</xsl:choose>


						<!--<xsl:text>. </xsl:text>-->
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>, </xsl:text>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="tei:analytic/tei:title[@type='sub']"/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:title[@type='sub'])>0">
						<xsl:text>, in: </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> in: </xsl:text>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="tei:monogr/tei:editor" mode="forenameFirst"/>

				<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>

				<xsl:text> </xsl:text>
				<xsl:if test="count(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'])>0">
					<!--<xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/><xsl:text>.</xsl:text>	-->
					<xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/>
				</xsl:if>

				<xsl:text> </xsl:text>
				<!--<xsl:apply-templates select="tei:monogr/tei:title[@type='sub']"/>-->
				<xsl:for-each select="tei:monogr/tei:title[@type='sub']">
					<!--<xsl:value-of select="."/>-->
					<xsl:apply-templates select="."/>
					<xsl:if test="count(current()/following-sibling::tei:title[@type='sub'])>0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>

				<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
					<xsl:text>, </xsl:text>
				</xsl:if>

				<xsl:apply-templates select="tei:monogr/tei:imprint/tei:pubPlace[.!='' and .!='-']"/>
<!--
				<xsl:if test="tei:monogr/tei:imprint/tei:pubPlace[.!='']">
					<xsl:value-of select="tei:monogr/tei:imprint/tei:pubPlace"/>
					<xsl:text> </xsl:text>
				</xsl:if>-->

				<xsl:text>(</xsl:text>

				<xsl:apply-templates select="tei:monogr/tei:edition[number(@n)>1]"/>

				<xsl:value-of select="tei:monogr/tei:imprint/tei:date"/>
				<xsl:text>) </xsl:text>

				<!--<xsl:text>, </xsl:text>-->
				<xsl:text>S. </xsl:text>
				<xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='page']"/>

				<xsl:apply-templates select="tei:note[@type='notes']"/>

				<xsl:apply-templates select="tei:analytic/tei:idno[@type='URL']"/>
			</td>
		</tr>
	</xsl:template>


	<xsl:template match="tei:biblStruct[@type='webPublication']//tei:biblScope[@unit='volume'][not(ancestor::tei:series)]">
		<!-- Bandnummer -->

		<!-- BAUSTELLE: mögliche Satzzeichen am Ende eines Titels berücksichtigen! -->

		<xsl:text>. </xsl:text>
		<xsl:apply-templates select="node()"/>

		<xsl:if test="parent::tei:biblStruct[@type='webPublication']/descendant::tei:title[not(@type='main')]">
			<!-- Untertitel folgt -->
			<xsl:text>. </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='webPublication']">
		<tr>
			<td class="Lit">

				<!--<xsl:text>(</xsl:text><xsl:value-of select="@type"/><xsl:text>)</xsl:text>-->

				<xsl:if test="tei:analytic">
					<xsl:apply-templates select="tei:analytic/tei:author" mode="surnameFirst"/>
					<xsl:apply-templates select="tei:analytic/tei:editor" mode="surnameFirst"/>
					<xsl:text>, </xsl:text>
					<!--<xsl:value-of select="tei:analytic/tei:title"/>-->
					<xsl:apply-templates select="tei:analytic/tei:title"/>
					<xsl:text>, auf: </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="tei:monogr/tei:idno[@type='short_title']"/>
				<!--<br/>-->
				<br/>
				<xsl:apply-templates select="tei:monogr/tei:author" mode="surnameFirst"/> <!-- surnameFirst?? -->
				<xsl:apply-templates select="tei:monogr/tei:editor" mode="surnameFirst"/> <!-- surnameFirst?? -->
				<xsl:text>, </xsl:text>
				<!--<xsl:value-of select="tei:monogr/tei:title"/>-->
				<xsl:apply-templates select="tei:monogr/tei:title"/>

				<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]"/>

				<xsl:apply-templates select="tei:note[@type='notes']"/>

				<xsl:apply-templates select="tei:monogr/tei:idno[@type='URL']"/>
			</td>
		</tr>
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

	<xsl:template name="EditorAlternativ">
		<xsl:param name="pEditor"/>
		<!--<xsl:param name="pMode">forenameFirst</xsl:param>-->

		<xsl:choose>
			<xsl:when test="$pEditor/text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$pEditor/preceding-sibling::tei:editor">
					<xsl:text> / </xsl:text>
				</xsl:if>

				<xsl:apply-templates select="$pEditor/tei:persName" mode="forenameFirst"/>
				<!--<xsl:apply-templates select="$pEditor/tei:persName" mode="{$pMode}"/>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:hi[@rend='super']">
		<sup>
			<xsl:apply-templates select="node()"/>
		</sup>
	</xsl:template>

	<xsl:template match="tei:surname">
		<xsl:value-of select="."/>
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

	<xsl:template match="tei:biblStruct//tei:idno[1]">

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

							<span id="{$vlinkID}">

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
											<xsl:value-of select="str:encode-uri(./ancestor::tei:biblStruct//tei:note/@target, true())"/> <!-- => beim lokalen Testen auskommentieren => !FINDMICH! -->
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
							</span>

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

				<span id="{$vlinkID}">

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

				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="//tei:hi[@rend='italic']">
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>

	<xsl:template name="tPruefeObSatzzeichenAmEnde">
		<xsl:param name="pString"/>

		<xsl:variable name="vZeichen1">
			<xsl:text>?</xsl:text>
		</xsl:variable>
		<xsl:variable name="vZeichen2">
			<xsl:text>!</xsl:text>
		</xsl:variable>
		<xsl:variable name="vZeichen3">
			<xsl:text>"</xsl:text>
		</xsl:variable>

		<xsl:variable name="vLetztesZeichen">
			<xsl:value-of select="substring($pString,string-length($pString))"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vLetztesZeichen=$vZeichen1">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="$vLetztesZeichen=$vZeichen2">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="$vLetztesZeichen=$vZeichen3">
				<xsl:variable name="vVorletztesZeichen">
					<xsl:value-of select="substring($pString,string-length($pString)-1,1)"/>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="$vVorletztesZeichen=$vZeichen1">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:when test="$vVorletztesZeichen=$vZeichen2">
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
