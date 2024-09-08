<template>
    <div v-if="response" class="tab-pane fade">
        <cap-pager class="my-3" :last="last_page ()" :current="page" @page="goto_page" />
        <article v-for="doc of response.docs"
                 :key="doc.id" class="search-results-excerpt my-3">
            <slot :doc="doc" :snippets="highlighting[doc.id]" :expanded="expanded[doc.cap_id_chapter]"/>
        </article>
        <cap-pager class="my-3" :last="last_page ()" :current="page" @page="goto_page" />
    </div>
</template>

<script>

/** @module plugins/cap-meta-search/cap-tab */

import * as tools from './tools.js';

const pageSize = 10;

/**
 * One tab of the search results.
 * @class Tab
 */
export default {
    'name'  : 'capMetaSearchTab',
    'props' : {
        'solrParams' : URLSearchParams, // extra SOLR query params
    },
    data () {
        return {
            'page'         : 1,
            'response'     : null,
            'highlighting' : null,
            'expanded'     : null,
        };
    },
    mounted () {
        this.goto_page (1);
    },
    /** @lends Tab */
    'methods' : {
        goto_page (n) {
            this.page = n;
            this.solr ((n - 1) * pageSize);
        },
        /**
         * Make a SOLR call.
         *
         * @param {integer} start The start offset
         */
        solr (start) {
            const vm = this;
            const queryParams = new URLSearchParams (window.location.search);
            const params = new URLSearchParams (vm.solrParams.toString ());
            params.set ('q', queryParams.get ('fulltext'));
            params.set ('start', start);
            console.log (`solr_query: ${params.toString ()}`);
            tools.api ('/solr/select.json', params).then ((response) => {
                vm.response = response.data.response || {};
                vm.highlighting = response.data.highlighting || {};
                vm.expanded = response.data.expanded || {};
                this.$emit ('numFound', vm.response.numFound ? vm.response.numFound : 0);
            });
        },
        last_page () {
            if (this.response && this.response.numFound) {
                return Math.ceil (this.response.numFound / pageSize);
            }
            return 0;
        },
    },
};

</script>

<style lang="scss">
/* main.vue */

div.cap-collation {
    h2 {
        @media print {
            display: none !important;
        }
    }

    h3 {
        margin-top: 1em;
        margin-bottom: 1em;
    }

    @media print {
        .no-print {
            display: none !important;
        }

        #wpcontent,
        #wpfooter {
            margin-left: 0;
        }

        html,
        body {
            background-color: white;
            font-size: 10pt;
        }
    }

    /* hide the 'Choose File' button */
    #load-config, #save-config {
        position: absolute;
        top: 0;
        visibility: hidden;
        z-index: -1;
    }

    .plus {
        &::before {
            content: '\f055'; /* fa-plus-circle */
        }
    }

    .spinner {
        &::before {
            content: '\f013'; /* fa-cog */
        }
    }
}
</style>
