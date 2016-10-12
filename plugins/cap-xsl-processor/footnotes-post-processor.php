<?php

/**
 * Capitularia Footnotes Post-Processor
 *
 * This script processes the output of xsltproc.  Here we do those things that
 * are easier in PHP than in XSLT.
 *
 * This script:
 *
 * - Merges adjacent footnotes and moves footnotes to the end of the word.
 * - Drops footnotes followed by an editorial note in the same word.
 * - Inserts footnote refs and backrefs and numbers them sequentially.
 * - Wraps initials (dropcaps) and the following word into a span.
 * - Substitutes editors' shortcuts with proper medieaval punctuation.
 * - Accepts XML or HTML input, always outputs HTML.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

const FOOTNOTE_SPAN = '//span[@data-note-id][not (ancestor::div[@class="footnotes-wrapper"])]';
const FOOTNOTE_REF  = 'a[contains (concat (" ", @class, " "), " annotation-ref ")]';

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
        ($node->nodeName == 'a') &&
        has_class ($node, 'annotation-ref');
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
 * Merge $note into $next.
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

    $note_id = str_replace ('-ref', '', $note->getAttribute ('id'));
    $next_id = str_replace ('-ref', '', $next->getAttribute ('id'));
    $src     = $xpath1->query ("//*[@id='{$note_id}-content']");
    $dest    = $xpath1->query ("//*[@id='{$next_id}-content']");

    if ($src->length == 0 || $dest->length ==  0) {
        return;
    }

    // echo ("about to merge $note_id into $next_id\n");

    // never merge into editorial notes
    if (has_class ($next, 'annotation-editorial')) {
        add_class ($next, 'previous-notes-dropped');
        remove_node ($src[0]); // the div class=annotation-content
        remove_node ($note);   // the span
        // echo ("dropped note $note_id\n");
        return;
    }

    $src_text = $xpath1->query ('.//div[contains (concat (" ", @class, " "), " annotation-text ")]', $src[0]);
    if (count ($src_text)) {
        $dest[0]->insertBefore ($src_text[0]->cloneNode (true), $dest[0]->lastChild);
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

function query_copy ($xpath_query_result)
{
    $nodes = array ();
    foreach ($xpath_query_result as $node) {
        $nodes[] = $node;
    }
    return $nodes;
}

function insert_footnote_ref ($elem, $id)
{
    // Never insert text content here or you will mess up the footnote merging stage.
    global $doc;
    $class = $elem->getAttribute ('class');
    $frag = $doc->createDocumentFragment ();
    $frag->appendXML ("<a class='annotation-ref ssdone $class' id='{$id}-ref' href='#{$id}-content' data-shortcuts='0'><span class='print-only footnote-number-ref'></span><span class='screen-only footnote-siglum'></span></a>");
    $elem->appendChild ($frag);
}

function insert_footnote_backref ($elem, $id)
{
    global $doc;
    $frag = $doc->createDocumentFragment ();
    $frag->appendXML ("<a class='annotation-backref ssdone' href='#{$id}-ref'><span class='print-only footnote-number-backref'></span><span class='screen-only footnote-siglum'></span></a>");
    $elem->insertBefore ($frag, $elem->firstChild);
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
$doc->substituteEntities = true;

$xpath  = new \DOMXpath ($doc);
$xpath1 = new \DOMXpath ($doc);

//
// Identify the transform (header, body, footer) so we are sure to generate
// different ids even if we combine many transformations into one page.
//

$xsl_id = 'undefined';
foreach (array ('header', 'body', 'footer') as $part) {
    $divs = $xpath->query ("//div[contains (concat (' ', @class, ' '), ' transkription-$part ')]");
    if (($divs !== false) && ($divs->length > 0)) {
        $xsl_id = $part;
        break;
    }
}

//
// Remove whitespace before isolated footnotes.
//
// We can either operate right away on the <span data-node-id="42"> or on the
// <a class="annotation-ref"> after we have inserted it.  Both modes have
// disadvantages.  Operating on the <span> we have to deal with the span's
// content: does it terminate with ws? and in that case remove it too.
// Operating with the <a> the <a> also has contents which gets in the way when
// we merge notes later on.  Currently we insert empty <a>'s and fill them with
// text later.
//
//
// Turn <span data-node-id="idm42"/> into footnote refs, add backrefs to the
// footnote bodies and link them via hrefs.
//

// get all spans in the text that have data-node-id and add footnote refs
foreach (query_copy ($xpath->query (FOOTNOTE_SPAN)) as $span) {
    $id = $span->getAttribute ('data-note-id');
    insert_footnote_ref ($span, $id);
}

// get all footnote bodies and add footnote backrefs
foreach (query_copy ($xpath->query ('//div[contains (concat (" ", @class, " "), " annotation-content ")]')) as $note) {
    $id = str_replace ('-content', '', $note->getAttribute ('id'));
    insert_footnote_backref ($note, $id);
}

// An isolated footnote is surrounded by ws.

$notes = $xpath->query ('//' . FOOTNOTE_REF);
foreach ($notes as $note) {
    //if (trim ($note->nodeValue)) {
    //    continue; // not empty, can't be moved
    //}

    $ws_before = false;
    $ws_after  = false;

    foreach ($xpath->query ('following::text()[string(.)][1]', $note) as $node) {
        if (ltrim ($node->nodeValue) != $node->nodeValue) {
            $ws_after = true;
        }
    }

    if ($ws_after) {
        foreach ($xpath->query ('preceding::text()[string(.)][1]', $note) as $node) {
            if (rtrim ($node->nodeValue) != $node->nodeValue) {
                $ws_before = true;
            }
        }
    }

    if ($ws_before && $ws_after) {
        // Trim all whitespace before this node.
        foreach (array_reverse (query_copy ($xpath->query ('preceding::text()[position() < 10]', $note))) as $node) {
            if (rtrim ($node->nodeValue) != $node->nodeValue) {
                $node->nodeValue = rtrim ($node->nodeValue);
            }
            if ($node->nodeValue) {
                // Node has ink.
                break;
            }
        }
    }
}

//
// Merge and move footnotes to the end of the word.
//

$notes = $xpath->query ('//' . FOOTNOTE_REF);
$fn = FOOTNOTE_REF;

foreach ($notes as $note) {
    // Don't touch editorial notes.
    if (has_class ($note, 'annotation-editorial')) {
        continue;
    }

    $nodes = array ();
    foreach ($xpath->query ("following::node()[self::text() or self::{$fn}][position() < 10]", $note) as $node) {
        $nodes[] = $node;
    }
    foreach ($nodes as $next) {
        // Merge notes in the same word
        if (is_note ($next)) {
            merge_notes ($note, $next);
            break;
        }

        // $next is a text node
        if ($next->parentNode->getAttribute ('data-shortcuts') == "0") {
            // skip non-latin texts
            continue;
        }

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
// Number footnote refs
//
// Add the foonote numbers for the print view.  We must do this after footnote
// merging.
//

$count = 0;
$id_to_number = array ();

foreach ($xpath->query ('//span[contains (concat (" ", @class, " "), " footnote-number-ref ")]') as $span) {
    $id = str_replace ('-ref', '', $span->parentNode->getAttribute ('id'));
    if (array_key_exists ($id, $id_to_number)) {
        $span->nodeValue = strVal ($id_to_number[$id]);
    } else {
        $count++;
        $id_to_number[$id] = $count;
        $span->nodeValue = strVal ($count);
    }
}

foreach ($xpath->query ('//span[contains (concat (" ", @class, " "), " footnote-siglum ")]') as $span) {
    $span->nodeValue = '*';
}

foreach ($xpath->query ('//span[contains (concat (" ", @class, " "), " footnote-number-backref ")]') as $span) {
    $id = str_replace ('-content', '', $span->parentNode->parentNode->getAttribute ('id'));
    if (array_key_exists ($id, $id_to_number)) {
        $span->nodeValue = strVal ($id_to_number[$id]);
    }
}

//
// Wrap initials (dropcaps) and the rest of words into spans.
//
// Some browsers (chrome) will break a line between an initial and the following
// word fragment.  We must wrap them into spans with word-wrap off.
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
// - implement the whitespace eater that eats all whitespace immediately before it
//

$textnodes = $xpath->query ('//text()');
foreach ($textnodes as $textnode) {
    $text = $textnode->nodeValue;
    $text = preg_replace ("/\s*[\x{e000}]/u", '', $text);
    if ($text != $textnode->nodeValue) {
        $textnode->nodeValue = $text;
    }
}

//
// Loop over text nodes to:
//
// - replace editors' keyboard shortcuts
// - change whitespace before punctuation into nbsp
//

// Test if this file was transformed with the CTE stylesheet.  In that case we
// don't want to replace shortcuts. FIXME: find a better way to configure this.
$divs = $xpath->query ('//div[@class="CTE"]');
$is_cte = ($divs !== false) && ($divs->length > 0);

if (!$is_cte) {
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
// Make the new w3c validator happy.
//

foreach ($xpath->query ('//script') as $script) {
    $script->removeAttribute ('language');
}

//
// Fix bogus xml:ids
//

$id_counter = 1000;
foreach ($xpath->query ('//@id') as $id) {
    if (preg_match ('/^[-_.:\pL\pN]+$/iu', $id->value)) {
        continue;
    }
    $id->value = "id-cap-gen-{$xsl_id}-{$id_counter}";
    $id_counter++;
}

//
// Output to stdout.
//

// Output as HTML because this gets embedded into a wordpress page. Also get rid
// of <DOCTYPE>, <html>, <head>, <body> by starting at the topmost <div>.

$divs = $xpath->query ('/html/body/div');

if (count ($divs)) {
    $out = $doc->saveHTML ($divs[0]);

    // xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    $out = preg_replace ('/ xmlns:[a-z]+=".*?"/u', ' ', $out);
} else {
    $out = $doc->saveHTML ();
}

// $out = html_entity_decode ($out, ENT_QUOTES, 'UTF-8');

file_put_contents ('php://stdout', $out);
