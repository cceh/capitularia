<template>
    <div v-if="last > 1" class="cap-pager">
        <template v-for="[index, page_no, page] in pages" :key="index">
            <a v-if="page_no !== null" class="cap-pageno" @click="$emit('page', page_no)" href="#">{{ page }}</a>
            <span v-else class="cap-pageno">{{ page }}</span>
            &nbsp;
        </template>
    </div>
</template>

<script>

/** @module plugins/cap-meta-search/cap-pager */

const hellip = '…';

/**
 * A pager widget.
 * @class Pager
 */
export default {
    'computed' : {
        pages () {
            const vm = this;
            const p = [];
            const range = 2;
            p.push ([0, vm.current > 1 ? vm.current - 1 : null, vm.$t ('« Previous page')]);
            for (let i = 1; i <= vm.last; ++i) {
                if (i === vm.current) {
                    // always show the current page as plain text
                    p.push ([i, null, i]);
                    continue;
                }
                if (i === 1 || i === vm.last) {
                    // always show the first and last pages as links
                    p.push ([i, i, i]);
                    continue;
                }
                if (i >= vm.current - range && i <= vm.current + range) {
                    // show $range pages around the current page as links
                    p.push ([i, i, i]);
                    continue;
                }
                if (p[p.length - 1][2] !== hellip) {
                    // show gaps as ellipsis
                    p.push ([i, null, hellip]);
                }
            }
            p.push ([-1, vm.current < vm.last ? vm.current + 1 : null, vm.$t ('Next page »')]);
            return p;
        },
    },
    'props' : {
        'current' : {
            'type'      : Number,
            'default'   : 0,
            'required'  : true,
            'validator' : (value) => value >= 0,
        },
        'last' : {
            'type'      : Number,
            'default'   : 0,
            'required'  : true,
            'validator' : (value) => value >= 0,
        },
    },
};

</script>

<style lang="scss">
/* cap-pager.vue */

div.cap-pager span.cap-pageno {
    font-weight: 600;
}

</style>
