<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0">

        <xsl:include href="xsl-output.xsl"/>
	<xsl:include href="base_variables.xsl"/>

	<!-- author: NG -->

	<xsl:include href="allgFunktionen.xsl"/>

	<xsl:strip-space elements="tei:*"/>
<!--

	<xsl:variable name="vAdd_mMetamark" select="//tei:add[following-sibling::*[1][local-name(.)='metamark']]"/>
	<xsl:variable name="vAdd_oMetamark" select="//tei:add[not(following-sibling::*[1][local-name(.)='metamark'])]"/>

	<xsl:variable name="vAdd_oNote" select="$vAdd_mMetamark[not(following-sibling::*[2][local-name(.)='note'])]|$vAdd_oMetamark[not(following-sibling::*[1][local-name(.)='note'])]"/>

	-->


	<xsl:variable name="vAdd_mNote" select="//tei:ab/tei:add[following-sibling::*[1][local-name(.)='note']]|//tei:ab/tei:add[(following-sibling::*[1][local-name(.)='lb'] or following-sibling::*[1][local-name(.)='metamark']) and following-sibling::*[2][local-name(.)='note']]|//tei:ab/tei:add[(following-sibling::*[1][local-name(.)='lb'] or following-sibling::*[1][local-name(.)='metamark']) and (following-sibling::*[2][local-name(.)='lb'] or following-sibling::*[2][local-name(.)='metamark']) and following-sibling::*[3][local-name(.)='note']]"/>
	<xsl:variable name="vAdd_oNote" select="//tei:ab/tei:add[not($vAdd_mNote)]"/>

	<xsl:variable name="vDel_mNote" select="//tei:ab/tei:del[following-sibling::*[1][local-name(.)='note']]|//tei:ab/tei:del[(following-sibling::*[1][local-name(.)='lb'] or following-sibling::*[1][local-name(.)='metamark']) and following-sibling::*[2][local-name(.)='note']]|//tei:ab/tei:del[(following-sibling::*[1][local-name(.)='lb'] or following-sibling::*[1][local-name(.)='metamark']) and (following-sibling::*[2][local-name(.)='lb'] or following-sibling::*[2][local-name(.)='metamark']) and following-sibling::*[3][local-name(.)='note']]"/>
	<xsl:variable name="vDel_oNote" select="//tei:ab/tei:del[not($vDel_mNote)]"/>

	<xsl:variable name="vSubst_mNote" select="//tei:ab/tei:subst[following-sibling::*[1][local-name(.)='note']]|//tei:ab/tei:subst[(following-sibling::*[1][local-name(.)='lb'] or following-sibling::*[1][local-name(.)='metamark']) and following-sibling::*[2][local-name(.)='note']]|//tei:ab/tei:subst[(following-sibling::*[1][local-name(.)='lb'] or following-sibling::*[1][local-name(.)='metamark']) and (following-sibling::*[2][local-name(.)='lb'] or following-sibling::*[2][local-name(.)='metamark']) and following-sibling::*[3][local-name(.)='note']]"/>
	<xsl:variable name="vSubst_oNote" select="//tei:ab/tei:subst[not($vSubst_mNote)]"/>

	<!-- VARIABLEN für Fußnoten(-index) -->
	<xsl:variable name="funoRef" select="//tei:cit/tei:ref"/>
	<xsl:variable name="funoSic" select="//tei:sic"/>
	<xsl:variable name="funoNote" select="//tei:note[@type='editorial']"/>
	<xsl:variable name="funoSubst" select="$vSubst_oNote"/>
	<xsl:variable name="funoDel" select="$vDel_oNote"/>
	<xsl:variable name="funoAdd" select="$vAdd_oNote"/>
	<xsl:variable name="funoSpace" select="//tei:space"/>
	<xsl:variable name="funoUnclear" select="//tei:unclear[count(tei:gap)>0]"/>

	<!-- alphabetischer Fußnotenindex -->
	<xsl:variable name="funoAlphabetisch" select="$funoSic|$funoNote|$funoSubst|$funoDel|$funoAdd|$funoSpace|$funoSpace"/>

	<!-- numerischer Fußnotenindex -->
	<xsl:variable name="funoNumerisch" select="$funoRef"/>


	<xsl:template match="/">
		<HTML lang="de">
			<HEAD>
				<meta charset="utf-8"/>
				<TITLE>
					<xsl:value-of select="//tei:title"/>
				</TITLE>

				<style type="text/css">
                    body { <!-- allgemeine Darstellung des Textes -->
                        <!--font-family: 'Times New Roman';-->
                        line-height: 100%;
                        <!--font-size: medium-->
						font-size: 90%
                        }
                    span.titel {
                        font-weight: bold;
                        font-size: 110%
                        }

                    span.encodingDesc {
                    	<!--display: inline-block;-->
                    	<!--font-style: italic;-->
                    	font-size: 90%
                    	}

                    div.text {
                    	<!--display: inline-block;-->

						white-space: nowrap;

                    	line-height: 200%;
                    	font-size: 120%
                    	}

					<!-- Hinzufügung durch DS am 29.08.2014, da sonst komplette WP-Seite inklusive Header und Menü in Times New Roman -->
					div.meta {
					line-height: 100%;
					font-family: 'Times New Roman'
					}

                    div.initial { <!-- Initialen -->
                        display: inline-block;
                        font-family: arial;
                        font-weight: bold
					<!--
                    	color: white;
                        background-color: black
					-->
                        }
                    span.initialABC { <!-- Initialen, Buchstaben -->
                        font-size: 110%
                        }
                    span.initialTYP { <!-- Initialen, Typ-Marker -->
                        font-size: 50%;
                        vertical-align: top
                        }
                    span.versalie {
                        font-size: 110%;
                        font-weight: bold
                        }

                    span.folio {
                    	font-weight: bold;
                    	font-style: italic
                    	}

                    span.milestone {
                        line-height: 100%;
                        font-size: 110%;
                        font-weight: bold
                        }
                    span.quote {
                        font-size: 100%;
                        font-weight: normal
                        }
					span.unclear {
						color: lightgrey;
                        }
                    span.abTEXT { <!-- Darstellung innerhalb <ab type="text"> -->
<!--                    line-height: 200%;
                        font-size: 120%-->
                        }
                    span.abMETA { <!-- Darstellung innerhalb <ab type="meta-text"> -->
<!--                    line-height: 200%;
                        font-size: 120%;-->
                        font-weight: bold
                        }

					span.hiSuper {
						vertical-align: top;
						font-size: 60%
					}

					ol.alphabetisch {
                        list-style:lower-alpha outside none;
                        }
					ol.numerisch {

                        }


                </style>
			</HEAD>
			<BODY>
				<!-- TITLE -->
				<div class="meta"><p><xsl:apply-templates select="//tei:teiHeader"/></p>
				</div>

				<br/>
				<!-- ??? für Abstand zwischen Header und Body -->
				<br/>
				<!-- ??? für Abstand zwischen Header und Body -->
				<!-- BODY -->
				<div class="text">
					<xsl:apply-templates select="//tei:body"/>
				</div>

				<br/>
				<br/>
				<hr/>

				<!-- Fußnoten -->

				<!-- numerische Fußnoten -->
				<ol type="1" class="numerisch">
					<xsl:for-each select="$funoNumerisch">
						<li id="{generate-id()}">
							<xsl:apply-templates select="./node()"/>
							<a href="#{generate-id()}-L" class="noteBack">&#x2934;</a>
						</li>
					</xsl:for-each>
				</ol>

				<!-- alphabetische Fußnoten -->
				<ol type="a" class="alphabetisch">
					<xsl:for-each select="$funoAlphabetisch">
						<li id="{generate-id()}">
							<xsl:choose>
								<xsl:when test="local-name(.)='sic'">
									<xsl:text>Sic Hs.</xsl:text>
								</xsl:when>
								<xsl:when test="local-name(.)='note'">
									<xsl:if test="@target">
										<xsl:variable name="vPrecSeg" select="preceding-sibling::node()[1][local-name(.)='span'][@xml:id]"/>
										<xsl:variable name="vBezug">
											<xsl:value-of select="$vPrecSeg/text()[1]"/>
											<xsl:value-of select="$vPrecSeg/tei:add"/>
											<xsl:value-of select="substring-before($vPrecSeg/text()[last()],' ')"/>
											<xsl:text>...</xsl:text>
											<xsl:value-of select="substring-after($vPrecSeg/text()[last()],' ')"/>
											<xsl:text>: </xsl:text>
										</xsl:variable>
										<xsl:value-of select="$vBezug"/>
									</xsl:if>
									<xsl:apply-templates select="node()"/>
								</xsl:when>
								<xsl:when test="local-name(.)='subst'">
									<xsl:variable name="vWortUmKnoten">
										<xsl:call-template name="WortUmKnoten">
											<xsl:with-param name="pKnoten" select="tei:del"/>
										</xsl:call-template>
									</xsl:variable>

									<xsl:choose>
										<xsl:when test="substring(tei:del/text(),1,1)='a' or substring(tei:del/text(),1,1)='e' or substring(tei:del/text(),1,1)='i' or substring(tei:del/text(),1,1)='o' or substring(tei:del/text(),1,1)='u'">
											<xsl:text>ex </xsl:text>
											<xsl:value-of select="$vWortUmKnoten"/>
											<xsl:text> corr.</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>e </xsl:text>
											<xsl:value-of select="$vWortUmKnoten"/>
											<xsl:text> corr.</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="local-name(.)='del'">
									<xsl:choose>
										<xsl:when test="count(@rend)>0">
											<!-- mit @rend => <del> hinter Worte -->

											<xsl:text>Folgt </xsl:text>

											<xsl:choose>
												<xsl:when test="@rend='scratched'">
													<xsl:text>radiertes</xsl:text>
												</xsl:when>
												<xsl:when test="@rend='expunged'">
													<xsl:text>expungiertes</xsl:text>
												</xsl:when>
												<xsl:when test="@rend='strikethrough'">
													<xsl:text>gestrichenes</xsl:text>
												</xsl:when>
												<xsl:when test="@rend='underlined'">
													<xsl:text>durch Unterstreichung getilgtes</xsl:text>
												</xsl:when>
											</xsl:choose>
											<xsl:text> </xsl:text>
											<xsl:value-of select="."/>
											<!--<xsl:apply-templates select="./text()"/>-->
										</xsl:when>
										<xsl:otherwise>
											<!-- ohne @rend => <del> innerhalb des Wortes -->

											<xsl:variable name="vWortUmKnoten">
												<xsl:call-template name="WortUmKnoten">
													<xsl:with-param name="pKnoten" select="."/>
												</xsl:call-template>
											</xsl:variable>

											<xsl:choose>
												<xsl:when test="substring(./text(),1,1)='a' or substring(./text(),1,1)='e' or substring(./text(),1,1)='i' or substring(./text(),1,1)='o' or substring(./text(),1,1)='u'">
													<xsl:text>ex </xsl:text>
													<xsl:value-of select="$vWortUmKnoten"/>
													<xsl:text> corr.</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>e </xsl:text>
													<xsl:value-of select="$vWortUmKnoten"/>
													<xsl:text> corr.</xsl:text>
												</xsl:otherwise>
											</xsl:choose>

										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="local-name(.)='add'">
<!--									<xsl:choose>
										<xsl:when test="following-sibling::*[1][local-name(.)='note']">
											<!-\- wenn <note> folgt -\->
											<!-\-<xsl:value-of select="following-sibling::*[1][name()='note']"/>-\->
											<!-\-<xsl:apply-templates select="following-sibling::*[1][name()='note']"/>-\->
											<xsl:value-of select="following-sibling::*[1][local-name(.)='note']"/>

											<!-\- erzeugt Duplikat?! -\->
										</xsl:when>
										<xsl:when test="following-sibling::*[1][local-name(.)='metamark'] and following-sibling::*[2][local-name(.)='note']">
											<xsl:value-of select="following-sibling::*[1][local-name(.)='note']"/>

											<!-\- erzeugt Duplikat?! -\->
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="following-sibling::*[1][local-name(.)='metamark']">
												<xsl:text>mit Einfügungszeichen </xsl:text>
											</xsl:if>
											<xsl:text>ergänzt </xsl:text>
											<xsl:value-of select="."/>
											<xsl:text> </xsl:text>
											<xsl:choose>
												<xsl:when test=".">

												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when test="./@place='above'">
															<xsl:text>über der Zeile</xsl:text>
														</xsl:when>
														<xsl:when test="./@place='margin'">
															<xsl:text>am Rand</xsl:text>
														</xsl:when>
														<xsl:when test="./@place='inline'">
															<xsl:text>in der Zeile</xsl:text>
														</xsl:when>
														<xsl:when test="./@place='inspace'">
															<xsl:text>in der Zeile in frei gelassenem Raum</xsl:text>
														</xsl:when>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>-->

									<xsl:if test="following-sibling::*[1][local-name(.)='metamark']">
										<xsl:text>mit Einfügungszeichen </xsl:text>
									</xsl:if>
									<xsl:text>ergänzt </xsl:text>
									<xsl:value-of select="."/>
									<xsl:text> </xsl:text>
									<xsl:choose>
										<xsl:when test=".">

										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="./@place='above'">
													<xsl:text>über der Zeile</xsl:text>
												</xsl:when>
												<xsl:when test="./@place='margin'">
													<xsl:text>am Rand</xsl:text>
												</xsl:when>
												<xsl:when test="./@place='inline'">
													<xsl:text>in der Zeile</xsl:text>
												</xsl:when>
												<xsl:when test="./@place='inspace'">
													<xsl:text>in der Zeile in frei gelassenem Raum</xsl:text>
												</xsl:when>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="local-name(.)='unclear'">
									<xsl:text>Lücke von ca. </xsl:text>
									<xsl:value-of select="./@quantity"/>
									<xsl:choose>
										<xsl:when test="./@unit='chars'">
											<xsl:text> Buchstaben</xsl:text>
										</xsl:when>
										<xsl:when test="./@unit='words'">
											<xsl:text> Wörtern</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="local-name(.)='space'">
									<xsl:text>Lücke von ca. </xsl:text>
									<xsl:value-of select="./@quantity"/>
									<xsl:choose>
										<xsl:when test="./@unit='chars'">
											<xsl:text> Buchstaben</xsl:text>
										</xsl:when>
										<xsl:when test="./@unit='words'">
											<xsl:text> Wörtern</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
							<a href="#{generate-id()}-L" class="noteBack">&#x2934;</a>
						</li>
					</xsl:for-each>
				</ol>
			</BODY>
		</HTML>
	</xsl:template>

	<!--
    #############################################################################################
      -->

	<xsl:template match="//tei:title">
		<span class="titel">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:publisher">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="//tei:encodingDesc">
		<br/>

		<span class="encodingDesc">
			<xsl:apply-templates select="node()"/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:encodingDesc//text()">
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:encodingDesc/tei:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="//tei:encodingDesc/tei:p/tei:mentioned">
		<!-- BAUSTELLE ??? -->
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="//tei:revisionDesc">
		<b>
			<xsl:text>Bearbeitung</xsl:text>
		</b>
		<br/>
		<xsl:for-each select="tei:change">
			<xsl:value-of select="text()"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="@who"/>
			<xsl:text> (</xsl:text>
			<xsl:value-of select="@when"/>
			<xsl:text>)</xsl:text>
			<br/>
		</xsl:for-each>
	</xsl:template>

	<!-- zusätzliche Formatierung -->
	<xsl:template match="//tei:fileDesc">
		<xsl:apply-templates select="./tei:titleStmt"/>
		<br/>
		<xsl:apply-templates select="./tei:publicationStmt"/>
	</xsl:template>

	<xsl:template match="//tei:respStmt">
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

	<xsl:template match="//tei:body/tei:ab[@type='text']">
		<span class="abTEXT" lang="la">
			<xsl:apply-templates/>
		</span>
		<!--<br/>-->
	</xsl:template>
	<xsl:template match="//tei:body/tei:ab[@type='meta-text']">
		<span class="abMETA" lang="la">
			<xsl:apply-templates/>
		</span>
		<!--<br/>-->
	</xsl:template>

	<xsl:template match="//tei:seg[@type[.='titulus' or .='numDenom' or .='num']][@rend[.='majuscule red']]">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>

	<xsl:template match="//tei:lb">
		<!-- <lb> ignorieren ?!? -->


		<!-- BAUSTELLE: =><lb> ignorieren! -->
		<xsl:choose>
			<xsl:when test="current()[@break='no']">
				<xsl:text>-</xsl:text>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<br/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:lb[parent::node()[@place='margin']]">
	</xsl:template>

	<xsl:template match="//tei:cb">
		<xsl:choose>
			<xsl:when test="current()[@break='no']">
				<xsl:text>-</xsl:text>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<br/>
			</xsl:otherwise>
		</xsl:choose>

		<span class="folio">
			<xsl:choose>
				<!--<xsl:when test="substring(@n,2,1)='r'">-->
				<!--<xsl:when test="contains(@n,'r')">-->
				<xsl:when test="substring(@n,2,1)='r'">
					<!-- recto -->
					<xsl:text>[Fol. </xsl:text>
					<xsl:value-of select="./@n"/>
					<xsl:text>] </xsl:text>
				</xsl:when>
				<xsl:when test="substring(@n,2,1)='v'">
					<!-- verso -->
					<xsl:text>[Fol. </xsl:text>
					<xsl:value-of select="./@n"/>
					<xsl:text>] </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!-- sonst -->
					<xsl:text>[p. </xsl:text>
					<xsl:value-of select="./@n"/>
					<xsl:text>] </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<xsl:template match="//tei:milestone">
		<br/>
		<span class="milestone">
			<xsl:value-of select="./@n"/>
		</span>
		<br/>
	</xsl:template>


	<!-- Typ-Unterscheidung hinzufügen!!! -->
	<!--
            Die einzelnen Typen sollen optisch unterscheidbar sein, ohne daß man Farbe verwenden muß.
            Alle größer und fett; zusätzlich zur Unterscheidung verschiedene Größen/Schrifttypen?
        -->
	<xsl:template match="//tei:seg[substring-before(@type,'-')='initial']">
		<xsl:element name="div">
			<xsl:attribute name="class">initial</xsl:attribute>
			<xsl:attribute name="title"><xsl:text>Initiale, Typ </xsl:text><xsl:value-of select="substring-after(@type, '-')"/></xsl:attribute>
<!--			<xsl:element name="span">
				<xsl:attribute name="class">initialTYP</xsl:attribute>

				<xsl:value-of select="substring-after(@type, '-')"/>
			</xsl:element>-->
			<xsl:element name="span">
				<xsl:attribute name="class">initialABC</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="//tei:seg[@type='versalie']">
		<!-- BAUSTELLE: VERSALIEN => Gibt es bisher noch nicht?! -->
		<span class="versalie">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:mentioned/text()">
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:cit">
		<xsl:apply-templates select="tei:quote"/>
		<xsl:apply-templates select="tei:ref"/>
	</xsl:template>

	<xsl:template match="//tei:cit/tei:quote">
		<span class="quote">
			<xsl:text>&#8222;</xsl:text>
		</span>
		<xsl:apply-templates select="./node()"/>
		<span class="quote">
			<xsl:text>&#8220;</xsl:text>
		</span>

	</xsl:template>

	<xsl:template match="//tei:cit/tei:ref">
		<xsl:variable name="refIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="//tei:cit/tei:ref"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink" title="{.}">
			<!--<sup>[<xsl:value-of select="$refIndex"/>]</sup>-->
			<sup><xsl:value-of select="$refIndex"/></sup>
		</a>
	</xsl:template>

	<!-- Hinzufügung durch DT am 27.08.2014, um auf externe Ressourcen wie die dMGH verlinken zu können (modifiziert durch NG am 04.09.2014: um mehrdeutige Regeln zu beseitigen => [@type] => tei:ref auf type-Attribut prüfen - Template muss möglicherweise noch ansich mit anderem ref-Template abgeglichen/angepasst werden)  -->
	<xsl:template match="//tei:ref[@type]">
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
			<!--<xsl:when test="@type='internal'">
				<xsl:if test="@subtype='mss'">
					<a>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:attribute name="title">interner Link</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$mss"/>
						<xsl:value-of select="substring-before(@target,'_')"/>
						<xsl:text>#</xsl:text>
						<xsl:value-of select="substring-after(@target,'_')"/>
					</xsl:attribute>
					<xsl:apply-templates/>
				</a></xsl:if>
			</xsl:when>-->
			<!-- mögliche andere Fälle wären Personen oder Orte - Normdaten! -->
		</xsl:choose>
	</xsl:template>

	<xsl:template match="//tei:note[@type='editorial'][not(@target)]">
		<xsl:variable name="noteIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<!--<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink" title="{.}">-->
		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
			<sup><xsl:value-of select="$noteIndex"/></sup>
		</a>
	</xsl:template>

<!--	<xsl:template match="//tei:note[@type='editorial'][@target]">
		<!-\- Note=“editorial“: als Fußnoten (Buchstaben) anzeigen. ??? -\->
		<!-\- als Teil von "Erstreckungsfußnote" -\->
		<xsl:variable name="noteIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoSicNote"/>
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
<!-\-				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="$vBezug"/>
				</xsl:call-template>-\->
			</xsl:attribute>
			<sup>[<xsl:value-of select="$noteIndex"/>]</sup>
		</a>
	</xsl:template>-->
	<xsl:template match="//tei:note[@type='editorial'][@target]">
		<!-- als Teil von "Erstreckungsfußnote" -->
		<xsl:variable name="noteIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
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
<!--								<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="$vBezug"/>
				</xsl:call-template>-->
			</xsl:attribute>
			<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
			<sup><xsl:value-of select="$noteIndex"/></sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:sic">
		<xsl:variable name="sicIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates select="node()"/> <!-- Beobachten: Könnte problematisch sein?! -->
		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink" title="Sic Hs.">
			<!--<sup>[<xsl:value-of select="$sicIndex"/>]</sup>-->
			<sup><xsl:value-of select="$sicIndex"/></sup>
		</a>
	</xsl:template>

	<xsl:template match="//text()[following-sibling::*[1][local-name(.)='subst'][not(following-sibling::*[1][local-name(.)='note'])]]">
		<!-- Text VOR <subst> -->
		<xsl:variable name="vWortteil">
			<xsl:call-template name="LastSubstringAfter">
				<!--<xsl:with-param name="pString" select="."/>-->
				<xsl:with-param name="pString" select="."/>
				<xsl:with-param name="pCharacter"><xsl:text> </xsl:text></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vLaengeWortteil">
			<xsl:value-of select="string-length($vWortteil)"/>
		</xsl:variable>

		<xsl:variable name="vStringVorWortteil">
			<!--<xsl:value-of select="substring(.,string-length(.),string-length(.)-$vLaengeWortteil)"/>-->
			<xsl:value-of select="substring(.,1,string-length(.)-$vLaengeWortteil)"/>
		</xsl:variable>

		<xsl:value-of select="$vStringVorWortteil"/>
	</xsl:template>

	<xsl:template match="//text()[preceding-sibling::*[1][local-name(.)='subst'][not(following-sibling::*[1][local-name(.)='note'])]]">
		<!-- Text NACH <subst> -->

		<xsl:variable name="vWortteil">
			<xsl:value-of select="substring-before(.,' ')"/>
		</xsl:variable>

		<xsl:variable name="vLaengeWortteil">
			<xsl:value-of select="string-length($vWortteil)"/>
		</xsl:variable>

		<xsl:variable name="vStringNachWortteil">
			<xsl:value-of select="substring(.,1+$vLaengeWortteil)"/>
		</xsl:variable>

		<xsl:value-of select="$vStringNachWortteil"/>

	</xsl:template>

<!--	<xsl:template match="//tei:subst[not(following-sibling::*[1][local-name(.)='note'])]">

		<xsl:variable name="vWortUmKnoten">
			<xsl:call-template name="WortUmKnoten">
				<xsl:with-param name="pKnoten" select="tei:add"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$vWortUmKnoten"/>
		<!-\-<xsl:value-of select="tei:add"/>-\->

		<xsl:variable name="noteIndex">
			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<!-\-<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-\->
			<sup><xsl:value-of select="$noteIndex"/></sup>
		</a>
	</xsl:template>-->

<!--	<xsl:template match="//tei:subst[following-sibling::*[1][local-name(.)='note']]">
		<xsl:apply-templates select="tei:add"/>
	</xsl:template>	-->

<!--	<xsl:template match="//tei:add[not(parent::*[local-name(.)='subst']) and not(parent::*[local-name(.)='num'])][not(following-sibling::*[1][local-name(.)='note'])]">
		<!-\- BAUSTELLE?!? -\->

		<xsl:variable name="vWortUmKnoten">
			<xsl:call-template name="WortUmKnoten">
				<xsl:with-param name="pKnoten" select="tei:add"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$vWortUmKnoten"/>
		<!-\-<xsl:value-of select="tei:add"/>-\->

		<xsl:variable name="addIndex">
			<xsl:call-template name="indexOf_a">
				<!-\-<xsl:with-param name="pSeq" select="$funoSicNote"/>-\->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<!-\-<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-\->
			<sup><xsl:value-of select="$addIndex"/></sup>
		</a>
	</xsl:template>-->

	<xsl:template match="//tei:ab/tei:subst">
		<xsl:variable name="vNoteFolgt">
			<xsl:call-template name="tNoteFolgt">
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vNoteFolgt=true()">
				<xsl:apply-templates select="node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="vWortUmKnoten">
					<xsl:call-template name="WortUmKnoten">
						<xsl:with-param name="pKnoten" select="tei:add"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:value-of select="$vWortUmKnoten"/>
				<!--<xsl:value-of select="tei:add"/>-->

				<xsl:variable name="noteIndex">
					<xsl:call-template name="indexOf_a">
						<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
						<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
						<xsl:with-param name="pNode" select="."/>
					</xsl:call-template>
				</xsl:variable>

				<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
					<xsl:attribute name="title">
						<xsl:call-template name="tooltip">
							<xsl:with-param name="pNode" select="."/>
						</xsl:call-template>
					</xsl:attribute>
					<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
					<sup><xsl:value-of select="$noteIndex"/></sup>
				</a>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	<xsl:template match="//tei:ab/tei:subst/tei:add">
		<xsl:value-of select="./text()"/>
	</xsl:template>
	<xsl:template match="//tei:ab/tei:subst/tei:del">
		<xsl:value-of select="./text()"/>
	</xsl:template>

	<xsl:template match="//tei:ab/tei:add">



		<xsl:variable name="vWortUmKnoten">
			<xsl:call-template name="WortUmKnoten">
				<xsl:with-param name="pKnoten" select="tei:add"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$vWortUmKnoten"/>
		<!--<xsl:value-of select="tei:add"/>-->

		<xsl:variable name="addIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<!--<sup>[<xsl:value-of select="$noteIndex"/>]</sup>-->
			<sup><xsl:value-of select="$addIndex"/></sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:ab/tei:del">

	</xsl:template>

	<xsl:template match="//tei:ab/tei:num/tei:add">
		<sup>
			<xsl:value-of select="."/>
		</sup>
	</xsl:template>

	<xsl:template match="//tei:add[not(parent::*[local-name(.)='subst']) and not(parent::*[local-name(.)='num'])][following-sibling::*[1][local-name(.)='note']]">
		<!-- BAUSTELLE?!? -->


	</xsl:template>

<!--	<xsl:template match="//tei:add[parent::*[local-name(.)='num']]">
		<sup>
			<xsl:value-of select="."/>
		</sup>
	</xsl:template>-->

	<xsl:template match="//tei:add/text()">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="//tei:del[not(parent::*[local-name(.)='subst'])][not(following-sibling::*[1][local-name(.)='note'])]">
		<!-- BAUSTELLE?!? -->
		<xsl:choose>
			<xsl:when test="count(@rend)>0">
				<!-- ...es wird nur der Index mit Hyperlink an das vorangehende Wort angehängt... -->
			</xsl:when>
			<xsl:otherwise>
				<!-- ohne @rend => <del> innerhalb des Wortes -->
				<xsl:variable name="vWortUmKnoten">
					<xsl:call-template name="WortUmKnoten">
						<xsl:with-param name="pKnoten" select="."/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:value-of select="$vWortUmKnoten"/>


			</xsl:otherwise>
		</xsl:choose>


		<!-- Index mit Hyperlink auf Fußnote anhängen -->
		<xsl:variable name="delIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<sup><xsl:value-of select="$delIndex"/></sup>
		</a>


	</xsl:template>

	<xsl:template match="//tei:del/text()">
	</xsl:template>

	<xsl:template match="//tei:choice">
		<span title="{./tei:abbr/text()}">
			<xsl:value-of select="./tei:expan/text()"/>
			<xsl:text> [</xsl:text>
			<xsl:value-of select="./tei:abbr/text()"/>
			<xsl:text>]</xsl:text>
		</span>
	</xsl:template>

	<xsl:template match="//tei:unclear[count(tei:gap)>0]">
		<xsl:text>...</xsl:text>

		<xsl:variable name="unclearIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<sup><xsl:value-of select="$unclearIndex"/></sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:unclear[count(tei:gap)=0]">
<!--		<span class="unclear" title="{following-sibling::*[1][name()='note']}">
			<xsl:apply-templates select="node()"/>
		</span>-->
		<u>
			<xsl:apply-templates select="node()"/>
		</u>
	</xsl:template>

	<xsl:template match="//tei:expan">
		<i>
			<xsl:apply-templates select="node()"/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:ex">
		<i>
			<xsl:apply-templates select="node()"/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:space">
		<xsl:text>---</xsl:text>

		<!-- Index mit Hyperlink auf Fußnote anhängen -->
		<xsl:variable name="spaceIndex">
			<xsl:call-template name="indexOf_a">
				<!--<xsl:with-param name="pSeq" select="$funoSicNote"/>-->
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<xsl:attribute name="title">
				<xsl:call-template name="tooltip">
					<xsl:with-param name="pNode" select="."/>
				</xsl:call-template>
			</xsl:attribute>
			<sup><xsl:value-of select="$spaceIndex"/></sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:date">
		<xsl:value-of select="./text()"/>
	</xsl:template>

	<xsl:template match="//tei:metamark">
		<!-- metamark vorerst ignorieren -->
	</xsl:template>

	<xsl:template match="//tei:hi[@rend='super']">
		<!--  -->
		<span class="hiSuper"><xsl:value-of select="."/></span>
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
	<xsl:template match="//tei:span[@xml:id]">
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


	<!-- ################################# zusätzliche "Funktionen"/Templates -->

	<xsl:template name="tooltip">
		<!-- Tooltip/Title in <a> aufhübschen -->
		<xsl:param name="pNode"/>

		<xsl:for-each select="$pNode/node()">
			<!--<xsl:value-of select="."/>-->

			<xsl:choose>
				<!--<xsl:when test="./child::node()">-->
				<xsl:when test="node()">
					<xsl:call-template name="tooltip">
						<xsl:with-param name="pNode" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="contains(.,'&#xA;')">
							<!-- Zeilenumbruchszeichen ersetzen! -->
							<xsl:variable name="ohneZeilenumbruch">
								<xsl:call-template name="string-replace">
									<xsl:with-param name="string" select="."/>
									<xsl:with-param name="replace" select="'&#xA;'"/>
									<xsl:with-param name="with" select="''"/>
								</xsl:call-template>
							</xsl:variable>

							<xsl:call-template name="string-replace">
								<xsl:with-param name="string" select="$ohneZeilenumbruch"/>
								<xsl:with-param name="replace" select="'  '"/>
								<xsl:with-param name="with" select="''"/>
							</xsl:call-template>

							<!-- PROBLEM: Immernoch Whitespace! -->
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="WortUmKnoten">
		<!-- gibt das Wort aus, innerhalb dessen sich die getaggte Zeichenkette/das getaggte Zeichen befinden => ACHTUNG: Benötigt text() vor und nach Knoten!-->
		<xsl:param name="pKnoten"></xsl:param>

		<xsl:call-template name="LastSubstringAfter">
			<!--<xsl:with-param name="pString" select="."/>-->
			<xsl:with-param name="pString" select="./preceding-sibling::text()[1]"/>
			<xsl:with-param name="pCharacter"><xsl:text> </xsl:text></xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$pKnoten"/>
		<!--<xsl:value-of select="substring-before(./following-sibling::text()[1],' ')"/>-->
		<xsl:value-of select="substring-before(./following-sibling::text()[1],' ')"/>

	</xsl:template>

	<xsl:template name="LastSubstringAfter">
		<!-- sucht hinter erstem Fund des Zeichens noch weiter in Zeichenkette und liefert den zuletzt gefundenen substring-after() -->
		<xsl:param name="pString"/>
		<xsl:param name="pCharacter"/>

		<xsl:variable name="vSubstringAfter" select="substring-after($pString,$pCharacter)"/>

		<xsl:choose>
			<xsl:when test="string-length($vSubstringAfter)>0">
				<!-- Zeichen/Zeichenkette in String gefunden -->
				<xsl:variable name="vLastSubstringAfter">
					<!-- Rekursion -->
					<xsl:call-template name="LastSubstringAfter">
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

<!--	<xsl:template name="PositionVonIn">
		<!-\- ermittelt Position von Zeichen in Zeichenkette -\->
		<xsl:param name="pZeichenkette"/>
		<xsl:param name="pZeichen"/>



	</xsl:template>-->

<!--
		Templates benötigt:
		=> Position von Zeichen X in Zeichenkette Y


	-->


	<xsl:template name="tNoteFolgt">
		<xsl:param name="pNode"/>


		<!-- vllt doch rekursiv lösen?! -->
		<xsl:choose>
			<xsl:when test="$pNode/following-sibling::*[1][local-name(.)='lb']">
				<xsl:choose>
					<xsl:when test="$pNode/following-sibling::*[2][local-name(.)='metamark']">
						<xsl:choose>
							<xsl:when test="$pNode/following-sibling::*[2][local-name(.)='note']">
								<xsl:value-of select="true()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="false()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$pNode/following-sibling::*[2][local-name(.)='note']">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
				<xsl:choose>
					<xsl:when test="$pNode/following-sibling::*[2][local-name(.)='lb']">
						<xsl:choose>
							<xsl:when test="$pNode/following-sibling::*[2][local-name(.)='note']">
								<xsl:value-of select="true()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="false()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$pNode/following-sibling::*[2][local-name(.)='note']">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>


		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>
