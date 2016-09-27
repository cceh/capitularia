<?xml version="1.0" encoding="UTF-8"?>

<!--
  Diese Datei enthält die grundlegenden Variablen zur internen (und externen) Verlinkung.
  Andere Skripte sollen auf diese zugreifen können.
  DS, NG 08/2015
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

  <!-- #### grundlegende interne Verlinkungen #### -->

  <xsl:variable name="base">http://capitularia.uni-koeln.de</xsl:variable>

  <!-- Verlinkungen zu den englischen Seiten -->
  <xsl:variable name="base_en">http://capitularia.uni-koeln.de/en/</xsl:variable>

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

  <!-- Boretius-Krause, 1. Teil;
       hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
  <xsl:variable name="BK1">http://www.mgh.de/dmgh/resolving/MGH_Capit._1_S._</xsl:variable>

  <!-- Boretius-Krause, 2. Teil;
       hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
  <xsl:variable name="BK2">http://www.mgh.de/dmgh/resolving/MGH_Capit._2_S._</xsl:variable>

  <!-- hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
  <xsl:variable name="Ansegis"
                >http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._</xsl:variable>

  <!-- nur Home hinterlegt; hier sind mehrere Informationen nötig; Handschriften vs. Studien vs. Edition -->
  <xsl:variable name="Benedictus">http://www.benedictus.mgh.de/</xsl:variable>

  <!-- Alte Capitularien-Edition von Pertz -->
  <xsl:variable name="Pertz1">http://www.mgh.de/dmgh/resolving/MGH_LL_1_S._</xsl:variable>

  <!--<xsl:variable name="Pertz2">http://www.mgh.de/dmgh/resolving/MGH_LL_2_S._2_</xsl:variable>-->
  <!-- Alte Capitularien-Edition von Pertz, 2. Teil -->

  <xsl:variable name="tei-ref-external-targets">
    <item key="BK1">
      <prefix><xsl:value-of select="$BK1"/></prefix>
      <caption>[:de]Zur Edition von Boretius/Krause I (dMGH)[:en]To the edition by Boretius/Krause I (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="BK2">
      <prefix><xsl:value-of select="$BK2"/></prefix>
      <caption>[:de]Zur Edition von Boretius/Krause II (dMGH)[:en]To the edition by Boretius/Krause II (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="dmgh">
      <prefix><xsl:value-of select="$dmgh"/></prefix>
      <caption>[:de]Zu den dMGH[:en]To dMGH website[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Pertz1">
      <prefix><xsl:value-of select="$Pertz1"/></prefix>
      <caption>[:de]Zur Edition von Pertz (dMGH)[:en]To the edition by Pertz (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Ansegis">
      <prefix><xsl:value-of select="$Ansegis"/></prefix>
      <caption>[:de]Zur Ansegis-Edition (dMGH)[:en]To the edition of Ansegis (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="BSB">
      <prefix></prefix>
      <caption>[:de]Zu den Digitalen Sammlungen[:en]To the Digitale Sammlungen[:] - BSB</caption>
      <alt>BSB</alt>
    </item>
    <item key="Bl">
      <prefix><xsl:value-of select="$Bl"/></prefix>
      <caption>[:de]Zur Beschreibung auf der Bibliotheca legum-Webseite[:en]To the manuscript description on the Bibliotheca legum website[:]</caption>
      <alt>Zur Bibliotheca legum</alt>
    </item>
    <item key="MM">
      <prefix></prefix>
      <caption>[:de]Zu Manuscripta Mediaevalia[:en]To Manuscripta Mediaevalia[:]</caption>
      <alt>Zu MM</alt>
    </item>
    <item key="IA">
      <prefix></prefix>
      <caption>[:de]Zum Internet Archive[:en]To Internet Archive[:]</caption>
      <alt>Zum Internet Archive</alt>
    </item>
    <item key="DZ">
      <prefix></prefix>
      <caption>[:de]Zur Digizeitschriften-Webseite[:en]To the Digizeitschriften website[:]</caption>
      <alt>Zu DZ</alt>
    </item>
    <item key="Baluze">
      <prefix></prefix>
      <caption>[:de]Zur Edition von Baluze[:en]To Baluze's edition[:]</caption>
      <alt>Zu Baluze</alt>
    </item>
    <item key="KatBNF">
      <prefix></prefix>
      <caption>[:de]Zum Katalog der BNF[:en]To the BNF catalogue[:]</caption>
      <alt>Zu KatBNF</alt>
    </item>
    <item key="">
      <prefix></prefix>
      <caption>[:de]Zur externen Ressource[:en]To the external resource[:]</caption>
      <alt>Zur externen Ressource</alt>
    </item>
  </xsl:variable>

  <xsl:variable name="tei-graphic-targets">
    <item key=".hab.de">
      <title>Herzog August Bibliothek</title>
      <caption>Digitale Bibliothek HAB</caption>
    </item>
    <item key="e-codices">
      <title>e-codices</title>
      <caption>e-codices</caption>
    </item>
    <item key="europeana">
      <title>europeana Regia</title>
      <caption>europeana Regia</caption>
    </item>
    <item key="mgh">
      <title>MGH</title>
      <caption>Monumenta Germaniae Historica</caption>
    </item>
    <item key="bsb">
      <title>Bayerische Staatsbibliothek München</title>
      <caption>BSB München</caption>
    </item>
    <item key="bnf">
      <title>Bibliothèque nationale de France</title>
      <caption>BnF</caption>
    </item>
    <item key="freelibrary">
      <title>Free Library Philadelphia</title>
      <caption>Free Library</caption>
    </item>
    <item key="bhnumerique">
      <title>Bibliothèque Humaniste numérique</title>
      <caption>Bibliothèque Humaniste numérique</caption>
    </item>
    <item key="bibliotecadigital">
      <title>Biblioteca Real Academia de la Historia Madrid</title>
      <caption>Biblioteca Real Academia de la Historia Madrid</caption>
    </item>
    <item key="socrates">
      <title>Digital Sources - Universität Leiden</title>
      <caption>Digital Sources - Universiteit Leiden</caption>
    </item>
    <item key="trier">
      <title>Die ältesten deutschsprachigen Texte der Stadtbibliothek Trier – ein Informationsportal im Internet“</title>
      <caption>Portal zu den ältesten deutschsprachigen Texten der SB Trier</caption>
    </item>
    <item key="heidelberg">
      <title>UB Heidelberg</title>
      <caption>UB Heidelberg</caption>
    </item>
    <item key="stgallplan">
      <title>Reichenau &amp; St. Gall</title>
      <caption>Carolingian Culture at Reichenau &amp; St. Gall</caption>
    </item>
    <item key="bodley">
      <title>Bodleian Library Oxford</title>
      <caption>Bodleian Library Oxford</caption>
    </item>
    <item key="bvmm">
      <title>Bibliothèque virtuelle</title>
      <caption>Bibliothèque virtuelle</caption>
    </item>
    <item key="parkerweb">
      <title>Parker Library</title>
      <caption>Parker Library</caption>
    </item>
    <item key="manuscripta-">
      <title>Manuscripta Mediaevalia</title>
      <caption>MM</caption>
    </item>
    <item key="manus">
      <title>Manus online</title>
      <caption>Manus online</caption>
    </item>
    <item key="wlb">
      <title>WLB Stuttgart</title>
      <caption>WLB Stuttgart</caption>
    </item>
    <item key="onb">
      <title>ÖNB</title>
      <caption>ÖNB</caption>
    </item>
    <item key="blb">
      <title>Badische Landesbibliothek</title>
      <caption>Badische Landesbibliothek</caption>
    </item>
    <item key="uni-muenchen">
      <title>Universitätsbibliothek München</title>
      <caption>Universitätsbibliothek München</caption>
    </item>
    <item key="berlin">
      <title>Staatsbibliothek Berlin</title>
      <caption>Staatsbibliothek Berlin</caption>
    </item>
    <item key="landesarchiv-nrw">
      <title>Landesarchiv NRW, Abt. Westfalen</title>
      <caption>Landesarchiv NRW, Abt. Westfalen</caption>
    </item>
    <item key="pares">
      <title>PARES - Portal de Archivos Españoles</title>
      <caption>PARES</caption>
    </item>
    <item key="archiviodiocesano">
      <title>Archivio Capitolare di Modena</title>
      <caption>Archivio Capitolare di Modena</caption>
    </item>
    <item key="vatlib">
      <title>Vatikan</title>
      <caption>BAV</caption>
    </item>
  </xsl:variable>

</xsl:stylesheet>
