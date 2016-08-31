<?xml version="1.0" encoding="UTF-8"?>

<!-- this include file sets the output method -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		version="1.0">

  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <xsl:strip-space elements="tei:* *"/>

  <xsl:preserve-space elements="tei:ab tei:lb tei:text ab lb text"/>

</xsl:stylesheet>
