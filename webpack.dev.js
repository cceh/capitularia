const { merge } = require ('webpack-merge');
const chokidar = require ('chokidar');
const common = require ('./webpack.common.js');

const host    = 'capitularia.fritz.box';
const devHost = 'localhost';
const devPort = 8081;

module.exports = merge (common, {
    'mode'    : 'development',
    'devtool' : 'eval-source-map',
    'output'  : {
        'publicPath' : `http://${devHost}:${devPort}/`,
    },
    'module' : {
        'rules' : [
            {
                'test' : /\.s?css$/,
                'use'  : [
                    'style-loader',
                    {
                        'loader'  : 'css-loader',
                        'options' : {
                            'importLoaders' : 2,
                        },
                    },
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
    'devServer' : {
        'host'       : devHost,
        'port'       : devPort,
        // Enable hot module reloading (HMR).
        'hot'        : true,
        'liveReload' : false,
        'static'     : {
            'directory' : './dist',
        },
        'devMiddleware' : {
            // write images because we still load them the traditional way
            'writeToDisk' : true,
        },

        // Needed because we access port devPort from port 80.
        'allowedHosts' : [host],
        'headers'      : { 'Access-Control-Allow-Origin' : `http://${host}` },

        // Watch for changes to PHP files and reload the page when one changes.
        // See: https://mikeselander.com/hot-reloading-using-webpack-with-php-file-changes/
        setupMiddlewares (middlewares, devServer) {
            chokidar
                .watch (['themes/**/*.php', 'plugins/*/*.php'], {
                    'alwaysStat'     : true,
                    'atomic'         : false,
                    'followSymlinks' : false,
                    'ignoreInitial'  : true,
                    'persistent'     : true,
                    'usePolling'     : true,
                })
                .on ('all', () => {
                    devServer.sendMessage (devServer.sockets, 'content-changed');
                });
            return middlewares;
        },
    },
});
