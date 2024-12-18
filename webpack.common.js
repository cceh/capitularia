const glob = require ('glob');
const path = require ('path');

const webpack                   = require ('webpack');
const HtmlWebpackPlugin         = require ('html-webpack-plugin');
const { WebpackManifestPlugin } = require ('webpack-manifest-plugin');
const { VueLoaderPlugin }       = require ('vue-loader');               // loads vue single-file components

module.exports = {
    'context' : path.resolve (__dirname),
    'entry'   : {
        'cap-vendor' : {
            'import' : ['jquery', 'lodash', '@popperjs/core', 'bootstrap', 'vue'],
        },
        'cap-theme-front' : {
            'import' : [
                './themes/Capitularia/src/js/front.js',
                './themes/Capitularia/src/css/front.scss',
                './themes/Capitularia/src/css/content-col.scss',
            ].concat (glob.sync ('./themes/Capitularia/src/images/*.png', { 'dotRelative' : true })),
            'dependOn' : 'cap-vendor',
        },
        'cap-theme-admin' : {
            'import' : [
                './themes/Capitularia/src/js/admin.js',
                './themes/Capitularia/src/css/admin.scss',
            ],
        },

        'cap-collation-front' : {
            'import'   : './plugins/cap-collation/src/js/front.js',
            'dependOn' : 'cap-vendor',
        },

        'cap-dynamic-menu-front' : {
            'import'   : './plugins/cap-dynamic-menu/src/js/front.js',
            'dependOn' : 'cap-vendor',
        },

        'cap-lib-front' : {
            'import'   : './plugins/cap-lib/src/js/front.js',
            'dependOn' : 'cap-vendor',
        },

        'cap-meta-search-front' : {
            'import' : [
                './plugins/cap-meta-search/src/js/front.js',
                './plugins/cap-meta-search/src/css/front.scss',
            ],
            'dependOn' : 'cap-vendor',
        },

        'cap-page-generator-front' : {
            'import' : [
                './plugins/cap-page-generator/src/css/front.scss',
            ],
            'dependOn' : 'cap-vendor',
        },

        'cap-page-generator-admin' : {
            'import' : [
                './plugins/cap-page-generator/src/js/admin.js',
                './plugins/cap-page-generator/src/css/admin.scss',
            ],
        },

        'cap-client' : {
            'import' : [
                './client/src/js/main.js',
            ],
            'dependOn' : 'cap-vendor',
        },
    },
    'output' : {
        'filename' : '[name].[contenthash].js',
        'path'     : path.resolve (__dirname, 'dist'),
    },
    'module' : {
        'rules' : [
            {
                'test'    : /\.js$/,
                'exclude' : /node_modules/,
                'use'     : [
                    'babel-loader',
                ],
            },
            {
                'test'    : /\.vue$/,
                'exclude' : /node_modules/,
                'use'     : [
                    {
                        'loader'  : 'vue-loader',
                        'options' : {
                            'compilerOptions' : {
                            },
                        },
                    },
                ],
            },
            {
                'test'      : /\.(png|jpg|jpeg|gif)$/,
                'type'      : 'asset/resource',
                'generator' : {
                    'filename' : 'images/[name].[contenthash][ext]',
                },
            },
            {
                'test'      : /\.(ttf|woff|woff2)$/,
                'type'      : 'asset/resource',
                'generator' : {
                    'filename' : 'webfonts/[name].[contenthash][ext]',
                },
            },
        ],
    },
    'optimization' : {
        'runtimeChunk' : {
            'name' : 'cap-runtime',
        },
        'moduleIds' : 'deterministic',
    },
    'plugins' : [
        new HtmlWebpackPlugin ({
            'template' : './client/src/index.html',
            'inject'   : false,
            'chunks'   : ['cap-client', 'cap-vendor', 'cap-runtime'],
        }),
        new WebpackManifestPlugin ({
            'fileName'        : 'manifest.json',
            'writeToFileEmit' : true,
        }),
        new VueLoaderPlugin (),
        new webpack.DefinePlugin ({
            '__VUE_OPTIONS_API__'                     : 'true',
            '__VUE_PROD_DEVTOOLS__'                   : 'false',
            '__VUE_PROD_HYDRATION_MISMATCH_DETAILS__' : 'false',
        }),
    ],
    'resolve' : {
        'alias' : {
            'lodash' : 'lodash-es',
        },
    },
};
