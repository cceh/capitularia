/** @module plugins/dynamic-menu */

/**
 * The dynamic menu applet.
 *
 * The dynamic menu is generated from xpath expressions that query the
 * page content.  There is one xpath expression for every level of the menu.
 * Use the standard wordpress admin interface to define the xpath expressions:
 *
 * To make a dynamic menu, insert a *Custom Link* item into any Wordpress menu
 * and give it a magic url of: :code:`#cap_dynamic_menu#`.  The *Custom Link*
 * item will be replaced by the generated menu.
 *
 * Put all the xpath expressions for each level of the menu into the
 * *Description* field.  Separate each level with a :code:`§` (section sign).
 *
 * The default xpath expressions are:
 * :code:`//h3[@id]§//h4[@id]§//h5[@id]§//h6[@id]`, which generate a 4 level
 * deep menu built from all <h3>-<h6> elements that have an :code:`id`
 * attribute.
 *
 * The caption of a generated menu item is taken from the
 * :code:`data-cap-dyn-menu-caption` attribute on the source element or
 * from the source element's :code:`textContent`.
 *
 * All classes in the *CSS Classes* field in the Wordpress admin interface are
 * copied over to each generated menu item along with a class
 * :code:`$class-level-$level`.  Eg. a class of :code:`my-menu` would become
 * :code:`my_menu` and :code:`my-menu-level-1`.
 *
 * All classes on the elements matched with the xpath expressions, that start
 * with :code:`dynamic-menu-`, are copied to each generated menu item.
 *
 * Additionally classes named :code:`menu-item`, :code:`dynamic-menu-item`, and
 * :code:`dynamic-menu-item-level-$level` are added to each generated menu item.
 *
 * .. note::
 *
 *    We use webpack as a workaround to load javascript modules in Wordpress.
 *    Wordpress cannot load javascript modules thru enqueue_script () because it
 *    lacks an option to specify type="module" on the <script> element.  Webpack
 *    also packs babel-runtime for us.  babel-runtime is required for async
 *    functions.
 *
 * @file
 */

/**
 * Initialize all dynamic menus on the page.
 *
 * This routine looks for an <a> with the :code:`data-cap-dynamic-menu`
 * attribute and transmogrifies it into the real menu by going through the DOM
 * of the page and adding all elements that fit the xpath'es in the attribute.
 *
 * @memberof module:plugins/dynamic-menu
 */
function init_dynamic_menues () {
    let menu_id = 1;
    let last_id = 1;
    for (const menu of document.querySelectorAll (`a[data-cap-dynamic-menu]`)) {
        const xpathes = (menu.getAttribute ('data-cap-dynamic-menu')
                         // default xpath expressions (a §-separated list)
                         || '//h3[@id]§//h4[@id]§//h5[@id]§//h6[@id]')
        // undo the bloody wp_texturizer that even messes with html data attributes
            .replace (/[′’]/g, "'")
            .replace (/[”]/g,  '"');
        const wp_classes = (menu.parentNode.getAttribute ('class') || '').trim ().split (' ');
        const level_attr = 'data-cap-level-' + menu_id;

        // set the attribute 'data-cap-level-*' on all source items
        let cap_level = 1;
        for (const xpath of xpathes.split ('§')) {
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
            if (href) {
                a.push (`<a href="${href}" title="${title}">${caption}</a>`);
            } else {
                a.push (`<a title="${title}">${caption}</a>`);
            }

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

init_dynamic_menues ();
