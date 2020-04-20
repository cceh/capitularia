<?xml version="1.0" encoding="UTF-8"?>

<stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/XSL/Transform"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xs xsl">

  <!-- fix these external refs -->
  <template match="tei:ref[@type='external']">
    <copy>
      <apply-templates select="@*"/>
      <choose>
        <when test="normalize-space (.) = 'Baluze I' or @subtype = 'Baluze1'">
          <text>Baluze 1780</text>
        </when>
        <when test="normalize-space (.) = 'Baluze II' or @subtype = 'Baluze2'">
          <text>Baluze 1780a</text>
        </when>

        <when test="normalize-space (.) = 'Boretius/Krause I' or @subtype = 'BK1'">
          <text>Boretius 1883</text>
        </when>
        <when test="normalize-space (.) = 'Boretius/Krause II' or @subtype = 'BK2'">
          <text>Boretius 1897</text>
        </when>

        <when test="normalize-space (.) = 'Pertz I' or @subtype = 'Pertz1'">
          <text>Pertz G 1835</text>
        </when>
        <when test="normalize-space (.) = 'Pertz II' or @subtype = 'Pertz2'">
          <text>Pertz G 1837</text>
        </when>
        <when test="normalize-space (.) = 'Pertz III' or @subtype = 'Pertz3'">
          <text>Pertz G 1837a</text>
        </when>

        <when test="normalize-space (.) = 'Werminghoff II, 1' or @subtype = 'Werminghoff1'">
          <text>Werminghoff 1906</text>
        </when>
        <when test="normalize-space (.) = 'Werminghoff II, 2' or @subtype = 'Werminghoff2'">
          <text>Werminghoff 1908</text>
        </when>

        <otherwise>
          <value-of select="." />
        </otherwise>
      </choose>
    </copy>
  </template>

  <!-- copy everything else -->
  <template match="node()|@*">
    <copy>
      <apply-templates select="node()|@*"/>
    </copy>
  </template>

</stylesheet>
