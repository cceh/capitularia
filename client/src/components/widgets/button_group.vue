<template>
<div class="button-group-vm btn-group btn-group-toggle btn-group-sm"
     role="group"
     :options="options">

  <template v-for="button in buttons">
    <label v-if="type !== 'button'" :key="button.value"
           :class="'btn btn-primary btn-sm' + (is_active (button.value) ? ' active' : '')" :title="button.title">
      <span>{{ button.text }}</span>
      <input :type="type" :checked="is_active (button.value)"
             @change="on_change (button, $event)" />
    </label>
    <button v-if="type === 'button'" :key="button.value" :type="type" class="btn btn-primary" :title="button.title"
            @click="on_click (button, $event)">{{ button.text }}</button>
  </template>
</div>
</template>

<script>
/**
 * A radio or checkbox group.  NOT USED RIGHT NOW!
 *
 * @component button-group
 * @author Marcello Perathoner
 */

import _ from 'lodash';
import 'bootstrap';

export default {
    'props' : {
        'eventname' : {
            'type'    : String,
            'default' : 'button-group',
        },
        'type' : {
            'type'    : String,     // "button", "radio", or "checkbox"
            'default' : 'button',
        },
        'options' : {
            'type'     : Array,
            'required' : true,
        },
        'modelValue' : {
            'type'     : [String, Array],  // string for radio, array for checkbox
        },
    },
    'data' : function () {
        return {
            buttons : [],
        };
    },
    'computed' : {
    },
    'watch' : {
        modelValue (newVal, oldVal) {
            if (newVal !== oldVal || newVal !== this.modelValue) {
                this.$forceUpdate ();
            }
        }
    },
    'methods' : {
        on_click (data, event) {
            if (this.type === 'button') {
                this.$trigger ('button-group-click', data.value);
            }
        },
        on_change (data, event) {
            // we cannot directly modify modelValue because it is a prop

            if (this.type === 'radio') {
                this.$trigger (this.eventname, data.value);
                this.$emit ('update:modelValue', data.value);  // makes it work with v-model
            }
            if (this.type === 'checkbox') {
                let a = [];
                if (this.modelValue.includes (data.value)) {
                    a = _.without (this.modelValue, data.value);
                } else {
                    a = this.modelValue;
                    a.push (data.value);
                }
                this.$trigger (this.eventname, a);
                this.$emit ('update:modelValue', a);  // makes it work with v-model
            }
        },
        is_active (value) {
            if (this.type === 'checkbox') {
                return this.modelValue.includes (value);
            }
            return value === this.modelValue;
        },
    },
    mounted () {
        this.buttons = this.options;
    },
};
</script>

<style lang="scss">
/* button-group.vue */
@import "../../css/bootstrap-custom";

.button-group-vm {
    @media print {
        display: none;
    }

    /* make buttons the same height as inputs */
    align-items: stretch;
}
</style>
