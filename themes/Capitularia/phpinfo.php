<?php

echo ("<div>Python version: ");
passthru ('python --version');
echo ("</div>\n");

echo ("<div>PHP CLI version: ");
passthru ('php --version');
echo ("</div>\n");

phpinfo ();
