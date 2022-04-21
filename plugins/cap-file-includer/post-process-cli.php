<?php
/**
 * Capitularia File Includer Main Class
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

use cceh\capitularia\lib;

require_once 'footnotes-post-processor-include.php';

/**
 * A CLI for the post-processor.
 *
 * Usage: php -f post-process-cli.php < infile > outfile
 */

$doc = load_xml_or_html (stream_get_contents (STDIN));
$doc = post_process ($doc);
$output = explode ("\n", save_html ($doc));
// remove eventual xml declaration
if (strncmp ($output[0], '<?xml ', 6) == 0) {
    array_shift ($output);
}
fwrite (STDOUT, join ("\n", $output));

?>
