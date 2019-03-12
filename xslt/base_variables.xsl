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
  <xsl:variable name="base">//capitularia.uni-koeln.de</xsl:variable>

  <!-- Verlinkungen zu den englischen Seiten -->
  <xsl:variable name="base_en">//capitularia.uni-koeln.de/en/</xsl:variable>

  <!-- #### Kapitularien #### -->
  <xsl:variable name="capit">/capit/</xsl:variable>
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
  <xsl:variable name="mss">/mss/</xsl:variable>
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
  <xsl:variable name="resources">/resources/</xsl:variable>
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
  <xsl:variable name="mss_downloads">/cap/publ/mss/</xsl:variable>
  <xsl:variable name="capit_downloads">/cap/publ/capit/</xsl:variable>
  <!-- #### Projekt - unklar, ob diese notwendig sind #### -->
  <xsl:variable name="project">/project/</xsl:variable>
  <xsl:variable name="blog">/blog/</xsl:variable>
  <!-- Aus jeder Datei führen Links zu den Tranksriptionsrichtlinien - Muss noch angepasst werden, wo diese genau liegen - welches Format? -->
  <xsl:variable name="trl"/>

  <xsl:variable name="tei-ref-external-targets">
    <item key="Baluze">
      <prefix></prefix>
      <caption>[:de]Zur Edition von Baluze[:en]To Baluze's edition[:]</caption>
      <alt>Zu Baluze</alt>
    </item>
    <item key="Baluze1">
      <prefix>http://reader.digitale-sammlungen.de/de/fs1/object/display/bsb10489967_</prefix>
      <postfix>.html</postfix>
      <caption>[:de]Zur Edition von Baluze[:en]To Baluze's edition[:]</caption>
      <alt>Zu Baluze</alt>
    </item>
    <item key="Baluze2">
      <prefix>http://reader.digitale-sammlungen.de/de/fs1/object/display/bsb10489967_</prefix>
      <postfix>.html</postfix>
      <caption>[:de]Zur Edition von Baluze[:en]To Baluze's edition[:]</caption>
      <alt>Zu Baluze</alt>
    </item>
    <item key="BK1">
      <!-- Boretius-Krause, 1. Teil;
           hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_Capit._1_S._</prefix>
      <caption>[:de]Zur Edition von Boretius/Krause I (dMGH)[:en]To the edition by Boretius/Krause I (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="BK2">
      <!-- Boretius-Krause, 2. Teil;
           hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_Capit._2_S._</prefix>
      <caption>[:de]Zur Edition von Boretius/Krause II (dMGH)[:en]To the edition by Boretius/Krause II (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="dmgh">
      <prefix>http://www.mgh.de/dmgh/resolving/</prefix>
      <caption>[:de]Zu den dMGH[:en]To dMGH website[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Pertz1">
      <!-- Alte Capitularien-Edition von Pertz, 1. Teil -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_LL_1_S._</prefix>
      <caption>[:de]Zur Edition von Pertz (dMGH)[:en]To the edition by Pertz (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Pertz2">
      <!-- Alte Capitularien-Edition von Pertz, 2. Teil -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_LL_2_S._2_</prefix>
      <caption>[:de]Zur Edition von Pertz (dMGH)[:en]To the edition by Pertz (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Pertz3">
      <!-- Alte Capitularien-Edition von Pertz, 3. Teil -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_LL_2_S._</prefix>
      <caption>[:de]Zur Edition von Pertz (dMGH)[:en]To the edition by Pertz (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Ansegis">
      <!-- hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_Capit._N._S._1_S._</prefix>
      <caption>[:de]Zur Ansegis-Edition (dMGH)[:en]To the edition of Ansegis (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Werminghoff1">
      <!-- FIXME hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_Conc._2,1_S._</prefix>
      <caption>[:de]Zur Edition von Werminghoff (dMGH)[:en]To the edition of Werminghoff (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Werminghoff2">
      <!-- FIXME hier muss in der XML nur noch die entsprechende Seitenzahl als Ziel angegeben werden -->
      <prefix>http://www.mgh.de/dmgh/resolving/MGH_Conc._2,2_S._</prefix>
      <caption>[:de]Zur Edition von Werminghoff (dMGH)[:en]To the edition of Werminghoff (dMGH)[:]</caption>
      <alt>dMGH</alt>
    </item>
    <item key="Benedictus">
      <!-- nur Home hinterlegt; hier sind mehrere Informationen nötig; Handschriften vs. Studien vs. Edition -->
      <prefix>http://www.benedictus.mgh.de/</prefix>
      <caption>[:de]Zur Edition der falschen Kapitularien des Benedictus Levita[:en]To the edition of Benedictus Levita[:]</caption>
      <alt>Benedictus Levita</alt>
    </item>
    <item key="BSB">
      <prefix></prefix>
      <caption>[:de]Zu den Digitalen Sammlungen[:en]To the Digitale Sammlungen[:] - BSB</caption>
      <alt>BSB</alt>
    </item>
    <item key="Bl">
      <prefix>http://www.leges.uni-koeln.de/mss/handschrift/</prefix>
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
    <item key="KatBNF">
      <prefix></prefix>
      <caption>[:de]Zum Katalog der BN[:en]To the BN catalogue[:]</caption>
      <alt>Zu KatBNF</alt>
    </item>
    <item key="Gallica">
      <prefix></prefix>
      <caption>[:de]Gallica[:en]Gallica[:]</caption>
      <alt>Zu Gallica</alt>
    </item>
    <item key="">
      <prefix></prefix>
      <caption>[:de]Zur externen Ressource[:en]To the external resource[:]</caption>
      <alt>Zur externen Ressource</alt>
    </item>
  </xsl:variable>

  <xsl:variable name="tei-graphic-targets">
    <item key="archiviodiocesano.mo.it">
      <title>Archivio Capitolare di Modena</title>
      <caption>Archivio Capitolare di Modena</caption>
    </item>
    <item key=".beic.it">
      <title>Biblioteca Europea di Informazione e Cultura</title>
      <caption>BEIC</caption>
    </item>
    <item key="bhnumerique.ville-selestat.fr">
      <title>Bibliothèque Humaniste numérique</title>
      <caption>Bibliothèque Humaniste numérique</caption>
    </item>
    <item key="bibliotecadigital.rah.es">
      <title>Biblioteca Real Academia de la Historia Madrid</title>
      <caption>Biblioteca RAH Madrid</caption>
    </item>
    <item key="blb-karlsruhe.de">
      <title>Badische Landesbibliothek</title>
      <caption>Badische Landesbibliothek</caption>
    </item>
    <item key="brbl-dl.library.yale.edu">
      <title>Beinecke Digital Collections</title>
      <caption>Beinecke Digital Collections</caption>
    </item>
    <item key=".bnf.fr">
      <title>Gallica</title>
      <caption>Gallica</caption>
    </item>
    <item key="www.bl.uk">
      <title>British Library</title>
      <caption>British Library</caption>
    </item>
    <item key="bodley.ox.ac.uk">
      <title>Bodleian Library Oxford</title>
      <caption>Bodleian</caption>
    </item>
    <item key="daten.digitale-sammlungen.de">
      <title>Bayerische Staatsbibliothek München</title>
      <caption>BSB München</caption>
    </item>
    <item key="bsb.lrz.de">
      <title>Staatsbibliothek Bamberg</title>
      <caption>Staatsbibliothek Bamberg</caption>
    </item>
    <item key="bvmm.irht.cnrs.fr">
      <title>Bibliothèque virtuelle</title>
      <caption>Bibliothèque virtuelle</caption>
    </item>
    <item key="e-codices.unifr.ch">
      <title>e-codices</title>
      <caption>e-codices</caption>
    </item>
    <item key="europeanaregia.eu">
      <title>Europeana Regia</title>
      <caption>Europeana Regia</caption>
    </item>
    <item key="freelibrary.org">
      <title>Free Library Philadelphia</title>
      <caption>Free Library Philadelphia</caption>
    </item>
    <item key=".hab.de">
      <title>Herzog August Bibliothek</title>
      <caption>HAB</caption>
    </item>
    <item key="internetculturale.it">
      <title>Internet Culturale</title>
      <caption>Internet Culturale</caption>
    </item>
    <item key="landesarchiv-nrw.de">
      <title>Landesarchiv NRW</title>
      <caption>Landesarchiv NRW</caption>
    </item>
    <item key="manus.iccu.sbn.it">
      <title>Manus online</title>
      <caption>Manus</caption>
    </item>
    <item key="manuscripta-mediaevalia.de">
      <title>Manuscripta Mediaevalia</title>
      <caption>MM</caption>
    </item>
    <item key=".mgh.de">
      <title>Monumenta Germaniae Historica</title>
      <caption>MGH</caption>
    </item>
    <item key="onb.ac.at">
      <title>Österreichische Nationalbibliothek</title>
      <caption>ÖNB</caption>
    </item>
    <item key="pares.mcu.es">
      <title>PARES - Portal de Archivos Españoles</title>
      <caption>PARES</caption>
    </item>
    <item key="parker.stanford.edu">
      <title>Parker Library</title>
      <caption>Parker Library</caption>
    </item>
    <item key="socrates.leidenuniv.nl">
      <title>Digital Sources - Universität Leiden</title>
      <caption>Digital Sources Leiden</caption>
    </item>
    <item key="staatsbibliothek-berlin.de">
      <title>Staatsbibliothek Berlin</title>
      <caption>Staatsbibliothek Berlin</caption>
    </item>
    <item key="stgallplan.org">
      <title>Carolingian Culture at Reichenau &amp; St. Gall</title>
      <caption>Reichenau &amp; St. Gall</caption>
    </item>
    <item key="sub.uni-hamburg.de">
      <title>Staats- und Universitätsbibliothek Hamburg</title>
      <caption>SUB Hamburg</caption>
    </item>
    <item key="trierer-handschriften.de">
      <title>Die ältesten deutschsprachigen Texte der Trierer Stadtbibliothek</title>
      <caption>Die ältesten deutschsprachigen Texte der Trierer Stadtbibliothek</caption>
    </item>
    <item key="ulb.tu-darmstadt.de">
      <title>Universitäts- und Landesbibliothek Darmstadt</title>
      <caption>ULB Darmstadt</caption>
    </item>
    <item key="ub.uni-heidelberg.de">
      <title>UB Heidelberg</title>
      <caption>UB Heidelberg</caption>
    </item>
    <item key="digi.vatlib.it">
      <title>DigiVatLib</title>
      <caption>BAV</caption>
    </item>
    <item key="wlb-stuttgart.de">
      <title>WLB Stuttgart</title>
      <caption>WLB Stuttgart</caption>
    </item>
    <item key="www.kb.dk">
      <title>Det Kongelige Bibliotek, København</title>
      <caption>Det Kongelige Bibliotek, København</caption>
    </item>
  </xsl:variable>

  <xsl:variable name="hand-names">
    <item key="X">
      <name>Korrekturhand 1</name>
    </item>
    <item key="Y">
      <name>Korrekturhand 2</name>
    </item>
    <item key="Z">
      <name>Korrekturhand 3</name>
    </item>
  </xsl:variable>

</xsl:stylesheet>
