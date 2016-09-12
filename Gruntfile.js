module.exports = function (grunt) {

    var php_files = ['themes/**/*.php', 'plugins/**/*.php'];

    var afs =  grunt.option ('afs') || process.env.GRUNT_CAPITULARIA_AFS || "/afs/rrz/vol/www/projekt/capitularia";

    var localfs = grunt.option ('localfs') || process.env.GRUNT_CAPITULARIA_LOCALFS ||
        "/var/www/capitularia";

    var git_user = grunt.option ('gituser') || process.env.GRUNT_CAPITULARIA_GITUSER;

    var browser = grunt.option ('browser') || process.env.GRUNT_BROWSER || "iceweasel";

    grunt.initConfig ({
        afs:            afs,
        localfs:        localfs,
        browser:        browser,
        rsync:          "rsync -rlptz --exclude='*~' --exclude='.*' --exclude='*.less' --exclude='node_modules'",
        transform:      afs     + "/http/docs/cap/publ/transform",
        wpcontent:      afs     + "/http/docs/wp-content",
        wpcontentlocal: localfs + "/wp-content",
        gituser:        git_user,
        pkg:            grunt.file.readJSON ('package.json'),

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
            files: ['Gruntfile.js', 'themes/Capitularia/js/*.js', 'plugins/**/*.js']
        },

        phplint: {
            themes:  ['themes/**/*.php'],
            plugins: ['plugins/**/*.php']
        },

        csslint: {
            options: {
                "adjoining-classes":      false,   // concerns IE6
                "box-sizing":             false,   // concerns IE6,7
                "ids":                    false,
                "overqualified-elements": false,
                "qualified-headings":     false,
            },
            src:  ['themes/Capitularia/css/*.css', 'plugins/**/*.css']
        },

        pot: {
            options: {
                text_domain: "capitularia",
                encoding: "utf-8",
                dest: 'themes/Capitularia/languages/',
                keywords: ['__', '_e', '_n:1,2', '_x:1,2c'],
                msgmerge: true,
            },
            files: {
                src: php_files,
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

        shell: {
            options: {
                cwd: ".",
                failOnError: false,
            },
            deploy: {
                command: '<%= rsync %> themes/Capitularia/* <%= wpcontent %>/themes/Capitularia/ ; <%= rsync %> plugins/cap-* <%= wpcontent %>/plugins/; <%= rsync %> xslt/*.xsl xslt/test/*xml <%= transform %>/',
            },
            testdeploy: {
                command: '<%= rsync %> themes/Capitularia/* <%= wpcontentlocal %>/themes/Capitularia/ ; <%= rsync %> plugins/cap-* <%= wpcontentlocal %>/plugins/',
            },
            phpcs: {
                /* PHP_CodeSniffer https://github.com/squizlabs/PHP_CodeSniffer */
                command: 'vendor/bin/phpcs --standard=tools/phpcs --report=emacs -s --extensions=php themes plugins',
            },
            phpdoc: {
                /* phpDocumentor http://www.phpdoc.org/ */
                command: 'vendor/bin/phpdoc run --directory="themes,plugins" --target="tools/reports/phpdoc" --template="responsive-twig" --title="Capitularia" && <%= browser %> tools/reports/phpdoc/index.html',
            },
            phpmd: {
                /* PHP Mess Detector http://phpmd.org/ */
	            command: 'vendor/bin/phpmd "themes,plugins" html tools/phpmd/ruleset.xml --reportfile "tools/reports/phpmd/index.html" ; <%= browser %> tools/reports/phpmd/index.html',
	        },
            phpmetrics: {
                /* PhpMetrics http://www.phpmetrics.org/ */
                command: 'vendor/bin/phpmetrics --config="tools/phpmetrics/config.yml" . && <%= browser %> tools/reports/phpmetrics/index.html',
            },
            sami: {
                /* Sami Documentation Generator https://github.com/FriendsOfPHP/Sami */
                command: 'vendor/bin/sami.php update tools/sami/config.php && <%= browser %> tools/reports/sami/build/index.html',
            },
            'git-fetch-collation': {
                command: 'git clone https://<%= gituser %>@github.com/cceh/capitularia-collation.git <%= afs %>/local/capitularia-collation',
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
    grunt.loadNpmTasks ('grunt-phplint');
    grunt.loadNpmTasks ('grunt-pot');
    grunt.loadNpmTasks ('grunt-potomo');
    grunt.loadNpmTasks ('grunt-shell');

    grunt.registerTask ('phpcs',      ['shell:phpcs']);
    grunt.registerTask ('phpdoc',     ['shell:phpdoc']);
    grunt.registerTask ('phpmd',      ['shell:phpmd']);
    grunt.registerTask ('phpmetrics', ['shell:phpmetrics']);
    grunt.registerTask ('sami',       ['shell:sami']);
    grunt.registerTask ('git',        ['shell:git-fetch-collation']);

    grunt.registerTask ('lint',       ['phplint', 'jshint']);
    grunt.registerTask ('mo',         ['pot', 'potomo']);
    grunt.registerTask ('doc',        ['phpdoc', 'phpmd', 'phpmetrics', 'sami']);
    grunt.registerTask ('testdeploy', ['lint', 'less', 'mo', 'shell:testdeploy']);
    grunt.registerTask ('deploy',     ['lint', 'less', 'mo', 'shell:deploy']);

    grunt.registerTask ('default',    ['lint', 'less']);
};
