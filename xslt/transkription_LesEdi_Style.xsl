<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0" exclude-result-prefixes="exslt msxsl tei xhtml my">

        <xsl:include href="xsl-output.xsl"/>

	<!-- author: NG -->

	<xsl:variable name="vStyle">

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

			<!--white-space: nowrap;-->

			line-height: 200%;
			font-size: 120%
			}

			<!-- Hinzufügung durch DS am 29.08.2014, da sonst komplette WP-Seite inklusive Header und Menü in Times New Roman -->
			div.meta {
			line-height: 100%;
			font-family: 'Times New Roman'
			}

			div.corresp {
			line-height: 100%;
			font-size: 70%;
			color: grey;
			font-weight: bold;
			vertical-align: top;
			font-family: 'Arial'
			}

			div.corresp2 {
			line-height: 100%;
			font-size: 70%;
			<!--color: lightgrey;-->
			font-weight: bold;
			vertical-align: top;
			<!--font-family: 'Arial'-->
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
			<!--font-style: italic-->
			font-style: normal
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

			span.corresp {
			line-height: 100%;
			font-size: 50%;
			color: lightgrey;
			font-weight: bold;
			font-family: 'Arial'
			}

			span.hiSuper {
			vertical-align: top;
			font-size: 60%
			}

			span.frontDiv {
			font-weight: bold
			}

			span.rendRed {
			color: #b92900
			}

			span.rendBlack {
				color: black
			}

			ol.alphabetisch {
			list-style:lower-alpha outside none;
			}
			ol.numerisch {

			}


			@media all {
			.page-break	{ display: none; }
			}

			@media print {
			.page-break	{ display: block; page-break-before: always; }
			div, span, article { float: none !important; }
			.qtrans_language_chooser { display: none; }
			nav {display: none !important}
			}


			span.frontMentioned {
			font-style: normal;
			}

			span.textMentioned {
			font-style: italic;
			}

			span.textItalic {
			font-style: italic;
			}

		</style>
		<!--
		<style type="text/css">
			body { <!-\- allgemeine Darstellung des Textes -\->
			<!-\-font-family: 'Times New Roman';-\->
			line-height: 100%;
			<!-\-font-size: medium-\->
			font-size: 90%
			}
			span.titel {
			font-weight: bold;
			font-size: 110%;
			color: #b92900;
			}

			span.encodingDesc {
			<!-\-display: inline-block;-\->
			<!-\-font-style: italic;-\->
			font-size: 90%
			}

			div.transkr {
			<!-\-font-family: 'Times New Roman';-\->
			}

			div.text {
			<!-\-display: inline-block;-\->

			<!-\-white-space: nowrap;-\->

			line-height: 200%;
			font-size: 120%
			}

			<!-\- Hinzufügung durch DS am 29.08.2014, da sonst komplette WP-Seite inklusive Header und Menü in Times New Roman -\->
			div.meta {
			line-height: 100%;
			<!-\-font-family: 'Times New Roman'-\->
			}

			<!-\-                    div.initial { <!-\\- Initialen -\\->
                        display: inline-block;
                        font-family: Arial;
                        font-weight: bold
					<!-\\-
                    	color: white;
                        background-color: black
					-\\->
                        }-\->

			span.initial { <!-\- Initialen -\->
			display: inline-block;
			font-family: Arial;
			font-weight: bold
			<!-\-
                    	color: white;
                        background-color: black
					-\->
			}

			span.initialABC { <!-\- Initialen, Buchstaben -\->
			font-size: 110%
			}
			span.initialTYP { <!-\- Initialen, Typ-Marker -\->
			font-size: 50%;
			vertical-align: top
			}
			span.versalie {
			font-size: 110%;
			font-weight: bold
			}

			span.folio {
			font-weight: bold;
			<!-\-font-style: italic-\->
			color: grey;
			font-style: normal
			}

			span.milestone {
			<!-\-
                        line-height: 100%;
                        font-size: 110%;
                        font-weight: bold
                    -\->
			font-weight: bold;
			<!-\-color: lightgrey;-\->
			color: grey;
			font-weight: bold;
			font-family: 'Arial'
			}

			span.corresp {
			line-height: 100%;
			font-size: 50%;
			<!-\-color: lightgrey;-\->
			color: grey;
			font-weight: bold;
			font-family: 'Arial'
			}

			div.corresp {
			line-height: 100%;
			font-size: 70%;
			color: grey;
			font-weight: bold;
			vertical-align: top;
			font-family: 'Arial'
			}

			div.corresp2 {
			line-height: 100%;
			font-size: 70%;
			<!-\-color: lightgrey;-\->
			font-weight: bold;
			vertical-align: top;
			<!-\-font-family: 'Arial'-\->
			}

			span.quote {
			font-size: 100%;
			font-weight: normal
			}
			span.unclear {
			color: lightgrey;
			}
			span.abTEXT { <!-\- Darstellung innerhalb <ab type="text"> -\->
			<!-\-                    line-height: 200%;
                        font-size: 120%-\->
			line-height: 150%;
			}
			span.abMETA { <!-\- Darstellung innerhalb <ab type="meta-text"> -\->
			<!-\-                    line-height: 200%;
                        font-size: 120%;-\->
			font-weight: bold
			}

			span.hiSuper {
			vertical-align: top;
			font-size: 60%
			}

			span.frontDiv {
			font-weight: bold
			}

			span.PublikationAenderung {
			font-size: smaller;
			color: black;
			}

			ol.alphabetisch {
			list-style:lower-alpha outside none;
			}
			ol.numerisch {

			}


			@media all {
			.page-break	{ display: none; }
			}

			@media print {
			.page-break	{ display: block; page-break-before: always; }
			div, span, article { float: none !important; }
			.qtrans_language_chooser { display: none; }
			nav {display: none !important}
			}

			<!-\-					a {
					vertical-align: super;
					font-size: smaller;
					}-\->

			span.frontMentioned {
			font-style: normal;
			}

			span.textMentioned {
			font-style: italic;
			}

			span.textItalic {
			font-style: italic;
			}

		</style>-->
	</xsl:variable>

</xsl:stylesheet>
