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

$FOOTNOTE  = 'span[contains (concat (" ", @class, " "), " annotation ")]';
$FOOTNOTES = '//' . $FOOTNOTE;

/**
 * Is the node a note?
 *
 * @param node $node The node to test.
 *
 * @return bool true if the node is a note.
 */

function is_note ($node)
{
    return
        $node &&
        ($node->nodeType == XML_ELEMENT_NODE) &&
        ($node->nodeName == 'span') &&
        has_class ($node, 'annotation');
}

function add_class ($node, $class)
{
    $classes = explode (' ', $node->getAttribute ('class'));
    $classes[] = $class;
    $node->setAttribute ('class', implode (' ', array_unique ($classes)));
}

function has_class ($node, $class)
{
    $classes = explode (' ', $node->getAttribute ('class'));
    return in_array ($class, $classes);
}

function is_text_node ($node)
{
    return $node && ($node->nodeType == XML_TEXT_NODE);
}

function remove_node ($node)
{
    $node->parentNode->removeChild ($node);
}

/**
 * Merge $note into $next and delete $note.
 *
 * @param \DOMNode $note The note to merge.
 * @param \DOMNode $next The note to merge into.
 *
 * @return nothing
 */

function merge_notes ($note, $next)
{
    global $xpath1;
    global $doc;

    $note_content_id = $note->getAttribute ('id') . '-content';
    $next_content_id = $next->getAttribute ('id') . '-content';

    $src      = $xpath1->query ('//*[@id="' . $note_content_id . '"]');
    $dest     = $xpath1->query ('//*[@id="' . $next_content_id . '"]');

    if ($src->length == 0 || $dest->length ==  0) {
        return;
    }

    // never merge into editorial notes, just drop the $note
    if (has_class ($next, 'annotation-editorial')) {
        add_class ($next, 'previous-notes-dropped');
        remove_node ($src[0]); // the div class=annotation-content
        remove_node ($note);   // the span
        return;
    }

    $src_text = $xpath1->query ('.//div[contains (concat (" ", @class, " "), " annotation-text ")]', $src[0]);
    if (count ($src_text)) {
        $dest[0]->insertBefore ($src_text[0], $dest[0]->lastChild);
        add_class ($next, 'previous-notes-merged');
    }
    remove_node ($src[0]); // the div class=annotation-content
    remove_node ($note);   // the span
}

/**
 * Wrap $nodes into a span.
 *
 * @param array $nodes Nodes to wrap.
 *
 * @return nothing
 */

function wrap ($nodes)
{
    global $doc;
    $span = $doc->createElement ('span');
    $nodes[0]->parentNode->insertBefore ($span, $nodes[0]);
    $span->setAttribute ('class', 'initial-word-wrapper');
    foreach ($nodes as $node) {
        $span->appendChild ($node);
    }
}

/**
 * Return the position of the character after the first word in $text_node.
 *
 * $text_node must be a text node.
 *
 * @param \DOMNode $text_node The text node.
 *
 * @return mixed Position of first whitespace or false.
 */

function word_end_pos ($text_node)
{
    $text = $text_node->nodeValue;
    $text = preg_replace ('/[[:punct:]\s]/u', ' ', $text);
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

if ($doc->loadXML  ($in, LIBXML_NONET | LIBXML_NOENT) === false) {
    libxml_clear_errors ();
    // Hack to load HTML with utf-8 encoding
    $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $in, LIBXML_NONET | LIBXML_NOENT);
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
// Identify the transform (header, body, footer) so we are sure to generate
// different ids even if we combine many transformations into one page.
//

$xsl_id = 'undefined';
foreach (array ('header', 'body', 'footer') as $part) {
    $divs = $xpath->query ("//div[@class='transkription-$part']");
    if (($divs !== false) && ($divs->length > 0)) {
        $xsl_id = $part;
        break;
    }
}

//
// Remove whitespace before isolated footnotes.  An isolated footnote is
// surrounded by whitespace.
//

$notes = $xpath->query ($FOOTNOTES);
foreach ($notes as $note) {

    // Does the first following non-empty text node start with whitespace?
    foreach ($xpath->query ('following::text()[string(.)][1]', $note) as $node) {
        if (ltrim ($node->nodeValue) != $node->nodeValue) {
            // ... Yes, it does.
            // Does the first preceding non-empty text node end with whitespace?
            foreach ($xpath->query ('preceding::text()[string(.)][1]', $note) as $node) {
                if (rtrim ($node->nodeValue) != $node->nodeValue) {
                    // ... Yes, it does. -> Isolated note.
                    $node->nodeValue = rtrim ($node->nodeValue);
                }
            }
        }
    }
}

//
// Merge and move footnotes to the end of the word.
//

$notes = $xpath->query ($FOOTNOTES);

foreach ($notes as $note) {
    // Don't touch editorial notes.
    if (has_class ($note, 'annotation-editorial')) {
        continue;
    }

    // iterate over footnotes and text nodes

    $nodes = array ();
    foreach ($xpath->query ("following::node()[self::text() or self::{$FOOTNOTE}][position() < 10]", $note) as $node) {
        $nodes[] = $node;
    }
    foreach ($nodes as $next) {

        // Merge notes in the same word
        //
        if (is_note ($next)) {
            merge_notes ($note, $next);
            break;
        }

        // $next is a text node

        $we_pos = word_end_pos ($next);
        if ($we_pos === false) {
            // $next contains no whitespace
            continue;
        }

        if ($we_pos > 0) {
            // split $next at the end of the word
            $next = $next->splitText ($we_pos);
        }

        // move the footnote to before $next
        $next->parentNode->insertBefore ($note, $next);
        add_class ($note, 'relocated');
        break;
    }
}

//
// Renumber footnote refs
// Delete footnote refs inside footnote texts
//

$count = 0;
$id_to_number = array ();

// make a copy of nodelist because we delete nodes as we go
$spans = array ();
foreach ($xpath->query ('//span[contains (concat (" ", @class, " "), " footnote-number-ref ")]') as $span) {
    $spans[] = $span;
}

foreach ($spans as $span) {
    $id = str_replace ('-ref', '-backref', $span->parentNode->getAttribute ('id'));
    if ($xpath1->query ('ancestor::div[contains (concat (" ", @class, " "), " annotation-text ")]', $span)->length) {
        remove_node ($span->parentNode);
    } else {
        $count++;
        $id_to_number[$id] = $count;
        $span->nodeValue = strVal ($count);
    }
}

foreach ($xpath->query ('//span[contains (concat (" ", @class, " "), " footnote-number-backref ")]') as $span) {
    $backref_id = $span->parentNode->getAttribute ('id');
    $span->nodeValue = strVal ($id_to_number[$backref_id]);
}

foreach ($xpath->query ('//span[contains (concat (" ", @class, " "), " footnote-siglum ")]') as $span) {
    $span->nodeValue = '*';
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

    $we_pos = word_end_pos ($next);

    if ($we_pos === false) {
        // following text node contains no whitespace
        // see if it is followed by a note

        $nnext = $next->nextSibling;
        if (is_note ($nnext)) {
            wrap (array ($initial, $next, $nnext));
        } else {
            wrap (array ($initial, $next));
        }
        continue;
    }

    if ($we_pos > 0) {
        // following text node contains whitespace
        // split the following text node at the end of the word
        $dummy_second_text_node = $next->splitText ($we_pos);
        wrap (array ($initial, $next));
        continue;
    }
}

//
// Loop over text nodes to:
//
// replace keyboard shortcuts
// change whitespace before punctuation into nbsp

//

// Test if this file was transformed with the CTE stylesheet.  In that case we
// don't want to replace shortcuts.
$divs = $xpath->query ('//div[@class="CTE"]');
$is_CTE = ($divs !== false) && ($divs->length > 0);

if (!$is_CTE) {
    $search  = array ('.:', ';.',  '.', '!',  '*');
    $replace = array ('∴',  '·,·', '·', ".'", '˙');

    $textnodes = $xpath->query ('//text()[ancestor::*[@data-shortcuts][1]/@data-shortcuts = "1"]');
    foreach ($textnodes as $textnode) {
        $text = $textnode->nodeValue;
        $text = preg_replace ('/\s+([[:punct:]])/u', ' $1', $text);
        $text = str_replace ($search, $replace, $text);
        if ($text != $textnode->nodeValue) {
            $textnode->nodeValue = $text;
        }
    }
}

//
// Make new w3c validator happy
//

foreach ($xpath->query ('//script') as $script) {
    $script->removeAttribute ('language');
}

//
// Fix bogus xml:ids
//

$id_counter = 1000;
foreach ($xpath->query ('//@id') as $id) {
    if (preg_match ('/^[-_.:\pL\pN]*$/iu', $id->value)) {
        continue;
    }
    $id->value = "id-cap-gen-{$xsl_id}-{$id_counter}";
    $id_counter++;
}

//
// Output to stdout.
//

// Output as HTML because this gets embedded into a wordpress page. Also get rid
// of <DOCTYPE>, <html>, <head>, <body> by starting at topmost <div>.

$divs = $xpath->query ('/html/body/div');
$doc->substituteEntities = true;

if (count ($divs)) {
    $out = $doc->saveHTML ($divs[0]);

    // xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    $out = preg_replace ('/ xmlns:[a-z]+=".*?"/u', ' ', $out);
} else {
    $out = $doc->saveHTML ();
}

$out = html_entity_decode ($out, ENT_QUOTES, "UTF-8");

file_put_contents ('php://stdout', $out);
