<?php

/**
 * Template for 404 Page not found.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();
get_main_start ('404-php');

?>

<article id='i404' class='page'>

  <header class='article-header cap-page-header'>
    <h2>404 - Seite nicht gefunden.</h2>
  </header>

  <div class="entry">
    <p>Wir können leider nicht finden, wonach Sie gesucht haben.</p>
    <p class="bold">Das könnte folgende Gründe haben:</p>
    <p>Sie haben die Webadresse nicht korrekt eingegeben oder die gesuchte
       Seite wurde verschoben, aktualisiert oder umbenannt.</p>
    <p class="bold">Bitte nutzen Sie eine der folgenden Optionen:</p>
    <p>Haben Sie sich vielleicht vertippt? Falls nicht, drücken Sie den
       Aktualisieren-Button Ihres Browsers oder nutzen Sie die Suche.</p>
  </div>

</article>

<?php

get_main_end ();

get_footer ();
