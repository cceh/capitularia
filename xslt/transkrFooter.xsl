<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:cs="urn:cs" xmlns:my="urn:sample" exclude-result-prefixes="msxsl date">
    <xsl:import href="base_variables.xsl"/>
    <!-- Änderung 16.09.2015 - Import der XSL und Anpassen der Variablen ## DS -->

    <xsl:include href="allgFunktionen.xsl"/>
    <xsl:include href="transkription_ZusatzFunktionen.xsl"/>

    <msxsl:script language="JScript" implements-prefix="date">
        <![CDATA[
	function date(){
		var oDate = new Date();
		var ret = "";
		var m = oDate.getMonth() + 1;
	    var mm = m < 10 ? "0" + m : m;
		ret = ret + mm + "/";
		var d = oDate.getDate();
		var dd = d < 10 ? "0" + d : d;
		ret = ret + dd + "/";
		ret = ret + oDate.getFullYear();
		return ret;
		}
	]]>
    </msxsl:script>

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
                    <td>+++</td>
                    <td>[:de]Getilgter Text, der nicht mehr entzifferbar ist. Die Anzahl der Kreuze
                        zeigt die (vermutliche) Anzahl der ausgefallenen Buchstaben an[:en]Deleted
                        text. The number of crosses indicates the (estimated) number of characters
                        missing[:]</td>
                </tr>
                <tr>
                    <td>[+]</td>
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
            <xsl:call-template name="hr"/>
        </div>
    </xsl:template>

    <xsl:variable name="vDate">
        <!--        <xsl:variable name="vDateRaw">
            <xsl:value-of select="date:date()"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($vDateRaw) &gt; 10">
                <!-\- enthält mehr als YYYY-MM-DD -\->
                <!-\-<xsl:value-of select="substring($vDateRaw,1,10)"/>-\->
                <xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
                    <xsl:with-param name="pDate_YYYY-MM-DD" select="substring($vDateRaw,1,10)"/>
                    <xsl:with-param name="pDelimiter" select="'.'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-\- enthält nur YYYY-MM-DD -\->
                <!-\-<xsl:value-of select="$vDateRaw"/>-\->
                <xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
                    <xsl:with-param name="pDate_YYYY-MM-DD" select="$vDateRaw"/>
                    <xsl:with-param name="pDelimiter" select="'.'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>-->


        <xsl:variable name="vDateRaw">
            <xsl:call-template name="tCurrentDate"/>
        </xsl:variable>

        <xsl:call-template name="tDate_YYYY-MM-DDtoDD-MM-YYYY">
            <xsl:with-param name="pDate_YYYY-MM-DD" select="$vDateRaw"/>
            <xsl:with-param name="pDelimiter" select="'.'"/>
        </xsl:call-template>
    </xsl:variable>

    <!--    <msxsl:script language="JScript" implements-prefix="my">
        function today()
        {
        return new Date();
        }
    </msxsl:script>-->
    <!--    <xsl:variable name="vToday">
        <xsl:value-of select="my:today()"/>
    </xsl:variable>-->

    <!--    <msxsl:script language="C#" implements-prefix="cs">
        <![CDATA[
        public string datenow()
        {
            return(DateTime.Now.ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"));
        }
            ]]>
    </msxsl:script>-->

    <!--    <msxsl:script language="CSharp" implements-prefix="cs">
        public string dateTimeNow()
        {
        return DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ssZ");
        }
    </msxsl:script>-->

    <!-- ################ Variablen ################# -->
    <!-- Variablen zu internen Ressourcen -->
    <!--<xsl:variable name="mss">http://capitularia.uni-koeln.de/handschriften/</xsl:variable>
    <xsl:variable name="download">http://capitularia.uni-koeln.de/cap/mss/msDesc_Mordek/</xsl:variable>-->

    <!-- Variablen zu externen Ressourcen -->
    <!--<xsl:variable name="Bl">http://www.leges.uni-koeln.de/mss/handschrift/</xsl:variable>-->

    <xsl:template match="/">
        <!--<html>-->
        <!--            <head>
                <title>Edition der fränkischen Herrschererlasse</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
                <meta content="Handschriften" name="register"/>

            </head>-->

        <!-- Headerbereich des Dokumentes mit Navigation und Titel -->

        <!--<body>-->
        <!--<h5>
                    <xsl:apply-templates select="tei:msDesc/tei:head"/>
                    <xsl:apply-templates select="tei:msDesc/tei:msIdentifier"/>
                </h5>-->
        <!--<div id="header">-->
        <!--<xsl:apply-templates select="//tei:teiHeader"/>-->

        <!-- ############ Muss ähnlich in anderes Script ################ -->


        <!--<div style="display: none;" id="info">-->
        <div class="transkription-footer">
            <!-- Hinzufügung der Überschrift DS 08.11.2015; desweiteren Änderung der Reihenfolge: Zitationshinweis vor Versiongeschichte -->
            <h4 id="info">[:de]Hinweise[:en]Notes[:]</h4>
            <!--                        <hr/>
                        <div align="right" style="font-size:xx-small;">
                            <a href="#top">[^]</a>
                        </div>
                        <div style="font-size:x-small;" id="citation">
                            <u>Zitationshinweis:</u>
                            <br/>
                            Wir empfehlen, diese Seite wie
                            folgt zu zitieren:<br/>
                            <xsl:text>Beschreibung (und Transkription) der Handschrift "</xsl:text>
                            <xsl:value-of select="//tei:titleStmt//tei:title[@type='main']"/>", Arbeitsstelle "Edition der fränkischen Herrschererlasse" unter der Leitung von Karl Ubl (Hrsg.),
                            Köln 2014-2017. URL: http://capitularia.uni-koeln.de/mss/<xsl:value-of select="//tei:TEI/@xml:id"/>.(abgerufen am: [aktuelles Datum])</div>
                        <br/>
                        <hr/>    -->

            <!--                        <xsl:text>{DEBUG}</xsl:text>
                        <xsl:value-of select="normalize-space(//tei:revisionDesc/node())"/>
                        <xsl:text>{/DEBUG}</xsl:text>-->

            <xsl:call-template name="legend"/>

            <div id="citation">
                <h5>[:de]Empfohlene Zitierweise[:en]How to cite[:]</h5>
                <p>
                    <xsl:value-of select="normalize-space(//tei:titleStmt//tei:title[@type='main'])"/>
                    <xsl:text>, [:de]in: Capitularia. Edition der fränkischen Herrschererlasse, bearb. von Karl Ubl und Mitarb., Köln 2014 ff.[:en]in: Capitularia. Edition of the Frankish Capitularies, ed. by Karl Ubl and collaborators, Cologne 2014 ff.[:] URL: </xsl:text>
                    <xsl:value-of select="$mss"/>
                    <xsl:value-of select="tei:TEI/@xml:id"/>
                    <xsl:text/>
                    <xsl:text> [:de](abgerufen am: [aktuelles Datum])[:en](last accessed on: [date])[:] </xsl:text>
                </p>
            </div>


            <!--                        <div id="citation">
                            <!-\-<u>Zitationshinweis:</u>-\->

                            <!-\-<h4>Zitatbox</h4>-\->
                            <h4>empfohlene Zitierweise</h4>
<!-\-                            <div class="zitatbox">
                                <xsl:text>Beschreibung (und Transkription) der Handschrift "</xsl:text>
                                <xsl:value-of select="//tei:titleStmt//tei:title[@type='main']"/>
                                <xsl:text>", Arbeitsstelle "Edition der fränkischen Herrschererlasse" unter der Leitung von Karl Ubl (Hrsg.),
                                Köln 2014-2017. URL: http://capitularia.uni-koeln.de/mss/</xsl:text>
                                <xsl:value-of select="//tei:TEI/@xml:id"/>
                                <xsl:text>. (abgerufen am: [aktuelles Datum])</xsl:text>
                                <!-\\-<xsl:text>{</xsl:text><xsl:value-of select="cs:datenow()"/><xsl:text>}</xsl:text>-\\->
                                <!-\\-<xsl:value-of select="my:today()"/>-\\->
                            </div>-\->

<!-\-                            <div class="zitatbox">
                                <xsl:value-of select="normalize-space(//tei:titleStmt//tei:title[@type='main'])"/>
                                <xsl:text>, in: Capitularia. Edition der fränkischen Herrschererlasse, bearb. von Karl Ubl und Mitarb., Köln 2014 ff. URL: </xsl:text><xsl:value-of select="$mss_downloads"/><xsl:value-of
                                                select="tei:TEI/@xml:id"
                                            /><xsl:text>.xml</xsl:text><xsl:text> (abgerufen am: </xsl:text><xsl:value-of select="$vDate"/><xsl:text>)</xsl:text>
<!-\\-                                ![CDATA[
                                <script type="text/javascript">
                                    var objToday = new Date(),
                                    weekday = new Array('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
                                    dayOfWeek = weekday[objToday.getDay()],
                                    domEnder = new Array( 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th' ),
                                    dayOfMonth = today + (objToday.getDate() < 10) ? '0' + objToday.getDate() + domEnder[objToday.getDate()] : objToday.getDate() + domEnder[parseFloat(("" + objToday.getDate()).substr(("" + objToday.getDate()).length - 1))],
                                    months = new Array('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'),
                                    curMonth = months[objToday.getMonth()],
                                    curYear = objToday.getFullYear(),
                                    curHour = objToday.getHours() > 12 ? objToday.getHours() - 12 : (objToday.getHours() < 10 ? "0" + objToday.getHours() : objToday.getHours()),
                                    curMinute = objToday.getMinutes() < 10 ? "0" + objToday.getMinutes() : objToday.getMinutes(),
                                    curSeconds = objToday.getSeconds() < 10 ? "0" + objToday.getSeconds() : objToday.getSeconds(),
                                    curMeridiem = objToday.getHours() > 12 ? "PM" : "AM";
                                    var today = curHour + ":" + curMinute + "." + curSeconds + curMeridiem + " " + dayOfWeek + " " + dayOfMonth + " of " + curMonth + ", " + curYear;
                                </script>
                                ]]-\\->
                            </div>-\->

                            <!-\-<div class="zitatbox">-\->
                                <xsl:value-of select="normalize-space(//tei:titleStmt//tei:title[@type='main'])"/>
                                <xsl:text>, in: Capitularia. Edition der fränkischen Herrschererlasse, bearb. von Karl Ubl und Mitarb., Köln 2014 ff. URL: </xsl:text><xsl:value-of select="$mss_downloads"/><xsl:value-of
                                    select="tei:TEI/@xml:id"
                                /><xsl:text>.xml</xsl:text><xsl:text> (abgerufen am: </xsl:text><xsl:text>[aktuelles Datum]</xsl:text><xsl:text>)</xsl:text>

                            <!-\-</div>-\->

                        </div>-->
            <xsl:call-template name="hr"/>
            <!--<u id="downloads">Downloads:</u>-->
            <!--<br/>-->
            <h5>Download</h5>
            <ul class="downloads">
                <li class="download-icon">
                    <xsl:variable name="url"
                        select="concat ($mss_downloads, /tei:TEI/@xml:id, '.xml')"/>
                    <!--                                    [Handschriftenbeschreibung als <a>
                                        <xsl:attribute name="href"
                                            ><xsl:value-of select="$download"/><xsl:value-of
                                                select="tei:TEI/@xml:id"
                                            /><xsl:text>.xml</xsl:text></xsl:attribute>
                                        <xsl:attribute name="title"
                                            ><xsl:text>Rechtsklick zum "Speichern unter"</xsl:text></xsl:attribute>XML-Download</a>]-->

                    <a class="screen-only ssdone" href="{$url}"
                        title='[:de]Rechtsklick zum "Speichern unter"[:en]right button click to save file[:]'>
                        <!--<xsl:text>[:de]Handschriftenbeschreibung und Transkription in XML[:en]Manuscript description and transcription in XML[:]</xsl:text>-->
                        <xsl:text>[:de]Datei in XML[:en]File in XML[:]</xsl:text>
                    </a>
                    <div class="print-only">
                        <!--[:de]Handschriftenbeschreibung und Transkription in XML[:en]Manuscript description and transcription in XML[:] <xsl:value-of select="$url"/>-->
                        [:de]Datei in XML[:en]File in XML[:] <xsl:value-of select="$url"/>
                    </div>
                </li>
            </ul>
            <!-- [Handschriftenbeschreibung als <a>
                        <xsl:attribute name="href"
                                >http://www.leges.uni-koeln.de/wp-content/uploads/pdf/<xsl:value-of
                                select="tei:TEI/@xml:id"
                        /><xsl:text>.pdf</xsl:text></xsl:attribute>PDF-Download</a>]<br/> -->
            <!--                        <br/>
                        <hr />
                        <div style="background:#eee;padding:2%;font-size:x-small;">
                            Diese Version ist ein bisher unkorrigiertes
                            Abbild der Beschreibung von Hubert Mordek, Bibliotheca (1995) und wird
                            weiteren Revisionen unterliegen.
                            <br/><br/>
                            <u>Versionsgeschichte:</u>
                            <ul>
                                <li>Datei aus Vorlage erstellt am: 10.08.2015</li>
                                <li>Online seit: 10.08.2015</li>
                                <xsl:apply-templates select="//tei:respStmt"></xsl:apply-templates>
                            </ul>
                        </div>-->
            <xsl:call-template name="hr"/>
            <xsl:if test="//tei:revisionDesc/tei:change">
                <div id="revisionDesc">
                    <h5>[:de]Versionsgeschichte[:en]Revision history[:]</h5>
                    <table>
                        <thead>
                            <tr>
                                <!--<th style="width: 10%;">Nr</th>-->
                                <th style="width: 20%;">[:de]Datum[:en]Date[:]</th>
                                <th>[:de]Änderung[:en]Change[:]</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Generiert aus Mordek soll nicht angezeigt werden, deswegen nur change ab position 1 - DS - 9.11. -->
                            <xsl:for-each select="//tei:revisionDesc/tei:change[position()!=1]">
                                <tr>
                                    <!--<td>
                                                    <xsl:value-of select="position()"/>
                                                </td>-->
                                    <td>
                                        <xsl:value-of select="@when"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="text()"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </xsl:if>
        </div>
        <!--</div>-->

        <!--</body>-->
        <!--</html>-->
    </xsl:template>

</xsl:stylesheet>
