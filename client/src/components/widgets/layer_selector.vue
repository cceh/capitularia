<template>
<div class="layer-selector-vm">
  <select class="form-select form-select-sm"
          data-bs-toggle="tooltip"
          data-bs-placement="bottom"
          :title="title"
          :value="value"
          @change="on_change ($event)">
    <option v-for="d in filtered_layers" :value="d.id" :title="d.long_title"
            :selected="d.id == value"
            >{{ d.title }}</option>
  </select>
</div>
</template>

<script>
/**
 * The layer selector.
 *
 * It triggers a 'layer_change' custom event with the selected layer as a
 * parameter.
 *
 * @component layer_selector
 * @author Marcello Perathoner
 */

export default {
    'props' : {
        'value' : {
            'type'     : String,
            'required' : true,
        },
        'layers' : {
            'type'     : Array,
            'required' : true,
        },
        'layer_type' : {
            'type'     : String,
            'required' : true,
        },
        'addnone' : {
            'type'    : Boolean,
            'default' : false,
        },
        'eventname' : {
            'type'    : String,
            'default' : 'layer_change',
        },
        'title' : {
            'type'    : String,
            'default' : 'Select a map layer.',
        },
    },
    'data' : function () {
        return {
            'layer' : 'none',
        };
    },
    'computed' : {
        filtered_layers () {
            return this.filter_layers (this.layers, this.layer_type, this.addnone)
        },
    },
    'methods' : {
        on_change (event) {
            const value = event.target.value;
            this.$trigger (this.eventname, value);
            this.$emit ('input', value);  // makes it work with v-model
        },
        filter_layers (layers, type, addnone) {
            const res = [];
            if (addnone) {
                res.push ({ 'id': 'none', 'title' : 'None', 'url' : null });
            }
            if (layers) {
                res.push (... layers.filter (d => d.type === type));
            }
            return res;
        },
    },
    mounted () {
    },
};
</script>

<style lang="scss">
/* date_range.vue */
@import "../../css/bootstrap-custom";

.layer-selector-vm {
    @media print {
        display: none;
    }
}
</style>
