<template>
  <nav class="toolbar-vm" @button-group-click="on_click">
    <div class="row justify-content-between">
      <slot></slot>
    </div>
  </nav>
</template>

<script>
/**
 * This module implements the toolbar that is on most of the cards.
 *
 * Most of the functionality here resides in widgets.  See the widgets
 * subdirectory.
 *
 * @component toolbar
 *
 * @author Marcello Perathoner
 */

import { Tooltip } from 'bootstrap';

export default {
    'props' : {
        'toolbar' : {
            'type'     : Object,
            'required' : true,
        },
    },
    'data' : function () {
        return {
        };
    },
    'methods' : {
        on_click (event) {
            this.toolbar[event.detail.data] ();
        },
    },
    mounted () {
        for (const el of this.$el.querySelectorAll ('[data-bs-toggle="tooltip"]')) {
            new Tooltip (el);
        }
    },
};
</script>

<style lang="scss">
/* widgets/toolbar.vue */
@import "../../css/bootstrap-custom";

div.btn-toolbar {
    margin-bottom: $spacer * -0.5;
    margin-right: $spacer * -0.5;

    div.btn-group, div.form-group {
        margin-right: $spacer * 0.5;
        margin-bottom: $spacer * 0.5;
    }

    div.dropdown-menu {
        border: 0;
        padding: 0;
        background: transparent;
        min-width: 20rem;

        div.btn-group {
            flex-wrap: wrap;
        }

        button.btn {
            min-width: 2rem;
        }
    }

    .btn-group > .btn.active {
        z-index: 0;
    }

    label.btn.active {
        @media print {
            color: black !important;
        }
    }
}

</style>
