<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="base_variables.xsl"/>

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:template match="/">
        <div id="all" class="transkription-header" style="font-size:90%;">
            <style type="text/css">
                div.xsl-output div.tei-listBibl li{
                    font-size:90%;
                    list-style-type:square;
                }
                div.xsl-output table{
                    table-layout:fixed;
                    width:100%;
                }
                div.xsl-output table.tei-physDesc-table th{
                    width:25%;
                }
                div.xsl-output td.value{
                    width:28%;
                }
                div.xsl-output img{
                    vertical-align:middle;
                }</style>
            <script language="javascript">
                    function toggle(control)
                    {
                    var elem = document.getElementById(control);
                    if(elem.style.display == "none")
                    {
                    elem.style.display = "block";
                    }
                    else
                    {
                    elem.style.display = "none";
                    }
                    }
                </script>


            <!-- Headerbereich des Dokumentes mit Navigation und Titel -->


            <xsl:apply-templates select="tei:msDesc/tei:msIdentifier"/>
            <xsl:apply-templates select="//tei:teiHeader"/>
        </div>
    </xsl:template>


    <xsl:template match="tei:head"/>

    <!-- Ausgabe des Titels, Informationen zur haltenden Institution, Entstehungsgeschichte, allgemeine Anmerkungen, Bibliographie -->
    <xsl:template match="tei:msDesc">
        <div class="tei-msDesc">

            <xsl:apply-templates select="tei:titleStmt"/>
            <!-- Beschreibung nach Mordek -->


            <div id="identification">
                <xsl:apply-templates select="tei:msIdentifier"/>
                <!-- Aufbewahrungsort -->
                <xsl:apply-templates select="//tei:facsimile"/>
            </div>

            <div id="notes">
                <xsl:apply-templates select="//tei:filiation"/>

                <xsl:if test="//tei:adminInfo/tei:note[@resp='KU']!=''">
                    <span style="text-align:justify; display:block;">
                        <xsl:apply-templates select="//tei:note[@resp='KU']"/>
                    </span>
                </xsl:if>
                <xsl:if test="//tei:note[@type='annotation']">
                    <span style="text-align:justify; display:block;">
                        <xsl:apply-templates select="//tei:msItem/tei:note[@type='annotation']"/>
                    </span>
                </xsl:if>
                <xsl:text> </xsl:text>
                <xsl:if test="//tei:ref[@subtype='mom']">
                    <br/>
                    <span style="text-align:justify; display:block;">
                        <xsl:apply-templates select="//tei:ref[@subtype='mom']"/>
                    </span>
                </xsl:if>
            </div>

            <xsl:choose>
                <xsl:when test="not(child::tei:msPart)">
                    <xsl:apply-templates select="tei:history[normalize-space()]"/>
                    <!-- Entstehung und Überlieferung -->
                    <xsl:apply-templates select="tei:physDesc[normalize-space()]"/>
                    <!-- Äußere Beschreibung -->
                    <xsl:apply-templates select="tei:msContents[normalize-space()]"/>
                    <!-- Inhalte -->
                    <xsl:apply-templates select="//tei:listBibl[not(@type)]"/>
                    <!-- Bibliographie -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="tei:msPart"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="page-break"/>

        </div>
    </xsl:template>

    <xsl:template match="tei:titleStmt">
        <xsl:if test="tei:title/tei:note[@type='filiation']">
            <xsl:apply-templates select="//tei:note[@type='filiation']"/>
        </xsl:if>
        <!--<h2><xsl:apply-templates select="child::tei:title[@type='main']"></xsl:apply-templates></h2>-->
        <h4 id="description-mordek" class="tei-titleStmt">[:de]Beschreibung <xsl:if
                test="//tei:listBibl[@type='cap']/tei:bibl[starts-with(.,'Mordek 1995')]">nach
                Mordek</xsl:if>[:en]Description <xsl:if
                test="//tei:listBibl[@type='cap']/tei:bibl[starts-with(.,'Mordek 1995')]">according
                to Mordek</xsl:if>[:]</h4>
    </xsl:template>
    <xsl:template match="tei:note[@type='filiation']">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="tei:title[@type='main']">
        <p class="tei-title-main">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="tei:title[@type='signatur']">
        <span class="signatur">
            <xsl:apply-templates/>
        </span>
    </xsl:template>



    <!-- Haltende Institution, Kollektion, Signatur,... -->
    <xsl:template match="tei:msIdentifier">
        <div class="tei-msIdentifier">
            <h5>[:de]Aufbewahrungsort:[:en]Repository:[:]</h5>

            <xsl:value-of select="tei:settlement"/>
            <br/>
            <xsl:value-of select="tei:repository"/>
            <br/>
            <xsl:value-of select="tei:collection"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="tei:idno"/>
            <br/>
            <br/>
            <div>
                <xsl:if test="tei:msName!=''">
                    <u>[:de]Name:[:en]Name:[:] </u>
                    <xsl:apply-templates select="tei:msName"/>
                </xsl:if>
                <xsl:apply-templates select="tei:altIdentifier"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="tei:msName">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::tei:msName">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Entstehung und Überlieferung -->

    <xsl:template match="tei:history">
        <xsl:call-template name="page-break"/>

        <div class="tei-history">
            <xsl:attribute name="id">
                <xsl:text>history</xsl:text>
                <xsl:if test="parent::tei:msPart">
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="substring-after(parent::tei:msPart/@n, ' ')"/>
                </xsl:if>
            </xsl:attribute>
            <h5>
                <xsl:attribute name="id">
                    <xsl:text>origin</xsl:text><xsl:if test="parent::tei:msPart"
                            ><xsl:text>_</xsl:text><xsl:value-of
                            select="substring-after(parent::tei:msPart/@n, ' ')"/></xsl:if>
                </xsl:attribute>[:de]Entstehung und Überlieferung[:en]Origin and history[:]</h5>

            <xsl:apply-templates select="tei:origin[normalize-space()]"/>
            <xsl:apply-templates select="tei:provenance[normalize-space()]"/>
            <xsl:apply-templates select="tei:summary[normalize-space()]"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:origin">
        <div class="tei-origin">
            <h6>[:de]Entstehung:[:en]Origin:[:]</h6>
            <xsl:apply-templates select="tei:p"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:provenance">
        <div class="tei-provenance">
            <h6>[:de]Provenienz:[:en]Provenance:[:]</h6>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:summary">
        <div class="tei-summary">
            <h6>[:de]Anmerkung:[:en]Note:[:]</h6>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:origDate">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:altIdentifier">
        <xsl:if test="@type='siglum'">
            <br/>
            <br/>
            <u>[:de]Sigle:[:en]Siglum[:]</u>
            <xsl:text> </xsl:text>
            <span class="italic">
                <xsl:value-of select="child::tei:idno"/>
                <xsl:if test="child::tei:note!=''">
                    <br/>
                    <xsl:apply-templates select="tei:note"/>
                </xsl:if>
            </span>
            <!--<xsl:text> (bei Mordek 1995)</xsl:text>-->
        </xsl:if>
        <!-- Im Folgenden auskommentiert, weil ansonsten alte Signaturen hier separat genannt und bei Provenienz, was zu einer unnötigen Redundanz führt -->
        <!--<xsl:if test="@type!='siglum'">
            <xsl:choose>
                <xsl:when test="not(preceding-sibling::tei:altIdentifier[@type!='siglum'])">
                    <br/>
                    <br/>
                    <u>Alte Signatur(en):</u>
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>-->
    </xsl:template>
    <!-- Teile von Handschriften -->
    <xsl:template match="tei:msPart">
        <xsl:for-each select=".">
            <xsl:call-template name="page-break"/>
            <div>
                <xsl:choose>
                    <xsl:when test="starts-with(@n,'foll.')">
                        <xsl:attribute name="id">
                            <xsl:text>foll_</xsl:text>
                            <xsl:value-of select="substring-after(@n,'foll. ')"/>
                        </xsl:attribute>
                        <h4>
                            <xsl:attribute name="id">
                                <xsl:value-of select="substring-after(@n,'foll. ')"/>
                            </xsl:attribute>
                            <xsl:value-of select="substring-after(descendant::tei:idno,' ')"/>
                        </h4>
                    </xsl:when>
                    <xsl:when test="starts-with(@n,'p.')">
                        <xsl:attribute name="id">
                            <xsl:text>foll_</xsl:text>
                            <xsl:value-of select="substring-after(@n,'p. ')"/>
                        </xsl:attribute>
                        <h4>
                            <xsl:attribute name="id">
                                <xsl:value-of select="substring-after(@n,'p. ')"/>
                            </xsl:attribute>
                            <xsl:value-of select="descendant::tei:idno"/>
                        </h4>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="id">
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="@n"/>
                        </xsl:attribute>
                        <h4>
                            <xsl:attribute name="id">
                                <xsl:value-of select="@n"/>
                            </xsl:attribute>
                            <xsl:value-of select="descendant::tei:idno"/>
                        </h4>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="tei:history[normalize-space()]"/>
                <!-- Entstehung und Überlieferung -->
                <xsl:apply-templates select="tei:physDesc[normalize-space()]"/>
                <!-- Äußere Beschreibung -->
                <xsl:apply-templates select="tei:msContents[normalize-space()]"/>
                <!-- Inhalte -->
                <xsl:apply-templates select="descendant::tei:listBibl[not(@type)]"/>
                <!-- Bibliographie -->
            </div>
        </xsl:for-each>
        <xsl:call-template name="page-break"/>
    </xsl:template>
    <!-- Inhalte -->

    <xsl:template match="tei:msContents">
        <xsl:call-template name="page-break"/>

        <div class="tei-msContents">
            <xsl:attribute name="id">
                <xsl:text>contents</xsl:text>
                <xsl:if test="parent::tei:msPart">
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="substring-after(parent::tei:msPart/@n, ' ')"/>
                </xsl:if>
            </xsl:attribute>
            <h5>
                <xsl:attribute name="id"><xsl:text>content</xsl:text><xsl:if
                        test="parent::tei:msPart"><xsl:text>_</xsl:text><xsl:value-of
                            select="substring-after(parent::tei:msPart/@n, ' ')"
                    /></xsl:if></xsl:attribute>[:de]Inhalte[:en]Contents[:]</h5>
            <xsl:apply-templates select="tei:summary[normalize-space()]"/>
            <ul class="bare">
                <xsl:apply-templates select="tei:msItem"/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="tei:msItem">
        <xsl:if test="@prev">
            <li class="tei-msItem">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/><xsl:value-of
                            select="substring-before(@prev,'_')"
                            /><xsl:text>#</xsl:text><xsl:value-of
                            select="substring-after(@prev,'_')"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">[:de]Zum zugehörigen Teil (in einer anderen
                        Handschrift)[:en]To the corresponding part in another
                        manuscript[:]</xsl:attribute>
                    <xsl:attribute name="target">_blank</xsl:attribute>→ </xsl:element>
            </li>
        </xsl:if>
        <li class="tei-msItem">
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="substring-after(@xml:id,'_')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
        <xsl:if test="@next">
            <li class="tei-msItem">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/><xsl:value-of
                            select="substring-before(@next,'_')"
                            /><xsl:text>#</xsl:text><xsl:value-of
                            select="substring-after(@next,'_')"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">[:de]Zum zugehörigen Teil (in einer anderen
                        Handschrift)[:en]To the corresponding part in another
                        manuscript[:]</xsl:attribute><xsl:attribute name="target"
                        >_blank</xsl:attribute> → </xsl:element>
            </li>
        </xsl:if>
    </xsl:template>



    <xsl:template match="tei:msItem//tei:title">
        <span style="font-weight:bold;">
            <xsl:if test="contains(ancestor::tei:msItem/@corresp,'.')">
                <xsl:attribute name="title">
                    <xsl:text>= </xsl:text>
                    <xsl:value-of select="substring-before(ancestor::tei:msItem/@corresp,'.')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="substring-after(ancestor::tei:msItem/@corresp,'.')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:emph">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rend='smallcaps'">
                <!--<span style="font-variant: small-caps;">-->
                <xsl:apply-templates/>
                <!--</span>-->
            </xsl:when>
            <xsl:when test="@rend='super'">
                <xsl:choose>
                    <xsl:when test="parent::tei:bibl">
                        <xsl:element name="span">
                            <xsl:attribute name="style"
                                >vertical-align:super;font-size:80%;</xsl:attribute>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="parent::tei:formula">
                        <xsl:element name="span">
                            <xsl:attribute name="style"
                                >vertical-align:super;font-size:80%;</xsl:attribute>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--<xsl:element name="span">
                    <xsl:attribute name="style">vertical-align:super;font-size:70%;</xsl:attribute>-->
                        <xsl:apply-templates/>
                        <!--</xsl:element>-->
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:when test="@rend='italic'">
                <span class="italic">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

    </xsl:template>


    <!-- Verlinkungen zu Resourcen -->

    <xsl:template match="tei:note[not(@type)]"> [<xsl:apply-templates/>] </xsl:template>


    <xsl:template match="tei:adminInfo">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:recordHist">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:listBibl[not(@type)]">
        <xsl:call-template name="page-break"/>

        <div class="tei-listBibl tei-listBibl-not-type">
            <xsl:attribute name="id">
                <xsl:text>lit</xsl:text>
                <xsl:if test="ancestor::tei:msPart">
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="substring-after(ancestor::tei:msPart/@n, ' ')"/>
                </xsl:if>
            </xsl:attribute>
            <h5>
                <xsl:attribute name="id">
                    <xsl:text>bibliography</xsl:text><xsl:if test="ancestor::tei:msPart"
                            ><xsl:text>_</xsl:text><xsl:value-of
                            select="substring-after(ancestor::tei:msPart/@n, ' ')"/></xsl:if>
                </xsl:attribute> [:de]Bibliographie[:en]Bibliography[:]</h5>

            <xsl:apply-templates select="tei:listBibl[@type='lit']"/>
            <xsl:apply-templates select="tei:listBibl[@type='cat']"/>
            <xsl:apply-templates select="tei:listBibl[@type='abb']"/>
            <xsl:apply-templates select="tei:listBibl[@type='cap']"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:listBibl[@type='lit']">
        <div class="tei-listBibl tei-listBibl-lit">
            <h6>[:de]Literatur:[:en]References:[:]</h6>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="tei:listBibl[@type='cat']">
        <div class="tei-listBibl tei-listBibl-cat">
            <h6>[:de]Katalog(e):[:en]Catalogue(s):[:]</h6>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="tei:listBibl[@type='abb']">
        <div class="tei-listBibl tei-listBibl-abb">
            <h6>[:de]Abbildungen:[:en]Images:[:]</h6>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="tei:listBibl[@type='cap']">
        <div class="tei-listBibl tei-listBibl-cap">
            <h6>[:de]Projektspezifische Referenzen:[:en]Project-specific references:[:]</h6>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="tei:bibl">

        <xsl:if test="@corresp">
            <xsl:choose>
                <xsl:when test="parent::tei:listBibl">
                    <li class="tei-bibl">
                        <xsl:apply-templates/>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$biblio"/>
                                <xsl:value-of select="@corresp"/>
                            </xsl:attribute>
                            <xsl:attribute name="title">[:de]Zum bibliographischen Eintrag[:en]To
                                the bibliographic entry[:]</xsl:attribute>
                            <xsl:text> </xsl:text>
                            <img class="align-middle" alt="Zur Bibliographie"
                                src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                            />
                        </xsl:element>
                    </li>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$biblio"/>
                            <xsl:value-of select="@corresp"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">[:de]Zum bibliographischen Eintrag[:en]To the
                            bibliographic entry[:]</xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zur Bibliographie"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="not(@corresp)">
            <li class="tei-bibl">
                <xsl:if test="not(@resp)">
                    <xsl:apply-templates/>
                </xsl:if>
                <xsl:if test="@resp">
                    <xsl:apply-templates/>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:locus">
        <span style="font-weight:bold;">
            <xsl:if test="@target">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/>
                        <xsl:value-of select="substring-before(@target,'_')"/>
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="substring-after(@target,'_')"/>
                    </xsl:attribute>
                    <xsl:attribute name="target">_blank</xsl:attribute>
                    <xsl:attribute name="title">[:de]Zur korrespondierenden Handschrift[:en]To the
                        corresponding manuscript[:]</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="not(@target)">
                <xsl:apply-templates/>
            </xsl:if>
        </span>
        <xsl:choose>
            <xsl:when test="parent::tei:note"/>
            <xsl:when test="following-sibling::tei:locus">
                <xsl:text>, </xsl:text>
            </xsl:when>
            <!--<xsl:when test="parent::tei:locusGrp"></xsl:when>-->
            <xsl:when test="parent::tei:origDate"/>
            <xsl:when test="parent::tei:origPlace"/>
            <xsl:otherwise>
                <br/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:locusGrp">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:text"/>

    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!-- Äußere Beschreibung -->

    <xsl:template match="tei:physDesc">
        <xsl:call-template name="page-break"/>

        <div class="tei-physDesc">
            <xsl:attribute name="id">
                <xsl:text>physDesc</xsl:text>
                <xsl:if test="parent::tei:msPart">
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="substring-after(parent::tei:msPart/@n, ' ')"/>
                </xsl:if>
            </xsl:attribute>
            <h5>
                <xsl:attribute name="id">
                    <xsl:text>description-exterior</xsl:text><xsl:if test="parent::tei:msPart"
                            ><xsl:text>_</xsl:text><xsl:value-of
                            select="substring-after(parent::tei:msPart/@n, ' ')"/></xsl:if>
                </xsl:attribute>[:de]Äußere Beschreibung[:en]Physical description[:]</h5>

            <table class="tei-physDesc-table">
                <tbody>
                    <xsl:apply-templates select="tei:objectDesc"/>
                    <xsl:apply-templates select="tei:scriptDesc[normalize-space()]"/>
                    <xsl:apply-templates select="tei:handDesc[normalize-space()]"/>
                    <xsl:apply-templates select="tei:decoDesc[normalize-space()]"/>
                    <xsl:apply-templates select="tei:bindingDesc[normalize-space()]"/>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="tei:objectDesc">
        <xsl:apply-templates select="tei:supportDesc"/>
        <xsl:apply-templates select="tei:layoutDesc"/>
    </xsl:template>

    <xsl:template match="tei:supportDesc">
        <xsl:apply-templates select="tei:support"/>
        <xsl:apply-templates select="tei:extent"/>
        <xsl:apply-templates select="tei:collation[normalize-space()]"/>
        <xsl:apply-templates select="tei:condition[normalize-space()]"/>
    </xsl:template>

    <xsl:template match="tei:condition">
        <tr>
            <th class="value">[:de]Zustand:[:en]Condition:[:]</th>
            <td class="text">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:support">
        <tr>
            <th class="value">[:de]Material:[:en]Material:[:]</th>
            <td class="text">
                <xsl:choose>
                    <xsl:when test=".=''">
                        <xsl:if test="child::tei:material">
                            <xsl:apply-templates/>
                        </xsl:if>
                        <xsl:if test="not(child::tei:material)">
                            <xsl:text> - </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:extent">
        <tr>
            <th class="value">[:de]Umfang:[:en]Number:[:]</th>
            <td class="text">
                <xsl:if test=".!=''">
                    <xsl:apply-templates select="text()"/>
                </xsl:if>
                <!--<xsl:if test=".=''"><xsl:text> - </xsl:text></xsl:if>-->
                <xsl:apply-templates select="tei:note[@type='corr']"/>
            </td>
        </tr>
        <xsl:apply-templates select="tei:dimensions"/>
    </xsl:template>

    <xsl:template match="tei:dimensions[@type='leaf']">
        <tr>
            <th class="value">[:de]Maße:[:en]Size:[:]</th>
            <td class="text">
                <xsl:if test="@precision">
                    <xsl:text>ca. </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="tei:height"/>
                <xsl:text> x </xsl:text>
                <xsl:apply-templates select="tei:width"/>
                <xsl:text> mm</xsl:text>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:dimensions[@type='written']">
        <tr>
            <th class="value">[:de]Schriftraum:[:en]Body text:[:]</th>
            <td class="text">
                <xsl:if test="@precision">
                    <xsl:text>ca. </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="tei:height"/>
                <xsl:text> x </xsl:text>
                <xsl:apply-templates select="tei:width"/>
                <xsl:text> mm</xsl:text>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:collation">
        <tr>
            <th class="value">[:de]Lagen:[:en]Quires:[:]</th>
            <td class="text">
                <xsl:if test="child::tei:p">
                    <xsl:apply-templates select="tei:p"/>
                    <xsl:text>.</xsl:text>
                    <br/>
                </xsl:if>
                <xsl:apply-templates select="tei:formula"/>
                <xsl:apply-templates select="tei:catchwords"/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:scriptDesc">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:scriptNote">
        <tr>
            <th class="value">[:de]Schrift:[:en]Script:[:]</th>
            <td class="text">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:handDesc">
        <tr>
            <th class="value">[:de]Schreiber:[:en]Scribe(s):[:]</th>
            <td class="text">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:decoDesc">
        <tr>
            <th class="value">[:de]Ausstattung:[:en]Decoration:[:]</th>
            <td class="text">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:bindingDesc">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:binding">
        <tr>
            <th class="value">[:de]Einband:[:en]Binding:[:]</th>
            <td class="text">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:layoutDesc">
        <tr>
            <th class="value">[:de]Zeilen:[:en]Lines:[:]</th>
            <td class="text">
                <xsl:apply-templates select="tei:layout[@writtenLines]"/>
            </td>
        </tr>
        <tr>
            <th class="value">[:de]Spalten:[:en]Columns:[:]</th>
            <td class="text">
                <xsl:apply-templates select="tei:layout[@columns]"/>
                <xsl:if test="tei:layout[@columns]=''">
                    <xsl:value-of select="tei:layout/@columns"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="tei:foliation">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:formula">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:catchwords">
        <xsl:if test="preceding-sibling::tei:formula">
            <br/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:encodingDesc"/>

    <xsl:template match="tei:publisher"/>

    <xsl:template match="tei:facsimile">
        <xsl:if test="starts-with(tei:graphic/@url,'http')">
            <div class="tei-facsimile">
                <span style="font-size:small;">
                    <xsl:text>[:de]Digitalisat verfügbar bei [:en]Digital image available at [:]</xsl:text>
                    <xsl:apply-templates/>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:revisionDesc"/>

    <xsl:template match="tei:note[@type='corr']">
        <img onclick="javascript:toggle('{generate-id()}')"
            src="http://capitularia.uni-koeln.de/cap/publ/material/attention.png"
            title="Bitte klicken Sie hier, um die Anmerkung bzw. Korrektur anzuzeigen."/>
        <span id="{generate-id()}" style="display:none;color:#B92900;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:anchor">
        <xsl:element name="div">
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:ref">
        <xsl:if test="@type='internal'">
            <xsl:choose>
                <xsl:when test="@subtype='mss'">
                    <xsl:if test="@target">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$mss"/>
                                <xsl:if test="not(contains(@target,'_'))"><xsl:value-of
                                        select="@target"/></xsl:if>
                                <xsl:if test="contains(@target,'_')">
                                    <xsl:value-of select="substring-before(@target,'_')"/>
                                    <xsl:text>#</xsl:text>
                                    <xsl:value-of select="substring-after(@target,'_')"/>
                                </xsl:if>
                            </xsl:attribute>
                            <xsl:attribute name="title">[:de]Zur Handschrift[:en]To the
                                manuscript[:]</xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:if test="not(contains(@target,'_'))"
                                    ><xsl:text>_self</xsl:text></xsl:if>
                                <xsl:if test="contains(@target,'_')"
                                    ><xsl:text>_blank</xsl:text></xsl:if></xsl:attribute> →
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="not(@target)">
                        <xsl:apply-templates/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@subtype='capit'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$capit"/><xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">[:de]Zum Kapitular[:en]To the respective
                            capitulary[:]</xsl:attribute> → <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='mom'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$blog"/><xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">[:de]Zum Artikel[:en]To the manuscript of the
                            month blogpost[:]</xsl:attribute> → [:de]Zum Artikel in der Rubrik
                        "Handschrift des Monats"[:en]To the Manuscript of the month blogpost[:]
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='int'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@type='external'">
            <xsl:choose>
                <xsl:when test="@subtype='BK1'">
                    <xsl:apply-templates/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$BK1"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Boretius/Krause I (dMGH)[:en]To the edition by Boretius/Krause I (dMGH)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="dMGH"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='BK2'">
                    <xsl:apply-templates/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$BK2"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Boretius/Krause II (dMGH)[:en]To the edition by Boretius/Krause II (dMGH)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="dMGH"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>

                    </a>
                </xsl:when>
                <xsl:when test="@subtype='dmgh'">
                    <xsl:apply-templates/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$dmgh"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zu den dMGH[:en]To dMGH website[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="dMGH"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='Pertz1'">
                    <xsl:apply-templates/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Pertz1"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Pertz (dMGH)[:en]To the edition by Pertz (dMGH)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="dMGH"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='Ansegis'">
                    <xsl:apply-templates/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Ansegis"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Ansegis-Edition (dMGH)[:en]To the edition of Ansegis (dMGH)[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img alt="dMGH"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='BSB'">
                    <xsl:apply-templates/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Digitale Sammlungen - BSB</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="BSB"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </a>
                </xsl:when>
                <xsl:when test="@subtype='mm'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>Manuscripta Mediaevalia</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img alt="Zur Ressource"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='Bl'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$Bl"/>
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Beschreibung auf der Bibliotheca legum-Webseite[:en]To the manuscript description on the Bibliotheca legum website[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zur Bl"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='MM'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zu Manuscripta Mediaevalia[:en]To Manuscripta Mediaevalia[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zu MM"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='IA'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zum Internet Archive[:en]To Internet Archive[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zu IA"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='DZ'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Digizeitschriften-Webseite[:en]To the Digizeitschriften website[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zu DZ"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='Baluze'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur Edition von Baluze[:en]To Baluze's edition[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zu Baluze"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@subtype='KatBNF'">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Katalog der BNF[:en]To the BNF catalogue[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zu Baluze"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text>[:de]Zur externen Ressource[:en]To the external resource[:]</xsl:text>
                        </xsl:attribute>
                        <xsl:text> </xsl:text>
                        <img class="align-middle" alt="Zur externen Ressource"
                            src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_ex.png"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:graphic">

        <!-- NG, 18.11.2015: Problem mit OnClick && target="blank" => in Chrome wird nur eins von beiden geöffnet, in Firefox beide! => vorerst wieder OnClick auskommentiert... -->

        <span style="font-size:small;">
            <xsl:if test="starts-with(@url, 'http')">
                <xsl:choose>
                    <xsl:when test="contains(@url,'.hab.de')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "Digitale Bibliothek HAB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Herzog August Bibliothek</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Digitale Bibliothek HAB </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'e-codices')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "e-codices",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">e-codices</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>e-codices </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'europeana')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "europeana Regia",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">europeana Regia </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>europeana Regia </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'mgh')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "MGH",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">MGH</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Monumenta Germaniae Historica </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bsb')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "BSB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Bayerische Staatsbibliothek
                                München</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>BSB München </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bnf')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "BnF",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Bibliothèque nationale de
                                France</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>BnF </xsl:text>
                        </a>
                        <xsl:value-of select="substring-after(@n,'_')"/>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@url,'freelibrary')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "FLP",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Free Library Philadelphia</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Free Library </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bhnumerique')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "FLP",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Bibliothèque Humaniste
                                numérique</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Bibliothèque Humaniste numérique </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bibliotecadigital')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "bibliotecadigital",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Biblioteca Real Academia de la Historia
                                Madrid</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Biblioteca Real Academia de la Historia Madrid </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'socrates')">
                        <a>
                            <xsl:attribute name="title">Digital Sources - Universität
                                Leiden</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Digital Sources - Universiteit Leiden</xsl:text>
                        </a>
                    </xsl:when>
                    <!--<xsl:when test="contains(@url,'leiden')">
                        <a>
                            <!-\-                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "leiden",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-\->
                            <xsl:attribute name="title">Bibliotheek der Rijksuniversiteit
                                Leiden</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Bibliotheek der Rijksuniversiteit Leiden </xsl:text>
                        </a>
                    </xsl:when>-->
                    <xsl:when test="contains(@url,'trier')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "trier",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">„Die ältesten deutschsprachigen Texte der
                                Stadtbibliothek Trier – ein Informationsportal im
                                Internet“</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Portal zu den ältesten deutschsprachigen Texten der SB Trier </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'heidelberg')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "heidelberg",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">UB Heidelberg</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>UB Heidelberg</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'stgallplan')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "st_gall",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Reichenau &amp; St. Gall</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Carolingian Culture at Reichenau &amp; St. Gall</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bodley')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "bodley",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Bodleian Library Oxford</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Bodleian Library Oxford</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bvmm')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "bvmm",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Bibliothèque virtuelle</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Bibliothèque virtuelle</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'parkerweb')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "parkerweb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Parker Library</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Parker Library</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'manuscripta-')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "onb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Manuscripta Mediaevalia</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>MM</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'manus')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "manus",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Manus online</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Manus online</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'wlb')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "wlb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">WLB Stuttgart</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>WLB Stuttgart</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'onb')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "onb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">ÖNB</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>ÖNB</xsl:text>
                        </a>
                    </xsl:when>

                    <xsl:when test="contains(@url,'blb')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "blb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Badische Landesbibliothek</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Badische Landesbibliothek</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'uni-muenchen')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "uni-muenchen",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Universitätsbibliothek
                                München</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Universitätsbibliothek München</xsl:text>
                        </a>
                    </xsl:when>
                    <!-- <xsl:when test="contains(@url,'archiviocapitolaremo')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archiviocapitolaremo",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Archivio Capitolare di
                                Modena</xsl:attribute>
                            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Archivio Capitolare di Modena</xsl:text>
                        </button>
                    </xsl:when>-->
                    <xsl:when test="contains(@url,'berlin')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "berlin",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Staatsbibliothek Berlin</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Staatsbibliothek Berlin</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'landesarchiv-nrw')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "archive.nrw",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Landesarchiv NRW, Abt.
                                Westfalen</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Landesarchiv NRW, Abt. Westfalen</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'pares')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "archive.nrw",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">PARES - Portal de Archivos
                                Españoles</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>PARES</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'archiviodiocesano')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "archiviodiocesano",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Archivio Capitolare di
                                Modena</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>Archivio Capitolare di Modena</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'vatlib')">
                        <a>
                            <!--                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                            />', "Digitale Bibliothek HAB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>-->
                            <xsl:attribute name="title">Vatikan</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:text>BAV </xsl:text>
                        </a>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </span>


        <!-- NG, 04.11.2015: Habe <a></a> durch <button></button> ausgetauscht. => Funktioniert. Sieht aber nicht unbedingt schön aus. => Gegebenenfalls statt onclick doch href nutzen?! -->
        <!--
        <span style="font-size:small;">
            <xsl:if test="starts-with(@url, 'http')">
                <xsl:choose>
                    <xsl:when test="contains(@url,'.hab.de')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "Digitale Bibliothek HAB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Herzog August Bibliothek</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Digitale Bibliothek HAB </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'.e-codices')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "e-codices",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">e-codices</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:text>e-codices </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'europeana')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "europeana Regia",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">europeana Regia </xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>europeana Regia </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'mgh')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "MGH",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">MGH</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Monumenta Germaniae Historica </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bsb')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "BSB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bayerische Staatsbibliothek
                                München</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>BSB München </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bnf')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "BnF",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bibliothèque nationale de
                                France</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>BnF </xsl:text>
                        </button>
                        <xsl:value-of select="substring-after(@n,'_')"/>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@url,'freelibrary')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "FLP",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Free Library Philadelphia</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Free Library </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bibliotecadigital')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "bibliotecadigital",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Biblioteca Real Academia de la Historia
                                Madrid</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Biblioteca Real Academia de la Historia Madrid </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'leiden')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "leiden",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bibliotheek der Rijksuniversiteit
                                Leiden</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Bibliotheek der Rijksuniversiteit Leiden </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'trier')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "trier",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">„Die ältesten deutschsprachigen Texte der
                                Stadtbibliothek Trier – ein Informationsportal im
                                Internet“</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Portal zu den ältesten deutschsprachigen Texten der SB Trier </xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'heidelberg')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "heidelberg",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">UB Heidelberg</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>UB Heidelberg</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'stgallplan')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "st_gall",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Reichenau &amp; St. Gall</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Carolingian Culture at Reichenau &amp; St. Gall</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bodley')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "bodley",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bodleian Library Oxford</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Bodleian Library Oxford</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bvmm')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "bvmm",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bibliothèque virtuelle</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Bibliothèque virtuelle</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'parkerweb')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "parkerweb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Parker Library</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Parker Library</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'manus')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "manus",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Manus online</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Manus online</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'wlb')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "wlb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">WLB Stuttgart</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>WLB Stuttgart</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'onb')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "onb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">ÖNB</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>ÖNB</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'blb')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "blb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Badische Landesbibliothek</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Badische Landesbibliothek</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'uni-muenchen')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "uni-muenchen",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Universitätsbibliothek
                                München</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Universitätsbibliothek München</xsl:text>
                        </button>
                    </xsl:when>
                    <!-\- <xsl:when test="contains(@url,'archiviocapitolaremo')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archiviocapitolaremo",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Archivio Capitolare di
                                Modena</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Archivio Capitolare di Modena</xsl:text>
                        </button>
                    </xsl:when>-\->
                    <xsl:when test="contains(@url,'berlin')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "berlin",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Staatsbibliothek Berlin</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Staatsbibliothek Berlin</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'landesarchiv-nrw')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archive.nrw",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Landesarchiv NRW, Abt.
                                Westfalen</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Landesarchiv NRW, Abt. Westfalen</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'pares')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archive.nrw",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">PARES - Portal de Archivos
                                Españoles</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>PARES</xsl:text>
                        </button>
                    </xsl:when>
                    <xsl:when test="contains(@url,'archiviodiocesano')">
                        <button>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archiviodiocesano",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Archivio Capitolare di
                                Modena</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Archivio Capitolare di Modena</xsl:text>
                        </button>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </span>-->


        <!--       <span style="font-size:small;">
            <xsl:if test="starts-with(@url, 'http')">
                <xsl:choose>
                    <xsl:when test="contains(@url,'.hab.de')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "Digitale Bibliothek HAB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Herzog August Bibliothek</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Digitale Bibliothek HAB </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'.e-codices')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "e-codices",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">e-codices</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="@url"/>
                            </xsl:attribute>
                            <xsl:text>e-codices </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'europeana')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "europeana Regia",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">europeana Regia </xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>europeana Regia </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'mgh')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "MGH",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">MGH</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Monumenta Germaniae Historica </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bsb')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "BSB",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bayerische Staatsbibliothek
                                München</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>BSB München </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bnf')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "BnF",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bibliothèque nationale de
                                France</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>BnF </xsl:text>
                        </a>
                        <xsl:value-of select="substring-after(@n,'_')"/>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@url,'freelibrary')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "FLP",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Free Library Philadelphia</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Free Library </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bibliotecadigital')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "bibliotecadigital",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Biblioteca Real Academia de la Historia
                                Madrid</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Biblioteca Real Academia de la Historia Madrid </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'leiden')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "leiden",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bibliotheek der Rijksuniversiteit
                                Leiden</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Bibliotheek der Rijksuniversiteit Leiden </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'trier')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "trier",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">„Die ältesten deutschsprachigen Texte der
                                Stadtbibliothek Trier – ein Informationsportal im
                                Internet“</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Portal zu den ältesten deutschsprachigen Texten der SB Trier </xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'heidelberg')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "heidelberg",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">UB Heidelberg</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>UB Heidelberg</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'stgallplan')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "st_gall",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Reichenau &amp; St. Gall</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Carolingian Culture at Reichenau &amp; St. Gall</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bodley')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "bodley",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bodleian Library Oxford</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Bodleian Library Oxford</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'bvmm')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "bvmm",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Bibliothèque virtuelle</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Bibliothèque virtuelle</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'parkerweb')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "parkerweb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Parker Library</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Parker Library</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'manus')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "manus",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Manus online</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Manus online</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'wlb')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "wlb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">WLB Stuttgart</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>WLB Stuttgart</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'onb')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "onb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">ÖNB</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>ÖNB</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'blb')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "blb",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Badische Landesbibliothek</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Badische Landesbibliothek</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'uni-muenchen')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "uni-muenchen",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Universitätsbibliothek
                                München</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Universitätsbibliothek München</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'archiviocapitolaremo')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archiviocapitolaremo",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Archivio Capitolare di
                                Modena</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Archivio Capitolare di Modena</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'berlin')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "berlin",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Staatsbibliothek Berlin</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Staatsbibliothek Berlin</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'landesarchiv-nrw')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archive.nrw",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Landesarchiv NRW, Abt.
                                Westfalen</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Landesarchiv NRW, Abt. Westfalen</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'pares')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archive.nrw",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">PARES - Portal de Archivos
                                Españoles</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>PARES</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:when test="contains(@url,'archiviodiocesano')">
                        <a>
                            <xsl:attribute name="onclick">window.open('<xsl:value-of select="@url"
                                />', "archiviodiocesano",
                                "width=500,height=700,left=1200,top=250")</xsl:attribute>
                            <xsl:attribute name="title">Archivio Capitolare di
                                Modena</xsl:attribute>
                            <xsl:attribute name="href"/>
                            <xsl:text>Archivio Capitolare di Modena</xsl:text>
                        </a>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </span>-->
    </xsl:template>
    <!--<xsl:template match="tei:p">
        <xsl:apply-templates/>
    </xsl:template>-->

    <xsl:template match="tei:publicationStmt"/>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <!-- Metadatenübergabe -->
    <xsl:template name="metadata">
        <xsl:for-each select="//tei:history//tei:origDate[1]">
            <xsl:element name="div">
                <xsl:attribute name="data-tei-elem">origDate</xsl:attribute>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[1][@when]">
                    <xsl:attribute name="data-when">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[1]/@when"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[1][@notAfter]">
                    <xsl:attribute name="data-notAfter">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[1]/@notAfter"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[1][@notBefore]">
                    <xsl:attribute name="data-notBefore">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[1]/@notBefore"/>
                    </xsl:attribute>
                </xsl:if>

                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[1][@from]">
                    <xsl:attribute name="data-from">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[1]/@from"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[1][@to]">
                    <xsl:attribute name="data-to">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[1]/@to"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="//tei:history/tei:origin/tei:p/tei:origDate[1]"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="//tei:history//tei:origDate[2]">
            <xsl:element name="div">
                <xsl:attribute name="data-tei-elem">origDate</xsl:attribute>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[2][@when]">
                    <xsl:attribute name="data-when">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[2]/@when"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[2][@notAfter]">
                    <xsl:attribute name="data-notAfter">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[2]/@notAfter"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[2][@notBefore]">
                    <xsl:attribute name="data-notBefore">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[2]/@notBefore"/>
                    </xsl:attribute>
                </xsl:if>

                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[2][@from]">
                    <xsl:attribute name="data-from">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[2]/@from"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="//tei:history/tei:origin/tei:p/tei:origDate[2][@to]">
                    <xsl:attribute name="data-to">
                        <xsl:apply-templates
                            select="//tei:history/tei:origin/tei:p/tei:origDate[2]/@to"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="//tei:history/tei:origin/tei:p/tei:origDate[2]"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="//tei:history//tei:origPlace[not(child::tei:placeName)]">
            <xsl:element name="div">
                <xsl:attribute name="data-tei-elem">origPlace</xsl:attribute>
                <xsl:if test="//tei:history//tei:origPlace[@ref]">
                    <xsl:attribute name="data-ref">
                        <xsl:apply-templates select="//tei:history//tei:origPlace/@ref"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="//tei:history/tei:origin/tei:p/tei:origPlace"/>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="//tei:history//tei:origPlace[child::tei:placeName]">
            <xsl:if test="//tei:history//tei:origPlace/tei:placeName[1]">
                <xsl:element name="div">
                    <xsl:attribute name="data-tei-elem">origPlace</xsl:attribute>
                    <xsl:attribute name="data-ref">
                        <xsl:apply-templates
                            select="//tei:history//tei:origPlace/tei:placeName[1]/@ref"/>
                    </xsl:attribute>
                    <xsl:apply-templates
                        select="//tei:history/tei:origin/tei:p/tei:origPlace/tei:placeName[1]"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="//tei:history//tei:origPlace/tei:placeName[2]">
                <xsl:element name="div">
                    <xsl:attribute name="data-tei-elem">origPlace</xsl:attribute>
                    <xsl:attribute name="data-ref">
                        <xsl:apply-templates
                            select="//tei:history//tei:origPlace/tei:placeName[2]/@ref"/>
                    </xsl:attribute>
                    <xsl:apply-templates
                        select="//tei:history/tei:origin/tei:p/tei:origPlace/tei:placeName[2]"/>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
        <xsl:element name="div">
            <xsl:attribute name="data-tei-elem">msItem</xsl:attribute>
            <xsl:for-each select="//tei:msContents/tei:msItem[@corresp]">
                <xsl:apply-templates select="@corresp"/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
