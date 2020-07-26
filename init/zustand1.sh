#/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$POSTGRES_DB" <<'EOF' <<-EOSQL
  CREATE SCHEMA zustand1;
  CREATE DATABASE zustand1;
CREATE FUNCTION aktualisiert() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
  BEGIN
  NEW.letzte_aktualisierung = CURRENT_TIMESTAMP;
  RETURNS NEW;
  END
   $$;
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
CREATE TABLE standort(
  standort_id NUMERIC(2) PRIMARY KEY,
  stadt_id NUMERIC(4) NOT NULL REFERENCES stadt,
  beschreibung VARCHAR(50) NOT NULL,
  anschrift VARCHAR(50) NOT NULL
);
CREATE TABLE lager(
  lager_id NUMERIC(3) PRIMARY KEY,
  standort_id NUMERIC(2) NOT NULL REFERENCES standort,
  lager_name VARCHAR(50) NOT NULL
);
CREATE TABLE abteilung(
  abteilung_id NUMERIC(4) PRIMARY KEY,
  standort_id NUMERIC(2) NOT NULL REFERENCES standort,
  standort_name VARCHAR(50)
);
CREATE TABLE priorisierung(
  p_id CHARACTER(1) PRIMARY KEY,
  beschreibung VARCHAR(45) NOT NULL,
  CONSTRAINT a_b_c CHECK(p_id SIMILAR TO '[a-c]')
);
CREATE SEQUENCE lieferant_id_seq AS SMALLINT START 1 INCREMENT 1 MAXVALUE 999
;
CREATE TABLE lieferant(
  lieferant_id NUMERIC(3) PRIMARY KEY,
  lieferant_name VARCHAR(50) NOT NULL,
  stadt_id NUMERIC(3) NOT NULL REFERENCES stadt,
  anschrift VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  ansprechpartner VARCHAR(50),
  letzte_aktualisierung TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  CONSTRAINT email_format CHECK (email LIKE '___%@%.__%')
);
CREATE TRIGGER aktualisierung_lieferant BEFORE UPDATE ON lieferant
  FOR EACH ROW EXECUTE PROCEDURE aktualisiert()
;
INSERT INTO priorisierung(p_id, beschreibung) VALUES
  ('a', 'Ersatzteil muss auf Lager sein'),
  ('b', 'Lieferzeit zwischen einem Tag und einer Woche'),
  ('c', 'Lieferzeit von mehr als einer Woche')
;
CREATE TABLE eclass(
  eclass VARCHAR(11) PRIMARY KEY,
  eclass_beschreibung VARCHAR(50) NOT NULL,
  CONSTRAINT eclass_format CHECK
   (eclass SIMILAR TO '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' OR
    eclass SIMILAR TO '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' OR
    eclass SIMILAR TO '[0-9][0-9]-[0-9][0-9]' OR
    eclass SIMILAR TO '[0-9][0-9]'),
    UNIQUE(eclass, eclass_beschreibung)
);
EOSQL
EOF
