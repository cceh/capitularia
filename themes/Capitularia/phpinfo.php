<?php

/**
 * Print server info (for debug use only).
 *
 * @package Capitularia
 */

echo ('<div>Python version: ');
passthru ('python --version');
echo ("</div>\n");

echo ('<div>PHP CLI version: ');
passthru ('php --version');
echo ("</div>\n");

phpinfo ();
