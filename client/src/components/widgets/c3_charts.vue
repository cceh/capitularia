<template>
  <div class="vm-c3-charts"></div>
</template>

<script>
import _  from 'lodash';
import c3 from 'c3';

export default {
    props: {
        'options' : {
            required: true,
            type: Object,
        },
    },
    data () {
        return {
        }
    },
    watch: {
        'options' : {
            handler () {
                this.update ();
            },
            'deep' : true,
        }
    },
    methods: {
        update () {
            const vm = this;
            const opts = _.cloneDeep (vm.options);
            opts.bindto = vm.$el;
            vm.chart = c3.generate (opts);
        },
    },
    mounted () {
        this.update ();
    },
}
</script>

<style lang="scss">
/* c3_charts.vue */
@import "../../css/bootstrap-custom";

@import "c3/c3.css";

div.vm-c3-charts {
    margin-bottom: ($spacer * 0.5);
}

</style>
