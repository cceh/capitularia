<?php

/**
 * Capitularia Footnotes Post-Processor Includes
 *
 * This file only declares symbols (classes, functions, constants) in accordance
 * with PSR-2.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

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
    $text = preg_replace ('/[[:punct:]\s\xa0]/u', ' ', $text);
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
