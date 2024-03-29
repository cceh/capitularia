const compiler = require.resolve ('@vue/compiler-sfc/');

// @see http://usejsdoc.org/about-plugins.html

exports.handlers = {
    beforeParse (e) {
        if (/\.vue$/.test (e.filename)) {
            const output = compiler.parseComponent (e.source, { 'pad' : 'line' });
            e.source = output.script ? output.script.content : '';
        }
    },
};

exports.defineTags = function (dictionary) {
    dictionary.lookUp ('module').synonym ('component');
};
