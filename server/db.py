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
    CreateGeneric (create_cmd).execute_at (create_when, metadata)
    DropGeneric (drop_cmd).execute_at (drop_when, metadata)


Base = declarative_base ()
Base.metadata.schema = 'capitularia'

class Manuscripts (Base):
    r"""Manuscripts

    .. sauml::
       :include: manuscripts

    """

    __tablename__ = 'manuscripts'

    ms_id   = Column (String, primary_key = True)
    title   = Column (String)

    __table_args__ = (
    )


class Geonames (Base):
    r"""Geonames

    Data scraped from geonames.org and cached here.

    .. sauml::
       :include: geonames

    """

    __tablename__ = 'geonames'

    geo_id = Column (Integer,  primary_key = True)

    name   = Column (String ())
    fcode  = Column (String ())
    geo    = Column (Geometry ('POINT', srid=4326))

    blob   = Column (JSONB)

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
    geo_id  = Column (Integer)

    date    = Column (INT4RANGE)
    leaf    = Column (ARRAY (String))
    written = Column (ARRAY (String))

    __table_args__ = (
        PrimaryKeyConstraint (ms_id, ms_part),
        ForeignKeyConstraint ([ms_id],  ['manuscripts.ms_id']),
        ForeignKeyConstraint ([geo_id], ['geonames.geo_id']),
    )


view ('msparts_geo_view', Base.metadata, '''
    SELECT count(distinct ms_id) as count, geonames.name AS name, ST_AsGeoJSON (geonames.geo)::json AS geo
    FROM msparts
      JOIN geonames USING (geo_id)
    GROUP BY geonames.geo, geonames.name
    ''')

view ('msparts_view', Base.metadata, '''
    SELECT ms.ms_id, ms.title, p.ms_part, lower (p.date) as notbefore, upper (p.date) as notafter,
           g.geo_id, g.name, g.fcode, ST_AsGeoJSON (g.geo)::json AS geo, g.blob
    FROM msparts p
      JOIN manuscripts ms USING (ms_id)
      JOIN geonames g USING (geo_id)
    ''')

view ('geonames_view', Base.metadata, '''
    SELECT geo_id, name, fcode, ST_AsGeoJSON (geonames.geo)::json AS geo, blob
    FROM geonames
    ''')
