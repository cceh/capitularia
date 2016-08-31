<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0" exclude-result-prefixes="exslt msxsl tei xhtml my">

        <xsl:include href="xsl-output.xsl"/>

	<!-- author: NG -->

	<xsl:variable name="vStyle">
	  <style type="text/css">
	    div.transkr {
	      <!-- allgemeine Darstellung des Textes -->
	      font-size: 90%
	    }

	    span.titel {
	      font-weight: bold;
	      font-size: 110%;
	      color: #b92900;
	    }

	    span.encodingDesc {
	      <!--display: inline-block;-->
	      <!--font-style: italic;-->
	      font-size: 90%
	    }

	    div.text {
	      line-height: 200%;
	      font-size: 120%
	    }

	    <!-- Initialen -->
	    span.initial {
	      display: inline-block;
	      font-weight: bold
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
	      color: grey;
	      font-style: normal
	    }

	    span.milestone {
 	      color: grey;
	      font-weight: bold;
	    }

	    span.corresp {
	      <!-- line-height: 100%; -->
	      font-size: 50%;
	      <!--color: lightgrey;-->
	      color: grey;
	      font-weight: bold;
	    }

	    div.corresp {
	      <!-- line-height: 100%; -->
	      font-size: 70%;
	      color: grey;
	      font-weight: bold;
	      vertical-align: top;
	    }

	    div.corresp2 {
	      <!-- line-height: 100%; -->
	      font-size: 70%;
	      <!--color: lightgrey;-->
	      font-weight: bold;
	      vertical-align: top;
	    }

	    span.quote {
	      font-size: 100%;
	      font-weight: normal
	    }

	    span.unclear {
	     color: lightgrey;
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
	    
	  </style>
	</xsl:variable>

</xsl:stylesheet>
