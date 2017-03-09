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
 * - Substitutes editors' shortcuts with proper mediaeval punctuation.
 * - Accepts XML or HTML input, always outputs HTML.
 *
 * This file executes only logic with side-effects in accordance with PSR-2.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

require 'footnotes-post-processor-include.php';

//
// Load document from stdin.
//

$doc    = load_xml_or_html (file_get_contents ('php://stdin'));
$xpath  = new \DOMXpath ($doc);
$xpath1 = new \DOMXpath ($doc);

//
// Identify which transformation we are post-processing (header, body, or
// footer) so that we can generate different ids.  We often combine the output
// of many transformations into one HTML page and we don't want clashing ids.
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

    // do we have a whitespace after the note?
    foreach ($xpath->query ('following::text()[string(.)][1]', $note) as $node) {
        if (ltrim ($node->nodeValue) != $node->nodeValue) {
            $ws_after = true;
        }
    }

    // do we have a whitespace before the note?
    if ($ws_after) {
        foreach ($xpath->query ('preceding::text()[string(.)][1]', $note) as $node) {
            if (rtrim ($node->nodeValue) != $node->nodeValue) {
                $ws_before = true;
            }
        }
    }

    if ($ws_before && $ws_after) {
        // This is an isolated note. So we should trim all whitespace before
        // this node and join it with the previous word..
        foreach (array_reverse (query_copy ($xpath->query ('preceding::text()[position() < 10]', $note))) as $node) {
            if (rtrim ($node->nodeValue) != $node->nodeValue) {
                $node->nodeValue = rtrim ($node->nodeValue);
            }
            if ($node->nodeValue) {
                // Break on the first node with ink.
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

    // Starting from this footnote look ahead for the first whitespace or
    // footnote, whichever comes first.  If it is a whitespace, move the
    // footnote before the whitespace.  If it is a footnote, merge the two
    // footnotes.
    $nodes = array ();
    foreach ($xpath->query ("following::node()[self::text() or self::{$fn}][position() < 10]", $note) as $node) {
        $nodes[] = $node;
    }
    foreach ($nodes as $next) {
        // Footnote found before finding whitespace.  Merge the two notes.
        if (is_note ($next)) {
            merge_notes ($note, $next);
            break;
        }

        // If we get here $next is a text node.
        if ($next->parentNode->getAttribute ('data-shortcuts') == '0') {
            // skip non-latin texts
            continue;
        }

        $we_pos = word_end_pos ($next);
        if ($we_pos === false) {
            // $next isd no footnote and contains no whitespace.  We must look at
            // the next node.
            continue;
        }

        if ($we_pos > 0) {
            // $next contains whitespace. Split $next into two textnodes before
            // the whitespace.
            $next = $next->splitText ($we_pos);
        }

        // move the footnote to before $next. $next starts with a whitespace.
        $next->parentNode->insertBefore ($note, $next);
        add_class ($note, 'relocated');
        break;
    }
}

//
// Number footnote refs
//
// Add the foonote numbers.  We need the numbers only for the print view.  We
// must do this after footnote merging or we'll get holes in the sequence.
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
// - replace editors' keyboard shortcuts
// - change whitespace before punctuation into nbsp
//

// Test if this file was transformed with the CTE stylesheet.  In that case we
// don't want to replace shortcuts. FIXME: find a better way to configure this.
$divs = $xpath->query ('//div[contains (concat (" ", @class, " "), " CTE ")]');
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
// Replace invalid xml:ids with valid generated ones.
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
