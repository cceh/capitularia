<?php

use Sami\Sami;
use Sami\Version\GitVersionCollection;
use Symfony\Component\Finder\Finder;

$dirs = array ('themes', 'plugins');

$iterator = Finder::create ()->files ()->name ('*.php')->in ($dirs);

return new Sami ($iterator, array (
    'theme'                => 'enhanced',
    'title'                => 'Capitularia',
    'build_dir'            => './tools/reports/sami/build',
    'cache_dir'            => './tools/reports/sami/cache',
    'default_opened_level' => 2,
));
