const path = require ('path');
const glob = require ('glob');
const VueLoaderPlugin = require ('vue-loader/lib/plugin'); // loads vue single-file components

module.exports = {
    context: path.resolve (__dirname),
    entry : {
        vendor : {
            import : ['jquery', 'lodash', 'popper.js', 'bootstrap', 'vue', 'bootstrap-vue'],
        },
        front : {
            import   : ['./themes/Capitularia/src/js/front.js', './themes/Capitularia/src/css/front.scss'],
            dependOn : 'vendor',
        },
        admin : {
            import : ['./themes/Capitularia/src/js/admin.js', './themes/Capitularia/src/css/admin.scss'],
        },
        images : {
            import : glob.sync ('./themes/Capitularia/src/images/*.png'),
        },

        'cap-collation-front' : {
            import   : './plugins/cap-collation/src/js/front.js',
            filename : './plugins/cap-collation/js/front.js',
            dependOn : 'vendor',
        },

        'cap-dynamic-menu-front' : {
            import   : './plugins/cap-dynamic-menu/src/js/front.js',
            filename : './plugins/cap-dynamic-menu/js/front.js',
            dependOn : 'vendor',
        },

        'cap-meta-search-front' : {
            import   : [
                './plugins/cap-meta-search/src/js/front.js',
                './plugins/cap-meta-search/src/css/front.scss',
            ],
            filename : './plugins/cap-meta-search/js/front.js',
            dependOn : 'vendor',
        },

        'cap-page-generator-front' : {
            import   : [
                './plugins/cap-page-generator/src/css/front.scss',
            ],
            filename : './plugins/cap-page-generator/js/front.js'
        },

        'cap-page-generator-admin' : {
            import   : [
                './plugins/cap-page-generator/src/js/admin.js',
                './plugins/cap-page-generator/src/css/admin.scss',
            ],
            filename : './plugins/cap-page-generator/js/admin.js'
        },
    },
    output : {
        filename   : 'themes/Capitularia/js/[name].js', // default filename
        path       : __dirname,
        publicPath : '/wp-content',
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
                test : /\.less$/,
                use  : [
                    'style-loader',
                    'css-loader',
                    'postcss-loader',
                    'less-loader',
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
                test : /\.(eot|svg|ttf|woff|woff2)$/,
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
    /*optimization: {
        splitChunks: {
            cacheGroups: {
                common: {
                    name: 'common',
                    chunks: 'all',
                    minChunks: 2,
                    enforce: true,
                },
                vendor: {
                    name: 'vendor',
                    test: /node_modules/,
                    chunks: 'all',
                    reuseExistingChunk: true,
                },
            },
        },
        runtimeChunk: 'single',
    },*/
    plugins : [
        new VueLoaderPlugin (),
    ],
    resolve : {
        modules : [
            path.resolve (__dirname, 'themes/Capitularia/node_modules'),
            path.resolve (__dirname, 'client/node_modules'),
            'node_modules',
        ],
        alias : {
            'vue$' : 'vue/dist/vue.esm.js', // includes template compiler
        },
    },
};
