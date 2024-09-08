<template>
  <div id="map" />
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

import { mapGetters } from 'vuex';

import jQuery   from 'jquery';
import * as d3  from 'd3';
import L        from 'leaflet';

import 'leaflet/dist/leaflet.css';

const colorScale = d3.scaleOrdinal (d3.schemeSet2);

function wrap (elems, width) {
    // Credit: adapted from https://bl.ocks.org/mbostock/7555321
    elems.each (function () {
        let text = d3.select (this);
        let words = text.text ().split (/\s+/).reverse ();
        let word;
        let line = [];
        let lineNumber = 0;
        let lineHeight = 1.3; // ems
        let y = text.attr ('y');
        let dy = parseFloat (text.attr ('dy') || '0');
        let tspan = text.text (null)
            .append ('tspan')
            .attr ('x', 0)
            .attr ('y', y)
            .attr ('dy', dy + 'em');
        while (word = words.pop ()) {
            line.push (word);
            tspan.text (line.join (' '));
            if (tspan.node ().getComputedTextLength () > width) {
                line.pop ();
                tspan.text (line.join (' '));
                line = [word];
                tspan = text.append ('tspan')
                    .attr ('x', 0)
                    .attr ('y', y)
                    .attr ('dy', ((++lineNumber * lineHeight) + dy) + 'em')
                    .text (word);
            }
        }
    });
}

// A Leaflet layer that uses D3 to display features.  Easily styleable with CSS.

L.D3_geoJSON = L.GeoJSON.extend ({
    onAdd (map) {
        const that = this;

        L.GeoJSON.prototype.onAdd.call (this, map);
        this.map = map;

        this.svg = d3.select (this.getPane ())
            .append ('svg')
            .classed ('d3', true)
            .classed (this.options.class, true);

        this.g = this.svg.append ('g')
            .classed ('leaflet-zoom-hide', true)
            .on ('mousedown', function (event) {
                that.last_pos = { 'x' : event.x, 'y' : event.y };
            })
            .on ('mouseup', function () {
                that.last_pos = { 'x' : 0, 'y' : 0 };
            });

        function projectPoint (x, y) {
            const point = map.latLngToLayerPoint (new L.LatLng (y, x));
            this.stream.point (point.x, point.y);
        }

        const transform = d3.geoTransform ({ 'point' : projectPoint });
        this.transform_path = d3.geoPath ().projection (transform);

        this.view_init ();

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
    setDatasource (url) {
        this.url = url;
        if (this.svg) {
            this.load_data ();
        }
    },
    load_data () {
        const that = this;
        if (this.url) {
            d3.json (this.url).then (function (json) {
                that.addData (json);
            });
        } else {
            that.addData ({ 'features' : [] });
        }
    },
    getAttribution () {
        return this.options.attribution;
    },
    setAttribution (attribution) {
        this.options.attribution = attribution;
        return this.options.attribution;
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
    is_dragging (event) {
        if (this.last_pos) {
            const dx = event.x - this.last_pos.x;
            const dy = event.y - this.last_pos.y;
            return Math.sqrt ((dx * dx) + (dy * dy)) > 5;
        }
        return true;
    },
    d3_init (dummy_geojson) {
        // override this
    },
    d3_update (dummy_geojson) {
        // override this
    },
});

L.Layer_Areas = L.D3_geoJSON.extend ({
    onAdd (map) {
        L.D3_geoJSON.prototype.onAdd.call (this, map);
        this.load_data ();
    },
    d3_update (geojson) {
        const that = this;
        const vm = this.options.vm;

        for (const f of geojson.features) {
            f.properties.geo_source = geojson.name;
            f.properties.key = geojson.name + '-' + f.properties.geo_id;
        }

        const t = d3.transition ()
            .duration (500)
            .ease (d3.easeLinear);

        const g = this.g.selectAll ('g').data (
            geojson.features,
            d => d.properties.key
        );

        g.exit ().transition (t).style ('opacity', 0).remove ();

        const entered = g.enter ()
            .append ('g')
            .attr ('class', 'area');

        entered.append ('path')
            .on ('mouseup', function (event, d) {
                if (that.is_dragging (event)) {
                    return;
                }
                vm.$trigger ('mss-tooltip-open', d);
            });

        entered.filter(d => d.properties.geo_label_y !== null)
            .append ('text')
            .classed ('caption', true);

        entered.style ('opacity', 0)
            .transition (t)
            .style ('opacity', 1);

        const merged = entered.merge (g);

        merged.selectAll ('path')
            .attr ('d', that.transform_path)
            .attr ('data-fcode', d => d.properties.geo_fcode)
            .style ('fill', d => {
                const fill = d.properties.geo_color || 'none';
                if (/^\d+$/.test (fill)) {
                    return colorScale (parseInt (fill, 10) / 8.0);
                }
                return fill;
            });

        merged.selectAll ('text')
            .text (d => d.properties.geo_name)
            .call (wrap, 150)
            .attr ('data-fcode', d => d.properties.geo_fcode)
            .attr ('transform', (d) => {
                const p = d.properties;
                const ll = new L.LatLng (p.geo_label_y, p.geo_label_x);
                const pp = that.map.latLngToLayerPoint (ll);
                return `translate(${pp.x},${pp.y})`;
            });
    },
});

L.Layer_Places = L.D3_geoJSON.extend ({
    onAdd (map) {
        L.D3_geoJSON.prototype.onAdd.call (this, map);
        this.load_data ();
    },
    d3_update (geojson) {
        const that = this;
        const vm = this.options.vm;

        const t = d3.transition ()
            .duration (500)
            .ease (d3.easeLinear);

        const g = this.g.selectAll ('g').data (
            geojson.features.filter (d => d.geometry !== null && d.geometry.coordinates !== null),
            d => d.properties.key
        );

        g.exit ().transition (t).style ('opacity', 0).remove ();

        const entered = g.enter ()
            .append ('g')
            .attr ('class', 'place');

        entered.style ('opacity', 0)
            .transition (t)
            .style ('opacity', 1);

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

        entered.on ('mouseup', function (event, d) {
            if (that.is_dragging (event)) {
                return;
            }
            d.position_target = event.target;
            vm.$trigger ('mss-tooltip-open', d);
        });

        entered.merge (g).attr ('transform', (d) => {
            const [x, y] = d.geometry.coordinates;
            const point = this.map.latLngToLayerPoint (new L.LatLng (y, x));
            return `translate(${point.x},${point.y})`;
        }).each (function (d) {
            const gr = d3.select (this);
            gr.selectAll ('circle.count').transition (t).attr ('r', 10 * Math.sqrt (d.properties.count));
            gr.selectAll ('text.count').text (d.properties.count);
        });
    },
});

L.Control.Info_Pane = L.Control.extend ({
    onAdd (dummy_map) {
        this._div = L.DomUtil.create ('div', 'info-pane-control');
        L.DomEvent.disableClickPropagation (this._div);
        L.DomEvent.disableScrollPropagation (this._div);
        jQuery (this._div).append (jQuery ('div.info-panels'));
        return this._div;
    },

    onRemove (dummy_map) {
    },
});

export default {
    'props' : {
        'toolbar' : {
            'type'     : Object,
            'required' : true,
        },
    },
    'data' : function () {
        return {
            'geo_data'          : null,
            'parts_data'        : null,
            'area_layer_infos'  : [],
            'place_layer_infos' : [],
        };
    },
    'computed' : {
        ... mapGetters ([
            'xhr_params',
            'area_layer_shown',
            'place_layer_shown',
            'geo_layers',
            'tile_layers',
        ]),
    },
    'watch' : {
        'xhr_params' : function () {
            this.update_place_layer ();
        },
        'place_layer_shown' : function (new_val) {
            this.register_place_layer (new_val);
        },
        'area_layer_shown' : function (new_val) {
            this.register_area_layer (new_val);
        },
        'geo_layers' : {
            handler (new_val) {
                this.init_geo_layers (new_val);
            },
            'deep' : true,
        },
        'tile_layers' : {
            handler (new_val) {
                this.init_tile_layers (new_val);
            },
            'deep' : true,
        },
    },
    'methods' : {
        update_place_layer () {
            const vm = this;
            if (vm.place_layer.options.url) {
                vm.place_layer.setDatasource (
                    vm.build_full_api_url (vm.place_layer.options.url) + '?' + $.param (vm.xhr_params)
                );
            } else {
                vm.place_layer.setDatasource (null);
            }
        },
        register_place_layer (new_id) {
            for (const layer_info of this.place_layer_infos) {
                if (layer_info.id === new_id) {
                    this.place_layer.options.layer = layer_info.id;
                    this.place_layer.setAttribution (layer_info.attribution);
                    this.place_layer.options.url   = layer_info.url;
                    break;
                }
            }
            this.update_place_layer ();
            this.update_attribution ();
        },
        register_area_layer (new_id) {
            for (const layer_info of this.area_layer_infos) {
                if (layer_info.id === new_id) {
                    this.area_layer.options.layer = layer_info.id;
                    this.area_layer.setAttribution (layer_info.attribution);
                    this.area_layer.setDatasource  (
                        // these are static geojson files
                        layer_info.url ? __webpack_public_path__ + layer_info.url : null
                    );
                    this.update_attribution ();
                    break;
                }
            }
        },
        init_tile_layers () {
            const vm = this;

            const baseLayers = {};
            const overlays   = {};

            for (const layer_info of vm.tile_layers.layers) {
                const layer = L.tileLayer (
                    vm.build_full_api_url (`tile/${layer_info.id}/{z}/{x}/{y}.png`),
                    {
                        'attribution' : layer_info.attribution,
                    }
                );
                if (layer_info.type === 'base') {
                    baseLayers[layer_info.title] = layer;
                    layer.addTo (vm.map);
                } else {
                    overlays[layer_info.title] = layer;
                }
            }

            baseLayers.OpenStreetMap = L.tileLayer ('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                'attribution' : '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            });

            L.control.layers (baseLayers, overlays, { 'collapsed' : true }).addTo (vm.map);

            vm.map.options.minZoom = vm.tile_layers.min_zoom;
            vm.map.options.maxZoom = vm.tile_layers.max_zoom;

            vm.zoom_extent ();
        },
        init_geo_layers () {
            const vm = this;

            vm.area_layer_infos = [{ 'id' : 'none', 'url' : null, 'attribution' : '' }];
            vm.place_layer_infos = [{ 'id' : 'none', 'url' : null, 'attribution' : '' }];
            vm.area_layer_infos.push  (... vm.geo_layers.layers.filter (d => d.type === 'area'));
            vm.place_layer_infos.push (... vm.geo_layers.layers.filter (d => d.type === 'place'));

            vm.area_layer.addTo (vm.map);

            vm.register_area_layer (vm.area_layer_shown);

            vm.place_layer.addTo (vm.map);

            vm.register_place_layer (vm.place_layer_shown);
            vm.update_place_layer ();
        },
        zoom_extent (dummy_json) {
            const vm = this;
            d3.json (vm.build_full_api_url ('geo/extent.json')).then (function (json) {
                const [[l, b], [r, t]] = d3.geoPath ().bounds (json);
                vm.map.fitBounds (L.latLngBounds (L.latLng (b, r), L.latLng (t, l)));
            });
        },
        update_attribution () {
            const ac = this.map.attributionControl;
            if (ac) {
                ac.setPrefix (false);
                ac._attributions = {};
                this.map.eachLayer (function (layer) {
                    ac.addAttribution (layer.getAttribution ());
                });
            }
        },
    },
    'mounted' : function () {
        const vm = this;

        vm.map = L.map ('map', {
            'renderer'    : L.svg (),
            'zoomControl' : false,
        });
        vm.area_layer = new L.Layer_Areas (null, {
            'class'               : 'areas',
            'vm'                  : vm,
            'interactive'         : true,
            'bubblingMouseEvents' : false,
        });
        vm.place_layer = new L.Layer_Places (null, {
            'class'               : 'places',
            'vm'                  : vm,
            'interactive'         : true,
            'bubblingMouseEvents' : false,
        });

        new L.Control.Info_Pane ({ 'position' : 'topleft' }).addTo (vm.map);

        vm.$store.commit ('toolbar_range',             vm.toolbar);
        vm.$store.commit ('toolbar_area_layer_shown',  vm.toolbar);
        vm.$store.commit ('toolbar_place_layer_shown', vm.toolbar);
    },
};
</script>

<style lang="scss">
/* map.vue */
@import "../css/bootstrap-custom";

#map {
    position: absolute;
    overflow: hidden;
    width: 100%;
    top: 0;
    bottom: 0;
}

.leaflet-control-layers-toggle {
    background-image: url(leaflet/dist/images/layers.png);
}

.leaflet-retina .leaflet-control-layers-toggle {
    background-image: url(leaflet/dist/images/layers-2x.png);
}

svg {
    &.d3 {
        overflow: visible;
        pointer-events: none;

        text {
            pointer-events: none;
            dominant-baseline: middle;
            text-anchor: middle;
        }

        &.areas {
            z-index: 200;
            path {
                cursor: pointer;
                pointer-events: all;
                stroke-width: 2px;
                stroke: $country-color;
                opacity: 0.5;
                &:hover {
                    fill: $country-color;
                }
            }
            text {
                font: bold 16px sans-serif;
                text-align: center;
                fill: black;
                text-shadow: 1px 1px 0 white, 1px -1px 0 white, -1px 1px 0 white, -1px -1px 0 white;
            }
        }

        &.places {
            z-index: 400;
            path {
                stroke-width: 1px;
            }
            circle.count {
                stroke: white;
                stroke-width: 1.5px;
                fill-opacity: 0.5;
                pointer-events: all;
                cursor: pointer;

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
        }
    }
}

</style>
