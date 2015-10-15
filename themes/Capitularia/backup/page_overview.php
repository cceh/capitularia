<?php get_header (); ?>

<main id="main">

  <div class="content-col">
    <?php while (have_posts()) : the_post(); ?>

    <div class="page-header">
      <h2><?php the_title (); ?></h2>
    </div>

    <div class="entry">
      <?php the_content (); ?>
    </div>

    <?php endwhile; ?>
  </div>

  <div class="sidebar-col">
    <?php

// compat
$template_map = array (
     'page-UebersichtKapitularien.php'  => 'capit',
     'page-UebersichtHandschriften.php' => 'mss',
     'page-UebersichtMaterialien.php'   => 'resources',
     'page-UebersichtProjekt.php'       => 'project',
     'page-UebersichtIntern.php'        => 'internal',
     'page-KapitularienMitListe.php'    => 'capit',
     'page-HandschriftenMitListe.php'   => 'mss',
     'page-MaterialienMitListe.php'     => 'resources',
     'page-ProjektMitListe.php'         => 'project',
     'page-InternMitListe.php'          => 'intern',
     'page-Transkription.php'           => 'transcription'
);

$template = basename (get_page_template_slug ());

if (isset ($template_map[$template])) {
    $template = $template_map[$template];
} else {
    $template = cap_get_slug_root ();
    // echo ("template: $template");
}

if ($template == 'capit') {
    dynamic_sidebar ($template);
}

if ($template == 'mss') {
    dynamic_sidebar ($template);
?>

    <div class="filter-box">

      <h4>Filter: Hss. nach Kriterien</h4>
      <form class="filter-form" action="#">

        <label for="filter-kapitularien">Kapitularien</label>
        <select id="filter-kapitularien" name="kapitularien">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-datierung">Datierung</label>
        <select id="filter-datierung" name="datierung">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-herkunft">Herkunft</label>
        <select id="filter-herkunft" name="herkunft">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-institution">Institution</label>
        <select id="filter-institution" name="institution">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-undoder1">und/oder</label>
        <input type="text" id="filter-undoder1" name="undoder1">

        <label for="filter-undoder2">und/oder</label>
        <input type="text" id="filter-undoder2" name="undoder2">

        <input type="submit" value="Absenden"/>
        <a href="javascript:void(0)" class="reset-form">Suche zur&uuml;rcksetzen</a>
      </form>

    </div>
<!--
    <div class="filter-box">

      <h4>Filter: Hss. nach Kriterien</h4>
      <form class="filter-form" action="#">

        <label for="filter-kapitularien">Kapitularien</label>
        <select id="filter-kapitularien" name="kapitularien">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-datierung">Datierung</label>
        <select id="filter-datierung" name="datierung">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-herkunft">Herkunft</label>
        <select id="filter-herkunft" name="herkunft">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-institution">Institution</label>
        <select id="filter-institution" name="institution">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-undoder1">und/oder</label>
        <input type="text" id="filter-undoder1" name="undoder1">

        <label for="filter-undoder2">und/oder</label>
        <input type="text" id="filter-undoder2" name="undoder2">

        <input type="submit" value="Absenden"/>
        <a href="javascript:void(0)" class="reset-form">Suche zur&uuml;rcksetzen</a>
      </form>

    </div>
    -->

<?php
        }

if ($template == 'resources') {
    dynamic_sidebar ($template);
}

if ($template == 'project') {
    dynamic_sidebar ($template);
}

if ($template == 'internal') {
    dynamic_sidebar ($template);
}

if ($template == 'transcription') {
    dynamic_sidebar ('mss');
?>
    <div id="sidebar-fixed">
      <h4>Seitennavigation</h4>
      <div id="sidebar-toc">
        <ul>
          <li><a href="#header">Seitenanfang</a></li>
          <li>
            <span>Beschreibung nach Mordek</span>
            <ul>
              <li><a href="#history">Entstehung und Überlieferung</a></li>
              <li><a href="#physDesc">Äußere Beschreibung</a></li>
              <li><a href="#contents">Inhalte</a></li>
              <li><a href="#lit">Bibliographie</a></li>
            </ul>
          </li>
          <li>
            <span>Transkription</span>
            <ul>
              <li><a href="#EditorischeVorbemerkung">Editorische Vorbemerkung</a></li>
              <li>
                <span>Inhalt (Rubriken)</span>
                <ul id="menu-dyn-is">
                  <!-- filled in by javascript -->
                </ul>
              </li>
              <li>
                <span>Inhalt (BK-Nummern)</span>
                <ul id="menu-dyn-bk">
                  <!-- filled in by javascript -->
                </ul>
              </li>
            </ul>
          </li>
          <li><a href="#info">Hinweise</a></li>
        </ul>
      </div>
    </div> <!-- class sidebar-fixed -->

<?php
}

dynamic_sidebar ('Sidebar');

?>

  </div>

</main>

<?php get_footer (); ?>
