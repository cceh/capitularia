<template>
  <div class="maps-vm"
       @mss-tooltip-open="on_mss_tooltip_open"
       @mss-tooltip-close="on_mss_tooltip_close">
    <toolbar :toolbar="toolbar">
      <form class="form-inline">
        <div class="form-group">
          <label class="mr-2" for="notbefore">From Year: </label>
          <b-form-input id="notbefore" v-model="toolbar.notbefore"
                        type="number"
                        placeholder="Not before this year"></b-form-input>
        </div>
        <div class="form-group">
          <label class="mr-2" for="notafter">To Year: </label>
          <b-form-input id="notafter"
                        v-model="toolbar.notafter"
                        type="number"
                        placeholder="Not after this year"></b-form-input>
        </div>
      </form>
    </toolbar>

    <slippy-map :toolbar="toolbar" />

    <div class="info-panels">
      <div v-for="p in info_panels" class="card info-panel">
        <div class="card-body">
          <h5 class="card-title">{{ p.title }}</h5>
        </div>
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Manuscript</th>
              <th>Part</th>
              <th>Created</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in p.rows">
              <td>{{ row.ms_id }}</td>
              <td>{{ row.ms_part }}</td>
              <td>{{ row.date_range }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * This module implements a map with some controls to query the database.
 *
 * @component maps
 * @author Marcello Perathoner
 */

import $   from 'jquery';
import _   from 'lodash';

import map        from 'map.vue';
import toolbar    from 'widgets/toolbar.vue';

/**
 * Transform a string so that numbers in the string sort naturally.
 *
 * Transform any contiguous run of digits so that it sorts
 * naturally during an alphabetical sort. Every run of digits gets
 * the length of the run prepended, eg. 123 => 3123, 123456 =>
 * 6123456.
 *
 * @function natural_sort
 *
 * @param {String} s - The input string
 *
 * @returns {String} The transformed string
 */

export function natural_sort (s) {
    return s.replace (/\d+/g, (match, dummy_offset, dummy_string) => match.length + match);
}

export default {
    'components' : {
        'toolbar'    : toolbar,
        'slippy-map' : map,
    },
    'data'  : function () {
        return {
            'toolbar' : {
                'notbefore' :  700,
                'notafter'  : 1500,

            },
            'info_panels' : [],
        };
    },
    'methods' : {
        on_mss_tooltip_open (event) {
            const data  = event.detail.data;
            const mss = data.properties.mss;
            const rows = [];

            for (const ms of _.sortBy (mss, o => { return natural_sort (o.properties.ms_id + o.properties.ms_part); })) {
                const props = ms.properties;
                rows.push ({
                    'ms_id'      : props.ms_id,
                    'ms_part'    : props.ms_part,
                    'date_range' : `${props.notbefore}-${props.notafter}`,
                });
            }
            const p = {
                'title' : data.properties.name,
                'rows' : rows,
            };
            this.info_panels.pop ();
            this.info_panels.push (p);
        },
        on_mss_tooltip_close (event) {
            // this.info_panels.pop ();
        },
    },
    'mounted' : function () {
        const vm = this;
    },
};
</script>

<style lang="scss">
/* maps.vue */
@import "bootstrap-custom";

#notbefore, #notafter {
    width: 5em;
}

div.info-pane-control {
    pointer-events: none;
}

div.info-panel {
	background: rgba(255,255,255,0.9);
    .card-body {
        padding-left: 0.3rem;
    }
    .card-title {
        margin-bottom: 0;
    }
}

</style>
