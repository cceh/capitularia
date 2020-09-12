const glob = require ('glob');
const path = require ('path');

const ManifestPlugin  = require ('webpack-manifest-plugin');
const VueLoaderPlugin = require ('vue-loader/lib/plugin'); // loads vue single-file components

module.exports = {
    context : path.resolve (__dirname),
    entry   : {
        'cap-vendor' : {
            import : ['jquery', 'lodash', 'popper.js', 'bootstrap', 'vue', 'bootstrap-vue'],
        },
        'cap-theme-front' : {
            import   : [
                './themes/Capitularia/src/js/front.js',
                './themes/Capitularia/src/css/front.scss'
            ],
            dependOn : 'cap-vendor',
        },
        'cap-theme-admin' : {
            import : [
                './themes/Capitularia/src/js/admin.js',
                './themes/Capitularia/src/css/admin.scss'
            ],
        },
        'cap-theme-images' : {
            // a dummy module to pull in all the images
            import : glob.sync ('./themes/Capitularia/src/images/*.png'),
        },

        'cap-collation-front' : {
            import   : './plugins/cap-collation/src/js/front.js',
            dependOn : 'cap-vendor',
        },

        'cap-dynamic-menu-front' : {
            import   : './plugins/cap-dynamic-menu/src/js/front.js',
            dependOn : 'cap-vendor',
        },

        'cap-lib-front' : {
            import   : './plugins/cap-lib/src/js/front.js',
            dependOn : 'cap-vendor',
        },

        'cap-meta-search-front' : {
            import   : [
                './plugins/cap-meta-search/src/js/front.js',
                './plugins/cap-meta-search/src/css/front.scss',
            ],
            dependOn : 'cap-vendor',
        },

        'cap-page-generator-front' : {
            import   : [
                './plugins/cap-page-generator/src/css/front.scss',
            ],
            dependOn : 'cap-vendor',
        },

        'cap-page-generator-admin' : {
            import   : [
                './plugins/cap-page-generator/src/js/admin.js',
                './plugins/cap-page-generator/src/css/admin.scss',
            ],
        },
    },
    output : {
        filename   : 'dist/[name].[contenthash].js',
        path       : __dirname,
        publicPath : '/wp-content/',
    },
    module : {
        rules : [
            {
                test    : /\.js$/,
                exclude : /node_modules/,
                use     : [
                    'babel-loader',
                ],
            },
            {
                test    : /\.vue$/,
                exclude : /node_modules/,
                use     : [
                    'vue-loader',
                ],
            },
            {
                test : /\.(png|jpg|jpeg|gif)$/,
                use  : [
                    {
                        loader  : 'file-loader',
                        options : {
                            name       : '[name].[ext]',
                            outputPath : 'dist/images',
                        },
                    },
                ],
            },
            {
                test : /\.(ttf|woff|woff2)$/,
                use  : [
                    {
                        loader  : 'file-loader',
                        options : {
                            name       : '[name].[ext]',
                            outputPath : 'dist/webfonts',
                        },
                    },
                ],
            },
        ],
    },
    optimization: {
        runtimeChunk: {
            name: 'cap-runtime',
        },
        moduleIds    : 'deterministic',
        /*
          splitChunks: {
          cacheGroups: {
          common: {
          name: 'common',
          chunks: 'all',
          minChunks: 2,
          enforce: true,
          },
          vendor: {
          name: 'cap-vendor',
          test: /node_modules/,
          chunks: 'all',
          reuseExistingChunk: true,
          },
          },
          },*/
    },
    plugins : [
        new ManifestPlugin ({
            fileName : path.resolve (__dirname, 'dist/manifest.json'),
            writeToFileEmit : true,
        }),
        new VueLoaderPlugin (),
    ],
    resolve : {
        modules : [
            'node_modules',
        ],
    },
};
