<template>
  <div class="search-your-search">{{ your_search() }}</div>
  <div class="search-results cap-meta-search-results">
    <div id="tabheader" class="nav nav-tabs">
      <div class="nav-item">
        <a
          class="nav-link"
          data-bs-toggle="tab"
          :class="activeTab === 'ms' ? 'active' : ''"
          data-bs-target="#ms-tab-pane"
          data-tabname="ms"
          >{{ $t("Transcriptions") }} ({{ getNumFound("ms") }})</a
        >
      </div>
      <div class="nav-item">
        <a
          class="nav-link"
          data-bs-toggle="tab"
          :class="activeTab === 'post' ? 'active' : ''"
          data-bs-target="#post-tab-pane"
          data-tabname="post"
          >{{ $t("Website") }} ({{ getNumFound("post") }})</a
        >
      </div>
    </div>
    <div class="tab-content">
      <div class="d-flex justify-content-end">
        <div class="form-check form-switch mt-2" v-if="activeTab === 'ms'">
          <input class="form-check-input" type="checkbox" id="fuzzyToggle" v-model="msFuzzySearch" />
          <label class="form-check-label" for="fuzzyToggle">
            {{ $t("Fuzzy Search") }}
          </label>
        </div>
      </div>

      <cap-tab
        v-show="activeTab === 'ms'"
        :solr-params="solr_params('ms')"
        id="ms-tab-pane"
        :class="activeTab === 'ms' ? 'active show' : 'hidden'"
        v-slot="{ doc, snippets, expanded }"
        @numFound="(n) => setNumFound('ms', n)"
        :key="msFuzzySearch /* update tab on fuzzy toggle */"
      >
        <a class="excerpt-corresp" :href="mss_url + doc.ms_id">{{ doc.title_de }}</a>
        <div>
          <a :href="mss_url + doc.ms_id + '#' + frag(doc)" style="font-size: 12px; margin-right: 4px">{{
            fragTxt(doc)
          }}</a>
          <span class="snippet" v-html="join_snippets(snippets)" />
        </div>
        <div v-if="expanded && expanded.docs" v-for="doc in expanded.docs">
          <a :href="mss_url + doc.ms_id + '#' + frag(doc)" style="font-size: 12px; margin-right: 4px">{{
            fragTxt(doc)
          }}</a>
          <span class="snippet" style="font-size: 10px; color: gray">
            {{ doc.text_la ? (doc.text_la.length > 50 ? doc.text_la.substring(0, 50) + "..." : doc.text_la) : "" }}
          </span>
        </div>
        <hr style="margin: 8px 0" />
      </cap-tab>

      <cap-tab
        v-show="activeTab === 'post'"
        :solr-params="solr_params('post')"
        id="post-tab-pane"
        :class="activeTab === 'post' ? 'active show' : 'hidden'"
        v-slot="{ doc, snippets }"
        @numFound="(n) => setNumFound('post', n)"
      >
        <header class="article-header excerpt-header search-excerpt-header">
          <a :href="post_url + doc.post_id" v-html="snippets?.title_de?.[0] || doc.title_de" />
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

import _ from "lodash";
import { sprintf } from "sprintf-js";

import * as tools from "./tools.js";

/**
 * Queries the SOLR server and manages the tabs.
 * @class Main
 */
export default {
  name: "capMetaSearchMain",
  data() {
    return {
      q: null,
      tabs: {
        ms: { numFound: 0 },
        post: { numFound: 0 },
      },
      msFuzzySearch: true,
      activeTab: "ms",
    };
  },
  created() {
    this.filter_group_docs = tools.filter_group_docs;
    this.mss_url = "/mss/";
    this.post_url = "/?page_id=";
    this.frag = (doc) => `${doc.cap_id}_${doc.chapter}`.replace(".", "_");
    this.fragTxt = (doc) => `${doc.cap_id}`.replace(".", " ") + ` c.${doc.chapter}`;
    this.join_snippets = (doc) => {
      for (const field of ["text_la", "text_de", "text_en", "text_la_ngrams"]) {
        if (doc[field]) {
          return doc[field].join(" [&hellip;] ");
        }
      }
      return "";
    };
    // this.join_expanded_docs = (doc, expanded) => {
    //   if (expanded) {
    //     const ids = new Set(expanded.docs.map((d) => d.ms_id));
    //     ids.add(doc.ms_id);
    //     return _.sortBy(Array.from(ids.keys()), tools.sort_key);
    //   }
    //   return [doc.ms_id];
    // };

    // Pick activeTab based on results
    if (this.getNumFound("post") > 0 && this.getNumFound("ms") <= 0) {
      this.activeTab = "post";
    } else {
      this.activeTab = "ms";
    }
  },
  mounted() {
    tools.update_bs_tabs();

    // Watch for tab changes, hide sidebar if activeTab is 'post'
    const sidebar = document.querySelector("nav.cap-right-col-push.sidebar-col");
    this.$watch("activeTab", (newTab) => {
      if (sidebar) {
        sidebar.style.display = newTab === "post" ? "none" : "";
      }
    });
    // Initial check
    if (sidebar) {
      sidebar.style.display = this.activeTab === "post" ? "none" : "";
    }

    // Listen on all tab links directly
    document.querySelectorAll('[data-bs-toggle="tab"]').forEach((tab) => {
      tab.addEventListener("shown.bs.tab", (event) => {
        this.activeTab = event.target.dataset.tabname;
      });
    });
  },
  /** @lends Main */
  methods: {
    solr_params(category) {
      const queryParams = new URLSearchParams(window.location.search);
      const params = new URLSearchParams();
      const q = queryParams.get("s");
      // Note the 'fq' form is a hack to get multiple params with the same name
      // past the brain-damaged PHP
      if (category == "ms") {
        // Remove this Block in Order to get full, Capit-based list (with all highlighting)
        // instead of list collapsed my MS (with only highlighting for highest ranked match)
        params.append("fq", "{!collapse field=ms_id}");
        params.set("sort", "strnumsort(ms_id) asc");
        params.set("expand", "true");

        category = "chapter";
        if (this.msFuzzySearch) {
          params.set("qf", "text_la^2 text_la_ngrams");
        } else {
          params.set("qf", "text_la"); // No ngrams, no boost
        }

        // Detail Search Params
        const capit = queryParams.get("capit");
        if (capit && capit !== "") {
          params.append("fq", `cap_id:${capit}`);
        }
        const notbefore = queryParams.get("notbefore");
        if (notbefore && notbefore !== "") {
          params.append("fq", `notbefore:[${notbefore} TO *]`);
        }
        const notafter = queryParams.get("notafter");
        if (notafter && notafter !== "") {
          params.append("fq", `notafter:[* TO ${notafter}]`);
        }
        const places = queryParams.getAll("places[]");
        if (places && places.length > 0) {
          params.append("fq", `places:(${places.join(" OR ")})`);
        }
      } else if (category === "post") {
        params.set("qf", "title_de^10 title_en^10 text_de text_en");
        params.set("fq", "category:post");
        params.set("expand", "false");
      }

      params.append("fq", `category:${category}`);
      params.set("q", q || "*:*");

      return params;
    },
    your_search() {
      const queryParams = new URLSearchParams(window.location.search);
      const templates = {
        s: "%s",
        capit: this.$t("in %s"),
        notbefore: this.$t("after %s"),
        notafter: this.$t("before %s"),
        "placenames[]": this.$t("origin in %s"),
      };
      const your_search = [];

      for (const [key, template] of Object.entries(templates)) {
        const value = (queryParams.getAll(key) || []).join(", ");
        if (value) your_search.push(sprintf(template, _.escape(value)));
      }
      return sprintf(this.$t('Your search for "%s" gave following results: '), your_search.join(" · "));
    },
    setNumFound(name, n) {
      this.tabs[name].numFound = n;
    },
    getNumFound(name) {
      return this.tabs[name].numFound;
    },
  },
};
</script>

<style lang="scss">
/* main.vue */

.nav-link {
  cursor: pointer;
}

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
  #load-config,
  #save-config {
    position: absolute;
    top: 0;
    visibility: hidden;
    z-index: -1;
  }

  .plus {
    &::before {
      content: "\f055"; /* fa-plus-circle */
    }
  }

  .spinner {
    &::before {
      content: "\f013"; /* fa-cog */
    }
  }
}
</style>
