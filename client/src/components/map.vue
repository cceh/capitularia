<template>
  <div id="map"></div>
</template>

<script>
/**
 * This module displays a tiled map with overlays.
 *
 * @component map
 * @author Marcello Perathoner
 */

import * as d3  from 'd3';
import L        from 'leaflet';
import _        from 'lodash';

import '../../node_modules/leaflet/dist/leaflet.css';

// A Leaflet layer that uses D3 to display features.  Easily styleable with CSS.

L.D3_geoJSON = L.GeoJSON.extend ({
    onAdd (map) {
        L.GeoJSON.prototype.onAdd.call (this, map);

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
    },
    addData (rows, init_function, update_function) {
        this.rows = rows;
        this.init_function   = init_function;
        this.update_function = update_function;
        this.view_init ();
        this.view_update ();
    },
    view_init () {
        if (this.rows && this.init_function) {
            this.features = this.init_function (this.rows);
        }
    },
    view_update () {
        if (this.features && this.update_function) {
            this.update_function (this.features);
        }
    },
    zoom_end (event) {
        if (this.svg) {
            this.svg.attr ('data-zoom', 'Z'.repeat (event.target._zoom));
        }
    },
});

L.d3_geoJSON = function (map, options) { return new L.D3_geoJSON (map, options); };

export default {
    'data'  : function () {
        return {
        };
    },
    'methods' : {
    },
    'mounted' : function () {
        const vm = this;

        const map = L.map ('map', {
            'renderer'    : L.svg (),
            'zoomControl' : false,
        }).setView ([50.77468, 6.08383], 7);

        vm.map = map;

        const capitularia = L.tileLayer (
            'http://localhost:5000/tile/{z}/{x}/{y}.png', {
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

        const layer_borders = L.d3_geoJSON ([], {
            'class' : 'borders',
        }).addTo (map);

        const layer_places = L.d3_geoJSON ([], {
            'class' : 'places',
        }).addTo (map);

        const baseLayers = { 'Capitularia' : capitularia, 'OpenStreetMap': openstreetmap, 'Mapnik' : toolserver };
        const overlays   = { 'Places' : layer_places, 'Borders' : layer_borders };
        L.control.layers (baseLayers, overlays).addTo (map);

        // the D3 borders layer
        const xhr_borders = d3.json ('/client/geodata/10m_cultural/ne_10m_admin_0_boundary_lines_land.json');
        Promise.all ([xhr_borders]).then ((responses) => {
            const layer = layer_borders;
            const rows = responses[0].features;

            function init (rows) {
                const features = layer.g.selectAll ('path')
                      .data (rows)
                      .enter ()
                      .append ('path');
                return features;
            }

            function update (features) {
                features.attr ('d', layer.transform_path);
            }

            layer.addData (rows, init, update);
        });

        // the D3 places layer
        const xhr = vm.get ('manuscripts.json');
        Promise.all ([xhr]).then ((responses) => {
            const layer = layer_places;

            // sort the data by count descending
            let rows = _.sortBy (responses[0].data.data, function (o) { return -o.count; } );
            rows = rows.map ((row) => {
                return {
                    'type' : 'Feature',
                    'properties' : {
                        'name'  : row.name,
                        'count' : row.count,
                    },
                    'geometry' : row.geo,
                }
            });

            function init (rows) {
                const features = layer.g.selectAll ('g')
                      .data (rows)
                      .enter ()
                      .append ('g')
                      .attr ('class', 'place');

                features.append ('circle')
                    .attr ('class', 'count')
                    .attr ('r', function (d) { return 10 * Math.sqrt (d.properties.count); });

                features.append ('text')
                    .attr ('class', 'name')
                    .attr ('y', '16px')
                    .text (function (d) {
                        return d.properties.name;
                    });

                features.append ('text')
                    .attr ('class', 'count')
                    .text (function (d) {
                        return d.properties.count;
                    });

                return features;
            }

            function update (features) {
                features.attr ('transform', function (d) {
                    const [x, y] = d.geometry.coordinates;
                    const point = map.latLngToLayerPoint (new L.LatLng (y, x));
                    return `translate(${point.x},${point.y})`;
                });
            }

            layer.addData (rows, init, update);

            const [[l, b], [r, t]] = d3.geoPath ().bounds ({
                'type' : 'FeatureCollection',
                'features' : rows
            });
            map.fitBounds ([[t, l], [b, r]]);
        });
    },
};
</script>

<style lang="scss">
/* map.vue */
@import "bootstrap-custom";

#map {
  width: 960px;
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

        &.borders {
            path {
                stroke: red;
                stroke-opacity: .7;
                stroke-width: 1.5px;
                fill: none;
            }
        }

        text {
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

        circle.count {
            stroke: white;
            stroke-width: 1.5px;
            fill: red;
            fill-opacity: .7;
        }

        image {
            x: -16px;
            y: -16px;
        }
    }
}

svg.borders[data-zoom^="ZZZZZZZZ"] {
    path {
        stroke-width: 3px;
    }
}

</style>
