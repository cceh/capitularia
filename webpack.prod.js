const webpack                = require ('webpack');
const { merge }              = require ('webpack-merge');
const MiniCssExtractPlugin   = require ('mini-css-extract-plugin');

const common = require ('./webpack.common.js');

module.exports = merge (common, {
    'mode'    : 'production',
    'devtool' : 'eval-source-map', // 'source-map', // but see: https://github.com/webpack/webpack-sources/issues/55
    'output'  : {
        'publicPath' : '/wp-content/dist/',
    },
    'module' : {
        'rules' : [
            {
                'test' : /\.s?css$/,
                'use'  : [
                    MiniCssExtractPlugin.loader,
                    {
                        'loader'  : 'css-loader',
                        'options' : {
                            'importLoaders' : 2,
                        },
                    },
                    'postcss-loader',
                    {
                        'loader'  : 'sass-loader',
                        'options' : {
                            'sassOptions' : {
                                'quietDeps' : true,
                            },
                        },
                    },
                ],
            },
        ],
    },
    'plugins' : [
        new MiniCssExtractPlugin ({
            'filename'      : '[name].[contenthash].css',
            'chunkFilename' : '[id].[contenthash].css',
        }),
    ],
});
