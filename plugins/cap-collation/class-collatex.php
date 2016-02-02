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
     * Format a CollateX table into HTML
     *
     * @param array $data The CollateX table
     *
     * @return string The HTML table
     */

    public function format_table ($data)
    {
        $out = array ();

        $out[] = '<table class="collation">';

        $table  = $data['table'];
        $n_witnesses = count ($table);
        for ($w = 0; $w < $n_witnesses; $w++) {
            $row = $table[$w];
            $witness = esc_attr ($data['witnesses'][$w]);
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

        $out[] = '</table>';

        $out[] = esc_html ($json_out);

        return implode ("\n", $out);
    }
}
