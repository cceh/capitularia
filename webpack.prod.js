const { merge }              = require ('webpack-merge');
const MiniCssExtractPlugin   = require ('mini-css-extract-plugin');

const common = require ('./webpack.common.js');

module.exports = merge (common, {
    mode    : 'production',
    devtool : 'source-map',
    entry   : {
        'cap-theme-front' : { import : ['./themes/Capitularia/src/js/piwik-wrapper.js'] },
    },
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
    ],
});
