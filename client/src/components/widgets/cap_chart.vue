<template>
<svg class="vm-chart"
     :viewBox="`${viewbox.left}, ${viewbox.top}, ${viewbox.right - viewbox.left}, ${viewbox.bottom - viewbox.top}`">
  <g class="graph" />
</svg>
</template>

<script>
import * as d3 from 'd3';

export default {
    'props' : {
        // the inner height (the height of y-axis)
        // the whole widget will be adding margins + padding for the POI text
        'height' : {
            'required' : false,
            'type'     : Number,
            'default'  : 150,
        },
        'width' : {
            'required' : false,
            'type'     : Number,
            'default'  : 250,
        },
        'data' : Array,
    },
    data () {
        return {
            'viewbox' : {
                'left'   : 0,
                'right'  : 0,
                'top'    : 0,
                'bottom' : 0,
            },
            'padding' : { // padding around d3.area
                'left'   : 7,
                'right'  : 5,
                'top'    : 5,
                'bottom' : 5,
            },
        };
    },
    'watch' : {
        'data' : {
            handler () {
                this.update ();
            },
            'deep' : true,
        },
    },
    'methods' : {
        update () {
            const vm = this;
            if (vm.data === null) {
                return;
            }

            // the y-axis

            function label (d) {
                return `${d.x0}-${d.x1}`;
            }

            vm.g.selectAll ('g.axis').remove ();
            const y_domain = vm.data.map (d => label (d));

            const y = d3.scaleBand ()
                .domain (y_domain)
                .rangeRound ([-vm.height, 0])
                .padding (0.2);

            vm.g.append ('g')
                .classed ('axis axis-y', true)
                .attr ('transform', `translate(${-vm.padding.left}, 0)`)
                .call (d3.axisLeft (y));

            // the x-axis

            const x = d3.scaleLinear ()
                .domain ([0, d3.max (vm.data, d => d.length)])
                .range ([0, vm.width]);

            vm.g.append ('g')
                .classed ('axis axis-x', true)
                .attr ('transform', `translate(0, ${vm.padding.bottom})`)
                .call (d3.axisBottom (x));

            // the bars

            vm.g.selectAll ('rect.bar')
                .data (vm.data)
                .join ('rect')
                .classed ('bar', true)
                .attr ('x', x (0))
                .attr ('width', d => x (d.length) - x (0)) // data
                .attr ('y', (d, dummy_i) => y (label (d)))
                .attr ('height', y.bandwidth ());

            // the bar labels

            vm.g.selectAll ('text.value')
                .data (vm.data)
                .join ('text')
                .classed ('value', true)
                .classed ('short', d => x (d.length) - x (0) < 25)
                .attr ('x', d => x (d.length) - x (0))
                .attr ('y', (d, dummy_i) => y (label (d)) + (y.bandwidth () / 2))
                .attr ('dx', d => x (d.length) - x (0) < 25 ? '0.5em' : '-0.5em')
                .text (d => d.length);

            // adjust viewbox
            const bb  = vm.g.node ().getBBox ();
            const vb  = vm.viewbox;
            vb.top    =  bb.y - vm.padding.top;
            vb.right  =  bb.x + bb.width  + vm.padding.right;
            vb.left   =  bb.x;
            vb.bottom =  bb.y + bb.height;
        },
    },
    mounted () {
        const vm = this;
        vm.g = d3.select (vm.$el).select ('g.graph');
        vm.update ();
    },
};
</script>

<style lang="scss">
/* chart.vue */
@import "../../css/bootstrap-custom";

// @import "~/src/css/bootstrap-custom";

svg.vm-chart {
    g.tick {
        font-size: 8px;
    }
    rect.bar {
        fill: steelblue;
    }
    text.value {
        dx: -0.5em;
        fill: white;
        text-anchor: end;
        dominant-baseline: middle;
        &.short {
            dx: 0.5em;
            fill: black;
            text-anchor: start;
        }
    }
}

</style>
