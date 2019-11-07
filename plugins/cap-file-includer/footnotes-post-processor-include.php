<?php

/**
 * Capitularia Footnotes Post-Processor Include File
 *
 * This script processes the output of xsltproc.  Here we do those things that
 * are easier in PHP than in XSLT:
 *
 * - Merge adjacent footnotes and move footnotes to the end of the word.
 * - Drop footnotes followed by an editorial note in the same word.
 * - Insert footnote refs and backrefs and numbers them sequentially.
 * - Wrap initials (dropcaps) and the following word into a span.
 * - Substitute editors' shortcuts with proper mediaeval punctuation.
 * - Accept XML or HTML input, always output HTML.
 *
 * This file only declares symbols (classes, functions, constants) in accordance
 * with PSR-2.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

const FOOTNOTE_SPAN = '//span[@data-note-id][not (ancestor::div[@class="footnotes-wrapper"])]';
const FOOTNOTE_REF  = 'a[contains (concat (" ", @class, " "), " annotation-ref ")]';

/**
 * Is the node a note?
 *
 * @param \DOMNode $node The node to test.
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

/**
 * Add a class to a node.
 *
 * Manages multiple classes .
 *
 * @param \DOMElement $node  The node.
 * @param string      $class The class to add.
 *
 * @return void
 */

function add_class ($node, $class)
{
    $classes = explode (' ', $node->getAttribute ('class'));
    $classes[] = $class;
    $node->setAttribute ('class', implode (' ', array_unique ($classes)));
}

/**
 * Test if node has class.
 *
 * @param \DOMElement $node  The node.
 * @param string      $class The class to test.
 *
 * @return boolean True if the node has the class.
 */

function has_class ($node, $class)
{
    $classes = explode (' ', $node->getAttribute ('class'));
    return in_array ($class, $classes);
}

/**
 * Test if node is a text node.
 *
 * @param \DOMElement $node The node.
 *
 * @return boolean True if the node is a text node.
 */

function is_text_node ($node)
{
    return $node && ($node->nodeType == XML_TEXT_NODE);
}

/**
 * Remove node from parent.
 *
 * @param \DOMElement $node The node to remove.
 *
 * @return void
 */

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
    $text = preg_replace ('/[!?,.:;"\'\s\xa0]/u', ' ', $text);
    return mb_strpos ($text, ' ');
}

/**
 * Copies the result of an XPath query into an array.
 *
 * @param \DOMNodeList $xpath_query_result The XPath result.
 *
 * @return array An array of nodes.
 */

function query_copy ($xpath_query_result)
{
    $nodes = array ();
    foreach ($xpath_query_result as $node) {
        $nodes[] = $node;
    }
    return $nodes;
}

/**
 * Insert a footnote reference into the document.
 *
 * @param \DOMElement $elem The element after which insertion should take place.
 * @param string      $id   The id of the footnote.
 *
 * @return void
 */

function insert_footnote_ref ($elem, $id)
{
    // Never insert text content here or you will mess up the footnote merging stage.
    global $doc;
    $class = $elem->getAttribute ('class');
    $frag = $doc->createDocumentFragment ();
    $frag->appendXML (
        "<a class='annotation-ref ssdone $class' id='{$id}-ref' href='#{$id}-content' data-shortcuts='0'>" .
        "<span class='print-only footnote-number-ref'></span>" .
        "<span class='screen-only footnote-siglum'></span></a>"
    );
    $elem->appendChild ($frag);
}

/**
 * Insert a footnote back reference into the document.
 *
 * @param \DOMElement $elem The element after which insertion should take place.
 * @param string      $id   The id of the footnote.
 *
 * @return void
 */

function insert_footnote_backref ($elem, $id)
{
    global $doc;
    $frag = $doc->createDocumentFragment ();
    $frag->appendXML (
        "<a class='annotation-backref ssdone' href='#{$id}-ref'>" .
        "<span class='print-only footnote-number-backref'></span>" .
        "<span class='screen-only footnote-siglum'></span></a>"
    );
    $elem->insertBefore ($frag, $elem->firstChild);
}

/**
 * Post process the footnotes, etc.
 *
 * @param \DOMDocument $doc The document to process.
 *
 * @return \DOMDocument The processed document.
 */

function post_process ($doc) {
    $xpath  = new \DOMXpath ($doc);

    global $xpath1;
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

    return $doc;
}


/**
 * Load XML or HTML.
 *
 * We have (had) a mix of transformation scripts outputting
 * either XML or HTML so we must read both formats.
 *
 * @param string $in The XML or HTML as string.
 *
 * @return \DOMDocument The new document.
 */

function load_xml_or_html ($in)
{
    // keep server error log small (big logfiles seem to be a problem at
    // uni-koeln.de)
    libxml_use_internal_errors (true);

    global $doc;
    $doc = new \DomDocument ();

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
    return $doc;
}

/**
 * Convert the document to HTML.
 *
 * We need the document as HTML because it gets embedded into a wordpress page.
 * Also we need to get rid of <DOCTYPE>, <html>, <head>, and <body>.  We do this
 * by starting output at the topmost <div>.
 *
 * @param \DOMDocument The document as DOM.
 *
 * @return The document as embeddable HTML.
 */

function save_html ($doc) {
    $xpath = new \DOMXpath ($doc);
    $divs  = $xpath->query ('/html/body/div');

    if (count ($divs)) {
        $out = $doc->saveHTML ($divs[0]);
        // get rid of namespace declarations
        // xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
        $out = preg_replace ('/ xmlns:[a-z]+=".*?"/u', ' ', $out);
    } else {
        $out = $doc->saveHTML ();
    }

    // $out = html_entity_decode ($out, ENT_QUOTES, 'UTF-8');

    return $out;
}
