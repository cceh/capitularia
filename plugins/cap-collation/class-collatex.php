<?php
/**
 * Capitularia Collation Collatex Interface
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

const COLLATION_ROOT  = AFS_ROOT . '/local/capitularia-collation';
const COLLATEX_JAR    = COLLATION_ROOT . '/scripts/collatex-tools-1.8-SNAPSHOT.jar';
const COLLATEX        = AFS_ROOT . '/local/bin/java -jar ' . COLLATEX_JAR;
const COLLATEX_PYTHON = AFS_ROOT . '/http/docs/wp-content/plugins/cap-collation/collatex-cli.py';

const ALGORITHMS = array (
    'dekker'           => 'Dekker',
    'gst'              => 'Greedy String Tiling',
    'medite'           => 'MEDITE',
    'needleman-wunsch' => 'Needleman-Wunsch',
);

/**
 * Implements the CollateX interface
 */

class CollateX
{
    /**
     * Call CollateX with pipes
     *
     * Call CollateX using only pipes, no temp files.  Web servers should not
     * write files.  Only works with our custom-patched version of CollateX for
     * Java because vanilla CollateX for Java does not understand stdin (shame,
     * shame).
     *
     * @param string $json_in The JSON input
     *
     * @return array The error code, stdout, and stderr
     */

    public function call_collatex_pipes ($json_in)
    {
        chdir (COLLATION_ROOT . '/scripts');

        $executable = COLLATEX;

        $descriptorspec = array (
            0 => array ('pipe', 'r'),  // stdin
            1 => array ('pipe', 'w'),  // stdout
            2 => array ('pipe', 'w'),  // stderr
        );
        $error_code = 666;
        $stdout     = '';
        $stderr     = '';

        $process = proc_open ($executable . ' -f json -', $descriptorspec, $pipes);

        if (is_resource ($process)) {
            stream_set_blocking ($pipes[1], 0);
            stream_set_blocking ($pipes[2], 0);

            fwrite ($pipes[0], $json_in);
            fclose ($pipes[0]);

            while (! (feof ($pipes[1]) && feof ($pipes[2]))) {
                $stdout .= fgets ($pipes[1], 1024);
                $stderr .= fgets ($pipes[2], 1024);
            }

            fclose ($pipes[1]);
            fclose ($pipes[2]);
            $error_code = proc_close ($process);
        }

        return array (
            'error_code' => $error_code,
            'stdout'     => $stdout,
            'stderr'     => $stderr,
        );
    }

    /**
     * Call Collate-X with temporary file.
     *
     * For vanilla CollateX for Java that does not understand stdin (shame,
     * shame).
     *
     * @param string $executable The CollateX executable
     * @param string $json_in    The JSON input
     *
     * @return array The error code, stdout, and stderr
     */

    public function call_collatex_tempfile ($executable, $json_in)
    {
        $tmpfile = tempnam (COLLATION_ROOT . '/output', 'collatex-tmp-');
        file_put_contents ($tmpfile, $json_in);

        chdir (COLLATION_ROOT . '/scripts');

        $cmd = array ();
        $cmd[] = $executable;
        $cmd[] = '-f json';
        $cmd[] = $tmpfile;

        $cmd = implode (' ', $cmd);
        $output = array ();
        exec ($cmd, $output, $error_code);

        unlink ($tmpfile);

        return array (
            'error_code' => $error_code,
            'stdout'     => implode ("\n", $output),
            'stderr'     => '',
        );
    }

    /**
     * Invert a table returned by CollateX
     *
     * Turn rows into columns and vice versa.
     *
     * @param array $in_table The CollateX table
     *
     * @return array
     */

    public function invert_table ($in_table)
    {
        $out_table = array ();
        $n_rows = count ($in_table);
        for ($r = 0; $r < $n_rows; $r++) {
            $row = $in_table[$r];
            $n_cols = count ($row);
            for ($c = 0; $c < $n_cols; $c++) {
                $out_table[$c][$r] = $row[$c];
            }
        }
        return $out_table;
    }

    /**
     * Calculate the cell width in characters
     *
     * @param array $cell The array of tokens
     *
     * @return integer The width in characters
     */

    private function cell_width ($cell)
    {
        $tmp = '';
        foreach ($cell as $token) {
            $tmp .= $token['t'];
        }
        return strlen (trim ($tmp));
    }

    /**
     * Split a table every n columns
     *
     * @param array   $in_table  The table to split
     * @param integer $max_width Split after this many characters
     *
     * @return array An array of tables
     */

    public function split_table ($in_table, $max_width)
    {
        $out_tables = array ();
        $n_cols = count ($in_table);

        $width = $max_width + 1;
        for ($c = 0; $c < $n_cols; $c++) {
            $column = $in_table[$c];
            $column_width = max (array_map (array ($this, 'cell_width'), $column));
            if ($width + $column_width > $max_width) {
                // ArrayObject because of reference copying
                $out_tables[] = $table = new \ArrayObject ();
                $width = 0;
            }
            $table->append ($column);
            $width += $column_width;
        }
        return $out_tables;
    }

    /**
     * Format a CollateX table into HTML
     *
     * @param array $witnesses The witnesses
     * @param array $table     The collation table in row orientation
     *
     * @return string[] The rows of the HTML table
     */

    public function format_table ($witnesses, $table)
    {
        $out = array ();
        $n_witnesses = count ($table);
        for ($w = 0; $w < $n_witnesses; $w++) {
            $row = $table[$w];
            $witness = esc_attr ($witnesses[$w]);
            $out[] = "<tr title='$witness'>";
            $out[] = "<th class='witness'>$witness</th>";
            $n_segments = count ($row);
            for ($s = 0; $s < $n_segments; $s++) {
                $token_set = $row[$s];
                $class = 'tokens';
                if ($w > 0 && ($table[0][$s] == $token_set)) {
                    $class .= ' equal';
                }
                $tmp = '';
                if (count ($token_set) > 0) {
                    foreach ($token_set as $token) {
                        $tmp .= $token['t'];
                    }
                } else {
                    $tmp = '<span class="missing" />';
                }
                $tmp = trim ($tmp);
                $out[] = "<td class='$class'>$tmp</td>";
            }
            $out[] = '</tr>';
        }
        return $out;
    }
}
