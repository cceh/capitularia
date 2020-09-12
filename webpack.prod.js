const { merge } = require ('webpack-merge');

const common = require ('./webpack.common.js');

module.exports = merge (common, {
    mode : 'production',
    entry : {
        'cap-theme-front' : { import: ['./themes/Capitularia/src/js/piwik-wrapper.js'] },
    },
});
