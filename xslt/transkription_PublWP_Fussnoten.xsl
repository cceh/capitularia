<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:set="http://exslt.org/sets"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:my="my"
    version="1.0"
    exclude-result-prefixes="exslt msxsl tei xhtml my">

	<!-- ########## INCLUDES ########## -->

        <xsl:include href="xsl-output.xsl"/>

	<!-- ########## /INCLUDES ########## -->

	<!-- author: NG & MP -->

	<!-- Funktion node-set() per Namespace "exslt" implementieren -->
	<msxsl:script language="JScript" implements-prefix="exslt">
		this['node-set'] =  function (x) {
		return x;
		}
	</msxsl:script>

	<xsl:template name="footnote-ref">
	  <a id="{generate-id(.)}-ref" href="#{generate-id(.)}-backref" class="annotation-ref ssdone">
	    <span class="print-only"></span>
	    <span class="screen-only">*</span>
	  </a>
	</xsl:template>

	<xsl:template name="footnote-backref">
	  <a id="{generate-id(.)}-backref" href="#{generate-id(.)}-ref" class="annotation-backref ssdone">
	    <span class="print-only"></span>
	    <span class="screen-only">*</span>
	  </a>
	</xsl:template>

	<xsl:template name="footnote">
	  <xsl:attribute name="data-shortcuts">0</xsl:attribute>
	  <xsl:call-template name="footnote-ref"/>
	  <div class="annotation-content">
	    <xsl:call-template name="footnote-backref"/>
	    <div class="annotation-text">
	      <xsl:apply-templates />
	    </div>
	  </div>
	</xsl:template>

	<xsl:template name="tFunoVerweis_alphabetisch">
		<xsl:param name="pBezug"/>

		<span class="annotation auto" data-shortcuts="0">
		  <xsl:call-template name="footnote-ref"/>
			<div class="annotation-content">
				<xsl:call-template name="footnote-backref"/>
				<div class="annotation-text">
					<xsl:call-template name="tFunoText_alphabetisch">
						<xsl:with-param name="pNode" select="$pBezug"/>
					</xsl:call-template>
				</div>
			</div>
		</span>

	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch">
		<xsl:param name="pNode"/>
		<xsl:choose>
			<!-- Weiterleitung zu den einzelnen Templates -->

			<xsl:when test="local-name($pNode)='subst'">
			<xsl:call-template name="tFunoText_alphabetisch_subst">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='mod'">
				<xsl:call-template name="tFunoText_alphabetisch_mod">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='add'">
				<xsl:call-template name="tFunoText_alphabetisch_add">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='del'">
				<xsl:call-template name="tFunoText_alphabetisch_del">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='note'">
				<xsl:call-template name="tFunoText_alphabetisch_note">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='sic'">
				<xsl:call-template name="tFunoText_alphabetisch_sic">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='space'">
				<xsl:call-template name="tFunoText_alphabetisch_space">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='unclear'">
				<xsl:call-template name="tFunoText_alphabetisch_unclear">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='choice'">
				<xsl:call-template name="tFunoText_alphabetisch_choice">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="local-name($pNode)='handShift'">
				<xsl:call-template name="tFunoText_alphabetisch_handShift">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_subst">

		<xsl:param name="pNode"/>

		<xsl:variable name="vWortUmKnoten">
			<xsl:call-template name="tGetWord_subst">
				<xsl:with-param name="pNode" select="$pNode"/>
				<xsl:with-param name="pWortMitte" select="$pNode/tei:del"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vWortUmKnoten_add">
			<xsl:call-template name="tGetWord">
				<xsl:with-param name="pNode" select="$pNode"/>
				<xsl:with-param name="pWortMitte" select="$pNode/tei:add"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vWortUmKnoten_del">
			<xsl:call-template name="tGetWord_subst">
				<xsl:with-param name="pNode" select="$pNode"/>
				<xsl:with-param name="pWortMitte" select="$pNode/tei:del"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vLeerzeichenDavor">
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLeerzeichenDanach">
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>


		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>


		<xsl:choose>
			<xsl:when test="not($pNode/tei:add/@hand)">
				<!-- keine Hand zugewiesen -->

				<xsl:if test="contains($pNode/tei:add,' ')">
					<span class="italic"><xsl:value-of select="$vWortUmKnoten_add"/></span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
					<xsl:text>mit Einfügungszeichen </xsl:text>
				</xsl:if>
				<xsl:if test="$pNode/tei:add/@rend='default'">
					<xsl:text>in Texttinte </xsl:text>
				</xsl:if>
				<xsl:text>korr. aus </xsl:text>

				<span class="italic"><xsl:value-of select="$vWortUmKnoten_del"/></span>

			</xsl:when>
			<xsl:when test="string-length($pNode/tei:add/@hand)!=string-length(translate($pNode/tei:add/@hand,$vHandABC,''))">
				<!-- "normale" Hand -->

				<xsl:if test="contains($pNode/tei:add,' ')">
					<span class="italic"><xsl:value-of select="$vWortUmKnoten_add"/></span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>von Hand </xsl:text>
				<xsl:value-of select="$pNode/tei:add/@hand"/>
				<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
					<xsl:text> mit Einfügungszeichen</xsl:text>
				</xsl:if>
				<xsl:if test="$pNode/tei:add/@rend='default'">
					<xsl:text> in Texttinte</xsl:text>
				</xsl:if>
				<xsl:text> korr. aus </xsl:text>

				<span class="italic"><xsl:value-of select="$vWortUmKnoten_del"/></span>

			</xsl:when>
			<xsl:when test="string-length($pNode/tei:add/@hand)!=string-length(translate($pNode/tei:add/@hand,$vHandXYZ,''))">
				<!-- "spezielle" Hand -->

				<xsl:if test="contains($pNode/tei:del,' ')">
					<span class="italic"><xsl:value-of select="$vWortUmKnoten_del"/></span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>von Hand </xsl:text>
				<xsl:value-of select="$pNode/tei:add/@hand"/>
				<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
					<xsl:text> mit Einfügungszeichen</xsl:text>
				</xsl:if>
				<xsl:if test="$pNode/tei:add/@rend='default'">
					<xsl:text> in Texttinte</xsl:text>
				</xsl:if>
				<xsl:text> korr. zu </xsl:text>
				<span class="italic"><xsl:value-of select="$vWortUmKnoten_add"/></span>

			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_mod">
		<xsl:param name="pNode"/>

		<xsl:variable name="vLeerzeichenDavor">
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vLeerzeichenDanach">
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
				<!-- wenn vor und nach <mod> kein Leerzeichen => <mod> umschließt ganzes Wort -->
				<xsl:text>korr. (?)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- <mod> innerhalb eines Wortes -->
				<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span><xsl:text> korr. (?)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_add">
		<xsl:param name="pNode"/>

		<!-- erzeugt Fußnotentext für <add> -->


				<xsl:variable name="vLeerzeichenDavorOderDanach">
					<xsl:call-template name="tLeerzeichenDavorOderDanach">
						<xsl:with-param name="pNode" select="$pNode"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="vLeerzeichenDavor">
					<xsl:call-template name="tLeerzeichenDavor">
						<xsl:with-param name="pNode" select="$pNode"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="vLeerzeichenDanach">
					<xsl:call-template name="tLeerzeichenDanach">
						<xsl:with-param name="pNode" select="$pNode"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="vWortUmKnoten">
					<xsl:call-template name="tGetWord">
						<xsl:with-param name="pNode" select="$pNode"/>
						<xsl:with-param name="pWortMitte" select="$pNode"/>
					</xsl:call-template>
				</xsl:variable>

				<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
				<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
				<xsl:variable name="vHandXYZ" select="'XYZ'"/>

				<xsl:choose>
					<xsl:when test="not($pNode/@hand)">
						<!-- #################### keine Hand zugewiesen #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine/ganzes Wort ergänzt -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- am Wortanfang -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- am Wortende -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- im Wort -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string-length($pNode/@hand)!=string-length(translate($pNode/@hand,$vHandABC,''))">
						<!-- #################### "normale" Hand #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine/ganzes Wort ergänzt -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:text> von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- am Wortanfang -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:text> von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- am Wortende -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:text> von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- im Wort -->

								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
								<xsl:text> von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänzt</xsl:text>

							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string-length($pNode/@hand)!=string-length(translate($pNode/@hand,$vHandXYZ,''))">
						<!-- #################### "spezielle" Hand #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine/ganzes Wort ergänzt -->

								<xsl:text>folgt von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> ergänztes </xsl:text>
								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='false'">
								<!-- am Wortanfang -->

								<xsl:text>von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> korr. zu </xsl:text>
								<span class="italic"><xsl:value-of select="$vWortUmKnoten"/></span>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- am Wortende -->

								<xsl:text>von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> korr. zu </xsl:text>
								<span class="italic"><xsl:value-of select="$vWortUmKnoten"/></span>

							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- im Wort -->

								<xsl:text>von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen</xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/@rend='default'">
									<xsl:text> in Texttinte</xsl:text>
								</xsl:if>
								<xsl:text> korr. zu </xsl:text>
								<span class="italic"><xsl:value-of select="$vWortUmKnoten"/></span>

							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_del">
		<xsl:param name="pNode"/>

		<xsl:variable name="vLeerzeichenDavor">
			<xsl:call-template name="tLeerzeichenDavor">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vLeerzeichenDanach">
			<xsl:call-template name="tLeerzeichenDanach">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
		</xsl:variable>


		<!-- Variablen/Mengen für Hand A-W bzw. Hand X-Z -->
		<xsl:variable name="vHandABC" select="'ABCDEFGHIJKLMNOPQRSTUVW'"/>
		<xsl:variable name="vHandXYZ" select="'XYZ'"/>

		<xsl:choose>
			<xsl:when test="count($pNode/node())=0">
				<!-- leer -->
			</xsl:when>

			<xsl:when test="count($pNode/node())>0">
				<!-- nicht leer -->

				<xsl:choose>
					<xsl:when test="not($pNode/@hand)">
						<!-- #################### keine Hand angegeben #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- ganzes Wort getilgt -->
								<xsl:text>folgt getilgtes </xsl:text>
								<span class="italic"><xsl:value-of select="$pNode"/></span>
							</xsl:when>
							<xsl:when test="($vLeerzeichenDavor='false' and $vLeerzeichenDanach='false') or ($vLeerzeichenDavor='true' and $vLeerzeichenDanach='false') or ($vLeerzeichenDavor='false' and $vLeerzeichenDanach='true')">
								<!-- Teil des Wortes getilgt -->
								<xsl:text>korr. aus </xsl:text>
								<span class="italic">
									<xsl:call-template name="tGetWord">
										<xsl:with-param name="pNode" select="$pNode"/>
										<xsl:with-param name="pWortMitte" select="$pNode"/>
									</xsl:call-template>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<!-- ??? -->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:when test="string-length($pNode/@hand)!=string-length(translate($pNode/@hand,$vHandABC,''))">
						<!-- #################### entspricht "normaler" Hand #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- ganzes Wort getilgt -->
								<xsl:text>folgt von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:text> getilgtes </xsl:text>
								<span class="italic"><xsl:apply-templates select="$pNode/node()"/></span>
							</xsl:when>
							<xsl:when test="($vLeerzeichenDavor='false' and $vLeerzeichenDanach='false') or ($vLeerzeichenDavor='true' and $vLeerzeichenDanach='false') or ($vLeerzeichenDavor='false' and $vLeerzeichenDanach='true')">
								<!-- Teil des Wortes getilgt -->


								<xsl:text>von Hand </xsl:text>
								<xsl:apply-templates select="$pNode/@hand"/>
								<xsl:text> korr. aus </xsl:text>
								<span class="italic">
									<xsl:call-template name="tGetWord">
										<xsl:with-param name="pNode" select="$pNode"/>
										<xsl:with-param name="pWortMitte" select="$pNode"/>
									</xsl:call-template>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<!-- ??? -->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:when test="string-length($pNode/@hand)!=string-length(translate($pNode/@hand,$vHandXYZ,''))">
						<!-- #################### entspricht "spezieller" Hand #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- ganzes Wort getilgt -->
								<xsl:text>von Hand </xsl:text>
								<xsl:value-of select="$pNode/@hand"/>
								<xsl:text> getilgt </xsl:text>
							</xsl:when>
							<xsl:when test="($vLeerzeichenDavor='false' and $vLeerzeichenDanach='false') or ($vLeerzeichenDavor='true' and $vLeerzeichenDanach='false') or ($vLeerzeichenDavor='false' and $vLeerzeichenDanach='true')">
								<!-- Teil des Wortes getilgt -->

								<xsl:text>von Hand </xsl:text>
								<xsl:apply-templates select="$pNode/@hand"/>
								<xsl:text> korr. zu </xsl:text>
								<span class="italic">
									<xsl:call-template name="tGetWord">
										<xsl:with-param name="pNode" select="$pNode"/>
										<xsl:with-param name="pWortMitte" select="''"/>
									</xsl:call-template>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<!-- ??? -->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_note">
		<xsl:param name="pNode"/>

		<xsl:if test="@target">
			<xsl:variable name="vPrecSeg" select="$pNode/preceding-sibling::node()[1][local-name(.)='span'][@xml:id]"/>
			<xsl:variable name="vBezug">
				<xsl:value-of select="$vPrecSeg/text()[1]"/>
				<xsl:value-of select="$vPrecSeg/tei:add"/>
				<xsl:value-of select="substring-before($vPrecSeg/text()[last()],' ')"/>
				<xsl:text>...</xsl:text>
				<xsl:value-of select="substring-after($vPrecSeg/text()[last()],' ')"/>
				<xsl:text>: </xsl:text>
			</xsl:variable>
			<xsl:value-of select="$vBezug"/>
		</xsl:if>
		<xsl:apply-templates select="$pNode/node()"/>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_sic">
		<xsl:param name="pNode"/>

		<xsl:text>sic Hs.</xsl:text>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_space">
		<xsl:param name="pNode"/>

		<xsl:text>Lücke von ca. </xsl:text>
		<xsl:value-of select="$pNode/@quantity"/>
		<xsl:text> </xsl:text>
		<!-- Zählwort/Maßeinheit mit passender Flexion ermitteln -->
		<xsl:choose>
			<xsl:when test="$pNode/@unit='chars'">
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<!-- Singular -->
						<xsl:text>Buchstaben</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- Plural -->
						<xsl:text>Buchstaben</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$pNode/@unit='words'">
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<!-- Singular -->
						<xsl:text>Wort</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- Plural -->
						<xsl:text>Wörtern</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<!-- Singular -->
						<xsl:text>Einheit</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- Plural -->
						<xsl:text>Einheiten</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_unclear">
		<xsl:param name="pNode"/>

		<xsl:text>Lücke von ca. </xsl:text>
		<xsl:value-of select="$pNode/@quantity"/>
		<xsl:text> </xsl:text>
		<!-- Zählwort/Maßeinheit mit passender Flexion ermitteln -->
		<xsl:choose>
			<xsl:when test="$pNode/@unit='chars'">
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<!-- Singular -->
						<xsl:text>Buchstaben</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- Plural -->
						<xsl:text>Buchstaben</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$pNode/@unit='words'">
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<!-- Singular -->
						<xsl:text>Wort</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- Plural -->
						<xsl:text>Wörtern</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$pNode/@quantity='1'">
						<!-- Singular -->
						<xsl:text>Einheit</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- Plural -->
						<xsl:text>Einheiten</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_choice">
		<xsl:param name="pNode"/>

		<xsl:text>gek. </xsl:text>
		<span class="italic">
			<xsl:value-of select="$pNode/tei:abbr"/>
		</span>

	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_handShift">
		<xsl:param name="pNode"/>

		<xsl:text>Im folgenden Schreiberwechsel zu Hand </xsl:text>
		<span class="italic">
			<xsl:value-of select="$pNode/@new"/>
		</span>
		<xsl:text>.</xsl:text>

	</xsl:template>

	<xsl:template name="tFunoText_numerisch">
		<xsl:param name="pNode"/>
		<xsl:choose>
			<xsl:when test="local-name($pNode)='note'">
				<xsl:apply-templates select="$pNode/node()"/>
			</xsl:when>
			<xsl:when test="local-name($pNode)='ref'">
				<xsl:apply-templates select="$pNode/node()"/>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
