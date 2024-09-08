import globals from 'globals';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import js from '@eslint/js';
import { FlatCompat } from '@eslint/eslintrc';

const __filename = fileURLToPath (import.meta.url);
const __dirname = path.dirname (__filename);
const compat = new FlatCompat ({
    'baseDirectory'     : __dirname,
    'recommendedConfig' : js.configs.recommended,
    'allConfig'         : js.configs.all,
});

export default [...compat.extends ('airbnb-base', 'plugin:vue/vue3-essential'), {
    'languageOptions' : {
        'globals' : {
            ...globals.browser,
            ...globals.jquery,
            'ajaxurl'                 : 'readonly',
            'pagenow'                 : 'readonly',
            'typenow'                 : 'readonly',
            'adminpage'               : 'readonly',
            'thousandsSeparator'      : 'readonly',
            'decimalPoint'            : 'readonly',
            'isRtl'                   : 'readonly',
            'wp'                      : 'readonly',
            'cap_lib'                 : 'readonly',
            'api_base_url'            : 'readonly',
            '__webpack_public_path__' : 'readonly',
        },

        'ecmaVersion' : 2020,
        'sourceType'  : 'module',
    },

    'rules' : {
        'comma-dangle' : ['error', {
            'arrays'  : 'always-multiline',
            'objects' : 'always-multiline',
        }],

        'func-call-spacing' : ['error', 'always'],

        'indent' : ['error', 4, {
            'SwitchCase'         : 0,
            'VariableDeclarator' : 1,
            'outerIIFEBody'      : 1,
            'MemberExpression'   : 1,
        }],

        'key-spacing' : ['error', {
            'singleLine' : {
                'beforeColon' : true,
                'afterColon'  : true,
            },

            'multiLine' : {
                'beforeColon' : true,
                'afterColon'  : true,
                'align'       : 'colon',
            },
        }],

        'max-len' : ['warn', 120, 4, {
            'ignoreUrls'     : true,
            'ignoreComments' : false,
        }],

        'quote-props'                 : ['error', 'always'],
        'space-before-function-paren' : ['error', 'always'],
        'curly'                       : ['error', 'all'],
        'eqeqeq'                      : ['error', 'always'],

        'no-unused-vars' : ['error', {
            'argsIgnorePattern' : '^dummy_',
        }],

        'no-continue' : 'off',
        'strict'      : 'off',
        'camelcase'   : 'off',
        'func-names'  : 'off',

        'no-mixed-operators' : ['error', {
            'allowSamePrecedence' : true,
        }],

        'no-spaced-func'       : 'off',
        'no-underscore-dangle' : 'off',
        'no-plusplus'          : 'off',
        'no-multi-spaces'      : 'off',
        'no-param-reassign'    : 'off',
        'vars-on-top'          : 'off',
        'no-restricted-syntax' : ['error', 'ForInStatement', 'LabeledStatement', 'WithStatement'],
        'import/no-amd'        : 'off',

        'object-curly-newline' : ['error', {
            'consistent' : true,
        }],

        'no-cond-assign' : 'off',

        'vue/max-attributes-per-line' : ['error', {
            'singleline' : 4,
            'multiline'  : 4,
        }],

        'vue/html-closing-bracket-newline' : ['error', {
            'singleline' : 'never',
            'multiline'  : 'never',
        }],
    },
}];
