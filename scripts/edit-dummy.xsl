<?xml version="1.0" encoding="UTF-8"?>

<!-- This stylesheet removes the crazy Oxygen formatting before doing a transform.
     Gives far quieter diffs. -->

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

  <!-- just copy everything -->
  <template match="node()|@*">
    <copy>
      <apply-templates select="node()|@*"/>
    </copy>
  </template>

</xsl:stylesheet>
