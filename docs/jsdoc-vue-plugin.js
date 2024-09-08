/**
 * A bare-bones JSDoc plugin to read vue files.
 */

const sfc = require ('@vue/compiler-sfc');

const re_ext = /\.vue$/;

/*
 * In files that do not end in .js JSDoc produces bogus module names for a
 * bare @module directive, eg: "longname" is "cap-tab.module:vue" instead of
 * "module:cap-tab"
 *
 * The reason is in file node_modules/jsdoc/lib/jsdoc/tag/dictionary/definitions.js in
 * function setDocletNameToFilename(doclet). You have to patch that function to
 * recognize the .vue extension as not part of the module name.
 *
 *   name += doclet.meta.filename.replace(/\.(js|jsx|jsdoc|vue)$/i, '');
 */

exports.handlers = {
    beforeParse (e) {
        if (re_ext.test (e.filename)) {
            const output = sfc.parse (e.source, { 'pad' : 'line' });
            e.source = output.descriptor.script ? output.descriptor.script.content : '';
        }
    },
};

exports.defineTags = (dictionary) => {
    dictionary.lookUp ('module').synonym ('component');
};
