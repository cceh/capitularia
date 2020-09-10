const path = require ('path');
const glob = require ('glob');

const VueLoaderPlugin   = require ('vue-loader/lib/plugin'); // loads vue single-file components
const ManifestPlugin    = require ('webpack-manifest-plugin');

module.exports = {
    context: path.resolve (__dirname),
    entry : {
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
        filename   : (pathData, assetInfo) => {
            const name = pathData.chunk.name;
            if (name === 'cap-runtime' ||
                name === 'cap-vendor' ||
                name.match (/^cap-theme-/)) {
                // default filename for theme
                return 'themes/Capitularia/dist/js/[name].[contenthash].js';
            }
            const plugin = name.replace (/(-front)|(-admin)$/, '');
            // default filename for plugins
            return `plugins/${plugin}/dist/js/[name].[contenthash].js`;
        },
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
                test : /\.scss$/,
                use  : [
                    'style-loader',
                    'css-loader',
                    'postcss-loader',
                    'sass-loader',
                ],
            },
            {
                test : /\.css$/,
                use  : [
                    'style-loader',
                    'css-loader',
                    'postcss-loader',
                ],
            },
            {
                test : /\.(png|jpg|jpeg|gif)$/,
                use  : [
                    {
                        loader  : 'file-loader',
                        options : {
                            name       : '[name].[ext]',
                            outputPath : 'themes/Capitularia/images',
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
                            outputPath : 'themes/Capitularia/webfonts',
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
        new VueLoaderPlugin (),
        new ManifestPlugin ({
            fileName : path.resolve (__dirname, 'themes/Capitularia/manifest.json'),
            writeToFileEmit : true,
        }),
    ],
    resolve : {
        modules : [
            path.resolve (__dirname, 'themes/Capitularia/node_modules'),
            path.resolve (__dirname, 'client/node_modules'),
            'node_modules',
        ],
        alias : {
            'vue$' : 'vue/dist/vue.esm.js', // includes the template compiler
        },
    },
};
