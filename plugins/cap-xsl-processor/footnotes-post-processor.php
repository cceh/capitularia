<?php

/**
 * Capitularia Footnotes Post-Processor
 *
 * We do some postprocessing in PHP because it is easier than in XSLT.  This
 * script is called immediately after xsltproc.
 *
 * This script:
 *
 * - Merges adjacent footnotes and moves footnotes to the end of the word.
 * - Wraps initials (dropcaps) and the following word into a span.
 * - Accepts XML or HTML input, always outputs HTML.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

const FOOTNOTES = '//span[contains (concat (" ", @class, " "), " annotation ")]';

/**
 * Is the node a note?
 *
 * @param node $node  The node to test.
 *
 * @return bool  true if the node is a note.
 */

function is_note ($node) {
    return
        $node &&
        ($node->nodeType == XML_ELEMENT_NODE) &&
        ($node->nodeName == 'span') &&
        has_class ($node, 'annotation');
}

function add_class ($node, $class) {
    $classes = explode (' ', $node->getAttribute ('class'));
    $classes[] = $class;
    $node->setAttribute ('class', implode (' ', array_unique ($classes)));
}

function has_class ($node, $class) {
    $classes = explode (' ', $node->getAttribute ('class'));
    return in_array ($class, $classes);
}

function is_text_node ($node) {
    return $node && ($node->nodeType == XML_TEXT_NODE);
}

function remove_node ($node) {
    $node->parentNode->removeChild ($node);
}

/**
 * Merge $note into $next and delete $note.
 *
 * @param \DOMNode $note  The note to merge.
 * @param \DOMNode $next  The note to merge into.
 *
 * @return nothing
 */

function merge_notes ($note, $next) {
    global $xpath1;

    $src  = $xpath1->query ('.//div[@class="annotation-text"]', $note);
    $dest = $xpath1->query ('.//div[@class="annotation-content"]',   $next);

    // never merge into editorial notes, just drop it
    if (has_class ($next, 'annotation-editorial')) {
        add_class ($next, 'previous-notes-dropped');
    } else {
        if (count ($src) && count ($dest)) {
            $dest[0]->insertBefore ($src[0], $dest[0]->lastChild);
            add_class ($next, 'previous-notes-merged');
        }
    }
    remove_node ($note);
}

/**
 * Wrap $nodes into a span.
 *
 * @param array $nodes  Nodes to wrap.
 *
 * @return nothing
 */

function wrap ($nodes) {
    global $doc;
    $span = $doc->createElement ('span');
    $nodes[0]->parentNode->insertBefore ($span, $nodes[0]);
    $span->setAttribute ('class', 'initial-word-wrapper');
    foreach ($nodes as $node) {
        $span->appendChild ($node);
    }
}

/**
 * Return the position of the first whitespace in $text_node.
 *
 * $text_node must be a text node.
 *
 * @param \DOMNode text_node
 *
 * @return mixed Position of first whitespace or false.
 */

function whitespace_pos ($text_node) {
    $text = $text_node->nodeValue;
    $text = preg_replace ('/\s/u', ' ', $text);
    return mb_strpos ($text, ' ');
}

//
// Load HTML doc from stdin.
//

$in = file_get_contents ('php://stdin');

$doc = new \DomDocument ();

// load XML or HTML

// keep server error log small (seems to be a problem at uni-koeln.de)
libxml_use_internal_errors (true);

if ($doc->loadXML  ($in, LIBXML_NONET) === false) {
    libxml_clear_errors ();
    // Hack to load HTML with utf-8 encoding
    $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $in, LIBXML_NONET);
    foreach ($doc->childNodes as $item) {
        if ($item->nodeType == XML_PI_NODE) {
            $doc->removeChild ($item); // remove xml declaration
        }
    }
    $doc->encoding = 'UTF-8'; // insert proper encoding
}

$xpath  = new \DOMXpath ($doc);
$xpath1 = new \DOMXpath ($doc);

//
// Merge an move footnotes to the end of the word.
//

$notes = $xpath->query (FOOTNOTES);
foreach ($notes as $note) {

    // Don't touch editorial notes.
    if (has_class ($note, 'annotation-editorial')) {
        continue;
    }

    $next = $note->nextSibling;
    if (!$next) {
        // note was last child
        continue;
    }

    // Merge immediately adjacent notes.
    //
    if (is_note ($next)) {
        merge_notes ($note, $next);
        continue;
    }

    if (!is_text_node ($next)) {
        // FIXME: is it necessary to look into other type nodes?
        continue;
    }

    $nnext = $next->nextSibling;
    $ws_pos = whitespace_pos ($next);

    // Merge notes separated by non-whitespace only (footnotes in the same word).
    //
    if ($ws_pos === false) {
        if (is_note ($nnext)) {
            merge_notes ($note, $nnext);
        }
        continue;
    }

    // Move footnote to the end of the word.
    //
    if ($ws_pos > 0) {
        // the note is not at the word's end
        // split the following text node at the end of the word
        // and move the note
        $dummy_second_text_node = $next->splitText ($ws_pos);
        $note->parentNode->insertBefore ($next, $note);
        add_class ($note, 'relocated');
        continue;
    }
}

//
// Remove whitespace before footnotes.  Do this after moving footnotes to the
// end of words or we will merge words.
//

$notes = $xpath->query (FOOTNOTES);
foreach ($notes as $note) {

    $prev = $note->previousSibling;
    if (!is_text_node ($prev)) {
        continue;
    }

    $text = $prev->nodeValue;
    $text = preg_replace ('/\s+$/u', '', $text);
    $prev->nodeValue = $text;

    if (empty ($text)) {
        remove_node ($prev);
    }
}

//
// Merge adjacent footnotes again.
// Footnotes may have become adjacent by removing whitespace.
//

$notes = $xpath->query (FOOTNOTES);
foreach ($notes as $note) {

    // Don't touch editorial notes.
    if (has_class ($note, 'annotation-editorial')) {
        continue;
    }

    $next = $note->nextSibling;
    if (!$next) {
        // note was last child
        continue;
    }

    // Merge immediately adjacent notes.
    //
    if (is_note ($next)) {
        merge_notes ($note, $next);
        continue;
    }
}

//
// Renumber footnote refs
//

$count = 0;
$notes = $xpath->query (FOOTNOTES);
foreach ($notes as $note) {
    $count++;

    $span = $xpath1->query ('.//a[contains (concat (" ", @class, " "), " annotation-ref ")]/span[contains (concat (" ", @class, " "), " print-only ")]', $note);
    if (count ($span)) {
        $span[0]->nodeValue = strVal ($count);
    }

    $span = $xpath1->query ('.//a[contains (concat (" ", @class, " "), " annotation-backref ")]/span[contains (concat (" ", @class, " "), " print-only ")]', $note);
    if (count ($span)) {
        $span[0]->nodeValue = strVal ($count);
    }
}

//
// Loop over footnote contents and move it into the respective <div class="footnotes-wrapper">.
//

$notes = $xpath->query ('//div[contains (concat (" ", @class, " "), " annotation-content ")]');
foreach ($notes as $note) {
    $abfs = $xpath1->query ('following::div[contains (concat (" ", @class, " "), " footnotes-wrapper ")]', $note);
    if (count ($abfs)) {
        $abfs[0]->appendChild ($note);
    }
}

//
// Loop over initials.
//

$initials = $xpath->query ('//span[contains (concat (" ", @class, " "), " initial ")]');
foreach ($initials as $initial) {

    $next = $initial->nextSibling;
    if (!is_text_node ($next)) {
        continue;
    }

    $ws_pos = whitespace_pos ($next);

    if ($ws_pos === false) {
        // following text node contains no whitespace
        // see if it is followed by a note

        $nnext = $next->nextSibling;
        if (is_note ($nnext)) {
            wrap (array ($initial, $next, $nnext));
        }
        continue;
    }

    if ($ws_pos > 0) {
        // following text node contains whitespace
        // split the following text node at the end of the word
        $dummy_second_text_node = $next->splitText ($ws_pos);
        wrap (array ($initial, $next));
        continue;
    }
}

//
// Loop over text nodes to nbsp punctuation following whitespace
//

$textnodes = $xpath->query ('//text()');
foreach ($textnodes as $textnode) {
    $text = $textnode->nodeValue;
    $text = preg_replace ('/\s+([·])/u', ' $1', $text);
    if ($text != $textnode->nodeValue) {
        $textnode->nodeValue = $text;
    }
}

//
// Make new w3c validator happy
//

/*
The w3c validator complains about this but it is not yet widely supported. It's
even buggy in Firefox.

foreach ($xpath->query ('//style') as $style) {
    $style->setAttribute ('scoped', '');
}
*/

foreach ($xpath->query ('//script') as $script) {
    $script->removeAttribute ('language');
}

//
// Output to stdout.
//

// Output as HTML because this gets embedded into a wordpress page. Also get rid
// of <DOCTYPE>, <html>, <head>, <body> by starting at topmost <div>.

$divs = $xpath->query ('/html/body/div');

if (count ($divs)) {
    $out = $doc->saveHTML ($divs[0]);

    // xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    $out = preg_replace ('/ xmlns:[a-z]+=".*?"/u', ' ', $out);
} else {
    $out = $doc->saveHTML ();
}

file_put_contents ('php://stdout', $out);
