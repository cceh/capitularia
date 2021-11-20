// const postcss_autoprefixer = require ('autoprefixer');
const postcss_nested = require ('postcss-nested');
const postcss_preset_env = require ('postcss-preset-env');

module.exports = {
    'plugins' : [
        postcss_preset_env ({ 'features' : {
            'double-position-gradients' : false, // See: https://github.com/csstools/postcss-preset-env/issues/223
        } }),
        // postcss_autoprefixer,
        postcss_nested,
    ],
};
