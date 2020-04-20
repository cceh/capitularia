<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xs xsl">

  <!-- remove all num tags -->
  <template match="//name//date">
    <apply-templates select="node()" />
  </template>

  <!-- copy everything else -->
  <template match="node()|@*">
    <copy>
      <apply-templates select="node()|@*"/>
    </copy>
  </template>

</xsl:stylesheet>
