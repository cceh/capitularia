<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="allgFunktionen.xsl"/>

	<xsl:variable name="vParams" select="document('biblioParams.xml')"/>

	<xsl:param name="pShow">all</xsl:param>
	<xsl:param name="pEmbedded">y</xsl:param>
	<xsl:param name="pIdnoAsShortcode">n</xsl:param>
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

	<!-- outputs an url for everybody -->
	<xsl:template name="url">
	  <br/>
	  <xsl:text>URL: </xsl:text>
	  <a target="_blank" href="{.}">
	    <xsl:value-of select="."/>
	  </a>
	</xsl:template>

	<!-- outputs an url for logged-in people only -->
	<xsl:template name="editor_url">
	  <xsl:text>[logged_in]</xsl:text>
	  <xsl:call-template name="url" />
	  <xsl:text>[/logged_in]</xsl:text>
	</xsl:template>


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
							}
						</style>

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
		<xsl:variable name="vBibliothekskataloge"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]"/>
		<!--<xsl:variable name="vSonstige" select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])]"/>-->
		<xsl:variable name="vSonstige"
			select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']]"/>


		<!--<h1 id="top" align="center">Bibliographie</h1>-->
		<!-- 09.09.2015 DS -->

		<!--<xsl:value-of select="$vParams//tei:note"/>-->
		<!--            	<hr/>
            	<u><b><xsl:text>Testdaten/-Parameter</xsl:text></b></u>
            	<br/>
            	<xsl:text>vDigitalisatePfad: </xsl:text><i><xsl:value-of select="$vDigitalisatePfad"/></i>
            	<br/>
            	<xsl:text>vTransformationenPfad: </xsl:text><i><xsl:value-of select="$vTransformationenPfad"/></i>
            	<hr/>-->


		<table rules="all" align="center" id="top">
			<!--<tr>
				<td align="center">
					<!-\-<a href="#top_Edition">Editionen</a>-\->
					<a href="#top_Edition">Editionen und Übersetzungen</a>
				</td>
			</tr>
			<tr>
				<td align="center">
					<!-\-<a href="#top_Literatur">Literatur</a>-\->
					<a href="#top_Literatur">Literatur</a>
				</td>
			</tr>
			<tr>
				<td align="center">
					<!-\-<a href="#top_Sonstige">Sonstige</a>-\->
					<a href="#top_Bibliothekskataloge">Bibliothekskataloge</a>
				</td>
			</tr>
			<xsl:if test="count($vSonstige)>0">
				<tr>
					<td align="center">
						<a href="#top_Sonstige">Sonstige</a>
					</td>
				</tr>
			</xsl:if>-->
		</table>

		<!--<h3 align="center">Editionen</h3>-->
		<h4 id="edition" align="center">Editionen und Übersetzungen</h4>
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
				<thead>
					<tr valign="top">
						<th class="Lit"/>
						<!--<th class="id">ID</th>-->
					</tr>
				</thead>
				<!--<xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='book']"/>-->
				<!--<xsl:apply-templates select="$vEditionen"/>-->


				<xsl:for-each select="$vEditionen">
					<xsl:variable name="buchstabe"
						select="substring(.//tei:idno[@type='short_title'],1,1)"/>
					<xsl:if
						test="not(preceding::tei:biblStruct[tei:note[@type='rel_text'][text()='Edition']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
						<tr>
							<td>
								<xsl:call-template name="back-to-top-compact"/>
								<span id="{$buchstabe}_Edition" style="font-weight: bold">
									<xsl:value-of select="$buchstabe"/>
								</span>
							</td>
						</tr>

					</xsl:if>

					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>
		<!-- Auskommentiert, da durch Verwendung der Sidebar nicht mehr nötig - DS 27.11.2015 -->
		<!--<br/>

		<hr/>
		<a href="#top_Edition">zum Index</a>
		<br/>
		<a href="#top">zum Seitenanfang</a>
		<hr/>

		<br/>
		<br/>-->
		<br/>

		<h4 id="lit" align="center">Literatur</h4>
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
				<thead>
					<tr valign="top">
						<th class="Lit"/>
						<!--<th class="id">ID</th>-->
					</tr>
				</thead>
				<!--<xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='book']"/>-->
				<!--<xsl:apply-templates select="$vLiteratur"/>-->


				<xsl:for-each select="$vLiteratur">
					<xsl:variable name="buchstabe"
						select="substring(.//tei:idno[@type='short_title'],1,1)"/>
					<xsl:if
						test="not(preceding::tei:biblStruct[tei:note[@type='rel_text'][text()='Literatur']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
						<tr>
							<td>
								<xsl:call-template name="back-to-top-compact"/>
								<span id="{$buchstabe}_Literatur" style="font-weight: bold">
									<xsl:value-of select="$buchstabe"/>
								</span>
							</td>
						</tr>

					</xsl:if>

					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>
		<!-- Auskommentiert, da durch Verwendung der Sidebar nicht mehr nötig - DS 27.11.2015 -->
		<!--<br/>

		<hr/>
		<a href="#top_Literatur">zum Index</a>
		<br/>
		<a href="#top">zum Seitenanfang</a>
		<hr/>

		<br/>
		<br/>-->
		<br/>

		<h4 id="cat" align="center">Handschriftenkataloge</h4>
		<div id="top_Bibliothekskataloge" align="center">
			            		<!--08.04.2015: needs debugging...-->
            		<xsl:for-each select="$vBibliothekskataloge">
            			<xsl:variable name="buchstabe" select="substring(.//tei:idno[@type='short_title'],1,1)"/>
            			<xsl:if test="not(following::tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
            				<a href="#{$buchstabe}_Bibliothekskataloge"><xsl:value-of select="$buchstabe"/></a>
            				<xsl:if test="position()!=last()"> | </xsl:if>
            			</xsl:if>
            		</xsl:for-each>

<!--			<a href="#A_Bibliothekskataloge">A</a> | <a href="#B_Bibliothekskataloge">B</a> | <a
				href="#C_Bibliothekskataloge">C</a> | <a href="#D_Bibliothekskataloge">D</a> | <a
				href="#E_Bibliothekskataloge">E</a> | <a href="#F_Bibliothekskataloge">F</a> | <a
				href="#G_Bibliothekskataloge">G</a> | <a href="#H_Bibliothekskataloge">H</a> | <a
				href="#I_Bibliothekskataloge">I</a> | <a href="#J_Bibliothekskataloge">J</a> | <a
				href="#K_Bibliothekskataloge">K</a> | <a href="#L_Bibliothekskataloge">L</a> | <a
				href="#M_Bibliothekskataloge">M</a> | <a href="#N_Bibliothekskataloge">N</a> | <a
				href="#O_Bibliothekskataloge">O</a> | <a href="#P_Bibliothekskataloge">P</a> | <a
				href="#Q_Bibliothekskataloge">Q</a> | <a href="#R_Bibliothekskataloge">R</a> | <a
				href="#S_Bibliothekskataloge">S</a> | <a href="#T_Bibliothekskataloge">T</a> | <a
				href="#U_Bibliothekskataloge">U</a> | <a href="#V_Bibliothekskataloge">V</a> | <a
				href="#W_Bibliothekskataloge">W</a> | <a href="#X_Bibliothekskataloge">X</a> | <a
				href="#Y_Bibliothekskataloge">Y</a> | <a href="#Z_Bibliothekskataloge">Z</a>-->
		</div>
		<div id="content">
			<table rules="all">
				<thead>
					<tr valign="top">
						<th class="Lit"/>
						<!--<th class="id">ID</th>-->
					</tr>
				</thead>
				<!--<xsl:apply-templates select="$vBibliothekskataloge"/>-->


				<xsl:for-each select="$vBibliothekskataloge">
					<xsl:variable name="buchstabe"
						select="substring(.//tei:idno[@type='short_title'],1,1)"/>
					<xsl:if
						test="not(preceding::tei:biblStruct[not(tei:note[@type='rel_text'][text()='Edition']) and not(tei:note[@type='rel_text'][text()='Literatur'])][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
						<tr>
							<td>
								<xsl:call-template name="back-to-top-compact"/>
								<span id="{$buchstabe}_Bibliothekskataloge"
									style="font-weight: bold">
									<xsl:value-of select="$buchstabe"/>
								</span>
							</td>
						</tr>

					</xsl:if>

					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</div>
		<!-- Auskommentiert, da durch Verwendung der Sidebar nicht mehr nötig - DS 27.11.2015 -->
		<!--<br/>

		<hr/>
		<a href="#top_Sonstige">zum Index</a>
		<br/>
		<a href="#top">zum Seitenanfang</a>
		<hr/>-->

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
					<thead>
						<tr valign="top">
							<th class="Lit"/>
							<!--<th class="id">ID</th>-->
						</tr>
					</thead>
					<!--<xsl:apply-templates select="$vSonstige"/>-->



					<xsl:for-each select="$vSonstige">
						<xsl:variable name="buchstabe"
							select="substring(.//tei:idno[@type='short_title'],1,1)"/>
						<xsl:if
							test="not(preceding::tei:biblStruct[tei:note[@type='rel_text'][text()='Sonstige...']][substring(.//tei:idno[@type='short_title'],1,1)=$buchstabe])">
							<tr>
								<td>
									<xsl:call-template name="back-to-top-compact"/>
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
			<!-- Auskommentiert, da durch Verwendung der Sidebar nicht mehr nötig - DS 27.11.2015 -->
			<!--<br/>

			<hr/>
			<a href="#top_Sonstige">zum Index</a>
			<br/>
			<a href="#top">zum Seitenanfang</a>
			<hr/>-->
		</xsl:if>
		<!--            	<br/><br/><br/>



            	<!-\-<h3 align="center">book</h3>-\->
            	<div id="top_book" align="center"><a href="#A_book">A</a> | <a href="#B_book">B</a> | <a href="#C_book">C</a> | <a href="#D_book">D</a>
            		| <a href="#E_book">E</a> | <a href="#F_book">F</a> | <a href="#G_book">G</a> | <a href="#H_book"
            			>H</a> | <a href="#I_book">I</a> | <a href="#J_book">J</a> | <a href="#K_book">K</a> | <a href="#L_book">L</a> |
            		<a href="#M_book">M</a> | <a href="#N_book">N</a> | <a href="#O_book">O</a> | <a href="#P_book"
            			>P</a> | <a href="#Q_book">Q</a> | <a href="#R_book">R</a> | <a href="#S_book">S</a> | <a href="#T_book">T</a> |
            		<a href="#U_book">U</a> | <a href="#V_book">V</a> | <a href="#W_book">W</a> | <a href="#X_book">X</a> | <a href="#Y_book">Y</a> | <a href="#Z_book">Z</a></div>
                <div id="content">
                    <table rules="all">
                        <thead>
                            <tr valign="top">
                            	<th class="Lit"></th>
                            	<!-\-<th class="id">ID</th>-\->
                            </tr>
                        </thead>
                        <xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='book']"/>
                    </table>
                </div>

            	<br/>

            	<hr/>
            	<a href="#top_book">zum Index</a>
            	<br/>
            	<a href="#top">zum Seitenanfang</a>
            	<hr/>

            	<br/><br/><br/>

            	<!-\-<h3 align="center">bookSection</h3>-\->
            	<div id="top_bookSection" align="center"><a href="#A_bookSection">A</a> | <a href="#B_bookSection">B</a> | <a href="#C_bookSection">C</a> | <a href="#D_bookSection">D</a>
            		| <a href="#E_bookSection">E</a> | <a href="#F_bookSection">F</a> | <a href="#G_bookSection">G</a> | <a href="#H_bookSection"
            			>H</a> | <a href="#I_bookSection">I</a> | <a href="#J_bookSection">J</a> | <a href="#K_bookSection">K</a> | <a href="#L_bookSection">L</a> |
            		<a href="#M_bookSection">M</a> | <a href="#N_bookSection">N</a> | <a href="#O_bookSection">O</a> | <a href="#P_bookSection"
            			>P</a> | <a href="#Q_bookSection">Q</a> | <a href="#R_bookSection">R</a> | <a href="#S_bookSection">S</a> | <a href="#T_bookSection">T</a> |
            		<a href="#U_bookSection">U</a> | <a href="#V_bookSection">V</a> | <a href="#W_bookSection">W</a> | <a href="#X_bookSection">X</a> | <a href="#Y_bookSection">Y</a> | <a href="#Z_bookSection">Z</a></div>
            	<div id="content">
            		<table rules="all">
            			<thead>
            				<tr valign="top">
            					<th class="Lit"></th>
            					<!-\-<th class="id">ID</th>-\->
            				</tr>
            			</thead>
            			<xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='bookSection']"/>
            		</table>
            	</div>

            	<br/>

            	<hr/>
            	<a href="#top_bookSection">zum Index</a>
            	<br/>
            	<a href="#top">zum Seitenanfang</a>
            	<hr/>

            	<br/><br/><br/>

            	<!-\-<h3 align="center">journalArticle</h3>-\->
            	<div id="top_journalArticle" align="center"><a href="#A_journalArticle">A</a> | <a href="#B_journalArticle">B</a> | <a href="#C_journalArticle">C</a> | <a href="#D_journalArticle">D</a>
            		| <a href="#E_journalArticle">E</a> | <a href="#F_journalArticle">F</a> | <a href="#G_journalArticle">G</a> | <a href="#H_journalArticle"
            			>H</a> | <a href="#I">I</a> | <a href="#J">J</a> | <a href="#K">K</a> | <a href="#L">L</a> |
            		<a href="#M_journalArticle">M</a> | <a href="#N_journalArticle">N</a> | <a href="#O_journalArticle">O</a> | <a href="#P_journalArticle"
            			>P</a> | <a href="#Q">Q</a> | <a href="#R">R</a> | <a href="#S">S</a> | <a href="#T">T</a> |
            		<a href="#U_journalArticle">U</a> | <a href="#V_journalArticle">V</a> | <a href="#W_journalArticle">W</a> | <a href="#X_journalArticle">X</a> | <a href="#Y_journalArticle">Y</a> | <a href="#Z_journalArticle">Z</a></div>
            	<div id="content">
            		<table rules="all">
            			<thead>
            				<tr valign="top">
            					<th class="Lit"></th>
            					<!-\-<th class="id">ID</th>-\->
            				</tr>
            			</thead>
            			<xsl:apply-templates select="//tei:text/tei:body/tei:listBibl/tei:biblStruct[@type='journalArticle']"/>
            		</table>
            	</div>

            	<br/>
            	<hr/>
            	<a href="#top_journalArticle">zum Index</a>
            	<br/>
            	<a href="#top">zum Seitenanfang</a>-->
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
						<xsl:apply-templates select="tei:monogr/tei:editor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:monogr/tei:author"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>
				<xsl:for-each select="tei:monogr/tei:title[@type='main']">
					<xsl:apply-templates select="."/>

					<xsl:if test="count(current()/following-sibling::tei:title[@type='main'])>0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>

				<xsl:if test="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]">
					<!-- Bandnummer -->
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]"/>

<!--					<xsl:if test="descendant::tei:title[not(@type='main')]">
						<!-\- Untertitel folgt -\->
						<xsl:text>. </xsl:text>
					</xsl:if>-->
				</xsl:if>

				<!--<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>-->
				<!--<xsl:text>. </xsl:text>-->
				<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
					<xsl:text>. </xsl:text>
				</xsl:if>

				<xsl:for-each select="tei:monogr/tei:title[@type='sub']">
					<xsl:apply-templates select="."/>

					<xsl:if test="count(current()/following-sibling::tei:title[@type='sub'])>0">
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:for-each>

				<xsl:if test="count(tei:series/tei:title)>0">
					<xsl:text> </xsl:text>
					<xsl:text>(</xsl:text>
					<xsl:value-of select="tei:series/tei:title"/>
					<xsl:if test="count(tei:series/tei:biblScope)>0">
						<xsl:if test="not(tei:series/tei:biblScope='-')">
							<xsl:text> </xsl:text>
							<xsl:value-of select="tei:series/tei:biblScope"/>
						</xsl:if>
					</xsl:if>
					<xsl:text>)</xsl:text>
				</xsl:if>

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

				<xsl:if test="tei:monogr/tei:imprint/tei:pubPlace[.!='']">
					<!--<xsl:value-of select="tei:monogr/tei:imprint/tei:pubPlace"/>-->

					<xsl:for-each select="tei:monogr/tei:imprint/tei:pubPlace">
						<xsl:if test="preceding-sibling::tei:pubPlace">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>

					<xsl:text> </xsl:text>
				</xsl:if>

				<xsl:if test="number(tei:monogr/tei:edition/@n)>1">
					<sup>
					<!--<span class="sup">-->
						<xsl:value-of select="tei:monogr/tei:edition/@n"/>
					<!--</span>-->
					</sup>
				</xsl:if>
				<xsl:value-of select="tei:monogr/tei:imprint/tei:date"/>



				<xsl:for-each select="tei:note[@type='notes']"><br/>
					<div style="font-size:85%;line-height:100%;padding-top:1%;"><xsl:text> [</xsl:text>
						<xsl:value-of select="."/>
						<xsl:text>]</xsl:text></div>
				</xsl:for-each>



				<xsl:for-each select="tei:monogr/tei:idno[@type='URL']">
				  <xsl:call-template name="url" />
				</xsl:for-each>

			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='bookSection']">
		<tr>
			<td class="Lit">

				<xsl:apply-templates select="tei:analytic/tei:idno[@type='short_title']"/>
				<!--				<br/>
				<xsl:text>(</xsl:text><xsl:value-of select="@type"/><xsl:text>)</xsl:text>-->

				<!--<br/>-->
				<br/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:author)=0">
						<!-- ohne Autor -->
						<xsl:apply-templates select="tei:analytic/tei:editor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:analytic/tei:author"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>
				<xsl:for-each select="tei:analytic/tei:title[@type='main']">
					<xsl:apply-templates select="."/>

					<xsl:if test="count(current()/following-sibling::tei:title[@type='main'])>0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>

<!--				<xsl:if test="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]">
					<!-\- Bandnummer -\->
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]"/>

<!-\-					<xsl:if test="descendant::tei:title[not(@type='main')]">
						<!-\\- Untertitel folgt -\\->
						<xsl:text>. </xsl:text>
					</xsl:if>-\->
				</xsl:if>-->

				<!--<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>-->
				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:title[@type='sub'])>0">
						<xsl:text>. </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>, in: </xsl:text>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:for-each select="tei:analytic/tei:title[@type='sub']">
					<xsl:apply-templates select="."/>

					<xsl:if test="count(current()/following-sibling::tei:title[@type='sub'])>0">
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:for-each>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:title[@type='sub'])>0">
						<xsl:text>, in: </xsl:text>
					</xsl:when>
				</xsl:choose>



				<xsl:choose>
					<xsl:when
						test="count(tei:monogr/tei:editor)>0 and count(tei:monogr/tei:author)>0">
						<xsl:apply-templates select="tei:monogr/tei:author"/>
						<xsl:text>, </xsl:text>

						<xsl:for-each select="tei:monogr/tei:title[@type='main']">
							<xsl:apply-templates select="."/>
							<xsl:if
								test="count(current()/following-sibling::tei:title[@type='main'])>0">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>

						<xsl:choose>
							<xsl:when
								test="count(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][not(.='')])>0">
								<xsl:text>. </xsl:text>
								<xsl:value-of
									select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/>
								<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
									<xsl:text>.</xsl:text>
								</xsl:if>
							</xsl:when>
							<!--							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)=0)">
								<xsl:text>, </xsl:text>
							</xsl:when>-->
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])>0">
								<xsl:text>. </xsl:text>
							</xsl:when>
							<!--							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)>0)">
							</xsl:when>-->
							<xsl:when test="count(tei:monogr/tei:title[@type='sub'])=0">
								<xsl:text>, </xsl:text>
							</xsl:when>
						</xsl:choose>




						<xsl:for-each select="tei:monogr/tei:title[@type='sub']">
							<xsl:value-of select="."/>
							<xsl:if
								test="count(current()/following-sibling::tei:title[@type='sub'])>0">
								<xsl:text>. </xsl:text>
							</xsl:if>
						</xsl:for-each>

						<!--						<xsl:choose>
							<xsl:when test="(count(tei:monogr/tei:title[@type='sub'])>0) and (count(tei:series/tei:title)=0)">
								<xsl:text>, </xsl:text>
							</xsl:when>
						</xsl:choose>-->

						<!--<xsl:text>, </xsl:text>-->

						<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
							<xsl:text>, </xsl:text>
						</xsl:if>

						<xsl:text>hg. v. </xsl:text>

						<xsl:for-each select="tei:monogr/tei:editor">
							<xsl:call-template name="EditorAlternativ">
								<xsl:with-param name="pEditor" select="."/>
							</xsl:call-template>
						</xsl:for-each>

						<xsl:if test="count(tei:series/tei:title)=0">
							<xsl:text>, </xsl:text>
						</xsl:if>

					</xsl:when>
					<xsl:otherwise>
						<xsl:if
							test="count(tei:monogr/tei:editor)>0 and tei:monogr/tei:editor!='Unbekannt'">
							<xsl:apply-templates select="tei:monogr/tei:editor"/>
							<xsl:text>, </xsl:text>
						</xsl:if>

						<xsl:for-each select="tei:monogr/tei:title[@type='main']">
							<xsl:apply-templates select="."/>
							<xsl:if
								test="count(current()/following-sibling::tei:title[@type='main'])>0">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>

						<xsl:choose>
							<xsl:when
								test="count(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][not(.='')])>0">
								<xsl:text>. </xsl:text>
								<xsl:value-of
									select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume']"/>
<!--								<xsl:if test="count(tei:monogr/tei:title[@type='sub'])>0">
									<xsl:text>.</xsl:text>
								</xsl:if>-->

								<xsl:choose>
									<xsl:when test="count(tei:monogr/tei:title[@type='sub'])>0">
										<xsl:text>.</xsl:text>
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
								<xsl:text>. </xsl:text>
							</xsl:when>
							<xsl:when
								test="(count(tei:monogr/tei:title[@type='sub'])=0) and (count(tei:series/tei:title)>0)"
							> </xsl:when>
						</xsl:choose>

						<xsl:text> </xsl:text>

						<xsl:for-each select="tei:monogr/tei:title[@type='sub']">
							<xsl:value-of select="."/>
							<xsl:if
								test="count(current()/following-sibling::tei:title[@type='sub'])>0">
								<xsl:text>. </xsl:text>
							</xsl:if>
						</xsl:for-each>

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



				<xsl:if test="count(tei:series/tei:title)>0">
					<xsl:text> </xsl:text>
					<xsl:text>(</xsl:text>
					<xsl:value-of select="tei:series/tei:title"/>
					<xsl:if test="count(tei:series/tei:biblScope)>0">
						<xsl:if test="not(tei:series/tei:biblScope='-')">
							<xsl:text> </xsl:text>
							<xsl:value-of select="tei:series/tei:biblScope"/>
						</xsl:if>
					</xsl:if>
					<xsl:text>)</xsl:text>
				</xsl:if>

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

				<xsl:if test="tei:monogr/tei:imprint/tei:pubPlace[.!='']">
					<!--<xsl:value-of select="tei:monogr/tei:imprint/tei:pubPlace"/>-->
					<xsl:for-each select="tei:monogr/tei:imprint/tei:pubPlace[.!='']">
						<xsl:if test="preceding-sibling::tei:pubPlace">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="number(tei:monogr/tei:edition/@n)>1">
					<sup>
					<!--<span class="sup">-->
						<xsl:value-of select="tei:monogr/tei:edition/@n"/>
					<!--</span>-->
					</sup>
				</xsl:if>
				<xsl:value-of select="tei:monogr/tei:imprint/tei:date"/>

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



				<xsl:for-each select="tei:note[@type='notes']"><br/>
					<div style="font-size:85%;line-height:100%;padding-top:1%;"><xsl:text> [</xsl:text>
						<xsl:value-of select="."/>
						<xsl:text>]</xsl:text></div>
				</xsl:for-each>


				<xsl:for-each select="tei:monogr/tei:idno[@type='URL']">
				  <xsl:call-template name="url" />
				</xsl:for-each>

			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tei:biblStruct[@type='journalArticle']">
		<tr>
			<td class="Lit">
				<xsl:apply-templates select="tei:analytic/tei:idno[@type='short_title']"/>
				<!--				<br/>
				<xsl:text>(</xsl:text><xsl:value-of select="@type"/><xsl:text>)</xsl:text>-->

				<!--<br/>-->
				<br/>

				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:author)=0">
						<!-- ohne Autor -->
						<xsl:apply-templates select="tei:analytic/tei:editor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:analytic/tei:author"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>

				<!--<xsl:apply-templates select="tei:analytic/tei:title[@type='main']"/>-->
				<xsl:for-each select="tei:analytic/tei:title[@type='main']">
					<xsl:apply-templates select="."/>

					<xsl:if test="count(current()/following-sibling::tei:title[@type='main'])>0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>

				<xsl:if test="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)][not(ancestor::tei:imprint)]">
					<!-- Bandnummer -->
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)][not(ancestor::tei:imprint)]"/>

					<xsl:if test="descendant::tei:title[not(@type='main')]">
						<!-- Untertitel folgt -->
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:if>

				<xsl:choose>
					<!--<xsl:when test="count(current()/following-sibling::tei:title[@type='sub'])>0">-->
					<xsl:when test="count(descendant::tei:title[@type='sub'])>0">
						<xsl:text>. </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>, </xsl:text>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:for-each select="tei:analytic/tei:title[@type='sub']">
					<xsl:apply-templates select="."/>

					<xsl:if test="count(following-sibling::tei:title[@type='sub'])>0">
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:choose>
					<xsl:when test="count(tei:analytic/tei:title[@type='sub'])>0">
						<xsl:text>, in: </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> in: </xsl:text>
					</xsl:otherwise>
				</xsl:choose>


				<xsl:if test="count(tei:monogr/tei:editor)>0">
					<xsl:apply-templates select="tei:monogr/tei:editor"/>
					<xsl:text>, </xsl:text>
				</xsl:if>
				<!--<xsl:apply-templates select="tei:monogr/tei:title[@type='main']"/>-->
				<xsl:for-each select="tei:monogr/tei:title[@type='main']">
					<!--<xsl:value-of select="."/>-->
					<xsl:apply-templates select="."/>
					<xsl:if test="count(current()/following-sibling::tei:title[@type='main'])>0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<!--<xsl:text>. </xsl:text>-->
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


				<xsl:if test="tei:monogr/tei:imprint/tei:pubPlace[.!='']">
					<xsl:value-of select="tei:monogr/tei:imprint/tei:pubPlace"/>
					<xsl:text> </xsl:text>
				</xsl:if>


				<xsl:text>(</xsl:text>

				<xsl:if test="number(tei:monogr/tei:edition/@n)>1">
					<sup>
					<!--<span class="sup">-->
						<xsl:value-of select="tei:monogr/tei:edition/@n"/>
					<!--</span>-->
					</sup>
				</xsl:if>

				<xsl:value-of select="tei:monogr/tei:imprint/tei:date"/>
				<xsl:text>) </xsl:text>

				<!--<xsl:text>, </xsl:text>-->
				<xsl:text>S. </xsl:text>
				<xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='page']"/>

				<xsl:for-each select="tei:note[@type='notes']"><br/>
					<div style="font-size:85%;line-height:100%;padding-top:1%;"><xsl:text> [</xsl:text>
						<xsl:value-of select="."/>
						<xsl:text>]</xsl:text></div>
				</xsl:for-each>

<!--				<xsl:if test="count(tei:analytic/tei:idno[@type='URL'])>0">
					<br/>
					<xsl:text>URL: </xsl:text>
					<a target="_blank" href="{tei:analytic/tei:idno[@type='URL']}">
						<xsl:value-of select="tei:analytic/tei:idno[@type='URL']"/>
					</a>
				</xsl:if>-->

				<xsl:for-each select="tei:analytic/tei:idno[@type='URL']">
				  <xsl:call-template name="url" />
				</xsl:for-each>

			</td>
		</tr>
	</xsl:template>


	<xsl:template match="tei:biblStruct[@type='webPublication']">
		<tr>
			<td class="Lit">

				<!--<xsl:text>(</xsl:text><xsl:value-of select="@type"/><xsl:text>)</xsl:text>-->

				<xsl:if test="tei:analytic">
					<xsl:apply-templates select="tei:analytic/tei:author"/>
					<xsl:apply-templates select="tei:analytic/tei:editor"/>
					<xsl:text>, </xsl:text>
					<!--<xsl:value-of select="tei:analytic/tei:title"/>-->
					<xsl:apply-templates select="tei:analytic/tei:title"/>
					<xsl:text>, auf: </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="tei:monogr/tei:idno[@type='short_title']"/>
				<!--<br/>-->
				<br/>
				<xsl:apply-templates select="tei:monogr/tei:author"/>
				<xsl:apply-templates select="tei:monogr/tei:editor"/>
				<xsl:text>, </xsl:text>
				<!--<xsl:value-of select="tei:monogr/tei:title"/>-->
				<xsl:apply-templates select="tei:monogr/tei:title"/>

				<xsl:if test="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]">
					<!-- Bandnummer -->
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="descendant::tei:biblScope[@unit='volume'][not(ancestor::tei:series)]"/>

					<xsl:if test="descendant::tei:title[not(@type='main')]">
						<!-- Untertitel folgt -->
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:if>



				<!--<xsl:text> (</xsl:text><a href="{tei:monogr/tei:idno[@type='URL']}"><xsl:value-of select="tei:monogr/tei:idno[@type='URL']"/></a><xsl:text>, </xsl:text><xsl:value-of select="tei:monogr/tei:date"/><xsl:text>)</xsl:text>-->

				<xsl:for-each select="tei:note[@type='notes']"><br/>
					<div style="font-size:85%;line-height:100%;padding-top:1%;"><xsl:text> [</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>]</xsl:text></div>
				</xsl:for-each>
<!--
				<br/>
				<xsl:text>URL: </xsl:text>
				<a target="_blank" href="{tei:monogr/tei:idno[@type='URL']}">
					<xsl:value-of select="tei:monogr/tei:idno[@type='URL']"/>
				</a>-->


				<xsl:for-each select="tei:monogr/tei:idno[@type='URL']">
				  <xsl:call-template name="url" />
				</xsl:for-each>

			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tei:author">
		<!--    	<xsl:choose>
            <xsl:when test="current()=current()/parent::node()/tei:author[1]">
                <!-\- Link nur auf ersten Author mit Anfangsbuchstabe [X] setzen -\-> <!-\- BAUSTELLE: Klappt das wirklich??? => Anders als gedacht...aber funktioniert zumindest.-\->
            	<xsl:variable name="linkID">
            		<xsl:value-of select="substring(descendant::tei:surname,1,1)"/>
            		<xsl:text>_</xsl:text>
            		<xsl:value-of select="ancestor::tei:biblStruct/@type"/>
            	</xsl:variable>

                <!-\-<span id="{substring(descendant::tei:surname,1,1)}" class="surname">-\->
                <span id="{$linkID}" class="surname">
                	<xsl:value-of select="descendant::tei:surname"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
            	<xsl:text> / </xsl:text>
            	<span class="surname">
	            	<xsl:value-of select="descendant::tei:surname"/>
            	</span>
            </xsl:otherwise>
        </xsl:choose>-->

		<xsl:if test="not(current()=current()/parent::node()/tei:author[1])">
			<xsl:text> / </xsl:text>
		</xsl:if>
		<span class="surname">
			<xsl:apply-templates select="descendant::tei:surname"/>
		</span>

		<xsl:choose>
			<xsl:when test="descendant::tei:forename">
				<xsl:text>, </xsl:text>
				<span class="forename">
					<!--<xsl:apply-templates select="descendant::tei:forename"/>-->
					<xsl:call-template name="gesVorname">
						<xsl:with-param name="pErster" select="descendant::tei:forename[1]"/>
					</xsl:call-template>
				</span>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="descendant::tei:note[@type='role']">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="descendant::tei:note[@type='role']"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:editor">
		<xsl:choose>
			<xsl:when test="./text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:when test="current()=current()/parent::node()/tei:editor[1]">
				<xsl:choose>
					<xsl:when test="descendant::tei:forename">
						<span class="forename">
							<!--<xsl:apply-templates select="descendant::tei:forename"/>-->
							<xsl:call-template name="gesVorname">
								<xsl:with-param name="pErster" select="descendant::tei:forename[1]"
								/>
							</xsl:call-template>
						</span>
						<xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
				<span class="surname">
					<xsl:value-of select="descendant::tei:surname"/>
				</span>
				<xsl:if test="descendant::tei:note[@type='role']">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="descendant::tei:note[@type='role']"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> / </xsl:text>
				<xsl:choose>
					<xsl:when test="descendant::tei:forename">
						<span class="forename">
							<!--<xsl:apply-templates select="descendant::tei:forename"/>-->
							<xsl:call-template name="gesVorname">
								<xsl:with-param name="pErster" select="descendant::tei:forename[1]"
								/>
							</xsl:call-template>
						</span>
						<xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
				<span class="surname">
					<xsl:value-of select="descendant::tei:surname"/>
				</span>
				<xsl:if test="descendant::tei:note[@type='role']">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="descendant::tei:note[@type='role']"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<!--    	<xsl:choose>
    		<xsl:when test="current()=current()/parent::node()/tei:editor[1]">
    			<span class="surname">
    				<xsl:value-of select="descendant::tei:surname"/>
    			</span>
    			<xsl:choose>
    				<xsl:when test="descendant::tei:forename">
    					<xsl:text>, </xsl:text>
    					<span class="forename">
    						<xsl:value-of select="descendant::tei:forename"/>
    					</span>
    				</xsl:when>
    			</xsl:choose>
    			<xsl:if test="descendant::tei:note[@type='role']">
    				<xsl:text> (</xsl:text><xsl:value-of select="descendant::tei:note[@type='role']"/><xsl:text>)</xsl:text>
    			</xsl:if>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:text> / </xsl:text>
    			<span class="surname">
    				<xsl:value-of select="descendant::tei:surname"/>
    			</span>
    			<xsl:choose>
    				<xsl:when test="descendant::tei:forename">
    					<xsl:text>, </xsl:text>
    					<span class="forename">
    						<xsl:value-of select="descendant::tei:forename"/>
    					</span>
    				</xsl:when>
    			</xsl:choose>
    			<xsl:if test="descendant::tei:note[@type='role']">
    				<xsl:text> (</xsl:text><xsl:value-of select="descendant::tei:note[@type='role']"/><xsl:text>)</xsl:text>
    			</xsl:if>
    		</xsl:otherwise>
    	</xsl:choose>-->
	</xsl:template>



	<xsl:template name="EditorAlternativ">
		<xsl:param name="pEditor"/>

		<xsl:choose>
			<xsl:when test="$pEditor/text()='Unbekannt'">
				<!-- NICHTS -->
			</xsl:when>
			<xsl:when test="$pEditor=$pEditor/parent::node()/tei:editor[1]">
				<xsl:choose>
					<xsl:when test="$pEditor/descendant::tei:forename">
						<span class="forename">
							<!--<xsl:apply-templates select="descendant::tei:forename"/>-->
							<xsl:call-template name="gesVorname">
								<xsl:with-param name="pErster"
									select="$pEditor/descendant::tei:forename[1]"/>
							</xsl:call-template>
						</span>
						<xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
				<span class="surname">
					<xsl:value-of select="$pEditor/descendant::tei:surname"/>
				</span>
				<!--				<xsl:if test="descendant::tei:note[@type='role']">
					<xsl:text> (</xsl:text><xsl:value-of select="descendant::tei:note[@type='role']"/><xsl:text>)</xsl:text>
				</xsl:if>-->
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> / </xsl:text>
				<xsl:choose>
					<xsl:when test="$pEditor/descendant::tei:forename">
						<span class="forename">
							<!--<xsl:apply-templates select="descendant::tei:forename"/>-->
							<xsl:call-template name="gesVorname">
								<xsl:with-param name="pErster"
									select="$pEditor/descendant::tei:forename[1]"/>
							</xsl:call-template>
						</span>
						<xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
				<span class="surname">
					<xsl:value-of select="$pEditor/descendant::tei:surname"/>
				</span>
				<!--				<xsl:if test="descendant::tei:note[@type='role']">
					<xsl:text> (</xsl:text><xsl:value-of select="descendant::tei:note[@type='role']"/><xsl:text>)</xsl:text>
				</xsl:if>-->
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
				<span>
					<!-- Hinzufügung short_title als name für Verlinkung - DS 09.09.2015 -->
					<xsl:attribute name="id">
						<xsl:value-of select="."/>
					</xsl:attribute>

					<xsl:choose>
						<xsl:when test="$pIdnoAsShortcode='y'">
							<!-- "Shortcode-Dummy" -->
							<xsl:text>[</xsl:text>
							<xsl:value-of select="$vNoUnderlineIDNO"/>
							<xsl:text>]</xsl:text>
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







<!--		<span>
			<!-\- Hinzufügung short_title als name für Verlinkung - DS 09.09.2015 -\->
			<xsl:attribute name="id">
				<xsl:value-of select="."/>
			</xsl:attribute>

			<xsl:choose>
				<xsl:when test="$pIdnoAsShortcode='y'">
					<!-\- "Shortcode-Dummy" -\->
					<xsl:text>[</xsl:text>
						<xsl:value-of select="$vNoUnderlineIDNO"/>
					<xsl:text>]</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!-\- keinen Shortcode verwenden => "fett" darstellen -\->
					<span style="font-weight: bold">
						<xsl:value-of select="$vNoUnderlineIDNO"/>
					</span>
				</xsl:otherwise>
			</xsl:choose>



<!-\-			<span style="text-decoration: underline">
				<xsl:value-of select="$vNoUnderlineIDNO"/>
			</span>-\->
			<!-\-<b><xsl:value-of select="$vNoUnderlineIDNO"/></b>-\->

		</span>-->


		<!--<span id="{substring(descendant::tei:surname,1,1)}" class="surname">-->
		<!--		<span id="{$vlinkID}">
			<!-\- Hinzufügung short_title als name für Verlinkung - DS 09.09.2015 -\->
			<xsl:attribute name="name"><xsl:value-of select="."/></xsl:attribute>

<!-\-			<xsl:choose>
				<xsl:when test="./ancestor::tei:biblStruct//tei:note/@target">
					<xsl:variable name="vTarget">
						<xsl:value-of select="./ancestor::tei:biblStruct//tei:note/@target"/>
					</xsl:variable>

					<!-\\- ACHTUNG: Unterscheidung der Ordner lit1/lit2 => Muss bei Umstrukturierung bzw. Umbenennung angepasst werden! -\\->
<!-\\-					<xsl:variable name="vTargetLit1">
						<xsl:value-of select="$vDigitalisatePfad"/>
						<xsl:text>/</xsl:text>
						<xsl:text>lit</xsl:text>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$vTarget"/>
					</xsl:variable>
					<xsl:variable name="vTargetLit2">
						<xsl:value-of select="$vDigitalisatePfad"/>
						<xsl:text>/</xsl:text>
						<xsl:text>lit2</xsl:text>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$vTarget"/>
					</xsl:variable>

					<xsl:variable name="vTargetAusgabe">
						<xsl:choose>
							<xsl:when test="document($vTargetLit1)">
								<xsl:value-of select="$vTargetLit1"/>
							</xsl:when>
							<xsl:when test="document($vTargetLit2)">
								<xsl:value-of select="$vTargetLit2"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Fehler: Datei nicht gefunden!</xsl:text>
								<xsl:text>(</xsl:text>
								<xsl:value-of select="$vDigitalisatePfad"/>
								<xsl:text>|</xsl:text>
								<xsl:value-of select="$vTargetLit1"/>
								<xsl:text>|</xsl:text>
								<xsl:value-of select="$vTargetLit2"/>
								<xsl:text>)</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>-\\->

					<xsl:variable name="vDigitalisatePfadUnterordner">
						<xsl:choose>
							<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Edition'">
								<!-\\-<xsl:text>Edition</xsl:text>-\\->
								<xsl:text>q</xsl:text>
							</xsl:when>
							<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text']/text()='Literatur'">
								<!-\\-<xsl:text>Literatur</xsl:text>-\\->
								<xsl:text>lit</xsl:text>
							</xsl:when>
							<xsl:when test="ancestor::tei:biblStruct/tei:note[@type='rel_text'][not(text()='Literatur') and not(text()='Edition')]">
								<!-\\-<xsl:text>Bibliothekskataloge</xsl:text>-\\->
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
							<!-\\-<xsl:value-of select="$vTargetAusgabe"/>-\\->
						</xsl:attribute>
						<xsl:attribute name="target">
							<!-\\- Link in neuem Fenster/Tab öffnen -\\->
							<xsl:text>_blank</xsl:text>
						</xsl:attribute>
						<!-\\-<xsl:value-of select="."/>-\\->
						<xsl:value-of select="$vNoUnderlineIDNO"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<!-\\-<xsl:value-of select="."/>-\\->
					<xsl:value-of select="$vNoUnderlineIDNO"/>
				</xsl:otherwise>
			</xsl:choose>-\->

			<b><xsl:value-of select="$vNoUnderlineIDNO"/></b>

		</span>-->
	</xsl:template>


	<xsl:template match="//tei:title">
		<xsl:apply-templates select="node()"/>
		<!--<xsl:value-of select="."/>-->
	</xsl:template>

	<xsl:template match="//tei:hi[@rend='italic']">
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>


	<!-- XSLT 1.0 "FUNKTIONEN"

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
	</xsl:template> -->


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
