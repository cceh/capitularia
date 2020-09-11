module.exports = {
    'plugins' : [
        'stylelint-scss',
    ],
    'extends' : 'stylelint-config-sass-guidelines',
    'rules'   : {
        'color-named' : 'always-where-possible',
        'declaration-colon-space-after' : 'at-least-one-space',
        'indentation' : 4,
        'max-nesting-depth' : null,
        'order/properties-alphabetical-order' : null,
        'scss/dollar-variable-colon-space-after' : 'at-least-one-space',
        'selector-class-pattern' : '[-a-z]+|tei-[a-zA-Z]+',
        'selector-max-compound-selectors' : null,
        'selector-max-id' : 1,
        'selector-no-qualifying-type' : 'off',
    },
};
