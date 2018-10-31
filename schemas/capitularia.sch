<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
	<ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
	<!--Platzhalter-->
	<pattern id="platzhalter_leerezeichen-vorgaben">
		<rule context="text()[ancestor::tei:body][not(ancestor::tei:note)]">
			<report test="matches(.,'\.[a-z]')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'\.[a-z]')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,'[a-z]\.')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'[a-z]\.')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,',[a-z]')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,',[a-z]')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,'[a-z],')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'[a-z],')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,';[a-z]')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,';[a-z]')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,'[a-z];')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'[a-z];')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,':[a-z]')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,':[a-z]')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,'[a-z]:')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'[a-z]:')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,'/[a-z]')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'/[a-z]')][ancestor::body][not(ancestor::note)]</report>
			<report test="matches(.,'[a-z]/')" role="warning">Auf Platzhalter folgt kein Leerzeichen X-PATH: //text()[matches(.,'[a-z]/')][ancestor::body][not(ancestor::note)]</report>
		</rule>
	</pattern>
	<!-- Prüfungen für Element cb: muss über ein n-Attribut verfügen und das Attribut darf nicht leer sein  -->
	<pattern id="cb">
		<rule context="tei:cb">
			<assert test="@n[string-length(.) > 0]" role="error">Attribut n muss vorhanden und darf nicht leer sein!</assert>
		</rule>
	</pattern>
	<!-- Prüfungen für Element lb: Attribut n darf nur Zahlen, keine Buchstaben enthalten -->
	<pattern id="lb">
		<rule context="tei:lb">
			<report test="@n[not(matches(., '(\d)$'))]" role="error">Attribut n darf nur Seitenzahlen enthalten</report>
		</rule>
	</pattern>
	<!--  -->
	<!--  -->
	<!--  -->
	<!-- Ausweisung von Schreibern -->
	<!-- Prüfungen für Element handShift: Attribut new ist obligatorisch und darf nur einzelne Großbuchstaben enthalten  -->
	<pattern id="handShift">
		<rule context="tei:handShift">
			<assert test="@new[string-length(.) > 0]" role="error">Schreiber: Attribut new muss vorhanden und darf nicht leer sein!</assert>
			<report test="@new[not(matches(., '[A-Z]'))]" role="warning">Schreiber: Attribut new darf nur einzelne Großbuchstaben enthalten</report>
		</rule>
	</pattern>
	<!-- Prüfungen für Attribut hand: darf nur einzelne Großbuchstaben enthalten  -->
	<pattern id="add">
		<rule context="tei:*">
			<report test="@hand[not(matches(., '[A-Z]'))]" role="warning">Schreiber: Attribut hand darf nur einzelne Großbuchstaben enthalten</report>
		</rule>
	</pattern>
	<!--  -->
	<!--  -->
	<!--  -->
	<!-- Abkürzungen -->
	<pattern id="abkuerzung-aufloesung">
		<rule context="tei:choice">
			<assert test="tei:abbr and tei:expan" role="error">Abkürzung oder Auflösung fehlt</assert>
		</rule>
	</pattern>
	<pattern id="abkuerzungen-stillschweigend-aufloesen-body">
		<rule context="text()[ancestor::tei:body][not(ancestor::tei:note)]">
			<report test="contains(.,' cap. ')" role="warning">Text enthält ' cap. ', soll stillschweigend aufgelöst werden zu: capitulum, capitulare (wo theoretisch beides möglich ist, wird weiterhin mit "choice"  codiert) - X-PATH: //text()[matches(.,' cap. ')][ancestor::body]</report>
			<report test="contains(.,' capit. ')" role="warning">Text enthält ' capit. ', Soll stillschweigend aufgelöst werden zu: capitulum, capitulare (wo theoretisch beides möglich ist, wird weiterhin mit "choice" codiert) - X-PATH: //text()[matches(.,' capit. ')][ancestor::body]</report>
			<report test="contains(.,' sol. ')" role="warning">Text enthält ' sol. ', Soll stillschweigend aufgelöst werden zu: solidus - X-PATH: //text()[matches(.,' sol. ')][ancestor::body]</report>
			<report test="contains(.,' sold. ')" role="warning">Text enthält ' sold. ', Soll stillschweigend aufgelöst werden zu: solidus - X-PATH: //text()[matches(.,' sold. ')][ancestor::body]</report>
			<report test="contains(.,' solid. ')" role="warning">Text enthält ' solid. ', Soll stillschweigend aufgelöst werden zu: solidus - X-PATH: //text()[matches(.,' solid. ')][ancestor::body]</report>
			<report test="contains(.,' denr. ')" role="warning">Text enthält ' denr. ', Soll stillschweigend aufgelöst werden zu: denarius - X-PATH: //text()[matches(.,' denr. ')][ancestor::body]</report>
			<!-- Noch in Diskussion, siehe Transkriptionsanweisungen -->
			<!--<report test="contains(.,' st. ')" role="warning">Soll stillschweigend aufgelöst werden zu: (-)sunt/-runt</report>
			<report test="contains(.,' rt. ')" role="warning">Soll stillschweigend aufgelöst werden zu: (-)sunt/-runte</report>-->
			<report test="contains(.,' d. ')" role="warning">Text enthält ' d. ', -Soll stillschweigend aufgelöst werden zu: dus - X-PATH: //text()[matches(.,' d. ')][ancestor::body]</report>
			<report test="contains(.,' dns. ')" role="warning">Text enthält ' dns. ', Soll stillschweigend aufgelöst werden zu: dominus (Gott, Christus; auch: „Herr“ allgemein, z.B. „dominus eius“ in Bezug auf einen Unfreien) bzw. domnus (für weltliche Anreden, z.B. „domnus rex“ oder „domnus Karolus“) - X-PATH: //text()[matches(.,' dns. ')][ancestor::body]</report>
		</rule>
	</pattern>
	<pattern id="abkuerzungen-stillschweigend-aufloesen-div-type-content">
		<rule context="text()[ancestor::tei:div[@type='content']][not(ancestor::tei:note)]">
			<report test="contains(.,' cap. ')" role="warning">Text enthält ' cap. ', Soll stillschweigend aufgelöst werden zu: capitulum, capitulare (wo theoretisch beides möglich ist, wird weiterhin mit "choice"  codiert) - X-PATH: //text()[matches(.,' cap. ')][ancestor::div[@type='content']]</report>
			<report test="contains(.,' capit. ')" role="warning">Text enthält ,' capit. ', Soll stillschweigend aufgelöst werden zu: capitulum, capitulare (wo theoretisch beides möglich ist, wird weiterhin mit "choice" codiert) - X-PATH: //text()[matches(.,' capit. ')][ancestor::div[@type='content']]</report>
			<report test="contains(.,' sol. ')" role="warning">Text enthält ' sol. ', Soll stillschweigend aufgelöst werden zu: solidus - X-PATH: //text()[matches(.,' sol. ')][ancestor::div[@type='content']]</report>
			<report test="contains(.,' sold. ')" role="warning">Text enthält ' sold. ', Soll stillschweigend aufgelöst werden zu: solidus - X-PATH: //text()[matches(.,' sold. ')][ancestor::div[@type='content']]</report>
			<report test="contains(.,' solid. ')" role="warning">Text enthält ' solid. ', Soll stillschweigend aufgelöst werden zu: solidus - X-PATH: //text()[matches(.,' solid. ')][ancestor::div[@type='content']]</report>
			<report test="contains(.,' denr. ')" role="warning">Text enthält ' denr. ', Soll stillschweigend aufgelöst werden zu: denarius - X-PATH: //text()[matches(.,' denr. ')][ancestor::div[@type='content']]</report>
			<!-- Noch in Diskussion, siehe Transkriptionsanweisungen -->
			<!--<report test="contains(.,' st. ')" role="warning">Soll stillschweigend aufgelöst werden zu: (-)sunt/-runt</report>
			<report test="contains(.,' rt. ')" role="warning">Soll stillschweigend aufgelöst werden zu: (-)sunt/-runte</report>-->
			<report test="contains(.,' d. ')" role="warning">Text enthält ' d. ', Soll stillschweigend aufgelöst werden zu: dus - X-PATH: //text()[matches(.,' d. ')][ancestor::div[@type='content']]</report>
			<report test="contains(.,' dns. ')" role="warning">Text enthält ' dns. ', Soll stillschweigend aufgelöst werden zu: dominus (Gott, Christus; auch: „Herr“ allgemein, z.B. „dominus eius“ in Bezug auf einen Unfreien) bzw. domnus (für weltliche Anreden, z.B. „domnus rex“ oder „domnus Karolus“) - X-PATH: //text()[matches(.,' dns. ')][ancestor::div[@type='content']]</report>
		</rule>
	</pattern>
	<pattern id="Unzulaessige-Kindelemente-in-abbr">
		<rule context="tei:choice">
			<report test="tei:abbr/*[not(self::tei:hi[@rend])]" role="warning">Codierung in "abbr" vorhanden(Ausnahme hi), darf aber nur in "expan" stehen</report>
		</rule>
	</pattern>
	<!-- Nicht auflösbare Abkürzungen -->
	<pattern id="abbr-nicht-aufloesbar">
		<rule context="tei:abbr[not (parent::tei:choice)]">
			<assert test="following-sibling::node()[1][self::tei:note[@type='editorial']]" role="warning">Auf nicht aufloesbare Abkürzung soll eine note type='editorial' folgen.</assert>
		</rule>
	</pattern>
	<!--  -->
	<!--  -->
	<!--  -->
	<!-- Korrekturen -->
	<pattern id="subst-del-add">
		<rule context="tei:subst">
			<assert test="tei:add and tei:del" role="error">subst soll add und del enthalten, eins von beiden fehlt</assert>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!-- Notes-->
	<pattern id="note">
		<rule context="tei:note[ancestor::tei:text]">
			<assert test="@type" role="warning">Alle notes im text-Element sollen über ein @type verfügen</assert>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!-- supportDesc-->
	<pattern id="supportDesc">
		<rule context="tei:supportDesc[ancestor::tei:text]">
			<assert test="@type" role="warning">Alle supportDesc im text-Element sollen über ein @material verfügen</assert>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!-- Sic mit Anmerkungen-->
	<pattern id="note-in-sic">
		<rule context="tei:sic">
			<report test="following-sibling::node()[1][self::tei:note]" role="warning">note folgt direkt auf sic, soll aber innerhalb stehen</report>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--Abbildungen-->
	<pattern id="figure">
		<rule context="tei:figure">
			<report test="tei:figDesc and tei:graphic" role="warning">figure soll figDesc und  graphic enthalten, eins von beiden fehlt</report>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--anchor-->
	<pattern id="anchor">
		<rule context="tei:anchor">
			<report test="text()" role="warning">Soll keinen Text enthalten</report>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--milestone-->
	<pattern id="milestone">
		<rule context="tei:milestone">
			<report test="text()" role="warning">Soll keinen Text enthalten</report>
		</rule>
	</pattern>
	<pattern id="milestone_prev">
		<rule context="tei:milestone/@prev">
			<assert test="starts-with(.,'#')" role="warning">Attributwert soll mit # starten</assert>
		</rule>
	</pattern>
	<pattern id="milestone_next">
		<rule context="tei:milestone/@next">
			<assert test="starts-with(.,'#')" role="warning">Attributwert soll mit # starten</assert>
		</rule>
	</pattern>
	<pattern id="milestone_spanTo">
		<rule context="tei:milestone/@spanTo">
			<assert test="starts-with(.,'#')" role="warning">Attributwert soll mit # starten</assert>
		</rule>
	</pattern>
	<pattern id="milestone_parents">
		<rule context="tei:milestone[ancestor::tei:ab]">
			<report test="parent::*/parent::tei:ab" role="warning">milestone innerhalb von ab darf in kein anderes Element geschachtelt sein</report>
		</rule>
	</pattern>
	<!--ab-->
	<pattern id="ab_prev">
		<rule context="tei:ab/@prev">
			<assert test="starts-with(.,'#')" role="warning">Attributwert soll mit # starten</assert>
		</rule>
	</pattern>
	<pattern id="ab_next">
		<rule context="tei:ab/@next">
			<assert test="starts-with(.,'#')" role="warning">Attributwert soll mit # starten</assert>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--ptr-->
	<pattern id="ptr-content">
		<rule context="tei:ptr[ancestor::tei:div[@type='content']]/@target">
			<assert test="starts-with(.,'#')" role="warning">Attributwert soll mit # starten</assert>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--metamark-->
	<pattern id="metamark">
		<rule context="tei:metamark">
			<report test="text()" role="warning">Soll keinen Text enthalten</report>
			<assert test="preceding-sibling::node()[1][self::tei:add]">metamark soll direkt auf ein schließendes "add" folgen</assert>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--seg-->
	<pattern id="seg-type">
		<rule context="tei:seg[@type='num']">
			<report test="contains(.,'.')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,',')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,';')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,':')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,'/')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
	<!--num-->
	<pattern id="num">
		<rule context="tei:num">
			<report test="contains(.,'.')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,',')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,';')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,':')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
			<report test="contains(.,'/')" role="warning">Inhalt darf keine Interpunktionszeichen enthalten </report>
		</rule>
	</pattern>
	<!--  -->	
	<!--  -->
	<!--  -->
<pattern id="altIdentifier-idno">
		<rule context="tei:altIdentifier[@type='siglum']/tei:idno">
			<report test="contains(.,' ')" role="warning">Inhalt darf keine Leerstellen enthalten</report>
		</rule>
	</pattern>
</schema>