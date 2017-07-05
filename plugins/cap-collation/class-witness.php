<?php
/**
 * Capitularia Collation Witness
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

const XSLTPROC      = AFS_ROOT . '/local/bin/xsltproc';
const COLLATION_XSL = AFS_ROOT . '/http/docs/cap/publ/transform/mss-transcript-collation.xsl';
// const COLLATION_XSL = AFS_ROOT . '/http/docs/cap/publ/transform/transkription_LesEdi_CapKoll.xsl';

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
    private $slug;
    public $sort_key;
    public $sub_id;
    private $sections = array ();

    /**
     * Constructor
     *
     * @param string $corresp      The capitulary section, eg. "BK.184_a"
     * @param string $xml_id       The xml:id of the TEI file, eg. "bamberg-sb-can-12"
     * @param string $xml_filename The full path to the TEI file.
     * @param string $slug         Slug of manuscript page
     * @param int    $sub_id       Sub-Id of witness. @See: clone_witness ().
     * @param bool   $later_hands  True if corrections by later hands should be included.
     *
     * @return Witness
     */

    public function __construct ($corresp, $xml_id, $xml_filename, $slug, $sub_id = 1, $later_hands = false)
    {
        $this->corresp      = $corresp;
        $this->xml_id       = $xml_id;
        $this->xml_filename = $xml_filename;
        $this->slug         = $slug;
        $this->sub_id       = $sub_id;
        $this->later_hands  = $later_hands;

        $this->sort_key     = preg_replace_callback (
            '|\d+|',
            function ($match) {
                return 'zz' . strval (strlen ($match[0])) . $match[0];
            },
            $this->get_id ()
        );
    }

    /**
     * Clone the witness structure with a different sub_id.
     *
     * Manuscripts may contain more than one copy of the same capitular.  In
     * that case we want to collate each copy separately and need to duplicate
     * this structure.  The sub_id indicates which copy of the capitular this
     * instance respresents.  The first or only copy gets a sub_id of 1.
     *
     * Manuscripts may contain corrections by later hands, in which case we want
     * to collate the earlier and later versions separately.
     *
     * @param integer $sub_id      The new sub_id. Should be > 1.
     * @param bool    $later_hands True if corrections by later hands should be included.
     *
     * @return Witness The cloned witness.
     */

    public function clone_witness ($sub_id, $later_hands)
    {
        return new Witness (
            $this->corresp,
            $this->xml_id,
            $this->xml_filename,
            $this->slug,
            $sub_id,
            $later_hands
        );
    }

    /**
     * Build an id containing a sub_id.
     *
     * To distinguish different copies of the same capitular in one manuscript.
     *
     * @return string The id including the sub_id.
     */

    public function get_id ()
    {
        $id = $this->xml_id;
        if ($this->later_hands) {
            $id .= '?hands=XYZ';
        }
        if ($this->sub_id > 1) {
            $id .= '#' . $this->sub_id;
        }
        return $id;
    }

    /**
     * Get the slug.
     *
     * @return string The slug.
     */

    public function get_slug ()
    {
        return $this->slug;
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
        $doc = new \DOMDocument ();
        $doc->loadXML ('<TEI xmlns="' . NS_TEI . '"><text><body/></text></TEI>');
        return $doc;
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
     * Get all nodes that have a certain corresp attribute
     *
     * @param string $corresp  The corresp
     *
     * @return nodelist The nodes
     */

    public function get_nodes_for ($corresp)
    {
        $s   = file_get_contents ($this->xml_filename);
        $doc = $this->string_to_dom ($s);
        $xpath = $this->xpath ($doc);
        $corr = "contains (concat (' ', @corresp, ' '), ' {$corresp} ')";

        return $xpath->query (
            "//tei:ab[{$corr}][not (.//tei:milestone[@unit='span'])] | //tei:milestone[@spanTo and @unit='span' and {$corr}]"
        );
    }

    /**
     * Process a node
     *
     * Nodes may be either <ab> or <milestone unit='span' spanTo='#id'>.  In
     * case of <ab> the node is copied, in case of <milestone> the output is an
     * <ab> containing all nodes up to the closing anchor.
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

        // <milestone spanTo="#id" /> ... <anchor id="id" />
        //
        // This outputs an <ab> containing all nodes up to the closing anchor.
        if ($node->localName == 'milestone' && $milestone_id = $node->getAttribute ('spanTo')) {
            $milestone_id = trim ($milestone_id, '#');
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
     * N.B. 2017-03-10 <span to='id'> wurde ersetzt durch <milestone unit='span'
     * spanTo='#id'>
     *
     * @param string   $corresp The corresp attribute to match
     * @param string[] $errors  Array for error messages
     *
     * @return void
     */

    public function extract_section ($corresp, &$errors)
    {
        $this->document = $this->new_tei_dom ();
        $xpath = $this->xpath ($this->document);
        $body  = $xpath->query ('//tei:body')[0];

        $n = 1;
        foreach ($this->get_nodes_for ($corresp) as $node) {
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
            $errors[] = "Nothing extracted from {$this->xml_filename} for {$corresp} " .
                      "sub-id {$this->sub_id} and hands {$this->later_hands}";
        }
    }

    /**
     * Convert TEI to plain text suited for collation.
     *
     * Use our own xslt toolchain because the Cogel-installed toolchain is
     * obsolete and buggy.  (eg. The exslt:str:padding () produces garbage when
     * asked to pad with a multibyte utf8 character.)
     *
     * @return integer The xsltproc error code
     */

    public function xml_to_text ()
    {
        $return_value = 666;

        $cmdline   = array ();
        $cmdline[] = XSLTPROC;
        if ($this->later_hands) {
            $cmdline[] = '--param include-later-hand "true()"';
        }
        $cmdline[] = COLLATION_XSL;
        $cmdline[] = '-';

        $descriptorspec = array (
            0 => array ('pipe', 'r'),
            1 => array ('pipe', 'w'),
            2 => array ('file', '/dev/null', 'w') // no stderr to keep server error logs small
        );

        $process = proc_open (join (' ', $cmdline), $descriptorspec, $pipes, null, null);

        if (is_resource ($process)) {
            fwrite ($pipes[0], $this->document->saveXML ());
            fclose ($pipes[0]);

            $this->pure_text = stream_get_contents ($pipes[1]);
            fclose ($pipes[1]);

            $return_value = proc_close ($process);

            $this->pure_text = mb_trim (preg_replace ('/\s+/u', ' ', strip_tags ($this->pure_text)));
        } else {
            error_log ('Could not proc_open () ' . join (' ', $cmdline));
        }
        return $return_value;
    }

    /**
     * Count how many copies of a section there are.
     *
     * Manuscripts may contain more than one copy of the same capitular.  In
     * that case we want to collate each copy separately.  This function counts
     * how many copies of a section there are in this manuscript.
     *
     * @param string $corresp The corresp
     *
     * @return int The number of sections.
     */

    public function count_sections ($corresp)
    {
        $n = 0;
        foreach ($this->get_nodes_for ($corresp) as $node) {
            if ($node->getAttribute ('prev')) {
                continue;
            }
            $n++;
        }
        return $n;
    }

    /**
     * Check for later hands in manuscript
     *
     * Sometimes we want to collate a manuscript in the version corrected by a
     * later hand.  A later hand is defined as hand in 'X', 'Y', or Z.
     *
     * @return True if there are later hands.
     */

    public function has_later_hands ()
    {
        $s   = file_get_contents ($this->xml_filename);
        $doc = $this->string_to_dom ($s);
        $xpath = $this->xpath ($doc);

        $nodes = $xpath->query ("//@hand[contains ('XYZ', .)]");
        return $nodes->length > 0;
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
        $text = mb_trim ($this->pure_text);

        foreach (mb_split (' ', 'ę=e Ę=E ae=e Ae=E AE=E') as $n) {
            $n = mb_split ('=', $n);
            $text = mb_ereg_replace ($n[0], $n[1],  $text);
        }
        $text = mb_ereg_replace ('[-.,:;!?*/]', '',  $text);
        $text = mb_ereg_replace (' ',           ' ', $text);

        foreach ($normalizations as $n) {
            $n = mb_split ('=', $n);
            if (count ($n) == 2) {
                $patterns[] = mb_trim ($n[0]);
                $replacements[] = mb_trim ($n[1]);
            }
        }

        // tokenize
        preg_match_all ('/\S+\s*/u', $text, $matches);
        foreach ($matches[0] as $token) {
            $n_patterns = count ($patterns);
            $normalized = $token = mb_trim ($token);
            for ($i = 0; $i < $n_patterns; $i++) {
                $normalized = mb_ereg_replace ($patterns[$i], $replacements[$i], $normalized);
            }
            $normalized = mb_strtolower ($normalized);
            $normalized = mb_ereg_replace ('\[\s*|\s*\]', '',  $normalized);

            if (!empty ($normalized)) {
                $tokens[] = array ('t' => $token, 'n' => $normalized);
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
