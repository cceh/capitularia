# -*- encoding: utf-8 -*-

"""This module contains the sqlalchemy classes that create the database structure.

"""

from sqlalchemy import String, Integer, Float, Boolean, DateTime, Column, Index, ForeignKey
from sqlalchemy import UniqueConstraint, CheckConstraint, ForeignKeyConstraint, PrimaryKeyConstraint
from sqlalchemy.ext import compiler
from sqlalchemy.ext.declarative import declarative_base, declared_attr
from sqlalchemy.schema import DDLElement
from sqlalchemy.sql import text
from sqlalchemy_utils import IntRangeType
from sqlalchemy.dialects.postgresql.json import JSONB
from sqlalchemy.dialects.postgresql import ARRAY, INT4RANGE
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


Base = declarative_base ()
Base.metadata.schema = 'capitularia'

generic (Base.metadata, '''
ALTER DEFAULT PRIVILEGES IN SCHEMA capitularia GRANT SELECT ON TABLES TO capitularia;
''', None);

class Geonames (Base):
    r"""Geonames

    Data scraped from geonames.org et al. and cached here.

    .. sauml::
       :include: geonames

    """

    __tablename__ = 'geonames'

    geo_id      = Column (String)
    geo_source  = Column (String) # geonames, dnb, viaf, countries_843

    geo_name    = Column (String)
    geo_fcode   = Column (String)

    geom        = Column (Geometry ('POINT', srid=4326))
    blob        = Column (JSONB)

    __table_args__ = (
        PrimaryKeyConstraint (geo_source, geo_id),
    )


class Manuscripts (Base):
    r"""Manuscripts

    .. sauml::
       :include: manuscripts

    """

    __tablename__ = 'manuscripts'

    ms_id    = Column (String, primary_key = True)
    ms_title = Column (String)

    __table_args__ = (
    )


class MsParts (Base):
    r"""The parts of a manuscript

    .. sauml::
       :include: msparts

    """

    __tablename__ = 'msparts'

    ms_id   = Column (String)
    ms_part = Column (String)

    msp_head    = Column (String)
    msp_date    = Column (INT4RANGE)
    msp_leaf    = Column (ARRAY (String))
    msp_written = Column (ARRAY (String))

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, ms_part),
        ForeignKeyConstraint ([ms_id],  ['manuscripts.ms_id']),
    )


class Capitularies (Base):
    r"""Capitularies

    .. sauml::
       :include: capitularies

    """

    __tablename__ = 'capitularies'

    cap_id    = Column (String, primary_key = True)
    cap_title = Column (String)
    cap_date  = Column (INT4RANGE)

    __table_args__ = (
    )


class MnMsPartsGeonames (Base):
    r"""The M:N relationship between msparts and geonames

    .. sauml::
       :include: mn_msparts_geonames

    """

    __tablename__ = 'mn_msparts_geonames'

    ms_id      = Column (String)
    ms_part    = Column (String)
    geo_id     = Column (String)
    geo_source = Column (String)

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, ms_part, geo_source, geo_id),
        ForeignKeyConstraint ([ms_id, ms_part], ['msparts.ms_id', 'msparts.ms_part']),
        ForeignKeyConstraint ([geo_source, geo_id], ['geonames.geo_source', 'geonames.geo_id']),
    )


class MnMsPartsCapitularies (Base):
    r"""The M:N relationship between msparts and capitularies

    .. sauml::
       :include: mn_msparts_capitularies

    """

    __tablename__ = 'mn_msparts_capitularies'

    ms_id   = Column (String)
    ms_part = Column (String)
    cap_id  = Column (String)

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, ms_part, cap_id),
        ForeignKeyConstraint ([ms_id, ms_part], ['msparts.ms_id', 'msparts.ms_part']),
        ForeignKeyConstraint ([cap_id],         ['capitularies.cap_id']),
    )


view ('msparts_view', Base.metadata, '''
    SELECT ms.ms_id, ms.ms_title, msp.ms_part, msp.msp_head,
           msp.msp_date, lower (msp.msp_date) as msp_notbefore, upper (msp.msp_date) as msp_notafter,
           g.geo_id, g.geo_source, g.geo_name, g.geo_fcode, g.geom
    FROM msparts msp
      JOIN manuscripts ms USING (ms_id)
      JOIN mn_msparts_geonames mn USING (ms_id, ms_part)
            JOIN geonames g USING (geo_source, geo_id)
    ''')


view ('capitularies_view', Base.metadata, '''
    SELECT ms.ms_id, ms.ms_title, msp.ms_part, msp.msp_head,
           msp.msp_date, lower (msp.msp_date) as msp_notbefore, upper (msp.msp_date) as msp_notafter,
           cap.cap_id, cap.cap_title,
           cap.cap_date, lower (cap.cap_date) as cap_notbefore, upper (cap.cap_date) as cap_notafter
    FROM msparts msp
      JOIN manuscripts ms USING (ms_id)
      JOIN mn_msparts_capitularies mn USING (ms_id, ms_part)
            JOIN capitularies cap USING (cap_id)
    ''')


class GeoAreas (Base):
    r"""GeoAreas

    Custom defined geographic areas

    .. sauml::
       :include: geoareas

    """

    __tablename__ = 'geoareas'

    geo_id      = Column (String)
    geo_source  = Column (String) # geonames, dnb, viaf, countries_843

    geo_name    = Column (String)
    geo_fcode   = Column (String)

    geo_color   = Column (String)
    geo_label_x = Column (Float (precision = 53))
    geo_label_y = Column (Float (precision = 53))

    geom        = Column (Geometry ('MULTIPOLYGON', srid=4326))

    __table_args__ = (
        PrimaryKeyConstraint (geo_source, geo_id),
        Index ('ix_geoareas_geom', geom, postgresql_using = 'gist'),
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
