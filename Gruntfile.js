module.exports = function (grunt) {

    grunt.initConfig ({
        afs: grunt.option ('afs') || process.env.GRUNT_CAPITULARIA_AFS ||
            "/afs/rrz/vol/www/projekt/capitularia/http/docs/wp-content",

        pkg: grunt.file.readJSON ('package.json'),

        less: {
            options: {
                banner: "/* Generated file. Do not edit. */\n",
                plugins: [
                    new (require ('less-plugin-autoprefix')) ({ browsers: ["last 2 versions"] })
                ]
            },
            production: {
                files: [
                    {
                        expand: true,
                        src: ['themes/Capitularia/css/*.less', 'plugins/**/*.less'],
                        ext: '.css',
                        extDot: 'last'
                    }
                ]
            }
        },

        jshint: {
            options: {
                globals: {
                    jQuery: true
                }
            },
            files: ['Gruntfile.js', 'themes/Capitularia/js/custom.js', 'plugins/cap*/js/*.js']
        },

        phplint: {
            themes:  ['themes/**/*.php'],
            plugins: ['plugins/**/*.php']
        },

        phpcs: {
            options: {
                // $ sudo apt-get install php-codesniffer
                bin: 'phpcs',
                standard: './phpcs',
                extensions: 'php',
                showSniffCodes: 'true',
                report: 'emacs'
            },
            themes: {
                src:  ['themes/Capitularia/**/*.php']
            },
            plugins: {
                src:  ['plugins/**/*.php']
            },
        },

        csslint: {
            options: {
                "ids": false,
                "adjoining-classes": false,   // IE6
                "box-sizing": false,          // IE6,7
                "qualified-headings": false,
                "overqualified-elements": false
            },
            src:  ['themes/Capitularia/css/*.css', 'plugins/**/*.css']
        },

        pot: {
            options: {
                text_domain: "capitularia",
                encoding: "utf-8",
                dest: 'themes/Capitularia/languages/',
                keywords: ['__', '_n:1,2', '_x'],
                msgmerge: true,
            },
            themes: {
                src: ['themes/Capitularia/**/*.php'],
                expand: true,
            }
        },

        potomo: {
            themes: {
                options: {
                    poDel: false
                },
                files: [{
                    expand: true,
                    src: ['themes/Capitularia/languages/*.po'],
                    dest: './',
                    ext: '.mo',
                    nonull: true,
                }]
            }
        },

        rsync: {
            options: {
                args: ["-rlptz"],
                exclude: ["*~", ".*", "*.less", "node_modules"],
                recursive: true
            },
            themes: {
                options: {
                    src: "themes/Capitularia/*",
                    dest: "<%= afs %>/themes/Capitularia/"
                }
            },
            plugins: {
                options: {
                    src: "plugins/cap-*",
                    dest: "<%= afs %>/plugins/"
                }
            },
        },

        watch: {
            files: ['<%= less.production.files %>'],
            tasks: ['less']
        }
    });

    grunt.loadNpmTasks ('grunt-contrib-csslint');
    grunt.loadNpmTasks ('grunt-contrib-jshint');
    grunt.loadNpmTasks ('grunt-contrib-less');
    grunt.loadNpmTasks ('grunt-contrib-watch');
    grunt.loadNpmTasks ('grunt-phpcs');
    grunt.loadNpmTasks ('grunt-phplint');
    grunt.loadNpmTasks ('grunt-pot');
    grunt.loadNpmTasks ('grunt-potomo');
    grunt.loadNpmTasks ('grunt-rsync');

    grunt.registerTask ('lint',   ['phplint', 'jshint']);
    grunt.registerTask ('mo',     ['pot',     'potomo']);
    grunt.registerTask ('deploy', ['lint',    'less',     'mo', 'rsync']);

    grunt.registerTask ('default', ['lint', 'less']);
};
