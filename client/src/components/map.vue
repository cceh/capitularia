<template>
    <div id="map">
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

import { mapGetters } from 'vuex'

import $        from 'jquery';
import * as d3  from 'd3';
import L        from 'leaflet';
import _        from 'lodash';

import '../../node_modules/leaflet/dist/leaflet.css';

const AREA_LAYERS = [
    {
        'layer'      : 'countries_843',
        'title'      : 'Countries - Anno 843',
        'class'      : 'countries countries-843',
        'datasource' : '/client/geodata/countries_843.geojson',
    },
    {
        'layer'      : 'regions_843',
        'title'      : 'Regions - Anno 843',
        'class'      : 'regions regions-843',
        'datasource' : '/client/geodata/regions_843.geojson',
    },
    {
        'layer'      : 'countries_870',
        'title'      : 'Countries - Anno 870',
        'class'      : 'countries countries-870',
        'datasource' : '/client/geodata/countries_870.geojson',
    },
    {
        'layer'      : 'countries_888',
        'title'      : 'Countries - Anno 888',
        'class'      : 'countries countries-888',
        'datasource' : '/client/geodata/countries_888.geojson',
    },
    {
        'layer'      : 'countries_modern',
        'title'      : 'Countries - Modern',
        'class'      : 'countries countries-modern',
        'datasource' : '/client/geodata/countries_modern.geojson',
    },
];

const PLACE_LAYERS = [
    {
        'layer'      : 'geonames',
        'title'      : 'Manuscripts',
        'class'      : 'places mss',
        'datasource' : 'geo/places/mss.json',
        'type'       : 'mss',
    },
    {
        'layer'      : 'geonames',
        'title'      : 'Manuscript Parts',
        'class'      : 'places msparts',
        'datasource' : 'geo/places/msparts.json',
        'type'       : 'msp',
    },
    {
        'layer'      : 'geonames',
        'title'      : 'Capitularies',
        'class'      : 'places capitularies',
        'datasource' : 'geo/places/capitularies.json',
        'type'       : 'cap',
    },
];

const RE_CAP = new RegExp ('^(\w+)[._](\d+)');

function add_centroids (feature_collection) {
    if (feature_collection.type == 'FeatureCollection') {
        for (const feature of feature_collection.features) {
            feature.properties.centroid = d3.geoCentroid (feature);
        }
    }
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
        L.GeoJSON.prototype.onRemove.call (this, map);
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
    onAdd (map) {
        L.D3_geoJSON.prototype.onAdd.call (this, map);
        this.update ();
    },
    update () {
        const layer = this;
        const opt = this.options;
        d3.json (opt.datasource).then (function (json) {
            layer.addData (json);
        });
    },
    d3_init (geojson) {
        const that = this;
        const vm = this.options.vm;

        const updated = this.g.selectAll ('path').data (geojson.features);
        this.features = updated.enter ()
            .append ('path')
            .attr ('data-fcode', d => d.properties.geo_fcode);

        this.features.on ('click', function (d) {
            d3.event.stopPropagation ();
            d.layer = that.options.layer;
            vm.$trigger ('mss-tooltip-open', d);
        });
    },
    d3_update (geojson) {
        this.features.attr ('d', this.transform_path);
    },
})

L.Layer_Places = L.D3_geoJSON.extend ({
    onAdd (map) {
        L.D3_geoJSON.prototype.onAdd.call (this, map);
        this.update ();
    },
    onRemove (map) {
        const t = d3.transition ()
            .duration (300)
            .ease (d3.easeLinear);
        const that = this;
        const g = this.g.selectAll ('g');
        g.transition (t).attr ('opacity', 0).end ().then (function () {
            L.D3_geoJSON.prototype.onRemove.call (that, map);
        });
    },
    update () {
        const layer = this;
        const opt = this.options;
        const vm = opt.vm;
        d3.json (opt.datasource + '?' + $.param (vm.xhr_params)).then (function (json) {
            layer.addData (json);
        });
    },
    d3_init (geojson) {
    },
    d3_update (geojson) {
        const that = this;
        const vm = this.options.vm;

        const t = d3.transition ()
            .duration (500)
            .ease (d3.easeLinear);

        const g = this.g.selectAll ('g').data (geojson.features, (d) => { return d.id; });

        g.exit ().transition (t).attr ('opacity', 0).remove ();

        const entered = g.enter ()
              .append ('g')
              .attr ('class', 'place')
              .attr ('opacity', 0);

        entered.append ('circle')
            .attr ('class', 'count')
            .attr ('data-fcode', d => d.properties.geo_fcode);

        entered.append ('text')
            .attr ('class', 'count');

        entered.append ('text')
            .attr ('class', 'name')
            .attr ('y', '16px')
            .text (function (d) {
                return d.properties.geo_name;
            });

        entered.on ('click', function (d) {
            d3.event.stopPropagation ();
            d.layer = that.options.layer;
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
    'computed' : {
        ... mapGetters ([
            'xhr_params',
            'type',
        ])
    },
    'watch' : {
        'xhr_params' : function () {
            this.update_map ();
        },
        'type' : function () {
            this.register_place_layers ();
        },
    },
    'methods' : {
        update_map () {
            const vm = this;
            vm.map.eachLayer (function (layer) {
                if (layer instanceof L.Layer_Places && vm.map.hasLayer (layer)) {
                    layer.update ();
                }
            });
        },
        register_place_layers () {
            const vm = this;
            vm.map.eachLayer (function (layer) {
                if (layer instanceof L.Layer_Places) {
                    layer.remove ();
                }
            });
            for (const opt of PLACE_LAYERS) {
                if (opt.type == this.type) {
                    const layer = new L.Layer_Places (null, {
                        'layer'               : opt.layer,
                        'class'               : opt.class,
                        'type'                : opt.type,
                        'datasource'          : vm.build_full_api_url (opt.datasource),
                        'vm'                  : vm,
                        'interactive'         : true,
                        'bubblingMouseEvents' : false,
                    });
                    layer.addTo (vm.map);
                }
            };
        },
        zoom_extent (json) {
            const vm = this;
            d3.json (vm.build_full_api_url ('geo/extent')).then (function (json) {
                const [[l, b], [r, t]] = d3.geoPath ().bounds (json);
                vm.map.fitBounds (L.latLngBounds (L.latLng (b, r), L.latLng (t, l)));
            });
        },
    },
    'mounted' : function () {
        const vm = this;

        const map = L.map ('map', {
            'renderer'    : L.svg (),
            'zoomControl' : false,
        });
        vm.map = map;

        const natural_earth = L.tileLayer (
            vm.build_full_api_url ('tile/ne/{z}/{x}/{y}.png'), {
                'attribution' : '&copy; <a href="http://www.naturalearthdata.com/">Natural Earth</a>'
            }).addTo (map);

        const lablache = L.tileLayer (
            vm.build_full_api_url ('tile/vl/{z}/{x}/{y}.png'), {
                'attribution' : 'Vidal-Lablache, Paul. Atlas général. Paris, 1898'
            });

        const shepherd = L.tileLayer (
            vm.build_full_api_url ('tile/sh/{z}/{x}/{y}.png'), {
                'attribution' : 'Shepherd, William. Historical Atlas. New York, 1911'
            });

        const openstreetmap = L.tileLayer (
            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                'attribution' : '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            });

        const baseLayers = {
            'Natural Earth' : natural_earth,
            'OpenStreetMap' : openstreetmap,
        };

        const overlays   = {
            'LaBlache - Empire de Charlemagne 843'  : lablache,
            'Shepherd - Carolingian Empire 843-888' : shepherd,
        };

        for (const opt of AREA_LAYERS) {
            const layer = new L.Layer_Borders (null, {
                'layer'      : opt.layer,
                'class'      : 'areas ' + opt.class,
                'datasource' : opt.datasource,
                'vm'         : vm,
            });
            overlays[opt.title] = layer;
        };

        L.control.layers (baseLayers, overlays, { 'collapsed' : true }).addTo (map);
        new L.Control.Info_Pane ({ position: 'topleft' }).addTo (map);

        this.is_zoomed = false;
        this.zoom_extent ();
        this.register_place_layers ();
        this.update_map ();
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
        &.countries-870 {
            z-index: 202;
        }
        &.countries-888 {
            z-index: 203;
        }
        &.countries-modern {
            z-index: 204;
        }
        &.regions {
            z-index: 300;
        }
        &.regions-843 {
            z-index: 301;
        }
        &.places.mss {
            z-index: 400;
        }
        &.places.msparts {
            z-index: 401;
        }
        &.places.capitularies {
            z-index: 402;
        }

        path {
            stroke-opacity: .7;
            stroke-width: 1.5px;
            fill: none;
            pointer-events: all;
        }

        &.areas {
            opacity: 0.5;
            path {
                stroke-width: 6px;
            }
        }

        &.countries {
            path {
                stroke: $country-color;
                &:hover {
                    fill: $country-color;
                }
            }
        }

        &.regions {
            path {
                stroke: $region-color;
                &:hover {
                    fill: $region-color;
                }
            }
        }

        circle.count {
            stroke: white;
            stroke-width: 1.5px;
            fill-opacity: 0.5;
            pointer-events: all;

            fill: $place-color;
            &[data-fcode^="PCL"] {
                fill: $country-color;
            };
            &[data-fcode^="ADM"] {
                fill: $region-color;
            };
            &:hover {
                fill-opacity: .7;
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

</style>
