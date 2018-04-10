<?php
/**
 * Capitularia Meta Search Extractor.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

/**
 * TEI metadata extraction.
 */

class Extractor
{
    const GEONAMES_API_ENDPOINT = 'http://api.geonames.org/hierarchyJSON';
    const GEONAMES_USER         = 'highlander'; // FIXME get an institutional user

    /**
     * Store metadata
     *
     * Calls the appropriate function to cook the raw metadata contained in the
     * XML nodes.  Then stores the cooked metadata with the post.
     *
     * @param integer  $post_id   The post ID to associate metadata
     * @param string   $key       The key to store the metadata
     * @param array    $node_list The list of XML nodes
     * @param callable $func      The cooking function
     *
     * @return void
     */

    private function meta ($post_id, $key, $node_list, $func = 'trim')
    {
        delete_post_meta ($post_id, $key);
        foreach ($node_list as $node) {
            $value = call_user_func ($func, $node->nodeValue);
            if (!is_array ($value)) {
                $value = array ($value);
            }
            foreach ($value as $val) {
                add_post_meta ($post_id, $key, $val);
                // error_log ("adding $key=$val to post $post_id");
            }
        }
    }

    /**
     * Explode nmtokens list intoarray.
     *
     * @param string $in One or more nmtokens separated by ' '.
     *
     * @return array Array of nmtokens.
     *
     * @SuppressWarnings(PHPMD.UnusedPrivateMethod)
     */

    private function nmtokens ($in)
    {
        return explode (' ', $in);
    }

    /**
     * Get geonames.org place names hierarchy from id.
     *
     * @param string $in One or more URLs to geoname services separated by ' '.
     *
     * @return array The names of the places and of the broader administrative
     * regions the places are in.
     *
     * @SuppressWarnings(PHPMD.UnusedPrivateMethod)
     */

    private function geonames ($in)
    {
        // See: http://www.geonames.org/export/place-hierarchy.html#hierarchy
        $places = array ();
        foreach (explode (' ', $in) as $urn) {
            // http://www.geonames.org/2984114/reims.html
            if (preg_match  ('#//www.geonames.org/([\d]+)/#', $urn, $matches)) {
                $url = self::GEONAMES_API_ENDPOINT . '?' . http_build_query (
                    array ('geonameId' => $matches[1], 'username' => self::GEONAMES_USER)
                );
                // $json = file_get_contents ($url);
                $json = wp_remote_retrieve_body (wp_remote_get ($url));
                // error_log ('Geonames answer is: ' . $json);
                $g = json_decode ($json, true);
                // error_log ('JSON Error is: ' . json_last_error_msg ());
                // error_log ('Decoded JSON is: ' . print_r ($g, true));
                if (isset ($g['geonames'])) {
                    foreach ($g['geonames'] as $r) {
                        if ($r['fcl'] == 'A') {
                            $places[] = $r['name'];
                            $places[] = $r['toponymName'];
                        }
                    }
                }
            }
        }
        $places = array_unique ($places);
        return $places;
    }

    /**
     * Extract metadata from TEI file
     *
     * Execute a set of xpath queries on the TEI file and store the result with
     * the wordpress post as metadata.  The Meta Search Widget allows the user
     * to search the collected metadata.
     *
     * @param integer $post_id  The post ID to associate the metadata
     * @param string  $xml_path The full path to the TEI file
     *
     * @return string[] Error messages or empty
     */

    public function extract_meta ($post_id, $xml_path)
    {
        delete_post_meta ($post_id, 'tei-filename');
        add_post_meta ($post_id, 'tei-filename', $xml_path);

        libxml_use_internal_errors (true);

        $dom = new \DOMDocument;
        $dom->Load ($xml_path);
        if ($dom === false) {
            return array ("Error: DOMDocument could not parse file: $xml_path");
        }
        $dom->xinclude ();

        $xpath = new \DOMXPath ($dom);
        $xpath->registerNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        $xpath->registerNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');

        $this->meta (
            $post_id,
            'tei-xml-id',
            $xpath->query ('/tei:TEI/@xml:id')
        );
        $this->meta (
            $post_id,
            'tei-corresp', /* capit pages */
            $xpath->query ('/tei:TEI/@corresp')
        );
        $this->meta (
            $post_id,
            'msitem-corresp',
            $xpath->query ('//tei:msItem/@corresp'),
            array ($this, 'nmtokens')
        );
        $this->meta (
            $post_id,
            'corresp',
            $xpath->query ('//tei:ab/@corresp|//tei:span/@corresp'),
            array ($this, 'nmtokens')
        );
        $this->meta (
            $post_id,
            'ab-corresp',
            $xpath->query ('//tei:ab[@type="text"]/@corresp|//tei:ab[@type="meta-text"]/@corresp'),
            array ($this, 'nmtokens')
        );
        $this->meta (
            $post_id,
            'ab-text-corresp',
            $xpath->query ('//tei:ab[@type="text"]/@corresp'),
            array ($this, 'nmtokens')
        );
        $this->meta (
            $post_id,
            'ab-meta-text-corresp',
            $xpath->query ('//tei:ab[@type="text"]/@corresp'),
            array ($this, 'nmtokens')
        );
        $this->meta ($post_id, 'milestone-capitulare',  $xpath->query ('//tei:milestone[@unit="capitulare"]/@n'));
        $this->meta ($post_id, 'origDate-notBefore',    $xpath->query ('//tei:head/tei:origDate/@notBefore'), 'intval');
        $this->meta ($post_id, 'origDate-notAfter',     $xpath->query ('//tei:head/tei:origDate/@notAfter'),  'intval');
        $this->meta ($post_id, 'origPlace',             $xpath->query ('//tei:head/tei:origPlace'));
        $this->meta ($post_id, 'head-title-main',       $xpath->query ('//tei:head/tei:title[@type="main"]'));
        $this->meta ($post_id, 'facsimile-graphic-url', $xpath->query ('/tei:TEI/tei:facsimile/tei:graphic/@url'));
        $this->meta (
            $post_id,
            'origPlace-ref',
            $xpath->query ('//tei:head/tei:origPlace/@ref'),
            array ($this, 'nmtokens')
        );
        $this->meta (
            $post_id,
            'origPlace-geonames',
            $xpath->query ('//tei:head/tei:origPlace/@ref'),
            array ($this, 'geonames')
        );

        // get tei:changes

        delete_post_meta ($post_id, 'change');
        foreach ($xpath->query ('//tei:revisionDesc/tei:change') as $node) {
            $when = $node->attributes->getNamedItem ('when')->nodeValue;
            $who  = $node->attributes->getNamedItem ('who')->nodeValue;
            $what = trim (preg_replace ('/\s+/', ' ', $node->nodeValue));
            add_post_meta ($post_id, 'change', "$when/$who/$what");
        }

        $errors = libxml_get_errors ();
        libxml_clear_errors ();

        $messages = array ();
        foreach ($errors as $e) {
            // Bug in the old libxml used by our web server (still running redhat el6)
            if (strncmp ($e->message, 'xmlParsePITarget:', 17) == 0) {
                continue;
            }
            $messages[] = "{$e->file}:{$e->line} {$e->level} {$e->code} {$e->message}\n";
        }
        return $messages;
    }
}
