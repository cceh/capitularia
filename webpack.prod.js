const webpack                = require ('webpack');
const { merge }              = require ('webpack-merge');
const MiniCssExtractPlugin   = require ('mini-css-extract-plugin');

const common = require ('./webpack.common.js');

module.exports = merge (common, {
    mode    : 'production',
    devtool : 'source-map', // but see: https://github.com/webpack/webpack-sources/issues/55
    output : {
        publicPath : '/wp-content/dist/',
    },
    module : {
        rules : [
            {
                test : /\.s?css$/,
                use  : [
                    MiniCssExtractPlugin.loader,
                    {
                        loader  : 'css-loader',
                        options : {
                            importLoaders : 2,
                        },
                    },
                    'postcss-loader',
                    'sass-loader',
                ],
            },
        ],
    },
    plugins : [
        new MiniCssExtractPlugin ({
            filename      : '[name].[contenthash].css',
            chunkFilename : '[id].[contenthash].css',
        }),
        new webpack.DefinePlugin ({
            __VUE_OPTIONS_API__   : JSON.stringify (true),
            __VUE_PROD_DEVTOOLS__ : JSON.stringify (false),
        }),
    ],
});
