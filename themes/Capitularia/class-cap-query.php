<?php

/**
 * The template for displaying Search Results pages.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

class CapQuery extends \WP_Query {
    /**
     * Generates SQL for the WHERE clause based on passed search terms.
     *
     * Copied from class-wp-query.php and doctored to accept any amount of whitespace
     * between each word in phrase searches.
     *
     * Prerequisite:
     *
     * mysql> create fulltext index post_content on wp_posts(post_content);
     * mysql> create fulltext index post_title   on wp_posts(post_title);
     * mysql> create fulltext index post_excerpt on wp_posts(post_excerpt);
     *
     * @since 3.7.0
     *
     * @global wpdb $wpdb WordPress database abstraction object.
     *
     * @param array $q Query variables.
     * @return string WHERE clause.
     */
    protected function parse_search( &$q ) {
        global $wpdb;

        $search = '';

        // Added slashes screw with quote grouping when done early, so done later.
        $q['s'] = stripslashes( $q['s'] );
        if ( empty( $_GET['s'] ) && $this->is_main_query() ) {
            $q['s'] = urldecode( $q['s'] );
        }
        // There are no line breaks in <input /> fields.
        $q['s']                  = str_replace( array( "\r", "\n" ), '', $q['s'] );
        $q['search_terms_count'] = 1;
        if ( ! empty( $q['sentence'] ) ) {
            $q['search_terms'] = array( $q['s'] );
        } else {
            if ( preg_match_all( '/".*?("|$)|((?<=[\t ",+])|^)[^\t ",+]+/', $q['s'], $matches ) ) {
                $q['search_terms_count'] = count( $matches[0] );
                $q['search_terms']       = $this->parse_search_terms( $matches[0] );
                // If the search string has only short terms or stopwords, or is 10+ terms long, match it as sentence.
                if ( empty( $q['search_terms'] ) || count( $q['search_terms'] ) > 9 ) {
                    $q['search_terms'] = array( $q['s'] );
                }
            } else {
                $q['search_terms'] = array( $q['s'] );
            }
        }

        $n                         = ! empty( $q['exact'] ) ? '' : '%';
        $searchand                 = '';
        $q['search_orderby_title'] = array();

        $default_search_columns = array( 'post_title', 'post_excerpt', 'post_content' );
        $search_columns         = ! empty( $q['search_columns'] ) ? $q['search_columns'] : $default_search_columns;
        if ( ! is_array( $search_columns ) ) {
            $search_columns = array( $search_columns );
        }

        /**
         * Filters the columns to search in a WP_Query search.
         *
         * The supported columns are `post_title`, `post_excerpt` and `post_content`.
         * They are all included by default.
         *
         * @since 6.2.0
         *
         * @param string[] $search_columns Array of column names to be searched.
         * @param string   $search         Text being searched.
         * @param WP_Query $query          The current WP_Query instance.
         */
        $search_columns = (array) apply_filters( 'post_search_columns', $search_columns, $q['s'], $this );

        // Use only supported search columns.
        $search_columns = array_intersect( $search_columns, $default_search_columns );
        if ( empty( $search_columns ) ) {
            $search_columns = $default_search_columns;
        }

        /**
         * Filters the prefix that indicates that a search term should be excluded from results.
         *
         * @since 4.7.0
         *
         * @param string $exclusion_prefix The prefix. Default '-'. Returning
         *                                 an empty value disables exclusions.
         */
        $exclusion_prefix = apply_filters( 'wp_query_search_exclusion_prefix', '-' );

        foreach ( $q['search_terms'] as $term ) {
            // If there is an $exclusion_prefix, terms prefixed with it should be excluded.
            $exclude = $exclusion_prefix && str_starts_with( $term, $exclusion_prefix );
            if ( $exclude ) {
                $like_op  = 'NOT LIKE';
                $andor_op = 'AND';
                $term     = substr( $term, 1 );
            } else {
                $like_op  = 'LIKE';
                $andor_op = 'OR';
            }

            if ( $n && ! $exclude ) {
                $like                        = '%' . $wpdb->esc_like( $term ) . '%';
                $q['search_orderby_title'][] = $wpdb->prepare( "{$wpdb->posts}.post_title LIKE %s", $like );
            }

            $like = $n . $wpdb->esc_like( $term ) . $n;

            if (str_contains($term, " ")) {
                $term = '"' . $term . '"';
            }

            $search_columns_parts = array();
            foreach ( $search_columns as $search_column ) {
                if (str_starts_with($term, '"')) {
                    $search_columns_parts[ $search_column ] = $wpdb->prepare(
                        "match({$wpdb->posts}.$search_column) against('%s')", $term
                    );
                } else {
                    $search_columns_parts[ $search_column ] = $wpdb->prepare(
                        "({$wpdb->posts}.$search_column $like_op %s)", $like
                    );
                }
            }

            if ( ! empty( $this->allow_query_attachment_by_filename ) ) {
                $search_columns_parts['attachment'] = $wpdb->prepare( "(sq1.meta_value $like_op %s)", $like );
            }

            $search .= "$searchand(" . implode( " $andor_op ", $search_columns_parts ) . ')';

            $searchand = ' AND ';
        }

        if ( ! empty( $search ) ) {
            $search = " AND ({$search}) ";
            if ( ! is_user_logged_in() ) {
                $search .= " AND ({$wpdb->posts}.post_password = '') ";
            }
        }
        error_log("WHERE {$search}");
        return $search;
    }
}
