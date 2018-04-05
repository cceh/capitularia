=============
 Capitularia
=============

.. revealjs:: Capitularia

   CCeH Cologne --- Marcello Perathoner <marcello@perathoner.de>

   Düsseldorf 07 Mar 2018


.. revealjs:: Use of Wordpress

   Advantages

   * simple functionality out of the box (content, user, ...)
   * you may write plugins for your more exotic functionality

   Disadvantages

   * you are locked into obsolete technology (PHP, mysql)
   * writing a plugin for everything gets tedious
   * some things do not fit well (cron jobs)


.. revealjs:: Current Document Workflow

   .. uml::
      :align: center

      skinparam handwritten true
      left to right direction
      scale 2

      skinparam file {
        backgroundColor gold
      }

      rectangle "Oxygen\n" as o2 {
         file "TEI" as tei1
         file "TEI" as tei2
         file "TEI" as tei3
      }

      cloud "Web Server\n" {
         rectangle "Wordpress\n" as wp #ddd {
            rectangle "Plugin\n" as plugin #bbb {
               rectangle "XSLT 1.0" as xslt
               rectangle "Postprocess" as post
            }
            database "HTML" as db
            file "HTML" as html1
            file "HTML" as html2
            file "HTML" as html3
         }
      }

      tei1 --> xslt
      tei2 --> xslt
      tei3 --> xslt

      xslt --> post
      post --> db

      db --> html1
      db --> html2
      db --> html3

   Drawbacks:

   * Must code everything as plugin in PHP.
   * Web servers at uni-koeln.de are only configured for XSLT 1.0.


.. revealjs:: Future Document Workflow with GitHub

   .. uml::
      :align: center

      skinparam handwritten true
      left to right direction
      scale 2

      skinparam file {
        backgroundColor gold
      }

      rectangle "Oxygen\n" as o2 {
         file "TEI" as tei1
         file "TEI" as tei2
         file "TEI" as tei3
      }

      cloud "GitHub\n" as github {
         database "TEI" as git
         rectangle "webhook" as githook
      }

      cloud "Build\nServer\n" {
         rectangle "XSLT 3.0" as xslt
         rectangle "Makefile" as make
      }

      cloud "Web Server\n" {
         rectangle "Wordpress\n" as wp #ddd {
            database "HTML" as db
            file "HTML" as html1
            file "HTML" as html2
            file "HTML" as html3
         }
      }

      tei1 <--> git
      tei2 <--> git
      tei3 <--> git

      git --> xslt
      git .l.> githook
      githook ..> make
      make .r.> xslt
      xslt --> db

      db --> html1
      db --> html2
      db --> html3

   Open Questions:

   * Oxygen plugin for Git?
   * quick preview for editors?


.. revealjs:: Current Online Collation Tool

   .. uml::
      :align: center

      skinparam handwritten true
      left to right direction
      scale 2

      skinparam rectangle<<layout>> {
         borderColor Transparent
         backgroundColor Transparent
         fontColor Transparent
         shadowColor Transparent
         stereotypeFontColor Transparent
      }

      skinparam file {
         backgroundColor gold
      }

      file "TEI" as tei1
      file "TEI" as tei2
      file "TEI" as tei3

      cloud "Web Server\n" {
         rectangle "Wordpress\n" as wp #ddd {
            rectangle "Plugin\n" as plugin #bbb {
               rectangle "preprocess" as pre
               rectangle "postprocess" as post
               file      "Report" as repo
            }
         }
         rectangle "Collate-X" as cx
      }

      tei1 --> pre
      tei2 --> pre
      tei3 --> pre
      post --> repo

      pre  --> cx
      cx   --> post
      pre  -[hidden]--> post


   Open Questions:

   * Scalability


.. revealjs:: Future Online Collation Tool

   .. uml::
      :align: center

      skinparam handwritten true
      left to right direction
      scale 2

      skinparam file {
         backgroundColor gold
      }

      file "TEI" as tei1
      file "TEI" as tei2
      file "TEI" as tei3

      cloud "Build Server\n" as bs {
         rectangle "preprocess" as pre
         together {
         rectangle "Collate-X" as cx
         rectangle "Controller" as ctrl
         }
         rectangle "postprocess" as post
      }

      cloud "Web Server\n" as ws {
         rectangle "Wordpress" as wp #ddd {
            rectangle "Plugin" as plugin #bbb {
               file "Report" as repo
            }
         }
      }

      tei1 --> pre
      tei2 --> pre
      tei3 --> pre
      pre  --> cx
      cx   --> post
      post --> repo

      ctrl .l.> pre
      ctrl .l.> cx
      ctrl .l.> post
      plugin .u..> ctrl

   Open Questions:

   * Scalability

..
   .. revealjs:: Kollationstool

      .. graphviz::

         digraph G {
            rankdir="LR";
            ordering="out";
            newrank=true;
            edge [color=red];
            graph [fontname="helvetica", fontsize=28, penwidth=2];
            node [shape=rect, style=filled; penwidth=2; color=firebrick; fillcolor=lemonchiffon; fontname="helvetica", fontsize=28];

            tei1 [shape=note,label="TEI"];
            tei2 [shape=note,label="TEI"];
            tei3 [shape=note,label="TEI"];
            tei4 [shape=note,label="TEI"];
            tei5 [shape=note,label="TEI"];

            subgraph cluster_web {
               label="Web Server";
               subgraph cluster_wp {
                  style=filled;
                  fillcolor=lightgray;
                  color="#21759B";
                  label="Wordpress";
                  subgraph cluster_plugin {
                     fillcolor=white;
                     label="Plugin";
                     ex [label="extract"];
                     pre [label="preprocess"];
                     format [label="format"];
                  }
                  repo [shape=note,label="Report"];
               }
               ct [label="Collate-X"]
               post [label="postprocess"]
            }

            {tei1, tei2, tei3, tei4, tei5} -> ex;
            ex -> pre;
            pre -> ct;
            { rank=same; pre; ct }
            { rank=same; post; format }
            ct -> post -> format -> repo;
         }
