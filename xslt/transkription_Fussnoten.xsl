<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:my="my" version="1.0" exclude-result-prefixes="exslt msxsl tei xhtml my">

        <xsl:include href="xsl-output.xsl"/>

	<!-- author: NG -->
	<!--<xsl:include href="allgFunktionen.xsl"/>-->
	<!--<xsl:include href="transkription_ZusatzFunktionen.xsl"/>-->

	<!-- Funktion node-set() per Namespace "exslt" implementieren -->
	<msxsl:script language="JScript" implements-prefix="exslt">
		this['node-set'] =  function (x) {
		return x;
		}
	</msxsl:script>

	<xsl:key name="kSubst_Liste" match="//tei:subst" use="generate-id(.)"/>
	<xsl:key name="kAdd_Liste" match="//tei:add" use="generate-id(.)"/>
	<xsl:key name="kDel_Liste" match="//tei:del" use="generate-id(.)"/>
	<xsl:key name="kMod_Liste" match="//tei:mod" use="generate-id(.)"/>

	<xsl:key name="kSic_Liste" match="//tei:sic" use="generate-id(.)"/>

	<xsl:key name="kSpace_Liste" match="//tei:space" use="generate-id(.)"/>

	<xsl:template name="tFunoVerweis_alphabetisch">
		<xsl:param name="pBezug"/>


		<!-- Bezugsknoten -->
		<xsl:variable name="vBezug" select="$pBezug"/>

		<!-- Text für Tooltip erstellen -->
		<xsl:variable name="vFunoText">
			<xsl:call-template name="tFunoText_alphabetisch">
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vIndex">
			<xsl:call-template name="indexOf_a">
				<xsl:with-param name="pSeq" select="$funoAlphabetisch"/>
				<xsl:with-param name="pNode" select="$vBezug"/>
			</xsl:call-template>
		</xsl:variable>

		<span class="annotation">
			<a href="#{generate-id($vBezug)}" id="{generate-id($vBezug)}-L" class="annotation-link ssdone">
				<xsl:value-of select="$vIndex"/>
				<xsl:if test="$vIndex=''">
					<xsl:text>{NoIndex}</xsl:text>
				</xsl:if>
			</a>
			<div class="annotation-content">
				<a class="ssdone" href="#{generate-id($vBezug)}">
					<xsl:call-template name="tTooltip">
						<xsl:with-param name="pNode" select="exslt:node-set($vFunoText)"/>
					</xsl:call-template>
				</a>
			</div>
		</span>

	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch">
		<xsl:param name="pNode"/>
		<xsl:choose>

			<!-- ############################################################## <subst> ############################################################## -->

			<xsl:when test="local-name($pNode)='subst'">
				<!--<xsl:text>{subst}</xsl:text> <!-\- TESTWEISE -\->-->
			<xsl:call-template name="tFunoText_alphabetisch_subst">
				<xsl:with-param name="pNode" select="$pNode"/>
			</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <mod> ############################################################## -->

			<xsl:when test="local-name($pNode)='mod'">
				<xsl:call-template name="tFunoText_alphabetisch_mod">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <add> ############################################################## -->

			<xsl:when test="local-name($pNode)='add'">
				<!--<xsl:text>{add}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_add">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <del> ############################################################## -->

			<xsl:when test="local-name($pNode)='del'">
				<!--<xsl:text>{del}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_del">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <note> ############################################################## -->

			<xsl:when test="local-name($pNode)='note'">
				<!--<xsl:text>{note}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_note">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <sic> ############################################################## -->

			<xsl:when test="local-name($pNode)='sic'">
				<!--<xsl:text>{sic}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_sic">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <space> ############################################################## -->

			<xsl:when test="local-name($pNode)='space'">
				<!--<xsl:text>{space}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_space">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <unclear> ############################################################## -->

			<xsl:when test="local-name($pNode)='unclear'">
				<!--<xsl:text>{unclear}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_unclear">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <choice> ############################################################## -->

			<xsl:when test="local-name($pNode)='choice'">
				<!--<xsl:text>{choice}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_choice">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ############################################################## <handShift> ############################################################## -->

			<xsl:when test="local-name($pNode)='handShift'">
				<!--<xsl:text>{handShift}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:call-template name="tFunoText_alphabetisch_handShift">
					<xsl:with-param name="pNode" select="$pNode"/>
				</xsl:call-template>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

	<xsl:template name="tFunoText_alphabetisch_subst">

		<xsl:param name="pNode"/>

		<xsl:variable name="vWortUmKnoten">
			<xsl:call-template name="tGanzesWort_subst">
				<xsl:with-param name="pNode" select="$pNode"/>
				<xsl:with-param name="pWortMitte" select="$pNode/tei:del"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vWortUmKnoten_add">
			<xsl:call-template name="tGanzesWort">
				<xsl:with-param name="pNode" select="$pNode"/>
				<xsl:with-param name="pWortMitte" select="$pNode/tei:add"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="vWortUmKnoten_del">
			<xsl:call-template name="tGanzesWort_subst">
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
					<xsl:call-template name="tGanzesWort">
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

								<!--<span class="debug"><xsl:text>{add_tt}</xsl:text></span>-->

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

								<!--<span class="debug"><xsl:text>{add_tf}</xsl:text></span>-->

<!--								<xsl:if test="contains($pNode,' ')">
									<i><xsl:value-of select="$vWortUmKnoten"/></i>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen </xsl:text>
								</xsl:if>
								<xsl:text>korr. aus </xsl:text>
								<i>
									<xsl:call-template name="tPrecedingWortteil_fromThis">
										<xsl:with-param name="pPrecedingTextThis" select="$pNode"/>
										<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
									</xsl:call-template>

									<!-\-<span class="debug"><xsl:text>{</xsl:text></span>-\->

									<xsl:call-template name="tFollowingWortteil_fromThis">
										<xsl:with-param name="pFollowingTextThis" select="$pNode"/>
										<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
									</xsl:call-template>

									<!-\-<span class="debug"><xsl:text>}</xsl:text></span>-\->
								</i>
								<xsl:if test="current()[@rend='default']">
									<xsl:text>- korr. in Texttinte</xsl:text>
								</xsl:if>-->

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

								<!--<span class="debug"><xsl:text>{add_ft}</xsl:text></span>-->

<!--								<xsl:if test="contains($pNode,' ')">
									<i><xsl:value-of select="$vWortUmKnoten"/></i>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen </xsl:text>
								</xsl:if>
								<xsl:text>korr. aus </xsl:text>
								<i>
									<!-\-<span class="debug"><xsl:text>{</xsl:text></span>-\->

									<xsl:call-template name="tPrecedingWortteil_fromThis">
										<xsl:with-param name="pPrecedingTextThis" select="$pNode"/>
										<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
									</xsl:call-template>

									<!-\-<span class="debug"><xsl:text>}</xsl:text></span>-\->

									<xsl:call-template name="tFollowingWortteil_fromThis">
										<xsl:with-param name="pFollowingTextThis" select="$pNode"/>
										<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
									</xsl:call-template>


								</i>
								<xsl:if test="current()[@rend='default']">
									<xsl:text> - korr. in Texttinte</xsl:text>
								</xsl:if>-->

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

								<!--<span class="debug"><xsl:text>{add_ff}</xsl:text></span>-->

<!--								<xsl:if test="contains($pNode,' ')">
									<i><xsl:value-of select="$vWortUmKnoten"/></i>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen </xsl:text>
								</xsl:if>
								<xsl:text>korr. aus </xsl:text>
								<i>
									<xsl:call-template name="tPrecedingWortteil_fromThis">
										<xsl:with-param name="pPrecedingTextThis" select="$pNode"/>
										<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
									</xsl:call-template>
									<xsl:call-template name="tFollowingWortteil_fromThis">
										<xsl:with-param name="pFollowingTextThis" select="$pNode"/>
										<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
									</xsl:call-template>
								</i>
								<xsl:if test="current()[@rend='default']">
									<xsl:text> - korr. in Texttinte</xsl:text>
								</xsl:if>-->

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

								<!--<span class="debug"><xsl:text>{add-A-tt}</xsl:text></span>-->

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

								<!--<span class="debug"><xsl:text>{add-A-tf}</xsl:text></span>-->

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




<!--								<xsl:if test="contains($pNode,' ')">
									<i><xsl:value-of select="$vWortUmKnoten"/></i>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen </xsl:text>
								</xsl:if>
								<xsl:text>korr. aus </xsl:text>
								<i>
									<xsl:call-template name="tPrecedingWortteil_fromThis">
										<xsl:with-param name="pPrecedingTextThis" select="$pNode"/>
										<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
									</xsl:call-template>

									<!-\-<span class="debug"><xsl:text>{</xsl:text></span>-\->

									<xsl:call-template name="tFollowingWortteil_fromThis">
										<xsl:with-param name="pFollowingTextThis" select="$pNode"/>
										<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
									</xsl:call-template>
								</i>-->
							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='true'">
								<!-- am Wortende -->

								<!--<span class="debug"><xsl:text>{add-A-ft}</xsl:text></span>-->

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


<!--								<xsl:if test="contains($pNode,' ')">
									<i><xsl:value-of select="$vWortUmKnoten"/></i>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen </xsl:text>
								</xsl:if>
								<xsl:text>korr. aus </xsl:text>
								<i>
									<xsl:call-template name="tPrecedingWortteil_fromThis">
										<xsl:with-param name="pPrecedingTextThis" select="$pNode"/>
										<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
									</xsl:call-template>

									<!-\-<span class="debug"><xsl:text>{</xsl:text></span>-\->

									<xsl:call-template name="tFollowingWortteil_fromThis">
										<xsl:with-param name="pFollowingTextThis" select="$pNode"/>
										<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
									</xsl:call-template>
								</i>-->
							</xsl:when>
							<xsl:when test="$vLeerzeichenDavor='false' and $vLeerzeichenDanach='false'">
								<!-- im Wort -->

								<!--<span class="debug"><xsl:text>{add-A-ff}</xsl:text></span>-->

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



<!--								<xsl:if test="contains($pNode,' ')">
									<i><xsl:value-of select="$vWortUmKnoten"/></i>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:if test="$pNode/following-sibling::*[1][local-name(.)='metamark']">
									<xsl:text> mit Einfügungszeichen </xsl:text>
								</xsl:if>
								<xsl:text>korr. aus </xsl:text>
								<i>
									<xsl:call-template name="tPrecedingWortteil_fromThis">
										<xsl:with-param name="pPrecedingTextThis" select="$pNode"/>
										<xsl:with-param name="pPrecedingTextBeforeNode" select="''"/>
									</xsl:call-template>

									<!-\-<span class="debug"><xsl:text>{</xsl:text></span>-\->

									<xsl:call-template name="tFollowingWortteil_fromThis">
										<xsl:with-param name="pFollowingTextThis" select="$pNode"/>
										<xsl:with-param name="pFollowingTextBeforeNode" select="''"/>
									</xsl:call-template>
								</i>-->
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string-length($pNode/@hand)!=string-length(translate($pNode/@hand,$vHandXYZ,''))">
						<!-- #################### "spezielle" Hand #################### -->

						<xsl:choose>
							<xsl:when test="$vLeerzeichenDavor='true' and $vLeerzeichenDanach='true'">
								<!-- steht alleine/ganzes Wort ergänzt -->

								<!--<span class="debug"><xsl:text>{tt}</xsl:text></span>-->

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

								<!--<span class="debug"><xsl:text>{tf}</xsl:text></span>-->


								<xsl:text>von Hand </xsl:text>
								<xsl:value-of select="@hand"/>
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

								<!--<span class="debug"><xsl:text>{ft}</xsl:text></span>-->

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

								<!--<span class="debug"><xsl:text>{ff}</xsl:text></span>-->

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
									<xsl:call-template name="tGanzesWort">
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

								<xsl:text>korr. von Hand </xsl:text>
								<xsl:apply-templates select="$pNode/@hand"/>
								<xsl:text> aus </xsl:text>
								<span class="italic">
									<xsl:call-template name="tGanzesWort">
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
								<xsl:text>korr. von Hand </xsl:text>
								<xsl:apply-templates select="$pNode/@hand"/>
								<xsl:text> zu </xsl:text>
								<span class="italic">
									<xsl:call-template name="tGanzesWort">
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
				<!--<xsl:text>{note @type=comment}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:apply-templates select="$pNode/node()"/>
			</xsl:when>
			<xsl:when test="local-name($pNode)='ref'">
				<!--<xsl:text>{ref}</xsl:text> <!-\- TESTWEISE -\->-->
				<xsl:apply-templates select="$pNode/node()"/>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

	<xsl:template match="*">
		<ERROR>
			<xsl:comment>
				<xsl:text>ERROR: element '</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>' not handled</xsl:text>
			</xsl:comment>
			<xsl:apply-templates/>
			<xsl:comment>
				<xsl:value-of select="local-name()"/>
			</xsl:comment>
		</ERROR>
	</xsl:template>

</xsl:stylesheet>
