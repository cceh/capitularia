<?php

namespace phpcs\Sniffs\NamingConventions;

/**
 * Returns true if the specified string is in the snake_case format.
 *
 * @param string $string The string to verify.
 *
 * @return boolean
 */
function isSnakeCase($string)
{
    // allow 'ID' in variable names because of its frequent use in Wordpress
    foreach (explode ('_', $string) as $s) {
        if (preg_match('/^([a-z0-9]+)|(ID)$/', $s) !== 1)
            return false;
    }
    return true;
}
