const { merge } = require ('webpack-merge');
const chokidar = require ('chokidar');
const common = require ('./webpack.common.js');

const devPort = 8081;

module.exports = merge (common, {
    mode    : 'development',
    devtool : 'eval-source-map',
    output  : {
        // This is where the HMR module looks for the hot-update files.
        // We actually serve nothing but the hot-update files from here.
        publicPath : `http://capitularia.fritz.box:${devPort}/`,
    },
    devServer : {
        host        : 'capitularia.fritz.box',
        port        : devPort,
        contentBase : './build',  // not used

        // Enable hot module reloading (HMR).
        hot        : true,
        liveReload : false,

        // Always write the files to disk because Wordpress needs to serve them
        // in case of page reload.
        writeToDisk : (filePath) => {
            return ! /hot-update.js/.test (filePath);
        },

        // Needed because we access port devPort from port 80.
        headers : { 'Access-Control-Allow-Origin' : '*' },

        // Watch for changes to PHP files and reload the page when one changes.
        // See: https://mikeselander.com/hot-reloading-using-webpack-with-php-file-changes/
        before (app, server) {
            chokidar
                .watch (['themes/**/*.php', 'plugins/**/*.php', 'webpack.*.js'], {
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
