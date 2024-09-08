<template>
  <div class="date-range-vm btn-group btn-group-sm" role="group" data-toggle="buttons">

    <label class="btn btn-primary d-flex align-items-center" :title="title"> <!-- moz needs align-center -->
      <slot></slot>
      <span class="date-range-label">{{ label }}</span>
      <input v-model="value" type="range" class="custom-range" min="700" max="1500"
             @change="on_change" />
      <datalist id="ticks" style="display: none;">
        <option value="700"  label="700" />
        <option value="800"  label="800" />
        <option value="900"  label="900" />
        <option value="1000" label="1000" />
        <option value="1100" label="1100" />
        <option value="1200" label="1200" />
        <option value="1300" label="1300" />
        <option value="1400" label="1400" />
        <option value="1500" label="1500" />
      </datalist>
    </label>
  </div>
</template>

<script>
/**
 * The date range slider.  NOT USED RIGHT NOW!
 *
 * It triggers a 'date_range' custom event with the selected date range as a
 * parameter.
 *
 * @component date_range
 * @author Marcello Perathoner
 */

import 'bootstrap';

export default {
    'props' : {
        'default' : { // the default reading
            'type'    : Number,
            'default' : 5,
        },
        'eventname' : {
            'type'    : String,
            'default' : 'date_range',
        },
        'title' : {
            'type'    : String,
            'default' : 'Select a date range.',
        },
    },
    'data' : function () {
        return {
            'value' : 1000,
        };
    },
    'computed' : {
        'label' : function () { return `${this.value}`; },
    },
    'methods' : {
        change (value) {
            this.$trigger (this.eventname, value);
            this.$emit ('update:modelValue', value);  // makes it work with v-model
        },
        on_change (event) {
            this.change (event.target.value);
        },
        on_submit () {
        },
    },
    mounted () {
    },
};
</script>

<style lang="scss">
/* date_range.vue */
@import "../../css/bootstrap-custom";

.date-range-vm {
    @media print {
        display: none;
    }

    /* make buttons the same height as inputs */
    align-items: stretch;

    label {
        margin-bottom: 0;

        span.date-range-label {
            display: inline-block;
            width: 1.5em;
            text-align: right;
        }
    }

    input[type="range"] {
        width: 12em;
        padding-left: ($spacer * 0.5);
        padding-right: ($spacer * 0.5);
    }
}
</style>
