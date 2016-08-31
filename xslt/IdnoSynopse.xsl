<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="base_variables.xsl"/>

    <xsl:include href="xsl-output.xsl"/>

    <xsl:include href="allgFunktionen.xsl"/>

    <xsl:template match="/">
        <div class="xsl-output">

                <style type="text/css">
                    table{
                        font-size:90%;
                    }
                    td{
                        font-size:90%;
                    }</style>

            <!-- Abbildung der Liste mit einer Zeile für jedes <msDesc> -->

            <!--<div align="center" class="pager kapitularien-pager"
                style="padding-top:3%;font-size:85%;">
                <ul>
                    <li>
                        <a class="ssdone" href="#sigla"> Handschriften, denen Mordek <br/>eine Sigle zugewiesen hat </a>
                    </li>
                    <li>
                        <a class="ssdone" href="#no_sigla"> Handschriften ohne Sigle </a>
                    </li>

                </ul>
            </div>-->
            
            <div class="handschriften">
                <p>[:de]In dieser Konkordanz werden die in Mordek 1995 vergebenen Siglen den ausführlichen Handschriftensignaturen zugeordnet. Die Siglen Mordeks werden auch in der neuen Edition weiterhin verwendet.[:en]
                    This concordance gives the shelfmarks of the sigla assigned in Mordek 1995 with the shelfmarks of the respective manuscripts.                     
                    The new edition will continue to use Mordek’s sigla.[:]</p>
                    <xsl:apply-templates select="//lists"/>
                </div>

        </div>
    </xsl:template>

    <xsl:template match="lists">
      <div>
          <h4 id="sigla">[:de]Handschriften, denen Mordek eine Sigle zugewiesen hat[:en]Manuscripts with sigla (allocated by Mordek)[:]</h4>
	<xsl:apply-templates select="list[@id='sigla']"/>
        <xsl:call-template name="back-to-top-compact"/>
      </div>
        <div>
            <h4 id="newsigla">[:de]Handschriften, denen im Rahmen der Neuedition eine Sigle zugewiesen wurde[:en]Manuscripts with new sigla (allocated by the editors)[:]</h4>
            <xsl:apply-templates select="list[@id='newsigla']"/>
            <xsl:call-template name="back-to-top-compact"/>
        </div>
      <div>
          <h4 id="no_sigla">[:de]Handschriften ohne Sigle[:en]Manuscripts without sigla[:]</h4>
	<xsl:apply-templates select="list[@id='nosigla']"/>
        <xsl:call-template name="back-to-top-compact"/>
      </div>
    </xsl:template>

    <xsl:template match="list[@id='sigla']">
        <table>
            <thead>
                <tr>
                    <td class="sigle">
                        <span style="font-weight: bold;">[:de]Sigle[:en]Sigla[:]</span>
                    </td>
                    <td class="mss">
                        <span style="font-weight: bold;">[:de]Handschrift[:en]Manuscripts[:]</span>
                    </td>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="list[@id='newsigla']">
        <table>
            <thead>
                <tr>
                    <td class="sigle">
                        <span style="font-weight: bold;">[:de]Sigle[:en]Sigla[:]</span>
                    </td>
                    <td class="mss">
                        <span style="font-weight: bold;">[:de]Handschrift[:en]Manuscripts[:]</span>
                    </td>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="list[@id='nosigla']">
        <table>
            <thead>
                <tr>
                    <td/>
                    <td>[:de]Bei den folgenden Codices handelt es sich entweder um Neufunde oder um
                        Handschriften, die Mordek zwar erwähnt, ihnen aber keine Sigle zuwies.[:en]Listed below are manuscripts that were either newly discovered or that were mentioned by Mordek, but with no sigla attributed to them.[:]</td>
                </tr>

            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="item">
        <xsl:for-each select=".">
            <tr>
                <td>
                    <xsl:apply-templates select="sigle"/>
                </td>
                <td>
                    <xsl:apply-templates select="mss"/>
                </td>
            </tr>

        </xsl:for-each>
    </xsl:template>


    <xsl:template match="mss">
        <xsl:choose>
            <xsl:when test="parent::item[@status='publ']">
                <!--<a><xsl:attribute name="href">
                    <xsl:value-of select="$mss"/>
                    <xsl:value-of select="following-sibling::url"/>
                </xsl:attribute>
                    <img src="http://capitularia.uni-koeln.de/cap/publ/material/arrow_in.png"
                        title="Zur Handschrift" alt="->"/></a><xsl:text> </xsl:text>-->

                <a class="ssdone">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$mss"/>
                        <xsl:value-of select="following-sibling::url"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="sigle">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
