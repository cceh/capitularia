# -*- encoding: utf-8 -*-

"""This module contains the sqlalchemy classes that initialize the database structure.

To create a new database: (must be database superuser)

.. code:: shell

   sudo -u postgres psql

.. code:: psql

   CREATE USER capitularia PASSWORD '<password>';
   CREATE DATABASE capitularia OWNER capitularia;

   \\c capitularia
   CREATE EXTENSION pg_trgm WITH SCHEMA public;
   CREATE EXTENSION postgis WITH SCHEMA public;
   CREATE SCHEMA capitularia AUTHORIZATION capitularia;
   CREATE SCHEMA gis AUTHORIZATION capitularia;
   ALTER DATABASE capitularia SET search_path = capitularia, gis, public;
   \\q

.. code:: shell

   make rebuild_db

"""

import lxml.etree as etree
import sqlalchemy
from geoalchemy2 import Geometry
from sqlalchemy import (
    DDL,
    Column,
    Float,
    ForeignKeyConstraint,
    Index,
    Integer,
    PrimaryKeyConstraint,
    String,
    event,
)
from sqlalchemy.dialects.postgresql import ARRAY, INT4RANGE, TEXT
from sqlalchemy.dialects.postgresql.json import JSONB
from sqlalchemy.ext.declarative import declarative_base

# let sqlalchemy manage our views


def view(name, metadata, sql):
    event.listen(
        metadata, "after_create", DDL("CREATE OR REPLACE VIEW %s AS %s" % (name, sql))
    )
    # Use CASCADE to drop dependent views because we drop the views in the same
    # order as we created them instead of correctly using the reverse order.
    event.listen(
        metadata, "before_drop", DDL("DROP VIEW IF EXISTS %s CASCADE" % (name))
    )


class XML(sqlalchemy.types.UserDefinedType):
    def get_col_spec(self):
        return "XML"

    def bind_processor(self, dialect):
        # store
        def process(value):
            if value is None:
                return None
            if isinstance(value, str):
                return value
            else:
                return etree.tostring(value, encoding="unicode")

        return process

    def result_processor(self, dialect, coltype):
        # retrieve
        def process(value):
            if value is None:
                return None
            return etree.fromstring(value)

        return process


Base = declarative_base()

event.listen(
    Base.metadata,
    "before_create",
    DDL(
        """
CREATE SCHEMA capitularia;
ALTER DATABASE capitularia SET search_path = capitularia, public;
"""
    ),
)

event.listen(
    Base.metadata,
    "after_drop",
    DDL(
        """
DROP SCHEMA IF EXISTS capitularia CASCADE;
"""
    ),
)

Base.metadata.schema = "capitularia"

event.listen(
    Base.metadata,
    "after_create",
    DDL(
        r"""
CREATE OR REPLACE FUNCTION natsort (t TEXT) RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
-- SELECT REGEXP_REPLACE ($1, '0*([0-9]+)', length (\1) || \1, 'g');
--
SELECT STRING_AGG (COALESCE (r[2], LENGTH (r[1])::text || r[1]), '')
    FROM REGEXP_MATCHES ($1, '0*([0-9]+)|([^0-9]+)', 'g') r;
$$"""
    ),
)


class Manuscripts(Base):
    r"""Manuscripts

    .. minilang:: sauml -i manuscripts

    """

    __tablename__ = "manuscripts"

    ms_id = Column(String, primary_key=True)
    """ The manuscript id assigned by the Capitularia project. """

    title = Column(String)
    """ The official title of the manuscript. """

    filename = Column(String)
    """The filename of the TEI file containing the transcription of the
    manuscript."""

    status = Column(String)
    """ The Wordpress publication status: either 'publish' or 'private' """

    __table_args__ = ()


class MsParts(Base):
    r"""The parts of a manuscript

    .. minilang:: sauml -i msparts

    """

    __tablename__ = "msparts"

    ms_id = Column(String)

    msp_part = Column(String)
    """ The official designation of the manuscript part. """

    locus_cooked = Column(ARRAY(INT4RANGE))
    """ Ranges of cooked loci. """

    date = Column(INT4RANGE)
    """ When did the manuscript part originate? Range of years. """

    leaf = Column(ARRAY(String))
    """ Size of the leaf. """

    written = Column(ARRAY(String))
    """ Size of the written area. """

    __table_args__ = (
        PrimaryKeyConstraint(ms_id, msp_part),
        ForeignKeyConstraint([ms_id], ["manuscripts.ms_id"], ondelete="CASCADE"),
    )


class Capitularies(Base):
    r"""Capitularies

    All capitularies catalogued according to BK or Mordek.

    .. minilang:: sauml -i capitularies

    """

    __tablename__ = "capitularies"

    cap_id = Column(String, primary_key=True)
    """ The capitulary number, eg. "BK.42"  """

    title = Column(String)
    """ The capitulary title assigned by BK. """

    date = Column(INT4RANGE)

    __table_args__ = ()


class Chapters(Base):
    r"""Chapters

    All chapters catalogued according to BK or Mordek.

    .. minilang:: sauml -i chapters

    """

    __tablename__ = "chapters"

    cap_id = Column(String)

    chapter = Column(String)
    """ The chapter number from 1 to N.  Also: 1_inscription, etc."""

    __table_args__ = (
        PrimaryKeyConstraint(cap_id, chapter),
        ForeignKeyConstraint([cap_id], ["capitularies.cap_id"], ondelete="CASCADE"),
    )


class MssCapitularies(Base):
    r"""A capitulary in a manuscript according to <msDesc>.

    This table also contains capitularies that are not yet transcribed.

    A finer granularity (chapters instead of capitularies) can be found in the
    :class:`MssChapters` table, albeit only already transcribed ones.

    .. minilang:: sauml -i mss_capitularies

    """

    __tablename__ = "mss_capitularies"

    ms_id = Column(String)
    cap_id = Column(String)

    mscap_n = Column(Integer)
    """The n_th occurence of the capitulary in the manuscript.  Default is 1.

    Since msItem does not contain milestones, this value is inferred by counting
    the number of preceding loci that contain this capitulary.

    N.B.: The value in the mss_chapters table is found in a different way.

    """

    msp_part = Column(String)
    """ The official designation of the manuscript part. """

    locus = Column(String)
    """ The locus of this capitulary instance in the ms as recorded
    by the editor, eg. 42ra-45vb. """

    locus_cooked = Column(ARRAY(INT4RANGE))
    """ Ranges of cooked loci. """

    __table_args__ = (
        PrimaryKeyConstraint(ms_id, cap_id, mscap_n),
        ForeignKeyConstraint(
            [ms_id, msp_part], ["msparts.ms_id", "msparts.msp_part"], ondelete="CASCADE"
        ),
        ForeignKeyConstraint([cap_id], ["capitularies.cap_id"], ondelete="CASCADE"),
        {"comment": "according to <msDesc>"},
    )


class MssChapters(Base):
    r"""A chapter in a manuscript according to <body>.

    This table contains only chapters that were already transcribed.

    Note: The table :class:`MssCapitularies` relates manuscripts to
    capitularies yet untranscribed.

    .. minilang:: sauml -i mss_chapters

    """

    __tablename__ = "mss_chapters"

    ms_id = Column(String)
    cap_id = Column(String)
    mscap_n = Column(Integer)
    """This chapter was found in the n_th occurence of the capitulary in the
    manuscript.  Default is 1.

    The value is read from the milestone, eg.:

       <milestone unit='capitulare' n='BK.139_2' />

    marks the second occurence of capitulary 139 in this manuscript.  All
    chapters of BK.139 following this milestone get a value of 2 in this field.

    N.B.: The value in the mss_capitularies table is found in a different way.

    """

    chapter = Column(String)

    msp_part = Column(String)
    """ The official designation of the manuscript part. """

    locus = Column(String)
    """ The locus of the chapter in the manuscript.
    As recorded by the editor, eg. 42ra """

    locus_index = Column(Integer)
    """ The index at the locus, eg. the '1' in 42ra-1 """

    locus_cooked = Column(Integer)
    """ The cooked locus. Locus transformed to a sortable integer. """

    transcribed = Column(Integer, nullable=False, server_default="0")
    """ Is this chapter already transcribed? 0 == no, 1 == partially, 2 == completed """

    xml = Column(XML)
    """ The XML text of the chapter. """

    __table_args__ = (
        PrimaryKeyConstraint(ms_id, cap_id, mscap_n, chapter),
        ForeignKeyConstraint(
            [cap_id, chapter],
            ["chapters.cap_id", "chapters.chapter"],
            ondelete="CASCADE",
        ),
        ForeignKeyConstraint(
            [ms_id, msp_part], ["msparts.ms_id", "msparts.msp_part"], ondelete="CASCADE"
        ),
        {"comment": "according to <body>"},
    )


class MssChaptersText(Base):
    r"""Various kinds of preprocessed texts extracted from the chapter.

    There may be more than one text extracted from the same chapter: the original
    hand and later corrector hands.

    .. minilang:: sauml -i mss_chapters_text

    """

    __tablename__ = "mss_chapters_text"

    ms_id = Column(String)
    cap_id = Column(String)
    mscap_n = Column(Integer)
    chapter = Column(String)

    type_ = Column("type", String)
    """Either 'original' or 'later_hands'.  The type of preprocessing applied.
    Whether the original hand was followed or a later corrector.

    """

    text = Column(TEXT)
    """ The preprocessed plain text of the chapter. """

    __table_args__ = (
        PrimaryKeyConstraint(ms_id, cap_id, mscap_n, chapter, type_),
        ForeignKeyConstraint(
            [ms_id, cap_id, mscap_n, chapter],
            [
                "mss_chapters.ms_id",
                "mss_chapters.cap_id",
                "mss_chapters.mscap_n",
                "mss_chapters.chapter",
            ],
            ondelete="CASCADE",
        ),
    )


event.listen(
    Base.metadata,
    "after_create",
    DDL(
        """
CREATE INDEX IF NOT EXISTS ix_mss_chapters_text_trgm ON mss_chapters_text USING GIN (text gin_trgm_ops);
"""
    ),
)

event.listen(
    Base.metadata,
    "before_drop",
    DDL(
        """
DROP INDEX IF EXISTS ix_mss_chapters_text_trgm;
"""
    ),
)

view(
    "chapters_count_transcriptions",
    Base.metadata,
    """
SELECT cap_id, chapter, COUNT (ms_id) AS transcriptions
FROM chapters
 JOIN mss_chapters mn USING (cap_id, chapter)
GROUP BY cap_id, chapter
""",
)


view(
    "capitularies_view",
    Base.metadata,
    """
    SELECT ms.ms_id, ms.title AS ms_title, msp_part, cap.cap_id, cap.title AS cap_title,
           cap.date, lower (cap.date) as cap_notbefore, upper (cap.date) as cap_notafter
    FROM mss_capitularies mn
      JOIN manuscripts ms USING (ms_id)
      JOIN capitularies cap USING (cap_id)
    """,
)

#
# The GIS schema
#

event.listen(
    Base.metadata,
    "before_create",
    DDL(
        """
CREATE SCHEMA gis;
ALTER DATABASE capitularia SET search_path = capitularia, gis, public;
"""
    ),
)

event.listen(
    Base.metadata,
    "after_drop",
    DDL(
        """
DROP SCHEMA IF EXISTS gis CASCADE;
"""
    ),
)

Base.metadata.schema = "gis"


class GeoPlaces(Base):
    r"""GeoPlaces

    Data extracted from capitularia_geo.xml

    .. minilang:: sauml -s gis -i gis.geoplaces

    """

    __tablename__ = "geoplaces"

    geo_id = Column(String)

    parent_id = Column(String)

    __table_args__ = (
        PrimaryKeyConstraint(geo_id),
        ForeignKeyConstraint([parent_id], ["geoplaces.geo_id"], ondelete="CASCADE"),
    )


class GeoPlacesNames(Base):
    r"""GeoPlacesNames

    Data extracted from capitularia_geo.xml

    .. minilang:: sauml -s gis -i gis.geoplaces_names

    """

    __tablename__ = "geoplaces_names"

    geo_id = Column(String)
    geo_lang = Column(String)

    geo_name = Column(String)

    __table_args__ = (
        PrimaryKeyConstraint(geo_id, geo_lang),
        ForeignKeyConstraint([geo_id], ["geoplaces.geo_id"], ondelete="CASCADE"),
    )


class MnManuscriptsGeoPlaces(Base):
    r"""The M:N relationship between manuscripts and geoplaces

    .. minilang:: sauml -s gis -i gis.mn_mss_geoplaces

    """

    __tablename__ = "mn_mss_geoplaces"

    ms_id = Column(String)
    geo_id = Column(String)

    __table_args__ = (
        PrimaryKeyConstraint(ms_id, geo_id),
        ForeignKeyConstraint(
            [ms_id], ["capitularia.manuscripts.ms_id"], ondelete="CASCADE"
        ),
        ForeignKeyConstraint([geo_id], ["geoplaces.geo_id"], ondelete="CASCADE"),
    )


class Geonames(Base):
    r"""Geonames

    Data scraped from geonames.org et al. and cached here.

    .. minilang:: sauml -s gis -i gis.geonames

    """

    __tablename__ = "geonames"

    geo_id = Column(String)
    geo_source = Column(String)  # geonames, dnb, viaf, countries_843

    parent_id = Column(String)

    geo_name = Column(String)
    geo_fcode = Column(String)

    geom = Column(Geometry("GEOMETRY", srid=4326))
    blob = Column(JSONB)

    __table_args__ = (
        PrimaryKeyConstraint(geo_source, geo_id),
        ForeignKeyConstraint([parent_id], ["geoplaces.geo_id"], ondelete="CASCADE"),
    )


class MnMsPartsGeonames(Base):
    r"""The M:N relationship between msparts and geonames

    .. minilang:: sauml -s gis -i gis.mn_msparts_geonames

    """

    __tablename__ = "mn_msparts_geonames"

    ms_id = Column(String)
    msp_part = Column(String)
    geo_id = Column(String)
    geo_source = Column(String)

    __table_args__ = (
        PrimaryKeyConstraint(ms_id, msp_part, geo_source, geo_id),
        ForeignKeyConstraint(
            [ms_id, msp_part],
            ["capitularia.msparts.ms_id", "capitularia.msparts.msp_part"],
            ondelete="CASCADE",
        ),
        ForeignKeyConstraint(
            [geo_source, geo_id],
            ["geonames.geo_source", "geonames.geo_id"],
            ondelete="CASCADE",
        ),
    )


class GeoAreas(Base):
    r"""GeoAreas

    Custom defined geographic areas

    .. minilang:: sauml -s gis -i gis.geoareas

    """

    __tablename__ = "geoareas"

    geo_id = Column(String)
    geo_source = Column(String)  # geonames, dnb, viaf, countries_843

    geo_name = Column(String)
    geo_fcode = Column(String)

    geo_color = Column(String)
    geo_label_x = Column(Float(precision=53))
    geo_label_y = Column(Float(precision=53))

    geom = Column(Geometry("GEOMETRY", srid=4326))

    __table_args__ = (
        PrimaryKeyConstraint(geo_source, geo_id),
        Index("ix_geoareas_geom", geom, postgresql_using="gist"),
    )


view(
    "msparts_view",
    Base.metadata,
    """
    SELECT ms.ms_id, ms.title AS ms_title, msp.msp_part, msp.locus_cooked,
           msp.date, lower (msp.date) as msp_notbefore, upper (msp.date) as msp_notafter,
           g.geo_id, g.geo_source, g.geo_name, g.geo_fcode, g.geom
    FROM capitularia.msparts msp
      JOIN capitularia.manuscripts ms USING (ms_id)
      JOIN mn_msparts_geonames mn USING (ms_id, msp_part)
      JOIN geonames g USING (geo_source, geo_id)
    """,
)

view(
    "geo_id_parents",
    Base.metadata,
    """
    SELECT g.geo_id, x."geonameId" as parent_id, x.fcode, x.name
    FROM geonames g, jsonb_to_recordset(g.blob->'geonames') AS x("geonameId" text, fcode text, name text)
    WHERE g.geo_source = 'geonames'
    """,
)

view(
    "geo_id_children",
    Base.metadata,
    """
    SELECT g.geo_id, x."geonameId" AS parent_id, g.geo_fcode, g.geo_name
    FROM geonames g,
      LATERAL jsonb_to_recordset (g.blob -> 'geonames'::text) x ("geonameId" text, fcode text, name text)
    WHERE g.geo_source::text = 'geonames'::text;
""",
)


# for table in 'countries_843 countries_870 countries_888 countries_modern regions_843'.split ():
#     fulltable = 'capitularia.' + table
#     generic (Base_geolayers.metadata, '''
#         CREATE TABLE {fulltable} (
#             geo_id      serial PRIMARY KEY,
#             geo_name    character varying,
#             geo_fcode   character varying,
#             geo_color   character varying,
#             geo_label_x double precision,
#             geo_label_y double precision,
#             geom        geometry(MultiPolygon,4326)
#         );
#         CREATE INDEX {table}_geom_idx ON {fulltable} USING gist (geom);
#         '''.format (table = table, fulltable = fulltable), '''
#         DROP TABLE IF EXISTS {table} CASCADE;
#         '''.format (table = table)
#     );
