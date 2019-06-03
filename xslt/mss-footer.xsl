<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns:cap="http://cceh.uni-koeln.de/capitularia"
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="cap exsl func set str"
    exclude-result-prefixes="tei xhtml xs xsl">
  <!-- libexslt does not support the regexp extension ! -->

  <xsl:include href="common.xsl"/>

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/tei:TEI">

    <div class="tei-TEI mss-footer-xsl transkription-footer">
      <h4 id="info">[:de]Hinweise[:en]Notes[:]</h4>

      <xsl:call-template name="legend"/>

      <xsl:variable name="title">
        <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']"/>
      </xsl:variable>

      <div id="citation">
        <h5>[:de]Empfohlene Zitierweise[:en]How to cite[:]</h5>
        <p>
          <xsl:value-of select="normalize-space ($title)"/>
          <xsl:text>, [:de]in: Capitularia. Edition der fränkischen Herrschererlasse, bearb. von
          Karl Ubl und Mitarb., Köln 2014 ff.[:en]in: Capitularia. Edition of the Frankish
          Capitularies, ed. by Karl Ubl and collaborators, Cologne 2014 ff.[:] </xsl:text>
          <xsl:value-of select="concat ('URL: ', $base_url, $mss, @xml:id, '/')"/>
          <xsl:text> [:de](abgerufen am [current_date])[:en](accessed on [current_date])[:]</xsl:text>
        </p>
      </div>

      <xsl:call-template name="hr"/>

      <div id="download">
        <h5>[:de]Download[:en]Downloads[:]</h5>
        <ul class="downloads">
          <li class="download-icon">
            <xsl:variable name="url"
                          select="concat ($mss_downloads, @xml:id, '.xml')"/>
            <a class="screen-only ssdone" href="{$url}"
               title='[:de]Rechtsklick zum "Speichern unter"[:en]right button click to save file[:]'>
              <xsl:text>[:de]Datei in XML[:en]File in XML[:]</xsl:text>
            </a>
            <div class="print-only">
              <xsl:text>[:de]Datei in XML[:en]File in XML[:] </xsl:text>
              <xsl:value-of select="$url"/>
            </div>
          </li>
        </ul>
      </div>

      <xsl:apply-templates select="tei:teiHeader/tei:revisionDesc" />

    </div>
  </xsl:template>

  <!-- Put only the main manuscript title in "How to cite" -->
  <xsl:template match="tei:note[@type = 'filiation']"/>

  <xsl:template match="tei:revisionDesc">
    <!-- "Generiert aus Mordek" soll nicht angezeigt werden, deswegen nur change ab position 1.  DS
         - 9.11. -->
    <xsl:if test="normalize-space (tei:change[position () > 1])">
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
            <xsl:apply-templates select="tei:change[position () > 1]" />
          </tbody>
        </table>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:revisionDesc/tei:change">
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
