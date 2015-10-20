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
    <ul>

<?php

// Code to choose the sidebar to display depending on page template (old method)
// or slug and taxonomy (new method).

// The sidebars to choose from. Only one of these gets displayed.
$cap_sidebars = array ('capit', 'mss', 'resources', 'project', 'internal', 'transcription');

// compatibility to old system of sidebar-selection through page template
$cap_template_map = array (
    'page-UebersichtKapitularien.php'  => 'capit',
    'page-UebersichtHandschriften.php' => 'mss',
    'page-UebersichtMaterialien.php'   => 'resources',
    'page-UebersichtProjekt.php'       => 'project',
    'page-UebersichtIntern.php'        => 'internal',
    'page-KapitularienMitListe.php'    => 'capit',
    'page-HandschriftenMitListe.php'   => 'mss',
    'page-MaterialienMitListe.php'     => 'resources',
    'page-ProjektMitListe.php'         => 'project',
    'page-InternMitListe.php'          => 'internal',
    'page-Transkription.php'           => 'transcription',
);

$cap_templates = array ();
$cap_template = basename (get_page_template_slug ());

if (isset ($cap_template_map[$cap_template])) {
    // old method: use page template
    $cap_templates[] = $cap_template_map[$cap_template];
} else {
    // new method: use page slug
    $cap_templates[] = cap_get_slug_root ();
}

// FIXME: stopgap measure
$cap_tags = get_the_tags ($post->ID);
if (is_array ($cap_tags)) {
    foreach ($cap_tags as $cap_tag) {
        if ($cap_tag->name == 'XML') {
            $cap_templates = array ('transcription');
        }
    }
}

// You can override the selection by assigning a term in the cap-sidebar
// taxonomy.

$terms = get_the_terms ($post->ID, 'cap-sidebar');
if ($terms && !is_wp_error ($terms)) {
    foreach ($terms as $term) {
        if (in_array ($term->name, $cap_sidebars)) {
            $cap_templates[] = $term->name;
        }
    }
}

// Display the chosen sidebars.
foreach ($cap_templates as $template) {
    dynamic_sidebar ($template);
}

// This sidebar gets displayed on all pages.
dynamic_sidebar ('Sidebar');

?>

    </ul>
  </div>

</main>

<?php get_footer (); ?>
