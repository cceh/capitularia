<template>
<div class="search-your-search">{{ your_search }}</div>
<div class="search-results cap-meta-search-results">
    <div id="tabheader" class="nav nav-tabs">
        <div class="nav-item">
            <a class="nav-link" data-bs-toggle="tab" data-bs-target="#chapter-tab-pane"
                :class="getTabHeaderClass ('chapter')"
                aria-current="page">{{ $t ('Capitularies') }} ({{ getNumFound ('chapter') }})</a>
        </div>
        <div class="nav-item">
            <a class="nav-link" data-bs-toggle="tab"
                :class="getTabHeaderClass ('front')"
                data-bs-target="#front-tab-pane">{{ $t ('Mordek') }} ({{ getNumFound ('front') }})</a>
        </div>
        <div class="nav-item">
            <a class="nav-link" data-bs-toggle="tab"
                :class="getTabHeaderClass ('post')"
                data-bs-target="#post-tab-pane">{{ $t ('Website') }} ({{ getNumFound ('post') }})</a>
        </div>
    </div>
    <div class="tab-content">
        <cap-tab :solr-params="solr_params('chapter')" id="chapter-tab-pane" :class="getTabClass ('chapter')"
                v-slot="{ doc, snippets, expanded }" @numFound="(n) => setNumFound ('chapter', n)">
            <a class="excerpt-corresp" :href="mss_url + doc.ms_id + '#' + frag(doc)">{{ doc.cap_id }}
                c. {{ doc.chapter }}:</a>&nbsp;
            <span class="snippet" v-html="join_snippets(snippets)" />

            <div>
                <template v-for="ms_id of join_expanded_docs(doc, expanded)" :key="ms_id">
                    <a class="internal transcription small"
                        :href="mss_url + ms_id + '#' + frag(doc)">{{ ms_id }}</a>
                    <span>&nbsp; </span>
                </template>
            </div>
        </cap-tab>

        <cap-tab :solr-params="solr_params('front')" id="front-tab-pane" :class="getTabClass ('front')"
                v-slot="{ doc, snippets }" @numFound="(n) => setNumFound('front', n)">
            <header class="article-header excerpt-header search-excerpt-header">
                <a :href="mss_url + doc.ms_id">
                    {{ doc.title_de }}
                </a>
            </header>
            <div class="excerpt">
                <span class="snippet" v-html="join_snippets(snippets)" />
            </div>
        </cap-tab>

        <cap-tab :solr-params="solr_params('post')" id="post-tab-pane" :class="getTabClass ('post')"
                v-slot="{ doc, snippets }" @numFound="(n) => setNumFound('post', n)">
            <header class="article-header excerpt-header search-excerpt-header">
                <a :href="post_url + doc.post_id">
                    {{ doc.title_de }}
                </a>
            </header>
            <div class="excerpt">
                <span class="snippet" v-html="join_snippets(snippets)" />
            </div>
        </cap-tab>
    </div>
</div>
</template>

<script>

/** @module plugins/cap-meta-search/main */

import _ from 'lodash';

import * as tools from './tools.js';

/**
 * Queries the SOLR server and manages the tabs.
 * @class Main
 */
export default {
    'name' : 'capMetaSearchMain',
    data () {
        return {
            'q'    : null,
            'tabs' : {
                'chapter' : { 'numFound' : 0 },
                'front'   : { 'numFound' : 0 },
                'post'    : { 'numFound' : 0 },
            },
        };
    },
    created () {
        this.filter_group_docs = tools.filter_group_docs;
        this.mss_url = '/mss/';
        this.post_url = '/?page_id=';
        this.frag  = (doc) => `${doc.cap_id}_${doc.chapter}`.replace ('.', '_');
        this.join_snippets = (doc) => {
            for (const field of ['text_la', 'text_de', 'text_en', 'text_la_ngrams']) {
                if (doc[field]) {
                    return doc[field].join (' [&hellip;] ');
                }
            }
            return '';
        };
        this.join_expanded_docs = (doc, expanded) => {
            if (expanded) {
                const ids = new Set (expanded.docs.map ((d) => d.ms_id));
                ids.add (doc.ms_id);
                return _.sortBy (Array.from (ids.keys ()), tools.sort_key);
            }
            return [doc.ms_id];
        };
    },
    mounted () {
        tools.update_bs_tabs ();
    },
    /** @lends Main */
    'methods' : {
        solr_params (category) {
            const params = new URLSearchParams ();
            // Note the 'fq' form is a hack to get multiple params with the same name
            // past the brain-damaged PHP
            params.set ('fq', `category:${category}`);
            if (category === 'chapter') {
                params.set ('qf', 'text_la^2 text_de text_en text_la_ngrams');
                params.append ('fq', '{!collapse field=cap_id_chapter}');
                // NOSONAR
                // p.set ('sort', 'strnumsort(cap_id_chapter) asc');
                params.set ('expand', 'true');

                const queryParams = new URLSearchParams (window.location.search);
                const capit = queryParams.get ('capit');
                if (capit && capit !== '') {
                    params.append ('fq', `cap_id:${capit}`);
                }
                const notbefore = queryParams.get ('notbefore');
                if (notbefore && notbefore !== '') {
                    params.append ('fq', `notbefore:[${notbefore} TO *]`);
                }
                const notafter  = queryParams.get ('notafter');
                if (notafter && notafter !== '') {
                    params.append ('fq', `notafter:[* TO ${notafter}]`);
                }
                const places = queryParams.getAll ('places[]');
                if (places && places.length > 0) {
                    params.append ('fq', `places:(${places.join (' OR ')})`);
                }
            }
            return params;
        },
        setNumFound (name, n) {
            this.tabs[name].numFound = n;
        },
        getNumFound (name) {
            return this.tabs[name].numFound;
        },
        getTabHeaderClass (name) {
            const c = [];
            for (const n of ['chapter', 'front', 'post']) {
                if (this.getNumFound (n) > 0) {
                    if (n === name) {
                        c.push ('active');
                    }
                    break; // only the first tab can be active
                }
            }
            if (this.getNumFound (name) === 0) {
                c.push ('disabled');
            }
            return c.join (' ');
        },
        getTabClass (name) {
            for (const n of ['chapter', 'front', 'post']) {
                if (this.getNumFound (n) > 0) {
                    if (n === name) {
                        return 'active show';
                    }
                    return null;
                }
            }
            return null;
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
