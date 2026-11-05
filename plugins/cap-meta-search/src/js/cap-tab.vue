<template>
  <div v-if="response" class="tab-pane fade">
    <div v-if="response.numFound === 0" class="mt-3">
      <div class="alert alert-secondary" role="alert">
        {{ $t("No results found") }}
      </div>
    </div>
    <cap-pager class="my-3" :last="last_page()" :current="page" @page="goto_page" />
    <article v-for="doc of response.docs" :key="doc.id" class="search-results-excerpt my-3">
      <slot :doc="doc" :snippets="highlighting[doc.id]" :expanded="expanded[doc.ms_id]" />
    </article>
    <cap-pager class="my-3" :last="last_page()" :current="page" @page="goto_page" />
  </div>
  <div v-else class="text-center my-3">
    <div class="spinner-border text-primary" role="status">
      <span class="sr-only">{{ $t("Loading results") }}</span>
    </div>
  </div>
</template>

<script>
/** @module plugins/cap-meta-search/cap-tab */

import * as tools from "./tools.js";

const pageSize = 10;

/**
 * One tab of the search results.
 * @class Tab
 */
export default {
  name: "capMetaSearchTab",
  props: {
    solrParams: URLSearchParams, // extra SOLR query params
  },
  data() {
    return {
      page: 1,
      response: null,
      highlighting: null,
      expanded: null,
    };
  },
  mounted() {
    this.goto_page(1);
  },
  /** @lends Tab */
  methods: {
    goto_page(n) {
      this.page = n;
      this.response = null;
      this.solr((n - 1) * pageSize);
    },
    /**
     * Make a SOLR call.
     *
     * @param {integer} start The start offset
     */
    solr(start) {
      const vm = this;
      const params = new URLSearchParams(vm.solrParams.toString());
      params.set("start", start);
      console.log(`solr_query: ${decodeURIComponent(params.toString())}`);
      tools.api("/solr/select.json", params).then((response) => {
        vm.response = response.data.response || {};
        vm.highlighting = response.data.highlighting || {};
        vm.expanded = response.data.expanded || {};
        console.log(response.data);
        this.$emit("numFound", vm.response.numFound ? vm.response.numFound : 0);
      });
    },
    last_page() {
      if (this.response && this.response.numFound) {
        return Math.ceil(this.response.numFound / pageSize);
      }
      return 0;
    },
  },
};
</script>
