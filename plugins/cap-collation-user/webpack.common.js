const path = require ('path');

module.exports = {
    entry : {
        app : './src/js/front.js', // in app.bundle.js
    },
    output : {
        filename : 'front.js',
        path : path.resolve (__dirname, 'js'),
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
                test: /\.css$/,
                use: [
                    'vue-style-loader',
                    'css-loader',
                    'postcss-loader',
                ],
            },
            {
                test: /\.scss$/,
                use: [
                    'vue-style-loader',
                    'css-loader',
                    'postcss-loader',
                    'sass-loader',
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
    devServer: {
        host: '127.0.6.1',
        port: 8080,
        contentBase: './build',
        public: 'ntg.fritz.box:8080',
    },
    resolve: {
        modules: [
            path.resolve (__dirname, 'src'),
            path.resolve (__dirname, 'src/components'),
            path.resolve (__dirname, 'src/css'),
            path.resolve (__dirname, 'src/js'),
            'node_modules',
        ],
    },
};
