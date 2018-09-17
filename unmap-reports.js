#!/usr/bin/env node

/*
Quick'n'dirty utility to remap csslint error messages to the less input files
and format them for emacs.

Usage: csslint --format compact <cssfiles> | node unmap-reports
*/

var source_map = require ('source-map'); // See: https://github.com/mozilla/source-map/
var fs         = require ('fs');
var pth        = require ('path');
var _          = require ('lodash');
// var yargs      = require ('yargs');

var re = new RegExp ('^(.*?): line ([0-9]+), col ([0-9]+), (.*)$', 'mg');

var stdin = fs.readFileSync ('/dev/stdin', 'utf8');

var messages = [];
while (m = re.exec (stdin)) {
    messages.push ( [m[1], m[2], m[3], m[4]] );
};

// group by path
_.forEach (_.groupBy (messages, '0'), function (messages, path) {
    var dir = pth.dirname (path)
    var map = fs.readFileSync (path + '.map', 'utf8');
    if (map) {
        var smc = new source_map.SourceMapConsumer (map);
        _.forEach (messages, function (msg) {
            const line   = parseInt (msg[1]) || 1; // smc doesn't like line 0
            const column = parseInt (msg[2]) || 1;
            const o      = smc.originalPositionFor ({ line : line, column : column });
            if (o.source) {
                console.log (pth.normalize (dir + '/' + o.source) + ':' + o.line + ':' + (o.column + 1) + ':' + msg[3]);
            } else {
                console.log (msg[0] + ':' + msg[1] + ':' + msg[2] + ':' + msg[3]);
            }
        });
    } else {
        _.forEach (messages, function (msg) {
            console.log (msg[0] + ':' + msg[1] + ':' + msg[2] + ':' + msg[3]);
        });
    }
});
