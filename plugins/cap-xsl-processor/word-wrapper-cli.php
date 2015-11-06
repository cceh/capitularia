<?php

$doc = new \DomDocument ();
// $doc->preserveWhiteSpace = false;
// $doc->substituteEntities = true;

$doc->load ('php://stdin', LIBXML_NONET);

$xpath = new \DOMXpath ($doc);
$xpath->registerNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
$xpath->registerNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');

$notes = $xpath->query ('//tei:subst');
// $notes = $xpath->query ('//tei:choice|//tei:add|//tei:del|//tei:subst|//tei:mod');

if (!is_null ($notes)) {
    foreach ($notes as $note) {
        echo ("*** Found $note->tagName\n");

        $next   = $note->nextSibling;
        $prev   = $note->previousSibling;
        $parent = $note->parentNode;
        $prefix = null;
        $suffix = null;

        if ($next && $next->nodeType == XML_TEXT_NODE) {
            $ws_pos = mb_strpos ($next->nodeValue, ' ');
            if ($ws_pos !== false && $ws_pos > 0) {
                // the element is not at the word's end
                echo ("*** Found next '$next->nodeValue'\n");
                $suffix = $next->splitText ($ws_pos);
                echo ("*** Found next '$next->nodeValue'\n");
                echo ("*** Found suffix '$suffix->nodeValue'\n");
            }
        }
        if ($prev && $prev->nodeType == XML_TEXT_NODE) {
            $ws_pos = mb_strrpos ($prev->nodeValue, ' ');
            if ($ws_pos !== false && $ws_pos < mb_strlen ($prev->nodeValue) - 1) {
                // the element is not at the word's start
                echo ("*** Found prev '$prev->nodeValue'\n");
                $prefix = $prev->splitText ($ws_pos + 1);
                echo ("*** Found prefix '$prefix->nodeValue'\n");
            }
        }
        $w = $doc->createElement ('w');
        $w->setAttribute ('class', 'generated');
        if ($prefix) {
            $w = $parent->insertBefore ($w, $prefix);
            $w->appendChild ($prefix);
        } else {
            $w = $parent->insertBefore ($w, $note);
        }
        $w->appendChild ($note);
        if ($suffix) {
            $w->appendChild ($next); // not $suffix !
        }
    }
}

$doc->save ('php://stdout');
