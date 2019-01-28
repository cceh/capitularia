<template>
    <div id="map"
       @mss-tooltip-open="on_mss_tooltip_open">
    </div>
</template>

<script>
/**
 * This module displays a tiled map with overlays.
 *
 * @component map
 * @author Marcello Perathoner
 *
 * GeoJSON specs: https://tools.ietf.org/html/rfc7946
 *
 * Geonames: FCODE http://www.geonames.org/export/codes.html
 *
 * Georeferenced Maps: http://www.naturalearthdata.com/
 *
 * Atlas General Vidal de la Blache as PDF with exportable maps:
 * http://bibliotheque-virtuelle.clermont-universite.fr/item/BCU_Atlas_general_Vidal_Lablache_1898
 */

import $        from 'jquery';
import * as d3  from 'd3';
import L        from 'leaflet';
import _        from 'lodash';

import '../../node_modules/leaflet/dist/leaflet.css';

/**
 * Transform a string so that numbers in the string sort naturally.
 *
 * Transform any contiguous run of digits so that it sorts
 * naturally during an alphabetical sort. Every run of digits gets
 * the length of the run prepended, eg. 123 => 3123, 123456 =>
 * 6123456.
 *
 * @function natural_sort
 *
 * @param {String} s - The input string
 *
 * @returns {String} The transformed string
 */

export function natural_sort (s) {
    return s.replace (/\d+/g, (match, dummy_offset, dummy_string) => match.length + match);
}

function fcode (d) {
    return d.properties.fcode || d.properties.featurecla.replace ('Admin-0 country', 'PCLI');
}

// A Leaflet layer that uses D3 to display features.  Easily styleable with CSS.

L.D3_geoJSON = L.GeoJSON.extend ({
    onAdd (map) {
        L.GeoJSON.prototype.onAdd.call (this, map);
        this.map = map;

        this.svg = d3.select (this.getPane ())
              .append ('svg')
              .classed ('d3', true)
              .classed (this.options.class, true);

        this.g = this.svg.append ('g').classed ('leaflet-zoom-hide', true);

        function projectPoint (x, y) {
            const point = map.latLngToLayerPoint (new L.LatLng (y, x));
            this.stream.point (point.x, point.y);
        }

        const transform = d3.geoTransform ({ 'point' : projectPoint });
        this.transform_path = d3.geoPath ().projection (transform);

        this.view_init ();
        this.view_update ();

        map.on ('viewreset zoom', this.view_update, this);
        map.on ('zoomend',        this.zoom_end, this);
    },
    onRemove (map) {
        map.off ('viewreset zoom', this.view_update);
        map.off ('zoomend',        this.zoom_end);
        this.svg.remove ();
        this.svg = null;
        this.g   = null;
        this.map = null;
    },
    addData (geojson) {
        this.geojson = geojson;
        this.view_init ();
        this.view_update ();
    },
    getBounds () {
        const [[l, b], [r, t]] = d3.geoPath ().bounds (this.geojson);
        return L.latLngBounds (L.latLng (b, r), L.latLng (t, l));
    },
    view_init () {
        if (this.geojson && this.svg) {
            this.d3_init (this.geojson);
        }
    },
    view_update () {
        if (this.geojson && this.svg) {
            this.d3_update (this.geojson);
        }
    },
    zoom_end (event) {
        if (this.svg) {
            this.svg.attr ('data-zoom', 'Z'.repeat (event.target._zoom));
        }
    },
});

L.Layer_Borders = L.D3_geoJSON.extend ({
    d3_init (geojson) {
        const vm = this.options.vm;

        const updated = this.g.selectAll ('path').data (geojson.features);
        this.features = updated.enter ()
            .append ('path')
            .attr ('data-fcode', fcode);

        this.features.on ('click', function (d) {
            d3.event.stopPropagation ();
            vm.$trigger ('mss-tooltip-open', d);
        });
    },
    d3_update (geojson) {
        this.features.attr ('d', this.transform_path);
    },
})

L.Layer_Places = L.D3_geoJSON.extend ({
    d3_init (geojson) {
    },
    d3_update (geojson) {
        const that = this;
        const vm = this.options.vm;

        const t = d3.transition()
            .duration (500)
            .ease (d3.easeLinear);

        const g = this.g.selectAll ('g').data (geojson.features, (d) => { return d.properties.geo_id; });

        g.exit ().transition (t).attr ('opacity', 0).remove ();

        const entered = g.enter ()
              .append ('g')
              .attr ('class', 'place')
              .attr ('opacity', 0);

        entered.append ('circle')
            .attr ('class', 'count')
            .attr ('data-fcode', fcode);

        entered.append ('text')
            .attr ('class', 'count');

        entered.append ('text')
            .attr ('class', 'name')
            .attr ('y', '16px')
            .text (function (d) {
                return d.properties.name;
            });

        entered.on ('click', function (d) {
            d3.event.stopPropagation ();
            vm.$trigger ('mss-tooltip-open', d);
        });

        entered.merge (g).attr ('transform', (d) => {
            const [x, y] = d.geometry.coordinates;
            const point = this.map.latLngToLayerPoint (new L.LatLng (y, x));
            return `translate(${point.x},${point.y})`;
        }).each (function (d) {
            const g = d3.select (this);
            g.selectAll ('circle.count').transition (t).attr ('r', 10 * Math.sqrt (d.properties.count));
            g.selectAll ('text.count').text (d.properties.count);
        });

        entered.transition (t).attr ('opacity', 1);
    },
})

L.Control.Info_Pane = L.Control.extend ({
    onAdd (map) {
	    this._div = L.DomUtil.create ('div', 'info-pane-control');
        L.DomEvent.disableClickPropagation (this._div);
        L.DomEvent.disableScrollPropagation (this._div);
	    $ (this._div).append ($ ('div.info-panels'));
	    // this._div.innerHTML = '<h4>hello, world</h4>';
	    return this._div;
    },

    onRemove (map) {
	},
});

export default {
    'props' : {
        'toolbar' : {
            'type'     : Object,
            'required' : true,
        },
    },
    'data'  : function () {
        return {
            'geo_data' : null,
            'parts_data' : null,
        };
    },
    'watch' : {
        'toolbar' : {
            handler () {
                this.update_map ();
            },
            'deep' : true,
        },
    },
    'methods' : {
        date_filter (features, tb) {
            // filter by date range
            return _.filter (
                features,
                function (o) {
                    const p = o.properties;
                    return (p.notbefore < tb.notafter) && (tb.notbefore < p.notafter);
                }
            );
        },
        geo_filter (features, polygon) {
            // include only features located inside polygon
            return _.filter (
                features,
                function (o) {
                    return d3.geoContains (polygon, o.geometry.coordinates);
                }
            );
        },
        on_mss_tooltip_open (event) {
            event.stopPropagation ();

            const data  = event.detail.data;
            let mss = null;

            if (data.geometry.type === 'Point') {
                // get manuscripts from data
                mss = data.properties.mss;
            } else {
                // get manuscripts inside polygon
                mss = this.date_filter (this.parts_data.features, this.toolbar);
                mss = this.geo_filter (mss, data);
            }

            const rows = [];
            for (const ms of _.sortBy (mss, o => { return natural_sort (o.properties.ms_id + o.properties.ms_part); })) {
                const props = ms.properties;
                rows.push ({
                    'ms_id'      : props.ms_id,
                    'ms_part'    : props.ms_part,
                    'date_range' : `${props.notbefore}-${props.notafter}`,
                });
            }
            const p = {
                'title'    : `${data.properties.name || data.properties.NAME}`,
                'subtitle' : `${fcode (data)} - ${rows.length} mss.`,
                'fcode'    : fcode (data),
                'rows'  : rows,
            };
            this.$parent.$trigger ("mss-tooltip-open", p);
        },
        update_map () {
            // filter by date range
            let ms_parts = this.date_filter (this.parts_data.features, this.toolbar);

            // group by place
            ms_parts = _.groupBy (
                ms_parts,
                function (o) { return o.properties.geo_id; }
            );
            // join with geo data
            ms_parts = _.map (Object.entries (ms_parts), (o) => {
                const [geo_id, grouped] = o;
                const g = this.geo_data[geo_id];
                return {
                    'geometry' : g.geometry,
                    'properties' : {
                        'geo_id' : geo_id,
                        'name'   : g.properties.name,
                        'fcode'  : fcode (g),
                        'count'  : grouped.length,
                        'mss'    : grouped,
                    },
                    'type' : 'Feature'
                };
            });
            this.layer_mss.addData ({ 'type' : 'FeatureCollection', 'features' : ms_parts });
        },
    },
    'mounted' : function () {
        const vm = this;

        const map = L.map ('map', {
            'renderer'    : L.svg (),
            'zoomControl' : false,
        });

        const natural_earth = L.tileLayer (
            vm.build_full_api_url ('tile/ne/{z}/{x}/{y}.png'), {
                'attribution' : '&copy; <a href="http://www.naturalearthdata.com/">Natural Earth</a>'
            }).addTo (map);

        const vidal_lablache = L.tileLayer (
            vm.build_full_api_url ('tile/vl/{z}/{x}/{y}.png'), {
                'attribution' : 'Atlas VIDAL-LABLACHE - Anno 843'
            });

        const openstreetmap = L.tileLayer (
            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                'attribution' : '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            });

        const layer_countries = new L.Layer_Borders (null, {
            'class' : 'countries countries-modern',
            'vm'    : vm,
        });

        const layer_countries_843 = new L.Layer_Borders (null, {
            'class' : 'countries countries-843',
            'vm'    : vm,
        });

        const layer_mss = new L.Layer_Places (null, {
            'class' : 'mss',
            'vm'    : vm,
        }).addTo (map);

        this.layer_mss = layer_mss;

        const baseLayers = {
            'Natural Earth' : natural_earth,
            'OpenStreetMap' : openstreetmap,
        };
        const overlays   = {
            'Atlas Vidal de la Blache - Anno 843' : vidal_lablache,
            'Manuscripts'          : layer_mss,
            'Countries - Modern'   : layer_countries,
            'Countries - Anno 843' : layer_countries_843,
        };
        L.control.layers (baseLayers, overlays).addTo (map);
        new L.Control.Info_Pane ({ position: 'bottomleft' }).addTo (map);

        const xhr_countries     = d3.json ('/client/geodata/10m_cultural/ne_10m_admin_0_countries.json');
        const xhr_countries_843 = d3.json ('/client/geodata/countries-843.geojson');
        const xhr_places    = d3.json (vm.build_full_api_url ('places.json'));
        const xhr_parts     = d3.json (vm.build_full_api_url ('msparts.json'));

        Promise.all ([xhr_countries, xhr_countries_843, xhr_places, xhr_parts]).then ((responses) => {
            const [data_countries, data_countries_843, data_places, data_parts] = responses;

            layer_countries.addData (data_countries);
            layer_countries_843.addData (data_countries_843);

            this.geo_data = Object ();
            for (const o of data_places.features) {
                this.geo_data[o.properties.geo_id] = o;
            };

            this.parts_data = data_parts;

            const [[l, b], [r, t]] = d3.geoPath ().bounds (data_places);
            map.fitBounds (L.latLngBounds (L.latLng (b, r), L.latLng (t, l)));

            this.update_map ();
        });

        d3.select (vm.$el).on ('click', function () {
            vm.$trigger ('mss-tooltip-close');
        });

    },
};
</script>

<style lang="scss">
/* map.vue */
@import "bootstrap-custom";

#map {
    width: 100%;
    height: 960px;
}

.leaflet-control-layers-toggle {
	background-image: url(/client/images/layers.png);
}

.leaflet-retina .leaflet-control-layers-toggle {
	background-image: url(/client/images/layers-2x.png);
}

svg {
    &.d3 {
        overflow: visible;
        pointer-events: none;

        &.countries {
            z-index: 200;
        }
        &.countries-843 {
            z-index: 201;
        }
        &.mss {
            z-index: 300;
        }

        path {
            stroke-opacity: .7;
            stroke-width: 1.5px;
            fill: transparent;
            pointer-events: all;
        }

        &.countries {
            path {
                stroke: white;
                &:hover {
                    fill-opacity: .7;
                    fill: red;
                    &[data-fcode^="PCL"] {
                        fill: blue;
                    };
                    &[data-fcode^="ADM"] {
                        fill: green;
                    };
                }
            }
        }

        circle.count {
            stroke: white;
            stroke-width: 1.5px;
            fill: red;
            fill-opacity: 0.5;
            pointer-events: all;
            &:hover {
                fill: red;
                fill-opacity: .7;
            };
            &[data-fcode^="PCL"] {
                fill: blue;
            };
            &[data-fcode^="ADM"] {
                fill: green;
            };
        }

        text {
            pointer-events: none;
            dominant-baseline: middle;
            text-anchor: middle;
            &.count {
                font: bold 16px sans-serif;
                fill: black;
                text-shadow: 1px 1px 0 white, 1px -1px 0 white, -1px 1px 0 white, -1px -1px 0 white;
            }
            &.name {
                x: 0;
                y: 24px;
                font: bold 12px sans-serif;
                fill: black;
                text-shadow: 1px 1px 0 white, 1px -1px 0 white, -1px 1px 0 white, -1px -1px 0 white;
            }
        }

        image {
            x: -16px;
            y: -16px;
        }
    }
}

svg.countries[data-zoom^="ZZZZZZZZ"] {
    path {
        stroke-width: 3px;
    }
}

</style>
