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
    private $xml_id;
    public $sort_key;
    public $sub_id;
    private $sections = array ();

    /**
     * Constructor
     *
     * Note: Manuscripts may contain more than one copy of the same @corresp. In
     * that case a second witness is generated with a Sub-Id > 1.
     *
     * @param string $corresp      The capitulary section, eg. "BK.184_a"
     * @param string $xml_id       The xml:id of the TEI file, eg. "bamberg-sb-can-12"
     * @param string $xml_filename The full path to the TEI file.
     * @param int    $sub_id       Sub-Id of witness.
     *
     * @return Collation_item
     */

    public function __construct ($corresp, $xml_id, $xml_filename, $sub_id = 1)
    {
        $this->corresp      = $corresp;
        $this->xml_id       = $xml_id;
        $this->xml_filename = $xml_filename;
        $this->sub_id       = $sub_id;

        $this->sort_key     = preg_replace_callback (
            '|\d+|',
            function ($match) {
                return 'zz' . strval (strlen ($match[0])) . $match[0];
            },
            $this->get_id ()
        );
    }

    public function clone_witness ($sub_id)
    {
        return new Witness ($this->corresp, $this->xml_id, $this->xml_filename, $sub_id);
    }

    public function get_id ()
    {
        if ($this->sub_id > 1) {
            return $this->xml_id . '-' . $this->sub_id;
        }
        return $this->xml_id;
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

    public function get_corresp ()
    {
        return $this->corresp;
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
     * Process a node
     *
     * Nodes may be either <ab> or <span to="id">.  In cased of <ab> the node is
     * copied, in case of <span to="id"> the output is an <ab> containing all
     * nodes up to the closing anchor.
     *
     * @param DOMNode  $body   The element to append to
     * @param DOMNode  $node   The node to process
     * @param string[] $errors An array for error messages
     *
     * @return void
     */

    private function process_node ($body, $node, &$errors)
    {
        // <ab>
        if ($node->localName == 'ab') {
            $body->appendChild ($this->document->importNode ($node, true));
        }

        // <span to="id" /> ... <anchor id="id" />
        //
        // This outputs an <ab> containing all nodes up to the closing anchor.
        if ($node->localName == 'span' && $milestone_id = $node->getAttribute ('to')) {
            $div = $body->appendChild ($this->document->createElementNS (NS_TEI, 'tei:ab'));
            $div->setAttribute ('corresp', $node->getAttribute ('corresp'));
            $xpath2 = $this->xpath ($node->ownerDocument);
            $nodes2 = $xpath2->query (
                "following-sibling::node()[following-sibling::tei:anchor[@xml:id='$milestone_id']]",
                $node
            );
            foreach ($nodes2 as $node2) {
                $div->appendChild ($this->document->importNode ($node2, true));
            }
        }

        // <* next="id">
        //
        // This outputs all nodes linked with @next.  Those nodes will all have
        // a @prev attribute.  All nodes with @prev attribute will be output
        // here.
        $next_id = $node->getAttribute ('next');
        $corresp = $node->getAttribute ('corresp');
        if ($next_id && $next_id[0] == '#') {
            $node = $node->ownerDocument->getElementById (substr ($next_id, 1));

            if ($node) {
                // Test if the @next element really corresp-onds to the source element.
                if ($node->getAttribute ('corresp') !== $corresp) {
                    // build error message
                    $bad_corresp = $node->getAttribute ('corresp');
                    $error_msg  = "@next='{$next_id}' ";
                    $error_msg .= "points from @corresp='{$corresp}' to @corresp='{$bad_corresp}'";
                    $errors[] = $error_msg;
                }

                // Yay, recurse!
                $this->process_node ($body, $node, $errors);
            } else {
                $errors[] = "Unresolved ref: {$next_id}";
            }
        }
    }

    /**
     * Extract section from TEI file.
     *
     * This function builds a new TEI-like DOM in memory and adds just the
     * section(s) matched by corresp.
     *
     * See: http://capitularia.uni-koeln.de/wp-admin/admin.php?page=wp-help-documents&document=7402
     *
     * Aus den Transkriptionsrichtlinien 1.3 beta
     *
     * Beginnt ein neues Kapitel mitten im Text, werden innerhalb des <ab/> alle
     * jeweils zu einem Kapitel gehörenden Textteile zusätzlich in <span/>s
     * gesetzt:
     *
     * <span corresp=”BK.184_b” to=”berlin-sb-phill-1762-71r-1_2″/>
     * Uolumus etiam … octauas paschae .
     * <anchor xml:id=”berlin-sb-phill-1762-71r-1_2″/>
     *
     * Der Anfang des Textabschnittes wird jeweils durch ein leeres
     * <span/>-Element markiert, in dem sich das @corresp mit dem Verweis auf
     * die entsprechende Stelle bei BK sowie ein @to befinden; letzteres
     * verweist auf die xml:id, mit dem das Ende des Textabschnittes markiert
     * wird. Am Ende des Abschnittes wird ein leeres <anchor>-Element gesetzt,
     * das die xml:id enthält (= die xml:id des <ab/>, in dem die <span/>
     * enthalten ist, mit dem Zusatz „_1“, „_2“, „_3“ etc.)
     *
     * Sind zusammengehörige Textabschnitte über mehrere <ab/> verteilt, so
     * erhält die erste <span/> zusätzlich ein @next (Wert: xml:id der folgenden
     * <span/>) und die folgenden zugehörigen jeweils ein @prev (Wert: xml:id
     * der vorangehenden <span/>) und @next. Die letzte <span/> des
     * zusammengehörigen Abschnittes erhält nur ein @prev.
     *
     * @param string   $corresp The corresp attribute to match
     * @param string[] $errors  Array for error messages
     *
     * @return void
     */

    public function extract_section ($corresp, &$errors)
    {
        $s   = file_get_contents ($this->xml_filename);
        $doc = $this->string_to_dom ($s);

        $this->document = $this->new_tei_dom ();
        $xpath = $this->xpath ($this->document);
        $body  = $xpath->query ('//tei:body')[0];
        $xpath = $this->xpath ($doc);

        $nodes = $xpath->query ("//tei:ab[@corresp='{$corresp}'] | //tei:span[@to and @corresp='{$corresp}']");
        $n = 1;
        foreach ($nodes as $node) {
            // Nodes with @prev are handled in the @next chain instead.
            if ($node->getAttribute ('prev')) {
                continue;
            }
            // Process only the correct sub-id.
            if ($n == $this->sub_id) {
                $this->process_node ($body, $node, $errors);
            }
            $n++;
        }
        if (empty ($body->textContent)) {
            $errors[] = "Nothing extracted from {$this->xml_filename} for $corresp";
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

    public function enum_sections ($corresp)
    {
        $s   = file_get_contents ($this->xml_filename);
        $doc = $this->string_to_dom ($s);
        $xpath = $this->xpath ($doc);

        $n = 0;
        $nodes = $xpath->query ("//tei:ab[@corresp='{$corresp}'] | //tei:span[@to and @corresp='{$corresp}']");
        foreach ($nodes as $node) {
            if ($node->getAttribute ('prev')) {
                continue;
            }
            $n++;
        }
        return $n;
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
     * @param string[] $normalizations Array of string in the form: oldstring=newstring
     *
     * @return array The array representation of one witness.
     */

    public function to_collatex ($normalizations = array ())
    {
        $tokens = array ();
        $patterns = array ();
        $replacements = array ();
        $text = trim ($this->pure_text);

        foreach ($normalizations as $n) {
            $n = explode ('=', $n);
            if (count ($n) == 2) {
                $patterns[] = trim ($n[0]);
                $replacements[] = trim ($n[1]);
            }
        }

        preg_match_all ('/\S+\s*/', $text, $matches);
        foreach ($matches[0] as $pattern) {
            $normalized = trim ($pattern);
            if (count ($patterns)) {
                $normalized = str_replace ($patterns, $replacements, $normalized);
            }
            $normalized = strtolower ($normalized);
            $normalized = preg_replace ('/\[\s*|\s*\]/', '', $normalized);
            $normalized = preg_replace ('/[.,:;]/',      '', $normalized);
            if (!empty ($normalized)) {
                $tokens[] = array ('t' => $pattern, 'n' => $normalized);
            }
        }
        return array ('id' => $this->get_id (), 'tokens' => $tokens);
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
