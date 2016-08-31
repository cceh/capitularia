<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>
    <xsl:include href="xsl-output.xsl"/>
    <xsl:include href="allgFunktionen.xsl"/>
    <xsl:template match="/">
        <!-- Abbildung der Liste als Tabelle mit einer Zeile für jedes <item> -->
        <div class="xsl-output">
            <style type="text/css">
                div.meta{
                    font-size: 90%;
                }
                table{
                    table-layout: auto;
                    font-size: small;
                    align: left;
                }
                td.shelfmark{
                    width: 27%;
                }
                td.capit{
                    width: 46%;
                }
                td.origin{
                    width: 27%;
                }
                ul{
                    list-style-type: none;
                }
                sup,
                sub{
                    vertical-align: baseline;
                    position: relative;
                    top: -0.4em;
                    font-size: 80%;
                }</style>
            <!-- <hr/>
                <div align="center"><a href="#A">A</a> | <a href="#B">B</a>
                    | <a href="#C">C</a> | <a href="#D">D</a> | <a href="#E">E</a> | <a href="#F"
                        >F</a> | <a href="#G">G</a> | <a href="#H">H</a> | <a href="#I">I</a> | <a
                        href="#K">K</a> | <a href="#L">L</a> | <a href="#M">M</a> | <a href="#N"
                        >N</a> | <a href="#O">O</a> | <a href="#P">P</a> | <a href="#R">R</a> | <a
                        href="#S">S</a> | <a href="#T">T</a> | <a href="#V">V</a> | <a href="#W"
                        >W</a> | <a href="#Z">Z</a></div>-->
            <div id="meta">[:de]<p>Die Übersicht listet alle bekannten Handschriften auf, die
                    Kapitularien enthalten. Die in Mordek 1995 vergebenen Handschriftensiglen stehen
                    in Klammern hinter der jeweiligen Signatur. Eine Konkordanz der Mordek-Siglen
                    findet sich <a href="http://capitularia.uni-koeln.de/mss/key/"
                        title="Konkordanz nach Mordek-Siglen">hier</a>.</p>
                <p>Hinter den enthaltenen Kapitularien (in der 2. Spalte) steht entweder die Nummer
                    der Edition von Boretius/Krause (BK) oder die Nummer im Anhang I von Mordek
                    1995.</p><p>Eine Liste mit allen Kapitularien findet sich <a
                        href="http://capitularia.uni-koeln.de/capit/list/"
                        title="Gesamtüberblick über die Kapitularien">hier</a>.</p>[:en]<p>This
                    table lists all known manuscripts containing capitularies. Shelfmarks are
                    usually followed by the siglum assigned by Mordek 1995 in square brackets. A
                    concordance of all these sigla can be found <a
                        href="http://capitularia.uni-koeln.de/mss/key/" title="concordance Mordek"
                        >here</a>.</p>
                <p>The second column lists all capitularies in the respective manuscript. In square
                    brackets you find either the number assigned to that capitulary in the edition
                    by Boretius/Krause (“BK”) or its number in Mordek 1995, appendix I
                    (“Mordek”).</p>
                <p>A table listing all capitularies can be found <a
                        href="http://capitularia.uni-koeln.de/capit/list/"
                        title="table of capitularies">here</a>.</p>[:]</div>
            <div align="left" id="content">
                <!-- Only for the sidebar menu.
		 <h4 id="table-top" style="display: none">Nach Anfangsbuchstaben</h4> -->
                <table align="center" class="handschriften" rules="all">
                    <thead>
                        <tr align="center" valign="top">
                            <th class="shelfmark"> [:de]Signatur [Siglum][:en]Shelfmark [siglum][:] </th>
                            <th class="capit"> [:de]Enthaltene Kapitularien[:en]Capitularies
                                contained[:] </th>
                            <th class="origin"> [:de]Datierung, Herkunft[:en]Origin[:] </th>
                        </tr>
                    </thead>
                    <xsl:apply-templates select="//list[@xml:id = 'manuscripts']"/>
                </table>
            </div>
        </div>
    </xsl:template>
    <!-- "Füllen" der einzelnen Spalten mit den entsprechenden Angaben (Signatur; Inhalt; Datierung; Literatur) -->
    <xsl:template match="list[@xml:id = 'manuscripts']">
        <xsl:apply-templates/>
        <!--Signatur, bzw. Signaturen-->
    </xsl:template>
    <xsl:template match="item[@xml:id]">
        <xsl:for-each select=".">
            <tr>
                <td class="shelfmark">
                    <span style="font-size:small;">
                        <xsl:apply-templates select="idno[@type = 'main']"/>
                    </span>
                    <span style="font-size:85%;">
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Sigle bei Mordek[:en]Siglum (Mordek)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates select="idno[@type = 'siglum']"/>
                    </span>
                    <span style="font-size:85%;">
                        <xsl:apply-templates select="note[@type = 'filiation']"/>
                    </span>
                </td>
                <td class="capit">
                    <span style="font-size:90%;">
                        <ul class="bare">
                            <xsl:apply-templates select="content"/>
                        </ul>
                    </span>
                </td>
                <td class="origin">
                    <span style="font-size:90%;">
                        <xsl:apply-templates select="origin"/>
                    </span>
                    <span style="font-size:85%;">
                        <xsl:apply-templates select="note[@type = 'annotation']"/>
                    </span>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="idno[@type = 'main']">
        <xsl:choose>
            <xsl:when test="../@status = 'publ'">
                <!--   <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/>
                        <xsl:value-of select="../@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">Zur Handschrift</xsl:attribute>
                    <img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                        title="Zur Handschrift"/>
                </a>
                <xsl:text> </xsl:text>-->
                <a class="ssdone">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/>
                        <xsl:value-of select="../@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">[:de]Zur Handschrift[:en]Go to
                        manuscript[:]</xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="idno[@type = 'siglum']">
        <xsl:text> [</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!-- Angaben zu Datierung und Herkunft -->
    <xsl:template match="origin">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::origin">
            <br/>
        </xsl:if>
    </xsl:template>
    <!-- Angaben zu Datierung und Herkunft II -->
    <xsl:template match="origDate">
        <xsl:if test="preceding-sibling::locus">
            <xsl:apply-templates select="locus"/>
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::origPlace">
            <xsl:if test="not(following-sibling::origDate)">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="following-sibling::origDate">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="origPlace">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Einträge zum Inhalt der Handschrift -->
    <xsl:template match="locus">
        <xsl:choose>
            <xsl:when test="parent::capit">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="parent::origDate">
                <xsl:text>(</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="content/capit">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="term">
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="@n">
                <xsl:value-of select="."/>
                <xsl:if test="@n">
                    <xsl:choose>
                        <xsl:when test="@status = 'publ'">
                            <span style="font-style:normal;">
                                <xsl:text> [</xsl:text>
                                <a class="ssdone">
                                    <xsl:attribute name="title">
                                        <xsl:text>[:de]Informationen zum Kapitular Nr.[:en]Information on capitulary no.[:] </xsl:text>
                                        <xsl:value-of select="substring-after(@n, '.')"/>
                                        <xsl:text> [:de]nach[:en]by[:] </xsl:text>
                                        <xsl:if test="contains(@n, 'BK')">
                                            <xsl:text>Boretius/Kause</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="contains(@n, 'Mordek')">
                                            <xsl:text>Mordek</xsl:text>
                                        </xsl:if>
                                    </xsl:attribute>
                                    <xsl:attribute name="href">
                                        <xsl:choose>
                                            <xsl:when test="@list = 'pre814'">
                                                <xsl:value-of select="$capit_pre"/>
                                                <xsl:if test="contains(@n, 'BK')">
                                                  <xsl:text>bk-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="contains(@n, 'Mordek')">
                                                  <xsl:text>mordek-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="substring-after(@n, '.')"/>
                                            </xsl:when>
                                            <xsl:when test="@list = 'post840'">
                                                <xsl:value-of select="$capit_post"/>
                                                <xsl:if test="contains(@n, 'BK')">
                                                  <xsl:text>bk-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="contains(@n, 'Mordek')">
                                                  <xsl:text>mordek-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="substring-after(@n, '.')"/>
                                            </xsl:when>
                                            <xsl:when test="@list = 'undated'">
                                                <xsl:value-of select="$capit_undated"/>
                                                <xsl:if test="contains(@n, 'BK')">
                                                  <xsl:text>bk-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="contains(@n, 'Mordek')">
                                                  <xsl:text>mordek-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="substring-after(@n, '.')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$capit_ldf"/>
                                                <xsl:if test="contains(@n, 'BK')">
                                                  <xsl:text>bk-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="contains(@n, 'Mordek')">
                                                  <xsl:text>mordek-nr-</xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="substring-after(@n, '.')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:value-of select="substring-before(@n, '.')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="starts-with(@n, 'BK.00')">
                                            <xsl:value-of select="substring-after(@n, '.00')"/>
                                        </xsl:when>
                                        <xsl:when test="starts-with(@n, 'BK.0')">
                                            <xsl:value-of select="substring-after(@n, '.0')"/>
                                        </xsl:when>
                                        <xsl:otherwise><xsl:value-of select="substring-after(@n, '.')"/></xsl:otherwise>
                                    </xsl:choose>                                    
                                </a>
                                <xsl:text>]</xsl:text>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span style="color:#808080;">
                                <xsl:attribute name="title">
                                    <xsl:text>[:de]Nr.[:en]No.[:] </xsl:text>
                                    <xsl:value-of select="substring-after(@n, '.')"/>
                                    <xsl:text> [:de]nach[:en]by[:] </xsl:text>
                                    <xsl:if test="contains(@n, 'BK')">
                                        <xsl:text>Boretius/Kause</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="contains(@n, 'Mordek')">
                                        <xsl:text>Mordek</xsl:text>
                                    </xsl:if>
                                </xsl:attribute>
                                <xsl:text> [</xsl:text>
                                <xsl:value-of select="substring-before(@n, '.')"/>
                                <xsl:text> </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="starts-with(@n, 'BK.00')">
                                        <xsl:value-of select="substring-after(@n, '.00')"/>
                                    </xsl:when>
                                    <xsl:when test="starts-with(@n, 'BK.0')">
                                        <xsl:value-of select="substring-after(@n, '.0')"/>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:value-of select="substring-after(@n, '.')"/></xsl:otherwise>
                                </xsl:choose>   
                                <xsl:text>]</xsl:text>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="milestone">
        <tr>
            <th class="dyn-menu-h4" colspan="3" id="{@n}">
                <xsl:value-of select="@n"/>
            </th>
        </tr>
    </xsl:template>
    <xsl:template match="hi">
        <xsl:if test="@rend = 'super'">
            <sup>
                <xsl:apply-templates/>
            </sup>
        </xsl:if>
    </xsl:template>
    <xsl:template match="note">
        <br/>
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>
    <xsl:template match="ref">
        <xsl:choose>
            <xsl:when test="@type = 'external'">
                <xsl:if test="@subtype = 'Bl'">
                    <a>
                        <xsl:attribute name="target">_blank</xsl:attribute>
                        <xsl:attribute name="title">Bibliotheca legum</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Bl"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:if>
            </xsl:when>
            <xsl:when test="@type = 'internal'">
                <!--<xsl:apply-templates/>-->
                <xsl:if test="@subtype = 'mss'">
                    <a>
                        <xsl:attribute name="title">Zur Handschriftenbeschreibung</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$mss"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
