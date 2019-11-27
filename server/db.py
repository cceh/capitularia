# -*- encoding: utf-8 -*-

"""This module contains the sqlalchemy classes that initialize the database structure.

To create a new database: (must be database superuser)

.. code:: shell

   sudo -u postgres psql

.. code:: psql

   CREATE USER capitularia PASSWORD '<password>';
   CREATE DATABASE capitularia OWNER capitularia;

   \c capitularia
   CREATE EXTENSION pg_trgm WITH SCHEMA public;
   CREATE EXTENSION postgis WITH SCHEMA public;
   CREATE SCHEMA capitularia AUTHORIZATION capitularia;
   CREATE SCHEMA gis AUTHORIZATION capitularia;
   ALTER DATABASE capitularia SET search_path = capitularia, gis, public;
   \q

.. code:: shell

   python3 -m scripts.import_data -c ./server.conf --init_db

"""

import sqlalchemy
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Column, Index, ForeignKey
from sqlalchemy import UniqueConstraint, CheckConstraint, ForeignKeyConstraint, PrimaryKeyConstraint
from sqlalchemy.ext import compiler
from sqlalchemy.ext.declarative import declarative_base, declared_attr
from sqlalchemy.schema import DDLElement
from sqlalchemy.sql import text
from sqlalchemy_utils import IntRangeType
from sqlalchemy.dialects.postgresql.json import JSONB
from sqlalchemy.dialects.postgresql import ARRAY, INT4RANGE, TEXT
from geoalchemy2 import Geometry

# let sqlalchemy manage our views

class CreateView (DDLElement):
    def __init__ (self, name, sql):
        self.name = name
        self.sql = sql.strip ()

class DropView (DDLElement):
    def __init__ (self, name):
        self.name = name

@compiler.compiles(CreateView)
def compile (element, compiler, **kw):
    return 'CREATE OR REPLACE VIEW %s AS %s' % (element.name, element.sql)

@compiler.compiles(DropView)
def compile (element, compiler, **kw):
    # Use CASCADE to drop dependent views because we drop the views in the same
    # order as we created them instead of correctly using the reverse order.
    return 'DROP VIEW IF EXISTS %s CASCADE' % (element.name)

def view (name, metadata, sql):
    CreateView (name, sql).execute_at ('after-create', metadata)
    DropView (name).execute_at ('before-drop', metadata)


# let sqlalchemy manage our functions

class CreateFunction (DDLElement):
    def __init__ (self, name, params, returns, sql, **kw):
        self.name       = name
        self.params     = params
        self.returns    = returns
        self.sql        = sql.strip ()
        self.language   = kw.get ('language', 'SQL')
        self.volatility = kw.get ('volatility', 'VOLATILE')

class DropFunction (DDLElement):
    def __init__ (self, name, params):
        self.name   = name
        self.params = params

@compiler.compiles(CreateFunction)
def compile (element, compiler, **kw):
    return 'CREATE OR REPLACE FUNCTION {name} ({params}) RETURNS {returns} LANGUAGE {language} {volatility} AS $$ {sql} $$'.format (**element.__dict__)

@compiler.compiles(DropFunction)
def compile (element, compiler, **kw):
    return 'DROP FUNCTION IF EXISTS {name} ({params}) CASCADE'.format (**element.__dict__)

def function (name, metadata, params, returns, sql, **kw):
    CreateFunction (name, params, returns, sql, **kw).execute_at ('after-create', metadata)
    DropFunction (name, params).execute_at ('before-drop', metadata)


# let sqlalchemy manage our foreign data wrappers

class CreateFDW (DDLElement):
    def __init__ (self, name, pg_db, mysql_db):
        self.name     = name
        self.pg_db    = pg_db
        self.mysql_db = mysql_db

class DropFDW (DDLElement):
    def __init__ (self, name, pg_db, mysql_db):
        self.name     = name
        self.pg_db    = pg_db
        self.mysql_db = mysql_db

@compiler.compiles(CreateFDW)
def compile (element, compiler, **kw):
    pp = element.pg_db.params
    mp = element.mysql_db.params
    return '''
    CREATE SCHEMA {name};
    -- Following commands don't work because you have to be superuser:
    -- CREATE EXTENSION mysql_fdw;
    -- GRANT USAGE ON FOREIGN DATA WRAPPER mysql_fdw TO {username};
    CREATE SERVER {name}_server FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '{host}', port '{port}');
    CREATE USER MAPPING FOR {pg_user} SERVER {name}_server OPTIONS (username '{username}', password '{password}');
    IMPORT FOREIGN SCHEMA "{database}" FROM SERVER {name}_server INTO {name};
    '''.format (name = element.name, pg_database = pp['database'], pg_user = pp['user'], **mp)

@compiler.compiles(DropFDW)
def compile (element, compiler, **kw):
    pp = element.pg_db.params
    mp = element.mysql_db.params
    return '''
    DROP SCHEMA IF EXISTS {name} CASCADE;
    DROP USER MAPPING IF EXISTS FOR {pg_user} SERVER {name}_server;
    DROP SERVER IF EXISTS {name}_server;
    '''.format (name = element.name, pg_database = pp['database'], pg_user = pp['user'], **mp)

def fdw (name, metadata, pg_database, mysql_db):
    CreateFDW (name, pg_database, mysql_db).execute_at ('after-create', metadata)
    DropFDW (name, pg_database, mysql_db).execute_at ('before-drop', metadata)


# let sqlalchemy manage generic stuff like triggers, aggregates, unique partial indices

class CreateGeneric (DDLElement):
    def __init__ (self, create_cmd):
        self.create = create_cmd

class DropGeneric (DDLElement):
    def __init__ (self, drop_cmd):
        self.drop = drop_cmd

@compiler.compiles(CreateGeneric)
def compile (element, compiler, **kw):
    return element.create

@compiler.compiles(DropGeneric)
def compile (element, compiler, **kw):
    return element.drop

def generic (metadata, create_cmd, drop_cmd, create_when='after-create', drop_when='before-drop'):
    if create_cmd:
        CreateGeneric (create_cmd).execute_at (create_when, metadata)
    if drop_cmd:
        DropGeneric (drop_cmd).execute_at (drop_when, metadata)


import lxml.etree as etree

class XML (sqlalchemy.types.UserDefinedType):
    def get_col_spec (self):
        return 'XML'

    def bind_processor (self, dialect):
        # store
        def process (value):
            if value is None:
                return None
            if isinstance (value, str):
                return value
            else:
                return etree.tostring (value, encoding = "unicode")
        return process

    def result_processor (self, dialect, coltype):
        # retrieve
        def process (value):
            if value is None:
                return None
            return etree.fromstring (value)
        return process


Base = declarative_base ()

CreateGeneric ("""
CREATE SCHEMA capitularia;
ALTER DATABASE capitularia SET search_path = capitularia, public;
"""
).execute_at ('before-create', Base.metadata)

DropGeneric ("""
DROP SCHEMA IF EXISTS capitularia CASCADE;
""").execute_at ('after-drop', Base.metadata)

Base.metadata.schema = 'capitularia'

function ('natsort', Base.metadata, 't TEXT', 'TEXT', '''
-- SELECT REGEXP_REPLACE ($1, '0*([0-9]+)', length (\1) || \1, 'g');
--
SELECT STRING_AGG (COALESCE (r[2], LENGTH (r[1])::text || r[1]), '')
    FROM REGEXP_MATCHES ($1, '0*([0-9]+)|([^0-9]+)', 'g') r;
''', volatility = 'IMMUTABLE')


class Manuscripts (Base):
    r"""Manuscripts

    .. sauml::
       :include: manuscripts

    """

    __tablename__ = 'manuscripts'

    ms_id = Column (String, primary_key = True)
    """ The manuscript id assigned by the Capitularia project. """

    title    = Column (String)
    """ The official title of the manuscript. """

    filename = Column (String)
    """The filename of the TEI file containing the transcription of the
    manuscript."""

    status   = Column (String)
    """ The Wordpress publication status: either 'publish' or 'private' """

    __table_args__ = (
    )


class MsParts (Base):
    r"""The parts of a manuscript

    .. sauml::
       :include: msparts

    """

    __tablename__ = 'msparts'

    ms_id    = Column (String)

    msp_part = Column (String)
    """ The official designation of the manuscript part. """

    date     = Column (INT4RANGE)
    """ When did the manuscript part originate? Range of dates. """

    loci     = Column (ARRAY (INT4RANGE))
    """ Ranges of loci. """

    leaf     = Column (ARRAY (String))
    """ Size of the leaf. """

    written  = Column (ARRAY (String))
    """ Size of the written area. """

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, msp_part),
        ForeignKeyConstraint ([ms_id],  ['manuscripts.ms_id'], ondelete = 'CASCADE'),
    )


class Capitularies (Base):
    r"""Capitularies

    All capitularies catalogued according to BK or Mordek.

    .. sauml::
       :include: capitularies

    """

    __tablename__ = 'capitularies'

    cap_id = Column (String, primary_key = True)
    """ The capitulary number, eg. "BK.42"  """

    title  = Column (String)
    """ The capitulary title assigned by BK. """

    date   = Column (INT4RANGE)

    __table_args__ = (
    )


class Chapters (Base):
    r"""Chapters

    All chapters catalogued according to BK or Mordek.

    .. sauml::
       :include: chapters

    """

    __tablename__ = 'chapters'

    cap_id  = Column (String)

    chapter = Column (String)
    """ The chapter number from 1 to N.  Also: 1_inscription, etc."""

    __table_args__ = (
        PrimaryKeyConstraint (cap_id, chapter),
        ForeignKeyConstraint ([cap_id], ['capitularies.cap_id'], ondelete = 'CASCADE'),
    )


class MnMssCapitularies (Base):
    r"""The M:N relationship between manuscripts and capitularies
    according to the <msDesc>.

    This table also contains capitularies that are not yet transcribed but at a
    lesser granularity (capitulary instead of chapter) than the
    :class:`MssChapters` table.

    .. sauml::
       :include: mn_mss_capitularies

    """

    __tablename__ = 'mn_mss_capitularies'

    ms_id   = Column (String)
    cap_id  = Column (String)

    mscap_n = Column (Integer)
    """Index used if there are more than one copy of this capitulary in the
    manuscript.

    """

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, cap_id, mscap_n),
        ForeignKeyConstraint ([ms_id],  ['manuscripts.ms_id'], ondelete = 'CASCADE'),
        ForeignKeyConstraint ([cap_id], ['capitularies.cap_id'], ondelete = 'CASCADE'),
    )


class MssChapters (Base):
    r"""The relationship manuscripts and chapters according to the <body>.

    This table contains only those chapters that were already transcribed.

    Note: The table :class:`MnMssCapitularies` relates manuscripts to
    capitularies yet untranscribed.

    .. sauml::
       :include: mss_chapters

    """

    __tablename__ = 'mss_chapters'

    ms_id    = Column (String)
    cap_id   = Column (String)
    mscap_n  = Column (Integer)

    chapter  = Column (String)

    locus = Column (String)
    """ The locus of the chapter in the manuscript.
    As recorded by the editor, eg. 42ra-1 """

    transcribed = Column (Integer, nullable = False, server_default = '0')
    """ Is this chapter already transcribed? 0 == no, 1 == partially, 2 == completed """

    xml     = Column (XML)
    """ The XML text of the chapter. """

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, cap_id, mscap_n, chapter),
        ForeignKeyConstraint (
            [cap_id, chapter],
            ['chapters.cap_id', 'chapters.chapter'],
            ondelete = 'CASCADE'
        ),
        ForeignKeyConstraint (
            [ms_id, cap_id, mscap_n],
            ['mn_mss_capitularies.ms_id', 'mn_mss_capitularies.cap_id', 'mn_mss_capitularies.mscap_n'],
            ondelete = 'CASCADE'
        ),
    )


class MssChaptersText (Base):
    r"""Various kinds of preprocessed texts extracted from the chapter.

    There may be more than one text extracted from the same chapter: the original
    hand and later corrector hands.

    .. sauml::
       :include: mss_chapters_text

    """

    __tablename__ = 'mss_chapters_text'

    ms_id    = Column (String)
    cap_id   = Column (String)
    mscap_n  = Column (Integer)
    chapter  = Column (String)

    type_    = Column ('type', String)
    """Either 'original' or 'later_hands'.  The type of preprocessing applied.
    Whether the original hand was followed or a later corrector.

    """

    text     = Column (TEXT)
    """ The preprocessed plain text of the chapter. """

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, cap_id, mscap_n, chapter, type_),
        ForeignKeyConstraint (
            [ms_id, cap_id, mscap_n, chapter],
            ['mss_chapters.ms_id', 'mss_chapters.cap_id', 'mss_chapters.mscap_n', 'mss_chapters.chapter'],
            ondelete = 'CASCADE'
        ),
    )


generic (Base.metadata, '''
CREATE INDEX IF NOT EXISTS ix_mss_chapters_text_trgm ON mss_chapters_text USING GIN (text gin_trgm_ops);
''', '''
DROP INDEX IF EXISTS ix_mss_chapters_text_trgm;
'''
)

view ('chapters_count_transcriptions', Base.metadata, '''
SELECT cap_id, chapter, COUNT (ms_id) AS transcriptions
FROM chapters
 JOIN mss_chapters mn USING (cap_id, chapter)
GROUP BY cap_id, chapter
''')


view ('capitularies_view', Base.metadata, '''
    SELECT ms.ms_id, ms.title AS ms_title, cap.cap_id, cap.title AS cap_title,
           cap.date, lower (cap.date) as cap_notbefore, upper (cap.date) as cap_notafter
    FROM manuscripts ms
      JOIN mn_mss_capitularies mn USING (ms_id)
        JOIN capitularies cap USING (cap_id)
    ''')

#
# The GIS schema
#

CreateGeneric ("""
CREATE SCHEMA gis;
ALTER DATABASE capitularia SET search_path = capitularia, gis, public;
"""
).execute_at ('before-create', Base.metadata)

DropGeneric ("""
DROP SCHEMA IF EXISTS gis CASCADE;
""").execute_at ('after-drop', Base.metadata)

Base.metadata.schema = 'gis'

class Geonames (Base):
    r"""Geonames

    Data scraped from geonames.org et al. and cached here.

    .. sauml::
       :schema: gis
       :include: gis.geonames

    """

    __tablename__ = 'geonames'

    geo_id        = Column (String)
    geo_source    = Column (String) # geonames, dnb, viaf, countries_843

    parent_id     = Column (String)

    geo_name      = Column (String)
    geo_fcode     = Column (String)

    geom          = Column (Geometry ('GEOMETRY', srid=4326))
    blob          = Column (JSONB)

    __table_args__ = (
        PrimaryKeyConstraint (geo_source, geo_id),
    )


class MnMsPartsGeonames (Base):
    r"""The M:N relationship between msparts and geonames

    .. sauml::
       :schema: gis
       :include: gis.mn_msparts_geonames

    """

    __tablename__ = 'mn_msparts_geonames'

    ms_id      = Column (String)
    msp_part   = Column (String)
    geo_id     = Column (String)
    geo_source = Column (String)

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, msp_part, geo_source, geo_id),
        ForeignKeyConstraint (
            [ms_id, msp_part],
            ['capitularia.msparts.ms_id', 'capitularia.msparts.msp_part'],
            ondelete = 'CASCADE'
        ),
        ForeignKeyConstraint (
            [geo_source, geo_id],
            ['geonames.geo_source', 'geonames.geo_id'],
            ondelete = 'CASCADE'
        ),
    )


class GeoAreas (Base):
    r"""GeoAreas

    Custom defined geographic areas

    .. sauml::
       :schema: gis
       :include: gis.geoareas

    """

    __tablename__ = 'geoareas'

    geo_id      = Column (String)
    geo_source  = Column (String) # geonames, dnb, viaf, countries_843

    geo_name    = Column (String)
    geo_fcode   = Column (String)

    geo_color   = Column (String)
    geo_label_x = Column (Float (precision = 53))
    geo_label_y = Column (Float (precision = 53))

    geom        = Column (Geometry ('GEOMETRY', srid=4326))

    __table_args__ = (
        PrimaryKeyConstraint (geo_source, geo_id),
        Index ('ix_geoareas_geom', geom, postgresql_using = 'gist'),
    )

view ('msparts_view', Base.metadata, '''
    SELECT ms.ms_id, ms.title AS ms_title, msp.msp_part, msp.loci,
           msp.date, lower (msp.date) as msp_notbefore, upper (msp.date) as msp_notafter,
           g.geo_id, g.geo_source, g.geo_name, g.geo_fcode, g.geom
    FROM capitularia.msparts msp
      JOIN capitularia.manuscripts ms USING (ms_id)
      JOIN mn_msparts_geonames mn USING (ms_id, msp_part)
      JOIN geonames g USING (geo_source, geo_id)
    ''')

view ('geo_id_parents', Base.metadata, '''
    SELECT g.geo_id, x."geonameId" as parent_id, x.fcode, x.name
    FROM geonames g, jsonb_to_recordset(g.blob->'geonames') AS x("geonameId" text, fcode text, name text)
    WHERE g.geo_source = 'geonames'
    ''')

view ('geo_id_children', Base.metadata, '''
    SELECT g.geo_id, x."geonameId" AS parent_id, g.geo_fcode, g.geo_name
    FROM geonames g,
      LATERAL jsonb_to_recordset (g.blob -> 'geonames'::text) x ("geonameId" text, fcode text, name text)
    WHERE g.geo_source::text = 'geonames'::text;
''')


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
