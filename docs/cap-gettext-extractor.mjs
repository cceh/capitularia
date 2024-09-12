import { GettextExtractor, JsExtractors, HtmlExtractors } from 'gettext-extractor';
import sfc from '@vue/compiler-sfc';
import { glob } from 'glob';
import { readFileSync } from 'node:fs';
import { ArgumentParser } from 'argparse';
import sourceMap from 'source-map';
import _ from 'lodash-es';

const sourceMaps = {};

const JSExtractor = new GettextExtractor();
const VueExtractor = new GettextExtractor();

/**
 * Extractor for JS files and <script> sections of Vue files.
 */
const jsParser = JSExtractor.createJsParser([
    JsExtractors.callExpression(['wp.i18n.__', '[this].$t', 'vm.$t'], {
        arguments: {
            text: 0,
        }
    }),
    JsExtractors.callExpression(['wp.i18n._x', '[this].$x', 'vm.$x'], {
        arguments: {
            text: 0,
            context: 1,
        }
    }),
    JsExtractors.callExpression(['wp.i18n._n', '[this].$n', 'vm.$n'], {
        arguments: {
            text: 0,
            textPlural: 1,
            context: 3
        }
    })
]);

/**
 * Extractor for a compiled Vue template.
 */
const vueParser = VueExtractor.createJsParser([
    JsExtractors.callExpression(['_ctx.$t'], {
        arguments: {
            text: 0,
            context: 1
        }
    }),
    JsExtractors.callExpression(['_ctx.$n'], {
        arguments: {
            text: 0,
            textPlural: 1,
            context: 2
        }
    })
]);

/**
 * Extractor for a HTML Vue template.
 */
const htmlParser = JSExtractor.createHtmlParser([
    HtmlExtractors.elementContent('*[v-translate]', {})
]);


function jsParseString (code, file, line) {
    jsParser.parseString (
        code,
        file,
        { lineNumberStart: line }
    )
}

async function main (args) {

    for (const glb of args.inputs) {
        const filenames = glob.sync (glb).sort ();

        for (const filename of filenames) {
            if (args.verbose)
                console.log(`Scanning: ${filename}`);

            const file = readFileSync (filename, { 'encoding' : 'utf-8' });

            if (filename.endsWith ('.vue')) {
                const { descriptor } = sfc.parse (file, { filename });

                if (descriptor.template && descriptor.template.content) {
                    const template = descriptor.template;
                    // if (filename.endsWith ('selector.vue')) {
                    //     console.dir(template, { depth: 4 });
                    //     exit ();
                    // }

                    // parse the template in HTML
                    htmlParser.parseString (
                        template.loc.source,
                        filename,
                        {
                            lineNumberStart: template.loc.start.line,
                            trimWhiteSpace: true,
                        }
                    );

                    // compile the template into JS
                    const compiled = sfc.compileTemplate ({
                        source: template.loc.source,
                        filename,
                        id: filename,
                        inMap: template.map,
                    });

                    // if (filename.endsWith ('selector.vue')) {
                    //     console.log(compiled.code);
                    //     exit();
                    // }

                    vueParser.parseString (
                        compiled.code,
                        filename,
                        // FIXME: it should be made possible to pass a sourceMap into this
                        { lineNumberStart: 1 }
                    )

                    // build a map that actually works because
                    // SourceMapConsumer.originalPositionFor(generatedPosition) surely
                    // does not!
                    new sourceMap.SourceMapConsumer(compiled.map).eachMapping((m) => {
                        sourceMaps[`${m.source}:${m.generatedLine}`] = `${m.source}:${m.originalLine}`;
                        // console.log(`${m.source}:${m.generatedLine} => ${m.source}:${m.originalLine}`);
                    }, this, sourceMap.SourceMapConsumer.ORIGINAL_ORDER);
                }

                if (descriptor.script && descriptor.script.content) {
                    // the <script> section of a Vue file
                    const script = descriptor.script;
                    jsParseString (
                        script.loc.source,
                        filename,
                        script.loc.start.line,
                    );
                }
            } else {
                // a plain old JS file
                jsParseString (
                    file,
                    filename,
                    0,
                );
            }
        }
    }

    for (const vueMsg of VueExtractor.getMessages()) {
        const msg = _.pick (vueMsg, ['text', 'references', 'comments']);
        if (vueMsg.textPlural)
            msg.textPlural = vueMsg.textPlural;
        if (vueMsg.context)
            msg.context = vueMsg.context;
        msg.references = vueMsg.references.map ((ref) => {
            const sref = sourceMaps[ref];
            console.log (ref, sref, msg.text);
            return sref || ref;
        });
        JSExtractor.addMessage (msg);
    }

    if (args.output == '-')
        process.stdout.write (JSExtractor.getPotString ());
    else
        JSExtractor.savePotFile (args.output);

    if (args.verbose)
        JSExtractor.printStats ();
}

const parser = new ArgumentParser ({
    description: 'Extract translatable strings from js and vue files.'
});

parser.add_argument('-v', '--verbose', { action: 'store_true', help: 'Be verbose' });
parser.add_argument('-o', '--output', { default: '-', help: 'Output to file (default stdout).' });
parser.add_argument('inputs', { nargs: '+', help: 'Input files' });

main (parser.parse_args());
