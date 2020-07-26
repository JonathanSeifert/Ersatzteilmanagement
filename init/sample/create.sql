--Funktion die den Zeitpunkt aktualisiert
CREATE FUNCTION aktualisiert() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
  BEGIN
  NEW.letzte_aktualisierung = CURRENT_TIMESTAMP;
  RETURN NEW;
  END
   $$;

--Tabelle fuer die Laender
CREATE TABLE land(
  land_id CHARACTER(2) PRIMARY KEY,
  land_name VARCHAR(50) NOT NULL,
  CONSTRAINT land_format CHECK (land_id SIMILAR TO '[A-Z][A-Z]'),
  UNIQUE(land_id, land_name)
);

--Tabelle fuer die Bundeslaender(Regierungsbezirke)
CREATE TABLE bundesland(
  bundesland_id CHARACTER(5) PRIMARY KEY,
  land_id CHARACTER(2) NOT NULL REFERENCES land,
  bundesland_name VARCHAR(50) NOT NULL,
  CONSTRAINT bundesland_format CHECK
    (bundesland_id similar to '[A-Z][A-Z]:[A-Z][A-Z]'),
  UNIQUE(bundesland_id, land_id)
);

--Tabelle fuer die Staedte
CREATE TABLE stadt(
  stadt_id NUMERIC(4) PRIMARY KEY,
  bundesland_id CHARACTER(5) NOT NULL REFERENCES bundesland,
  stadt_name VARCHAR(58) NOT NULL,
  plz VARCHAR(10) NOT NULL,
  UNIQUE(bundesland_id, stadt_name),
  CONSTRAINT bundesland_format CHECK
    (bundesland_id SIMILAR TO '[A-Z][A-Z]:[A-Z][A-Z]')
);

--Tabelle fuer die Standorte
CREATE TABLE standort(
  standort_id NUMERIC(2) PRIMARY KEY,
  stadt_id NUMERIC(3) NOT NULL REFERENCES stadt,
  beschreibung VARCHAR(50) NOT NULL,
  anschrift VARCHAR(50) NOT NULL
);

--Tabelle fuer die Lager
CREATE TABLE lager(
  lager_id NUMERIC(3) PRIMARY KEY,
  standort_id NUMERIC(2) NOT NULL REFERENCES standort,
  lager_name VARCHAR(50) NOT NULL
);

--Tabelle fuer die Abteilungen
CREATE TABLE abteilung(
  abteilung_id NUMERIC(4) PRIMARY KEY,
  standort_id NUMERIC(2) NOT NULL REFERENCES standort,
  standort_name VARCHAR(50)
);

--Sequenz, CREATE und Trigger fuer die Lieferaten-Tabelle
CREATE SEQUENCE lieferant_id_seq AS SMALLINT START 1 INCREMENT 1 MAXVALUE 999
;
CREATE TABLE lieferant(
  lieferant_id NUMERIC(3) PRIMARY KEY DEFAULT(NEXTVAL('lieferant_id_seq')),
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

--Tabelle fuer die eclass-Kategorisierung
CREATE TABLE eclass(
eclass VARCHAR(11) PRIMARY KEY,
beschreibung VARCHAR(50) NOT NULL,
CONSTRAINT eclass_format CHECK
 (eclass SIMILAR TO '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' OR
  eclass SIMILAR TO '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' OR
  eclass SIMILAR TO '[0-9][0-9]-[0-9][0-9]' OR
  eclass SIMILAR TO '[0-9][0-9]'),
UNIQUE(eclass, beschreibung)
);

--Tabelle fuer die Prioriserung des Bedarfs
CREATE TABLE priorisierung(
p_id CHARACTER(1) PRIMARY KEY,
beschreibung VARCHAR(45) NOT NULL,
CONSTRAINT a_b_c CHECK(p_id SIMILAR TO '[a-c]')
);
INSERT INTO priorisierung VALUES
  ('a', 'Ersatzteil muss auf Lager sein'),
  ('b', 'Lieferzeit zwischen einem Tag und einer Woche'),
  ('c', 'Lieferzeit von mehr als einer Woche')
;

--Sequenz, CREATE und Trigger für Ersatzteiltabelle
CREATE SEQUENCE e_id_seq AS INTEGER START 1 INCREMENT 1 MAXVALUE 99999
;
CREATE TABLE ersatzteil(
  e_id NUMERIC(5) PRIMARY KEY DEFAULT(NEXTVAL('e_id_seq')),
  eclass VARCHAR(11) NOT NULL REFERENCES eclass,
  abteilung_id NUMERIC(4) NOT NULL REFERENCES abteilung,
  lieferant_id NUMERIC(3) NOT NULL REFERENCES lieferant,
  kennzeichnung VARCHAR(50) NOT NULL,
  kosten NUMERIC(9,2) NOT NULL,
  p_id CHARACTER(1) NOT NULL REFERENCES priorisierung,
  letzte_aktualisierung TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(eclass, kennzeichnung),
  CONSTRAINT kosten_muessen_positiv_sein CHECK(kosten > 0)
);
CREATE TRIGGER aktualiserung_ersatzteil BEFORE UPDATE ON ersatzteil
  FOR EACH ROW EXECUTE PROCEDURE aktualisiert()
;
