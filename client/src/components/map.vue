<template>
  <div id="map"></div>
</template>

<script>
/**
 * This module displays a tiled map with overlays.
 *
 * @component map
 * @author Marcello Perathoner
 *
 * GeoJSON specs: https://tools.ietf.org/html/rfc7946
 */

import $        from 'jquery';
import * as d3  from 'd3';
import L        from 'leaflet';
import _        from 'lodash';

import '../../node_modules/leaflet/dist/leaflet.css';

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
        const updated = this.g.selectAll ('path').data (geojson.features);
        this.features = updated.enter ().append ('path');
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

        entered.append ('text')
            .attr ('class', 'count')

        entered.append ('text')
            .attr ('class', 'name')
            .attr ('y', '16px')
            .text (function (d) {
                return d.properties.name;
            });

        entered.on ('mouseover', function (d) {
            vm.$trigger ('mss-tooltip-open', d);
        });

        entered.on ('mouseout', function (d) {
            vm.$trigger ('mss-tooltip-close', d);
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
        geo_filter (features, polygon) {
            // include only features located inside polygon
            return _.filter (
                features,
                function (o) {
                    d3.geoContains (polygon, o.geometry.coordinates);
                }
            );
        },
        update_map () {
            const tb = this.toolbar;

            // filter by date range
            let features = _.filter (
                this.parts_data.features,
                function (o) {
                    const p = o.properties;
                    return (p.notbefore < tb.notafter) && (tb.notbefore < p.notafter);
                }
            );
            // group by place
            features = _.groupBy (
                features,
                function (o) { return o.properties.geo_id; }
            );
            // join with geo data
            features = _.map (Object.entries (features), (o) => {
                const [geo_id, grouped] = o;
                const g = this.geo_data[geo_id];
                return {
                    'geometry' : g.geometry,
                    'properties' : {
                        'geo_id' : geo_id,
                        'name'   : g.properties.name,
                        'count'  : grouped.length,
                        'mss'    : grouped,
                    },
                    'type' : 'Feature'
                };
            });
            this.layer_mss.addData ({ 'type' : 'FeatureCollection', 'features' : features });
        },
    },
    'mounted' : function () {
        const vm = this;

        const map = L.map ('map', {
            'renderer'    : L.svg (),
            'zoomControl' : false,
        });

        const capitularia = L.tileLayer (
            vm.build_full_api_url ('tile/{z}/{x}/{y}.png'), {
                'attribution' : '&copy; Capitularia'
            }).addTo (map);

        const openstreetmap = L.tileLayer (
            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                'attribution' : '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            });

        const toolserver = L.tileLayer (
            'http://{s}.www.toolserver.org/tiles/bw-mapnik/{z}/{x}/{y}.png', {
                'attribution' : '&copy; toolserver.org Mapnik'
            });

        const layer_countries = new L.Layer_Borders (null, {
            'class' : 'countries',
        });

        const layer_provinces = new L.Layer_Borders (null, {
            'class' : 'provinces',
        });

        const layer_mss = new L.Layer_Places (null, {
            'class' : 'mss',
            'vm'    : vm,
        }).addTo (map);

        this.layer_mss = layer_mss;

        const baseLayers = {
            'Capitularia'   : capitularia,
            'OpenStreetMap' : openstreetmap,
            'Mapnik'        : toolserver,
        };
        const overlays   = {
            'Manuscripts' : layer_mss,
            'Countries'   : layer_countries,
            'Provinces'   : layer_provinces,
        };
        L.control.layers (baseLayers, overlays).addTo (map);
        new L.Control.Info_Pane ({ position: 'bottomleft' }).addTo (map);

        const xhr_countries = d3.json ('/client/geodata/10m_cultural/ne_10m_admin_0_countries.json');
        const xhr_provinces = d3.json ('/client/geodata/10m_cultural/ne_10m_admin_1_states_provinces.json');
        const xhr_places    = d3.json (vm.build_full_api_url ('places.json'));
        const xhr_parts     = d3.json (vm.build_full_api_url ('msparts.json'));

        Promise.all ([xhr_countries, xhr_provinces, xhr_places, xhr_parts]).then ((responses) => {
            const [data_countries, data_provinces, data_places, data_parts] = responses;

            layer_countries.addData (data_countries);
            layer_provinces.addData (data_provinces);

            this.geo_data = Object ();
            for (const o of data_places.features) {
                this.geo_data[o.properties.geo_id] = o;
            };

            this.parts_data = data_parts;

            const [[l, b], [r, t]] = d3.geoPath ().bounds (data_places);
            map.fitBounds (L.latLngBounds (L.latLng (b, r), L.latLng (t, l)));

            this.update_map ();
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
        &.provinces {
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
                    fill: red;
                    fill-opacity: .7;
                }
            }
        }

        &.provinces {
            path {
                stroke: white;
                &:hover {
                    fill: #f0f;
                    fill-opacity: .7;
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
            }
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

div.info-pane-control-xxx {
	padding: 6px 8px;
	font: 14px/16px Arial, Helvetica, sans-serif;
	background: white;
	background: rgba(255,255,255,0.8);
	box-shadow: 0 0 15px rgba(0,0,0,0.2);
	border-radius: 5px;
}

</style>
