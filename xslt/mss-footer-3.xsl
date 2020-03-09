<?xml version="1.0" encoding="UTF-8"?>

<!--

Outputs the footer section of a single manuscript page.

Transforms: $(MSS_DIR)/%.xml      -> $(CACHE_DIR)/mss/%.footer.html
Transforms: $(MSS_PRIV_DIR)/%.xml -> $(CACHE_DIR)/internal/mss/%.footer.html

URL: $(CACHE_DIR)/mss/%.footer.html          /mss/%/
URL: $(CACHE_DIR)/internal/mss/%.footer.html /internal/mss/%/

Target: mss      $(CACHE_DIR)/mss/%.footer.html
Target: mss_priv $(CACHE_DIR)/internal/mss/%.footer.html

-->

<xsl:stylesheet
    version="3.0"
    xmlns=""
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="cap tei xhtml xs xsl">

  <xsl:include href="common-3.xsl"/>
  <xsl:include href="common-html.xsl"/>

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/TEI">

    <div class="tei-TEI mss-footer-xsl transkription-footer">
      <h4 id="info">[:de]Hinweise[:en]Notes[:]</h4>

      <xsl:call-template name="legend"/>

      <xsl:call-template name="cite_as">
        <xsl:with-param name="author" select="''" />
      </xsl:call-template>

      <xsl:call-template name="hr"/>

      <xsl:call-template name="downloads">
        <xsl:with-param name="url" select="concat ($mss_downloads, @xml:id, '.xml')"/>
      </xsl:call-template>

      <xsl:apply-templates select="teiHeader/revisionDesc" />
    </div>
  </xsl:template>

  <!-- Put only the main manuscript title in "How to cite" -->
  <xsl:template match="note[@type = 'filiation']"/>

  <xsl:template match="revisionDesc">
    <!-- "Generiert aus Mordek" soll nicht angezeigt werden, deswegen nur change ab position 1.  DS
         - 9.11. -->
    <xsl:if test="normalize-space (string-join (change[position () > 1]))">
      <xsl:call-template name="hr"/>

      <div class="tei-revisionDesc">
        <h5>[:de]Versionsgeschichte[:en]Revision history[:]</h5>
        <table>
          <thead>
            <tr>
              <th class="col-1">[:de]Datum[:en]Date[:]</th>
              <th>[:de]Änderung[:en]Change[:]</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="change[position () > 1]" />
          </tbody>
        </table>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="revisionDesc/change">
    <tr>
      <td class="col1">
        <xsl:value-of select="@when"/>
      </td>
      <td>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="legend">
    <div id="legend">
      <h5>[:de]Legende[:en]Key[:]</h5>
      <table>
        <col class="legend-col-1"/>
        <col class="legend-col-2"/>
        <tr>
          <th>[:de]Verwendete Zeichen[:en]Symbols used[:]</th>
          <th>[:de]Bedeutung[:en]Meaning[:]</th>
        </tr>
        <tr>
          <td>·&#x2003;˙&#x2003;:&#x2003;.'&#x2003;/<br/>
          ·,·&#x2003;:/&#x2003;,&#x2003;;&#x2003;∴</td>
          <td>[:de]Interpunktion (wie in den Hss. verwendet)[:en]Punctuation (as used in
          the mss.)[:]</td>
        </tr>
        <tr>
          <td>
            <sup>*</sup>
          </td>
          <td>[:de]Fußnote (Text der Anmerkung erscheint bei Mouseover)[:en]Footnote (text
          of note appears on mouseover)[:]</td>
        </tr>
        <tr>
          <td>[:de]Fettdruck (Worte, Sätze)[:en]Bold type (words, phrases)[:]</td>
          <td>[:de]Rubriken, Überschriften; in den Hss. durch Auszeichnungsschrift oder
          andere visuelle Gestaltungsmerkmale hervorgehoben[:en]Rubrics, headings;
          differently rendered by using another font or other visual features[:]</td>
        </tr>
        <tr>
          <td>[:de]Fettdruck (einzelne Buchstaben)[:en]Bold type (single letters)[:]</td>
          <td>[:de]Initialen[:en]Initials[:]</td>
        </tr>
        <tr>
          <td>[:de]Rot[:en]Red[:]</td>
          <td>[:de]Verwendung von farbiger Tinte (jeglicher Art)[:en]Use of coloured ink
          (of any kind)[:]</td>
        </tr>
        <tr>
          <td>[xyz]</td>
          <td>[:de]Unsichere Lesung, schwer entzifferbarer Text[:en]Uncertain reading,
          text hard to decipher[:]</td>
        </tr>
        <tr>
          <td>[…]</td>
          <td>[:de]Unlesbarer Text. Die Anzahl der Punkte zeigt die (vermutliche) Anzahl
          der ausgefallenen Buchstaben an[:en]Illegible text. The number of dots
          indicates the (estimated) number of characters missing[:]</td>
        </tr>
        <tr>
          <td>†††</td>
          <td>[:de]Getilgter Text, der nicht mehr entzifferbar ist. Die Anzahl der Kreuze
          zeigt die (vermutliche) Anzahl der ausgefallenen Buchstaben an[:en]Deleted
          text. The number of crosses indicates the (estimated) number of characters
          missing[:]</td>
        </tr>
        <tr>
          <td>[†]</td>
          <td>[:de]Platzhalter für nicht mehr entzifferbare getilgte Textstellen (<span
          class="italic">ohne</span> Angabe zur Anzahl der vermutlich
          ausgefallenen Buchstaben)[:en]Place holder for deleted, non-reconstructable
          passages (<span class="italic">without</span> indication of estimated number
          of characters missing)[:]</td>
        </tr>
        <tr>
          <td>- - -</td>
          <td>[:de]In der Hs. absichtlich freigelassener Leerraum innerhalb der
          Zeile[:en]Space left blank intentionally within a line in the ms.[:]</td>
        </tr>
        <tr>
          <td>[!]</td>
          <td>sic</td>
        </tr>
        <tr>
          <td>[BK 139 c. 1]</td>
          <td>[:de]Referenz zur Edition von Boretius/Krause[:en]Reference to the
          Boretius/Krause edition[:]</td>
        </tr>
        <tr>
          <td>[fol. 123r], [p. 123]</td>
          <td>[:de]Blatt- oder Seitenwechsel bzw. Spaltenwechsel in der Hs.[:en]Page break
          (fol. or p.) or column break in the ms.[:]</td>
        </tr>
      </table>
      <!-- Must be here because the legend is moved into the sidebar. -->
      <xsl:call-template name="hr"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
