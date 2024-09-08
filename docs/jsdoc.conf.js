'use strict';

module.exports = {
    'plugins' : [
        './jsdoc-vue-plugin',
        // 'node_modules/jsdoc-vuejs',
    ],
    'source' : {
        'includePattern' : '.+\\.(js|vue)$',
    },
    'recurseDepth' : 10,
    'sourceType'   : 'module',
    'tags'         : {
        'allowUnknownTags' : true,
        'dictionaries'     : ['jsdoc', 'closure'],
    },
    'templates' : {
        'cleverLinks'    : false,
        'monospaceLinks' : false,
    },
};
