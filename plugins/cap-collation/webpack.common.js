const path = require ('path');
const VueLoaderPlugin = require ('vue-loader/lib/plugin'); // loads vue single-file components

module.exports = {
    entry : {
        app : './src/js/main.js', // in app.bundle.js
    },
    output : {
        filename : 'front.js',
        path : path.resolve (__dirname, 'js'),
    },
    externals: {
        // Avoid duplicates
        // These libs are loaded in <script>s by the Wordpress theme
        // in themes/Capitularia/functions-include.php
        'vue'                 : 'Vue',
        'bootstrap-vue'       : 'BootstrapVue',
        'bootstrap-vue-icons' : 'BootstrapVueIcons',
        'lodash'              : '_',
        'jquery'              : 'jQuery',
    },
    module : {
        rules : [
            {
                test : /\.js$/,
                exclude : /node_modules/,
                use : [
                    'babel-loader',
                ],
            },
            {
                test: /\.vue$/,
                exclude: /node_modules/,
                use: [
                    'vue-loader',
                ],
            },
            {
                test: /\.scss$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'postcss-loader',
                    'sass-loader',
                ],
            },
            {
                test: /\.css$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'postcss-loader',
                ],
            },
            {
                test: /\.(png|jpg|jpeg|gif)$/,
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: '/images/[name].[ext]',
                        },
                    },
                ],
            },
            {
                test: /\.(eot|svg|ttf|woff|woff2)$/,
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: '/webfonts/[name].[ext]',
                        },
                    },
                ],
            },
        ],
    },
    plugins: [
        new VueLoaderPlugin (),
    ],
    resolve: {
        modules: [
            path.resolve (__dirname, 'src'),
            path.resolve (__dirname, 'src/components'),
            path.resolve (__dirname, 'src/css'),
            path.resolve (__dirname, 'src/js'),
            path.resolve (__dirname, '../../themes/Capitularia/node_modules'),
            'node_modules',
        ],
    },
};