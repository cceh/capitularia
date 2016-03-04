<?php
/**
 * Capitularia Collation Witness
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

const COLLATION_XSL = AFS_ROOT . '/http/docs/cap/publ/transform/transkription_LesEdi_CapKoll.xsl';

const NS_TEI = 'http://www.tei-c.org/ns/1.0';
const NS_XML = 'http://www.w3.org/XML/1998/namespace';

/**
 * A collation witness
 */

class Witness
{
    private $corresp;
    private $xml_filename;
    public $xml_id;
    public $sort_key;

    /**
     * Constructor
     *
     * @param string $corresp      The capitulary section, eg. "BK.184_a"
     * @param string $xml_id       The xml:id of the TEI file, eg. "bamberg-sb-can-12"
     * @param string $xml_filename The full path to the TEI file.
     *
     * @return Collation_item
     */

    public function __construct ($corresp, $xml_id, $xml_filename)
    {
        $this->corresp      = $corresp;
        $this->xml_id       = $xml_id;
        $this->xml_filename = $xml_filename;

        $this->sort_key     = preg_replace_callback (
            '|\d+|',
            function ($match) {
                return 'zz' . strval (strlen ($match[0])) . $match[0];
            },
            $xml_id
        );
    }

    /**
     * Construct a \DOMXPath instance
     *
     * Constructs an instance of \DOMXPath and registers the namespaces we need.
     *
     * @param \DOMDocument $doc The DOM document
     *
     * @return \DOMXpath The xpath instance
     */

    private function xpath ($doc)
    {
        $xpath = new \DOMXpath ($doc);
        $xpath->registerNamespace ('tei', NS_TEI);
        $xpath->registerNamespace ('xml', NS_XML);
        return $xpath;
    }

    private function new_tei_dom ()
    {
        return \DOMDocument::loadXML ('<TEI xmlns="' . NS_TEI . '"><text><body/></text></TEI>');
    }

    /**
     * Build a DOMDocument from an XML or HTML string
     *
     * @param string $s The string
     *
     * @return \DOMDocument The DOM
     */

    private function string_to_dom ($s)
    {
        $doc = new \DOMDocument ();

        // load XML or HTML

        // keep server error log small (seems to be a problem at uni-koeln.de)
        libxml_use_internal_errors (true);

        if ($doc->loadXML  ($s, LIBXML_NONET) === false) {
            libxml_clear_errors ();
            // Hack to load HTML with utf-8 encoding
            $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $s, LIBXML_NONET);
            foreach ($doc->childNodes as $item) {
                if ($item->nodeType == XML_PI_NODE) {
                    $doc->removeChild ($item); // remove xml declaration
                }
            }
            $doc->encoding = 'UTF-8'; // insert proper encoding
        }
        return $doc;
    }

    /**
     * Extract section from TEI file
     *
     * @return void
     */

    public function extract_section ()
    {
        $s   = file_get_contents ($this->xml_filename);
        $doc = $this->string_to_dom ($s);

        $this->document = $this->new_tei_dom ();
        $xpath = $this->xpath ($this->document);
        $body  = $xpath->query ('//tei:body')[0];

        $xpath = $this->xpath ($doc);
        $nodes = $xpath->query ("//tei:ab[@corresp='{$this->corresp}'] | //tei:span[@corresp='{$this->corresp}']");
        foreach ($nodes as $node) {
            $body->appendChild ($this->document->importNode ($node, true));
            if ($node->nodeName == 'span' && ($milestone_id = $node->getAttribute ('to'))) {
                $xpath2 = $this->xpath ($doc);
                $nodes2 = $xpath2->query (
                    "following-sibling::node()[following-sibling::tei:anchor[@xml:id='$milestone_id']]",
                    $node
                );
                foreach ($nodes2 as $node2) {
                    $body->appendChild ($this->document->importNode ($node2, true));
                }
            }
        }
    }

    public function xml_to_text ()
    {
        $xsl = new \DOMDocument ();
        $xsl_filename = COLLATION_XSL;
        if ($xsl->load ($xsl_filename)) {
            $proc = new \XSLTProcessor ();
            $proc->importStylesheet ($xsl);
            $this->pure_text = $proc->transformToXML ($this->document);
            $this->pure_text = trim (preg_replace ('/\s+/', ' ', $this->pure_text));
        } else {
            error_log ("Could not open $xsl_filename");
        }
    }

    /**
     * Build the input to Collate-X
     *
     * Builds the JSON for one witness.  Returns an array that must be combined
     * into the witness array and then json_encode()d.
     *
     * Example of Collate-X input file:
     *
     * {
     *   "witnesses" : [
     *     {
     *       "id" : "A",
     *       "tokens" : [
     *           { "t" : "A ",      "n" : "a"     },
     *           { "t" : "black " , "n" : "black" },
     *           { "t" : "cat.",    "n" : "cat"   }
     *       ]
     *     },
     *     {
     *       "id" : "B",
     *       "tokens" : [
     *           { "t" : "A ",      "n" : "a"     },
     *           { "t" : "white " , "n" : "white" },
     *           { "t" : "kitten.", "n" : "cat"   }
     *       ]
     *     }
     *   ]
     * }
     *
     * @return array The array representation of one witness.
     */

    public function to_collatex ()
    {
        $tokens = array ();
        preg_match_all ('/\S+\s*/', trim ($this->pure_text), $matches);

        foreach ($matches[0] as $pattern) {
            $normalized = strtolower (trim ($pattern));
            $normalized = preg_replace ('/\[\s*|\s*\]/', '', $normalized);
            $normalized = preg_replace ('/[.,:;]/',      '', $normalized);
            if (!empty ($normalized)) {
                $tokens[] = array ('t' => $pattern, 'n' => $normalized);
            }
        }
        return array ('id' => $this->xml_id, 'tokens' => $tokens);
    }

    /**
     * Parse the Collate-X response
     *
     * {
     *   "witnesses":["A","B"],
     *   "table":[
     *     [ [ {"t":"A","ref":123 } ],      [ {"t":"A" } ] ],
     *     [ [ {"t":"black","adj":true } ], [ {"t":"white","adj":true } ] ],
     *     [ [ {"t":"cat","id":"xyz" } ],   [ {"t":"kitten.","n":"cat" } ] ]
     *   ]
     * }
     *
     * @return void
     */

    public function parse_response ()
    {
    }
}
