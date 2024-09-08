""" Convert .po files to .json files suited for Wordpress.

.. seealso::

    - https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html
    - https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
    - https://polib.readthedocs.io/en/latest/index.html

Example of output:

{
  "generator": "po2json.py",
  "domain": "cap-collation",
  "locale_data": {
    "messages": {
      "": {
        "domain":       "cap-collation",
        "plural-forms": "nplurals=2; plural=n != 1",
        "lang":         "en-gb"
      },
      "This file is too big. Files must be less than %d KB in size.": [
        "This file is too big. Files must be less than %d KB in size."
      ],
      "%d Theme Update": [
        "%d Theme Update",
        "%d Theme Updates"
      ],
      "password strength\u0004Medium": [
        "Medium"
      ],
      "taxonomy singular name\u0004Category": [
        "Category"
      ],
      "post type general name\u0004Pages": [
        "Pages"
      ]
    }
  }
}
"""

import argparse
import json as js
import os.path

import polib

DEF_DOMAIN = "messages"
""" The default text domain. """

GOOD_FILETYPES = ".js .ts .vue".split()
""" Only collects messages occurring in these file types. """


def in_good_filetype(occurences: list[tuple[str, int]]):
    return any([os.path.splitext(o[0])[1] in GOOD_FILETYPES for o in occurences])


def main(args: argparse.Namespace):
    po = polib.pofile(args.infile)

    json = {
        "generator": "po2json.py",
        "domain": args.domain,
        "locale_data": {
            "messages": {
                "": {
                    "domain": args.domain,
                    "lang": args.language or po.metadata["Language"],
                    "plural-forms": args.plurals or po.metadata["Plural-Forms"],
                },
            }
        },
    }
    msgs = json["locale_data"]["messages"]

    for entry in po:
        if not entry.obsolete and in_good_filetype(entry.occurrences):
            # Note: from the example found in the Wordpress docs it looks like we have
            # to write only the singular id for plural forms
            msgid = entry.msgid_with_context
            msgstr = []
            if entry.msgid_plural:
                for i in sorted(entry.msgstr_plural):
                    msgstr.append(entry.msgstr_plural[i])  # type: ignore
            else:
                msgstr.append(entry.msgstr)

            msgs[msgid] = msgstr

    args.outfile.write(js.dumps(json, indent=2, ensure_ascii=False))


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,  # don't wrap my description
        description=__doc__,
    )

    parser.add_argument(
        "--domain",
        type=str,
        default=DEF_DOMAIN,
        help=f"The text domain. Defaults to '{DEF_DOMAIN}'.",
    )
    parser.add_argument(
        "--language",
        type=str,
        default=None,
        help="The language. Defaults to the .po file.",
    )
    parser.add_argument(
        "--plurals",
        type=str,
        default=None,
        help="The plural forms. Defaults to the .po file.",
    )
    parser.add_argument("infile", type=str, help="The .po input file")

    parser.add_argument(
        "outfile", type=argparse.FileType("w"), help="The .json output file"
    )

    main(parser.parse_args())
