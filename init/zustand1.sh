#/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE SCHEMA zustand1;
  CREATE DATABASE zustand1;
CREATE TABLE land(
  land_id CHARACTER(2) PRIMARY KEY,
  land_name VARCHAR(50) NOT NULL,
  CONSTRAINT land_format CHECK (land_id SIMILAR TO '[A-Z][A-Z]'),
  UNIQUE(land_id, land_name)
);
CREATE TABLE bundesland(
  bundesland_id CHARACTER(5) PRIMARY KEY,
  land_id CHARACTER(2) NOT NULL REFERENCES land,
  bundesland_name VARCHAR(50) NOT NULL,
  CONSTRAINT bundesland_format CHECK
    (bundesland_id similar to '[A-Z][A-Z]:[A-Z][A-Z]'),
  UNIQUE(bundesland_id, land_id)
);
CREATE TABLE stadt(
  stadt_id NUMERIC(4) PRIMARY KEY,
  bundesland_id CHARACTER(5) NOT NULL REFERENCES bundesland,
  stadt_name VARCHAR(58) NOT NULL,
  UNIQUE(bundesland_id, stadt_name),
  CONSTRAINT bundesland_format CHECK
    (bundesland_id SIMILAR TO '[A-Z][A-Z]:[A-Z][A-Z]')
);

EOSQL
