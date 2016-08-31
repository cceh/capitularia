<?xml version="1.0" encoding="UTF-8"?>

<!-- Diese Datei enthält die grundlegenden Variablen zur internen (und externen) Verlinkung. Andere Skripte sollen auf diese zugreifen können.
    DS, NG 08/2015 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">

    <!-- #### grundlegende interne Verlinkungen #### -->
    <xsl:variable name="base">http://capitularia.uni-koeln.de</xsl:variable>
    <xsl:variable name="base_en">http://capitularia.uni-koeln.de/en/</xsl:variable>
    <!-- Verlinkungen zu den englischen Seiten -->

    <!-- #### Kapitularien #### -->
    <xsl:variable name="capit"><xsl:value-of select="$base"/>/capit/</xsl:variable>
    <!-- Kapitularien - Einleitungstext; darunter hängen die einzelnen Übersichten -->
    <xsl:variable name="capit_all"><xsl:value-of select="$capit"/>list/</xsl:variable>
    <!-- Kapitulariengesamtliste -->
    <xsl:variable name="capit_ldf"><xsl:value-of select="$capit"/>ldf/</xsl:variable>
    <!-- Kapitularien Ludwigs des Frommen -->
    <xsl:variable name="capit_loth"><xsl:value-of select="$capit"/>ltr/</xsl:variable>
    <!-- Kapitularien Lothars - DS 15.08.2016 -->
    <xsl:variable name="capit_pre"><xsl:value-of select="$capit"/>pre814/</xsl:variable>
    <!-- Kapitularien vor 814 ### langfristig Aufspaltung in einzelne Herrscher -->
    <xsl:variable name="capit_post"><xsl:value-of select="$capit"/>post840/</xsl:variable>
    <!-- Kapitularien nach 840 ### langfristig Aufspaltung in einzelne Herrscher -->
    <xsl:variable name="capit_undated"><xsl:value-of select="$capit"/>undated/</xsl:variable>
    <!-- undatierte Kapitularien -->

    <!-- #### Handschriften #### -->
    <xsl:variable name="mss"><xsl:value-of select="$base"/>/mss/</xsl:variable>
    <!-- Handschriften - Einleitungstext; darunter hängen die entsprechenden Übersichten sowie die einzelnen Handschriftenseiten (=ID)-->
    <xsl:variable name="mss_table"><xsl:value-of select="$mss"/>table</xsl:variable>
    <!-- tabellarische Übersicht über die Handschriften -->
    <xsl:variable name="mss_capit"><xsl:value-of select="$mss"/>capit</xsl:variable>
    <!-- Handschriften nach Kapitularien -->
    <xsl:variable name="mss_idno"><xsl:value-of select="$mss"/>idno</xsl:variable>
    <!-- Handschriften nach Signatur / alphabetisch -->
    <xsl:variable name="mss_sigl"><xsl:value-of select="$mss"/>key</xsl:variable>
    <!-- Handschriften nach Sigle Mordek (1995)/Konkordanz -->

    <!-- #### Materialien/Ressourcen ####-->
    <xsl:variable name="resources"><xsl:value-of select="$base"/>/resources/</xsl:variable>
    <xsl:variable name="biblio"><xsl:value-of select="$resources"/>biblio/</xsl:variable>
    <!-- Verlinkung zur Bibliographie -->
    <!-- Verlinkung zu Verzeichnissen/Indices - langfristig: Personen, Orte, Glossar??? -->
    <xsl:variable name="people"><xsl:value-of select="$resources"/>indices/people</xsl:variable>
    <xsl:variable name="places"><xsl:value-of select="$resources"/>indices/places</xsl:variable>
    <xsl:variable name="glossary"><xsl:value-of select="$resources"/>indices/glossary</xsl:variable>
    <xsl:variable name="studies"><xsl:value-of select="$resources"/>studies/</xsl:variable>
    <!-- Verlinkung zu eventuellen Studien, die aus dem Projekt raus entstehen -->
    <xsl:variable name="downloads"><xsl:value-of select="$resources"/>downloads/</xsl:variable>
    <!-- Verlinkung zur Downloadseite, auf der alle Downloads gesammelt angeboten werden; ??? Wo liegen diese auf dem Server ??? -->
    <xsl:variable name="mss_downloads"><xsl:value-of select="$base"/>/cap/publ/mss/</xsl:variable>
    <!-- #### Projekt - unklar, ob diese notwendig sind #### -->
    <xsl:variable name="project"><xsl:value-of select="$base"/>/project/</xsl:variable>
    <xsl:variable name="blog"><xsl:value-of select="$base"/>/blog/</xsl:variable>
    <!-- Aus jeder Datei führen Links zu den Tranksriptionsrichtlinien - Muss noch angepasst werden, wo diese genau liegen - welches Format? -->
    <xsl:variable name="trl"/>

    <!-- Variablen zu externen Ressourcen -->
    <xsl:variable name="Bl">http://www.leges.uni-koeln.de/mss/handschrift/</xsl:variable>
    <xsl:variable name="dmgh">http://www.mgh.de/dmgh/resolving/</xsl:variable>
    <xsl:variable name="BK1">http://www.mgh.de/dmgh/resolving/MGH_Capit._1_S._</xsl:variable>
    <!-- Boretius-Krause, 1. Teil; hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
    <xsl:variable name="BK2">http://www.mgh.de/dmgh/resolving/MGH_Capit._2_S._</xsl:variable>
    <!-- Boretius-Krause, 2. Teil; hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
    <xsl:variable name="Ansegis"
        >http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._</xsl:variable>
    <!-- hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
    <xsl:variable name="Benedictus">http://www.benedictus.mgh.de/</xsl:variable>
    <!-- nur Home hinterlegt; hier sind mehrere Informationen nötig; Handschriften vs. Studien vs. Edition -->
    <xsl:variable name="Pertz1">http://www.mgh.de/dmgh/resolving/MGH_LL_1_S._</xsl:variable>
    <!-- Alte Capitularien-Edition von Pertz -->
    <!--<xsl:variable name="Pertz2">http://www.mgh.de/dmgh/resolving/MGH_LL_2_S._2_</xsl:variable>-->
    <!-- Alte Capitularien-Edition von Pertz, 2. Teil -->

</xsl:stylesheet>
