/*
 * The dynamic menu is generated from xpath expressions that query the page
 * content.  There is one xpath expression for every level of the menu.  Use the
 * standard wordpress admin interface to define the xpath expressions:
 *
 * To make a dynamic menu, insert a _Custom Link_ item into any Wordpress menu
 * and give it a magic url of: _#cap\_dynamic\_menu#_.  The _Custom Link_
 * item will be replaced by the generated menu.
 *
 * Put all the xpath expressions for each level of the menu into the
 * _Description_ field.  Separate each level with a _§_ (section sign).
 *
 * The default xpath expressions are: //h3[@id]§//h4[@id]§//h5[@id]§//h6[@id],
 * which generate a 4 level deep menu built from h3-h6 elements that have an
 * _id_ attribute.
 *
 * The caption of a generated menu item is taken from the
 * _data-cap-dyn-menu-caption_ attribute on the source element or
 * from the source element's _textContent_.
 *
 * All classes in the _CSS Classes_ field in the Wordpress admin interface are
 * copied over to each generated menu item along with a class
 * _$class-level-$level_.  Eg. a class of _my-menu_ would become _my_menu_ and
 * _my-menu-level-1_.
 *
 * All classes on the elements matched with the xpath expressions, that start
 * with _dynamic-menu-_, are copied to each generated menu item.
 *
 * Additionally classes named _menu-item_,
 * _dynamic-menu-item_, and
 * _dynamic-menu-item-level-$level_ are added to each generated menu
 * item.
 *
 *
 * We use webpack as a workaround to load javascript modules in Wordpress.
 * Wordpress cannot load javascript modules thru enqueue_script () because it
 * lacks an option to specify type="module" on the <script> element.  Webpack
 * also packs babel-runtime for us.  babel-runtime is required for async
 * functions.
 */

const MAGIC = '#cap_dynamic_menu#';

(function ($) {
    function init_dynamic_menues () {
        let menu_id = 1;
        let last_id = 1;
        for (const menu of document.querySelectorAll (`a[href="${MAGIC}"]`)) {
            const target = (menu.getAttribute ('target')
                            // default xpath expressions (a §-separated list)
                            || '//h3[@id]§//h4[@id]§//h5[@id]§//h6[@id]')
            // undo the bloody wp_texturizer
                .replace (/[′’]/g, "'")
                .replace (/[”]/g,  '"');
            const wp_classes = (menu.parentNode.getAttribute ('class') || '').trim ().split (' ');
            const level_attr = 'data-cap-level-' + menu_id;

            // set the attribute 'data-cap-level-*' on all source items
            let cap_level = 1;
            for (const xpath of target.split ('§')) {
                const snapshot = document.evaluate (
                    xpath, document.body, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
                );
                for (let i = 0; i < snapshot.snapshotLength; ++i) {
                    const n = snapshot.snapshotItem (i);
                    n.setAttribute (level_attr, cap_level);
                    n.setAttribute (
                        'data-cap-dyn-menu-caption',
                        n.getAttribute ('data-cap-dyn-menu-caption') || n.textContent || ''
                    );
                }
                ++cap_level;
            }

            // now get the source items in document order
            const last_node_on_level = {};
            let last_level = 1;
            const a = [];

            for (const n of document.querySelectorAll (`[${level_attr}]`)) {
                const id      = 'cap-menu-item-id-' + last_id++;
                const href    = n.hasAttribute ('id') ? '#' + n.getAttribute ('id') : n.getAttribute ('href');
                const level   = Number (n.getAttribute (level_attr));
                let   caption = n.getAttribute ('data-cap-dyn-menu-caption');
                const title   = caption.replace (/\s+/g, ' ').trim ();

                // optionally shorten nested menu entries (eg. BK 123 c. 2)
                if (level > 1 && n.hasAttribute ('data-fold-menu-entry')) {
                    const parent_caption = last_node_on_level[level - 1].getAttribute ('data-cap-dyn-menu-caption');
                    if (caption && parent_caption && caption.indexOf (parent_caption) === 0) {
                        caption = caption.substr (parent_caption.length).trim ();
                    }
                }

                // add classes keyed to level from the wordpress menu definition
                const classes = ['dynamic-menu-item'];
                classes.push (`dynamic-menu-item-level-${level}`);
                for (const wp_class of wp_classes) {
                    classes.push (wp_class);
                    classes.push (`${wp_class}-level-${level}`);
                }

                // copy classes that start with 'dynamic-menu-' from the
                // HTML of the page to the menu.  This is a way to style
                // arbitrary entries of the menu.
                const html_classes = (n.getAttribute ('class') || '').trim ().split (' ');
                for (let html_class of html_classes) {
                    classes.push (`${html_class}-level-${level}`);
                    if (html_class.startsWith ('dynamic-menu-')) {
                        classes.push (html_class);
                    }
                }

                if (level === last_level) {
                    a.push ('</li>');
                }
                for (let i = level; i < last_level; ++i) {
                    a.push ('</li>');
                    a.push ('</ul>');
                }
                for (let i = level; i > last_level; --i) {
                    a.push ('<ul>');
                }

                a.push (`<li id="${id}" class="${classes.join (' ')}">`);
                a.push (`<a href="${href}" title="${title}">${caption}</a>`);

                last_node_on_level[level] = n;
                last_level = level;
            }
            a.push ('</li>');
            menu.parentNode.outerHTML = a.join ('\n');
            ++menu_id;
        }

        const toc = $ ('div.sidebar-toc > ul');

        toc.css ('display', 'none');

        // Initializes the sidebar menu collapsibles

        $ ('li.dynamic-menu-item').each (function () {
            const $this = $ (this);
            const id = $this.attr ('id') + '-ul';
            if ($this.children ('ul').length > 0) {
                $this.children ('a').addClass ('has-opener');
                $ ('<a class="opener"/>').prependTo ($this)
                    .attr ('data-toggle', 'collapse')
                    .attr ('data-target', '#' + id)
                    .addClass ('collapsed');
                $this.children ('ul').attr ('id', id).addClass ('collapse sub-menu');
            }
        });

        // Remove dangling links

        toc.find ('a[href]').each (function () {
            // jquery interprets #BK.123 as selector id=BK and class=123
            let href = $ (this).attr ('href');
            if (href[0] === '#') {
                href = '#' + $.escapeSelector (href.slice (1));
                if ($ (href).length === 0) {
                    $ (this).removeAttr ('href');
                }
            }
        });

        toc.css ('display', '');
    }

    $ (document).ready (function () {
        init_dynamic_menues ();
    });
} (jQuery));
