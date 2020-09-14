const { merge } = require ('webpack-merge');
const chokidar = require ('chokidar');
const common = require ('./webpack.common.js');

const host    = 'capitularia.fritz.box';
const devHost = 'localhost';
const devPort = 8081;

module.exports = merge (common, {
    mode    : 'development',
    devtool : 'eval-source-map',
    output  : {
        publicPath : `http://${devHost}:${devPort}/`,
    },
    module : {
        rules : [
            {
                test : /\.s?css$/,
                use  : [
                    'style-loader',
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
    devServer : {
        host        : devHost,
        port        : devPort,
        contentBase : './dist',

        // Enable hot module reloading (HMR).
        hot        : true,
        liveReload : false,

        // write images because we still load them the traditional way
        writeToDisk : true,

        // Needed because we access port devPort from port 80.
        allowedHosts : [host],
        headers      : { 'Access-Control-Allow-Origin' : `http://${host}` },

        // Watch for changes to PHP files and reload the page when one changes.
        // See: https://mikeselander.com/hot-reloading-using-webpack-with-php-file-changes/
        before (app, server) {
            chokidar
                .watch (['themes/**/*.php', 'plugins/*/*.php'], {
                    alwaysStat     : true,
                    atomic         : false,
                    followSymlinks : false,
                    ignoreInitial  : true,
                    persistent     : true,
                    usePolling     : true,
                })
                .on ('all', () => {
                    server.sockWrite (server.sockets, 'content-changed');
                });
        },
    },
});
