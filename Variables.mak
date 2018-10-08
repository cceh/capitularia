AFS     := $(or $(CAPITULARIA_AFS),/afs/rrz/vol/www/projekt/capitularia)
LOCALFS := $(or $(CAPITULARIA_LOCALFS),/var/www/capitularia)
BROWSER := $(or $(BROWSER),firefox)
GITUSER := $(CAPITULARIA_GITUSER)

WPCONTENT := $(AFS)/http/docs/wp-content
PUBL	  := $(AFS)/http/docs/cap/publ
TRANSFORM := $(AFS)/http/docs/cap/publ/transform

WPCONTENTLOCAL := $(LOCALFS)/wp-content

NODE_MODULES := ../../node_modules
NODE         := $(NODE_MODULES)/.bin

BABEL           = $(NODE)/babel
BABELFLAGS      = --source-maps true
SASS            = $(NODE)/sass
SASSFLAGS       = -I $(CSS_SRC)
POSTCSS         = $(NODE)/postcss
POSTCSSFLAGS    =
ESLINT         := eslint
ESLINTFLAGS     = -f unix
JSHINT         := jshint
JSHINTFLAGS     = --reporter=unix
STYLELINT       = $(NODE)/stylelint $(STYLELINTFLAGS)
STYLELINTFLAGS  = -f unix
RSYNC          := rsync -rlptz --exclude='*~' --exclude='.*'

PHP_FILES         ?= $(wildcard $(PHP_SRC)/*.php)
JS_SRC_FILES      ?= $(wildcard $(JS_SRC)/*.js)
CSS_SRC_FILES     ?= $(CSS_SRC)/front.scss $(CSS_SRC)/admin.scss
CSSIMG_SRC_FILES  ?= $(CSSIMG_SRC)/*.png

JS_DEST_FILES     := $(patsubst $(JS_SRC)/%,$(JS_DEST)/%,$(JS_SRC_FILES))
CSS_DEST_FILES    := $(patsubst $(CSS_SRC)/%.scss,$(CSS_DEST)/%.css,$(CSS_SRC_FILES))
CSSIMG_DEST_FILES := $(patsubst $(CSSIMG_SRC)/%,$(CSSIMG_DEST)/%,$(CSSIMG_SRC_FILES))

JSON_FILES     = $(wildcard *.json)
