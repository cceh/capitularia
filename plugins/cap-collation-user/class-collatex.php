<?php
/**
 * Capitularia Collation Collatex Interface
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

const COLLATION_ROOT  = AFS_ROOT . '/local/capitularia-collation';
const COLLATEX_JAR    = AFS_ROOT . '/local/bin/collatex-tools-1.8-SNAPSHOT.jar';
const COLLATEX        = AFS_ROOT . '/local/bin/java -jar ' . COLLATEX_JAR;

/**
 * Implements the CollateX interface
 */

class CollateX
{
    /**
     * Call CollateX with pipes
     *
     * Call CollateX using only pipes, no temp files.  Web servers should not
     * write files.
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
     * For old CollateX that does not understand stdin (shame, shame).
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
}