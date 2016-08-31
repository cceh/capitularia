<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0">

        <xsl:include href="xsl-output.xsl"/>

	<!-- author: NG -->
	<xsl:strip-space elements="tei:*"/>

	<xsl:variable name="funoRef" select="//tei:cit/tei:ref"/>
	<xsl:variable name="funoSic" select="//tei:sic"/>
	<xsl:variable name="funoNote" select="//tei:note[@type='editorial']"/>
	<xsl:variable name="funoSicNote" select="$funoSic|$funoNote"/>

	<!--
        Schriftart, -größe, Zeilenabstand: Ich gebe besser keine konkreten Vorgaben, sondern verlasse mich auf eure Erfahrungswerte.
        Generell: lieber eine klare als verschnörkelte Schrift (Arial, Calibri, Verdana o.ä.),
        lieber etwas größer und großzügiger Zeilenabstand als zu wenig. Es soll gut lesbar sein.
        Ich habe lediglich relative Angaben gemacht („normal“ = Standardschrift, „etwas größer“ [als die Standardschrift] etc.).
        Mit „ignorieren“ meine ich das Markup, nicht die Buchstaben/Worte innerhalb des Markups
        – also: normal ausgeben, keine Verarbeitungsanweisungen für den Text an dieser Stelle.
    -->

	<xsl:template match="/">
		<HTML lang="de">
			<HEAD>
				<meta charset="utf-8"/>
				<TITLE>
					<xsl:value-of select="//tei:title"/>
				</TITLE>

				<style type="text/css">
					body { <!-- allgemeine Darstellung des Textes -->
					font-family: 'Times New Roman';
					line-height: 100%;
					<!--font-size: medium-->
					font-size: 90%
					}
					span.titel {
					font-weight: bold
					}

					div.text {
					<!--display: inline-block;-->
					line-height: 200%;
					font-size: 120%
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
					<!--                        line-height: 200%;
                        font-size: 120%-->
					}
					span.abMETA { <!-- Darstellung innerhalb <ab type="meta-text"> -->
					<!--                        line-height: 200%;
                        font-size: 120%;-->
					font-weight: bold
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
				<xsl:apply-templates select="//tei:teiHeader"/>

				<br/>
				<!-- ??? für Abstand zwischen Header und Body -->
				<br/>
				<!-- ??? für Abstand zwischen Header und Body -->
				<!-- BODY -->
				<div class="text">
					<xsl:apply-templates select="//tei:body"/>
				</div>

				<!-- Fußnoten?! -->
				<ol type="1" class="numerisch">
					<xsl:for-each select="$funoRef">
						<li id="{generate-id()}">
							<xsl:apply-templates select="./node()"/>
							<a href="#{generate-id()}-L" class="noteBack">&#x2934;</a>
						</li>
					</xsl:for-each>
				</ol>

				<ol type="a" class="alphabetisch">
					<xsl:for-each select="$funoSicNote">
						<li id="{generate-id()}">
							<xsl:choose>
								<xsl:when test="name()='sic'">
									<xsl:text>Sic Hs.</xsl:text>
								</xsl:when>
								<xsl:when test="name()='note'">
									<xsl:apply-templates select="./node()"/>
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
        <header>: nur <title>, <publisher>, <encodingDesc> und <revisionDesc> ausgeben, den Rest unterdrücken.
      -->

	<xsl:template match="//tei:title">
		<!-- <title> = fett und etwas größer -->
		<span class="titel">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:publisher">
		<!-- <publisher> = normal -->
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="//tei:encodingDesc//text()">
		<!-- <encodingDesc> = kursiv, Text innerhalb von <mentioned> recte, einzelne <p> als Absätze -->
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
		<!-- <encodingDesc> = kursiv, Text innerhalb von <mentioned> recte, einzelne <p> als Absätze -->
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="//tei:revisionDesc">
		<!-- -	<revisionDesc> = etwas kleiner; vor dem Text einfügen: „Bearbeitung“ (fett, danach Absatz)
o	Hinter dem Text, der von <change> umschlossen wird: Doppelpunkt, Wert von @who, dahinter in Klammern Wert von @when.
 -->

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
		<!-- <seg type=“titulus“/”numDenom”/”num” rend=“majuscule red“>: fett -->
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>

	<xsl:template match="//tei:lb">
		<!-- <lb> ignorieren ?!? -->
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

	<xsl:template match="//tei:cb">
		<!-- -	<cb>: Wie <lb>; zu Beginn der darauf folgenden neuen Zeile: Wert von @n ausgeben, davor „Fol.“; fett, in eckigen Klammern, danach Leerzeichen -->
		<xsl:choose>
			<xsl:when test="current()[@break='no']">
				<xsl:text>-</xsl:text>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<br/>
			</xsl:otherwise>
		</xsl:choose>

		<b>
			<xsl:text>[Fol. </xsl:text>
			<xsl:value-of select="./@n"/>
			<xsl:text>] </xsl:text>
		</b>
	</xsl:template>

	<xsl:template match="//tei:milestone">
		<!-- <milestone>: Wert von @n ausgeben, fett und etwas größer, Leerzeile davor und danach -->
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
			<xsl:element name="span">
				<xsl:attribute name="class">initialTYP</xsl:attribute>

				<xsl:value-of select="substring-after(@type, '-')"/>
			</xsl:element>
			<xsl:element name="span">
				<xsl:attribute name="class">initialABC</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="//tei:seg[@type='versalie']">
		<!-- BAUSTELLE: VERSALIEN => Gibt es bisher noch nicht?! -->
		<!-- -	Versalien innerhalb von <seg type=“versalie“>: fett, größer und nach links aus dem Satzspiegel herausrücken (bzw., wenn das nicht möglich ist, den übrigen Text etwas nach rechts einrücken) -->
		<span class="versalie">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:mentioned/text()">
		<!-- Text innerhalb von <mentioned> = kursiv -->
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:cit/tei:quote">
		<!-- <quote> (innerhalb von <cit>) = in Anführungszeichen -->
		<span class="quote">
			<xsl:text>&#8222;</xsl:text>
		</span>
		<xsl:apply-templates select="./node()"/>
		<span class="quote">
			<xsl:text>&#8220;</xsl:text>
		</span>

	</xsl:template>

	<xsl:template match="//tei:cit/tei:ref">
		<!--<ref> (innerhalb von <cit>) = in Fußnote (Zahlen)-->
		<xsl:variable name="refIndex">
			<xsl:call-template name="indexOf">
				<xsl:with-param name="pSeq" select="//tei:cit/tei:ref"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<sup>[<xsl:value-of select="$refIndex"/>]</sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:note[@type='editorial']">
		<!-- Note=“editorial“: als Fußnoten (Buchstaben) anzeigen. ??? -->
		<xsl:variable name="noteIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoSicNote"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<sup>[<xsl:value-of select="$noteIndex"/>]</sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:sic">
		<!-- Note=“editorial“: als Fußnoten (Buchstaben) anzeigen. ??? -->
		<xsl:variable name="sicIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoSicNote"/>
				<xsl:with-param name="pNode" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="."/>
		<a href="#{generate-id()}" id="{generate-id()}-L" class="noteLink">
			<sup>[<xsl:value-of select="$sicIndex"/>]</sup>
		</a>
	</xsl:template>

	<xsl:template match="//tei:add/text()">
		<!-- -	Text innerhalb von <add> ausgeben, innerhalb von <del> unterdrücken (später: als Anmerkung anzeigen lassen [Buchstabenindex]) -->
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="//tei:del/text()">
		<!-- -	Text innerhalb von <add> ausgeben, innerhalb von <del> unterdrücken (später: als Anmerkung anzeigen lassen [Buchstabenindex]) -->
	</xsl:template>

	<xsl:template match="//tei:choice">
		<!-- "<choice> (abbr, expan): Wort innerhalb von <expan> ausgeben, Buchstabenfolge innerhalb von <abbr> in eckigen Klammern dahinter (im Fließtext)" -->
		<xsl:value-of select="./tei:expan/text()"/>
		<xsl:text> [</xsl:text>
		<xsl:value-of select="./tei:abbr/text()"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="//tei:unclear[tei:gap]">
		<!-- "<unclear> + <gap> = 3 Pünktchen (egal, wieviele units angegeben sind)" -->
		<xsl:text>...</xsl:text>
	</xsl:template>

	<xsl:template match="//tei:unclear[count(tei:gap)=0]">
		<!-- -	<unclear> ohne <gap>: unterstreichen -->
		<span class="unclear" title="">
			<xsl:apply-templates select="node()"/>
		</span>
	</xsl:template>

	<xsl:template match="//tei:expan">
		<!-- <expan> und <ex>: kursiv -->
		<i>
			<xsl:apply-templates select="node()"/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:ex">
		<!-- <expan> und <ex>: kursiv -->
		<i>
			<xsl:apply-templates select="node()"/>
		</i>
	</xsl:template>

	<xsl:template match="//tei:space">
		<!-- "<expan>, <space>, <date>: ignorieren" -->
		<xsl:value-of select="./text()"/>
	</xsl:template>

	<xsl:template match="//tei:date">
		<!-- "<expan>, <space>, <date>: ignorieren" -->
		<xsl:value-of select="./text()"/>
	</xsl:template>


	<!-- ################################# zusätzliche "Funktionen"/Templates -->

	<xsl:template name="indexOf">
		<!-- Zahl -->
		<xsl:param name="pSeq"/>
		<xsl:param name="pNode"/>

		<xsl:for-each select="$pSeq">
			<xsl:if test="current()=$pNode">
				<xsl:number value="position()" format="1"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="indexOf_a">
		<!-- Buchstabe -->
		<xsl:param name="pSeq"/>
		<xsl:param name="pNode"/>

		<xsl:for-each select="$pSeq">
			<xsl:if test="current()=$pNode">
				<xsl:number value="position()" format="a"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
