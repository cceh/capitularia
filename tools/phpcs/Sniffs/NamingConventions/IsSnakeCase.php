<?php

/**
 * Returns true if the specified string is in the snake_case format.
 *
 * @param string $string The string to verify.
 *
 * @return boolean
 */
function isSnakeCase($string)
{
    // If there are space in the name, it can't be valid.
    if (strpos($string, ' ') !== false) {
        return false;
    }

    $validName = preg_match('|^[_a-z0-9]+$|', $string) === 1;

    return $validName;

}//end isSnakeCase()
