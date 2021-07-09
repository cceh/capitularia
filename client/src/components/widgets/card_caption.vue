<template>
<div class="vm-card-caption card-header"
     @dragstart="on_dragstart">
  <div class="d-flex justify-content-between">
    <slot />
    <div>
      <template v-if="slidable">
        <button type="button" class="btn btn-sm" aria-label="Minimize" @click="minimize">
          <span class="fas fa-window-minimize"></span>
        </button>
        <button type="button" class="btn btn-sm" aria-label="Maximize" @click="maximize">
          <span class="fas fa-window-maximize"></span>
        </button>
      </template>
      <template v-if="closable">
        <button type="button" class="btn btn-sm" aria-label="Close" @click="close">
          <span class="fas fa-window-close"></span>
        </button>
      </template>
    </div>
  </div>
</div>
</template>

<script>
/**
 * The card caption with min/max/close buttons.
 *
 * @component card_caption
 * @author Marcello Perathoner
 */

export default {
    'props' : {
        'slidable' : {
            'type'    : Boolean,
            'default' : false,
        },
        'closable' : {
            'type'    : Boolean,
            'default' : true,
        },
    },
    'methods' : {
        minimize (event) {
            // tell the card what to do
            event.card_action = 'minimize';
        },
        maximize (event) {
            event.card_action = 'maximize';
        },
        close (event) {
            event.card_action = 'close';
        },
        on_dragstart (event) {
            // tell the card that this is a valid drag
            event.drag_handle = this;
        },
    },
};

</script>

<style lang="scss">
/* card_caption.vue */
@import "../../css/bootstrap-custom";

div.vm-card-caption {
    cursor: grab;

    h2 {
        font-size: 1rem;
        margin-bottom: 0;
    }

    button {
        padding: 0;
        margin-left: ($spacer * 0.25);
        font-size: 1rem;

        @media print {
            display: none;
        }
    }

    .fa-window-close:before {
        content: "\f410";
    }

    .fa-window-maximize:before {
        content: "\f2d0";
    }

    .fa-window-minimize:before {
        content: "\f2d1";
    }

    .fa-window-restore:before {
        content: "\f2d2";
    }
}
</style>
