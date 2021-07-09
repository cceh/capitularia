<template>
  <div class="vm-card card"
     @click="on_click"
     @dragstart="on_dragstart"
     @mousemove="on_mousemove"
     @mouseup="on_mouseup"
     @mouseleave="on_mouseleave"
     >
    <slot />
  </div>
</template>

<script>
/**
 * This module is the base for a card.
 *
 * The card may position itself relatively to a target element.
 * The card may be draggable.
 *
 * @component client/widgets/card
 * @author Marcello Perathoner
 */

import $ from 'jquery';

import { createPopper } from '@popperjs/core';

export default {
    'props' : {
        'card_id'         : Number,
        'position_target' : Element,
        'start_closed'    : {
            'type'    : Boolean,
            'default' : false,
        },
    },
    'data' : function () {
        return {
            'visible'  : true,
            'dragging' : null,
        };
    },
    'methods' : {
        /**
         * Position the card relative to target.
         *
         * Target usually is the element that the user clicked to create the popup.
         *
         * @param {DOM} target - A DOM element relative to which to position the popup.
         */

        position (target) {
            /* eslint-disable-next-line no-new */
            createPopper (target, this.$el, {
                'placement'     : 'left-start',
                'positionFixed' : true,
                'eventsEnabled' : false,
                'modifiers'     : [
                    {
                        'name'    : 'offset',
                        'options' : {
                            'offset' : [0, 10],
                        }
                    },
                    {
                        'name' : 'flip',
                        'options' : {
                            'fallbackPlacements' : ['left', 'right', 'top'],
                        },
                    },
                    {
                        'name' : 'preventOverflow',
                    },
                ],
            });
        },

        on_click (event) {
            const vm = this;
            if (event.card_action) {
                // was clicked on any caption button
                const $el = $ (vm.$el);
                if (event.card_action == 'minimize') {
                    $el.find ('.card-slide').slideUp (() => {
                        vm.visible = false;
                    });
                }
                if (event.card_action == 'maximize') {
                    vm.visible = true;
                    $el.find ('.card-slide').slideDown ();
                }
                if (event.card_action == 'close') {
                    $el.fadeOut (() => {
                        vm.$trigger ('destroy-card', vm.card_id);
                    });
                }
            }
        },

        /*
         * Allow moving the card around by dragging it.
         */

        on_dragstart (event) {
            // We use the html5 drag protocol only to detect a drag start.
            // After that we only listen to mouse events.  This approach does
            // not capture the mouse, so it `loses´ the drag if dragged too
            // fast, but is very simple.  The card caption has draggable="true"
            // set, catches the dragstart event and adds a token.  Then the
            // event bubbles up here.
            //
            // Notes: the drag events of html5 drag and drop protocol
            // (especially the last one before dragend) sometimes contain bogus
            // coordinates that make the card jump.  Mouse capture is
            // deprecated.  The pointer capture protocol allows to drag the card
            // completely offscreen.

            if (!event.drag_handle) {
                // No token.  Something else (not the caption) was dragged, maybe a <p>
                // or a link.  Do not interfere.
                return;
            }

            // abort the drag
            event.preventDefault ();

            const vm = this;

            // get the offset of the mouse pointer into the dragged card
            // (popperjs uses 'transform: translate' to position the element)
            const m = [... this.$el.style.transform.matchAll (/(-?\d+)px/g)];
            let left = 0,
                top = 0;
            if (m.length) {
                left = parseInt (m[0][1], 10);
                top  = parseInt (m[1][1], 10);
            }

            this.dragging = {
                'x' : event.clientX - left,
                'y' : event.clientY - top,
            };

            // console.log ('dragstart');
        },

        move (event, data) {
            const style = this.$el.style;
            style.transform = `translate(${event.clientX - data.x}px, ${event.clientY - data.y}px)`;
            // console.log (style.transform);
        },

        end_drag (event) {
            // console.log (event.x, event.y);
            if (this.dragging) {
                this.move (event, this.dragging);
            }
            this.dragging = null;
        },

        on_mousemove (event) {
            if (this.dragging) {
                this.move (event, this.dragging);
            }
        },

        on_mouseup (event) {
            // console.log ('mouseup');
            this.end_drag (event);
        },

        on_mouseleave (event) {
            // happens if the mouse moved too fast for the renderer to keep up
            // console.log ('mouseleave');
            this.end_drag (event);
        },
    },
    mounted () {
        const vm = this;

        if (vm.start_closed) {
            for (const el of vm.$el.querySelectorAll ('.card-slide')) {
                el.style.height = 0;
            }
        }

        // position floating card relative to target
        if (vm.position_target) {
            vm.position (vm.position_target);
        }
    },
};
</script>

<style lang="scss">
/* widgets/card.vue */

.vm-card {
    .card-slide {
        overflow: hidden;
    }
}

</style>
