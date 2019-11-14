<?php
/**
 * Capitularia Collation Witness
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

/**
 * A collation witness
 *
 * N.B. This class is a remnant of when we actually *did* something with the
 * witness in this plugin.  Currently we do everything on the application server
 * and just pass the ids to the server.
 */

class Witness
{
    private $corresp;
    private $xml_id;
    private $xml_filename;
    private $locus;
    private $sub_id;
    private $later_hands;

    /**
     * Constructor
     *
     * @param string $corresp      The corresp, eg. "BK.184_a"
     * @param string $xml_id       The xml:id of the TEI file, eg. "bamberg-sb-can-12"
     * @param string $xml_filename The full path to the TEI file.
     * @param string $locus        The locus of the corresp in the ms.
     * @param int    $sub_id       Sub-Id of witness. @See: clone_witness ().
     * @param bool   $later_hands  True if corrections by later hands should be included.
     *
     * @return Witness
     */

    public function __construct ($corresp, $xml_id, $xml_filename, $locus, $sub_id, $later_hands = false)
    {
        $this->corresp      = $corresp;
        $this->xml_id       = $xml_id;
        $this->xml_filename = $xml_filename;
        $this->locus        = $locus;
        $this->sub_id       = $sub_id;
        $this->later_hands  = $later_hands;

        $this->sort_key     = make_sort_key ($this->get_id ());
    }

    /**
     * Clone the witness structure with a different sub_id.
     *
     * Witnesses may contain more than one copy of the same capitular.  In
     * that case we want to collate each copy separately and need to duplicate
     * this structure.  The sub_id indicates which copy of the capitular this
     * instance respresents.  The first or only copy gets a sub_id of 1.
     *
     * Witnesses may contain corrections by later hands, in which case we want
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
            $this->locus,
            $sub_id,
            $later_hands
        );
    }

    /**
     * Build an id containing a sub_id.
     *
     * To distinguish different copies of the same capitular in one witness.
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
}
