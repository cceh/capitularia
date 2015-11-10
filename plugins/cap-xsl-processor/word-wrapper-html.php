<?php

/**
 * This script:
 *
 * - Merges adjacent footnotes and moves footnotes to the end of the word.
 * - Wraps initials and the following word into a span.
 * - Converts XML to HTML.
 *
 * We do this in PHP because it is easier than in XSLT. This script is called
 * immediately after the xslt processor. This script accepts XML or HTML input.
 */

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

function is_note ($node) {
    return
        $node &&
        ($node->nodeType == XML_ELEMENT_NODE) &&
        ($node->nodeName == 'div') &&
        has_class ($node, 'annotation');
}

/**
 * Merge @note into @next and delete @note.
 *
 * @param note  The note to merge.
 * @param next  The note to merge into.
 *
 * @return nothing
 */

function merge_notes ($note, $next) {
    global $xpath1;

    $src  = $xpath1->query ('.//div[@class="annotation-content"]/a', $note);
    $dest = $xpath1->query ('.//div[@class="annotation-content"]',   $next);

    // never merge into editorial notes, just drop it
    if (has_class ($next, 'editorial')) {
        add_class ($next, 'previous-notes-dropped');
    } else {
        $dest[0]->insertBefore ($src[0], $dest[0]->lastChild);
        add_class ($next, 'previous-notes-merged');
    }
    $note->parentNode->removeChild ($note);
}

/**
 * Wrap @nodes into a span.
 *
 * @param nodes
 *
 * @return
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
 * Return the position of the first whitespace in the node.
 *
 * Node must be a text node.
 *
 * @param text_node
 *
 * @return Position of first whitespace or false.
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

if ($doc->loadXML  ($in, LIBXML_NONET) === false) {
    // Hack to load HTML with utf-8 encoding
    $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $in, LIBXML_NONET);
    foreach ($doc->childNodes as $item)
        if ($item->nodeType == XML_PI_NODE)
            $doc->removeChild ($item); // remove xml declaration
    $doc->encoding = 'UTF-8'; // insert proper encoding
}

$xpath  = new \DOMXpath ($doc);
$xpath1 = new \DOMXpath ($doc);

//
// Loop over footnotes.
//

$notes = $xpath->query ('//div[contains (concat (" ", @class, " "), " annotation ")]');
foreach ($notes as $note) {

    // Don't touch editorial notes.
    if (has_class ($note, 'editorial')) {
        continue;
    }

    $next = $note->nextSibling;
    if (!$next) {
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

    $ws_pos = whitespace_pos ($next);

    // Merge footnotes in the same word.
    //
    if ($ws_pos === false) {
        // following text node contains no whitespace

        $nnext = $next->nextSibling;
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
// Loop over footnotes again to remove leading whitespace.
//

$notes = $xpath->query ('//div[contains (concat (" ", @class, " "), " annotation ")]');
foreach ($notes as $note) {

    $prev = $note->previousSibling;
    if (!is_text_node ($prev)) {
        continue;
    }

    $text = $prev->nodeValue;
    $text = preg_replace ('/\s+$/u', '', $text);
    $prev->nodeValue = $text;
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
// Loop over text nodes to replace punctuation following whitespace
//

$textnodes = $xpath->query ('//text()');
foreach ($textnodes as $textnode) {
    $text = $textnode->nodeValue;
    $text = preg_replace ('/\s+([·])/u', ' $1', $text);
    if ($text != $textnode->nodeValue)
        $textnode->nodeValue = $text;
}

//
// Make new w3c validator happy
//

foreach ($xpath->query ('//style') as $style) {
    $style->setAttribute ('scoped', '');
}
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
    $out = preg_replace ('/xmlns:(tei|html|cs|my)=".*?"/u', '', $out);
} else {
    $out = $doc->saveHTML ();
}

file_put_contents ('php://stdout', $out);
