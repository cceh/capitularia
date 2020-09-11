module.exports = {
    // See: http://eslint.org/docs/rules/
    'extends' : [
        // 'airbnb'
        'airbnb-base/legacy',
        // 'eslint:recommended'
        'plugin:vue/recommended',
    ],
    'env' : {
        'es6'      : true,
        'browser'  : true,
        'commonjs' : true,
        'jquery'   : true,
    },
    'parserOptions' : {
        'sourceType'  : 'module',
        'ecmaVersion' : 8,
    },
    'globals' : {
        'ajaxurl'            : 'readonly',  // added by wordpress
        'pagenow'            : 'readonly',  // added by wordpress
        'typenow'            : 'readonly',  // added by wordpress
        'adminpage'          : 'readonly',  // added by wordpress
        'thousandsSeparator' : 'readonly',  // added by wordpress
        'decimalPoint'       : 'readonly',  // added by wordpress
        'isRtl'              : 'readonly',  // added by wordpress
        'wp'                 : 'readonly',  // added by wordpress
        'cap_lib'            : 'readonly',
    },
    'rules' : {
        // restrict airbnb

        // style.js
        'comma-dangle' : ['error', {
            'arrays'  : 'always-multiline',
            'objects' : 'always-multiline',
        }],
        'func-call-spacing' : ['error', 'always'],
        'indent'            : [
            'error', 4, {
                'SwitchCase'         : 0,
                'VariableDeclarator' : 1,
                'outerIIFEBody'      : 1,
                'MemberExpression'   : 1,
            },
        ],
        'key-spacing' : [
            'error', {
                'singleLine' : {
                    'beforeColon' : true,
                    'afterColon'  : true,
                },
                'multiLine' : {
                    'beforeColon' : true,
                    'afterColon'  : true,
                    'align'       : 'colon',
                },
            },
        ],
        'max-len' : ['warn', 120, 4, {
            'ignoreUrls'     : true,
            'ignoreComments' : false,
        }],
        'quote-props'                 : ['error', 'always'],
        'space-before-function-paren' : ['error', 'always'],

        // best-practices.js
        'curly'  : ['error', 'all'],
        'eqeqeq' : ['error', 'always'],

        // variables.js
        'no-unused-vars' : ['error', { 'argsIgnorePattern' : '^dummy_' }],

        'no-continue' : 'off',

        // strict.js
        'strict' : 'off',

        // relax airbnb

        // style.js
        'camelcase'            : 'off',
        'func-names'           : 'off',
        'no-mixed-operators'   : ['error', { 'allowSamePrecedence' : true }],
        'no-spaced-func'       : 'off',
        'no-underscore-dangle' : 'off',
        'no-plusplus'          : 'off',

        // best practices
        'no-multi-spaces'   : 'off',
        'no-param-reassign' : 'off',
        'vars-on-top'       : 'off',

        // disallow certain syntax forms
        // http://eslint.org/docs/rules/no-restricted-syntax
        'no-restricted-syntax' : [
            'error',
            'ForInStatement',
            'LabeledStatement',
            'WithStatement',
        ],

        // import.js
        'import/no-amd' : 'off',

        'object-curly-newline' : ['error', { 'consistent' : true }],

        'vue/max-attributes-per-line' : ['error', {
            'singleline' : 4,
            'multiline'  : {
                'max'            : 4,
                'allowFirstLine' : true,
            },
        }],
        'vue/html-closing-bracket-newline' : ['error', {
            'singleline' : 'never',
            'multiline'  : 'never',
        }],
    },
};
