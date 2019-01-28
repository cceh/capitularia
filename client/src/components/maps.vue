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
        <div class="card-header text-white" :data-fcode="p.fcode">
          <h5 class="card-title">{{ p.title }}</h5>
          <h6 class="card-subtitle">{{ p.subtitle }}</h6>
        </div>
        <div class="table-wrapper mb-0">
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
            this.info_panels.pop ();
            this.info_panels.push (event.detail.data);
        },
        on_mss_tooltip_close (event) {
            this.info_panels.pop ();
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

div.info-panel {
	background: rgba(255,255,255,0.9);

    .card-header {
        opacity: 0.5;
        background: red;
        &[data-fcode^="PCL"] {
            background: blue;
        };
        &[data-fcode^="ADM"] {
            background: green;
        };
    }

    div.table-wrapper {
        max-height: 30em;
        overflow-y: auto;
        table.table {
	        background: transparent;
        }
    }
}


</style>
