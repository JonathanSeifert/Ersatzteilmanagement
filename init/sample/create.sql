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
  bundesland_id VARCHAR(6) PRIMARY KEY,
  land_id CHARACTER(2) NOT NULL REFERENCES land,
  bundesland_name VARCHAR(50) NOT NULL,
  CONSTRAINT land_id CHECK (land_id SIMILAR TO '[A-Z][A-Z]'),
  CONSTRAINT bundesland_format CHECK
    (bundesland_id SIMILAR TO '[A-Z][A-Z](:|-)[A-Z][A-Z]' OR
     bundesland_id LIKE '__%'),
  UNIQUE(bundesland_id, land_id)
);

--Tabelle fuer die Staedte
CREATE SEQUENCE stadt_id_seq AS SMALLINT START 1 INCREMENT 1 MAXVALUE 9999;
CREATE TABLE stadt(
  stadt_id NUMERIC(4) PRIMARY KEY DEFAULT NEXTVAL('stadt_id_seq'),
  bundesland_id VARCHAR(6) NOT NULL REFERENCES bundesland,
  stadt_name VARCHAR(58) NOT NULL,
  plz VARCHAR(10) NOT NULL,
  UNIQUE(bundesland_id, plz),
  CONSTRAINT bundesland_format CHECK
    (bundesland_id SIMILAR TO '[A-Z][A-Z](:|-)[A-Z][A-Z]' OR
     bundesland_id LIKE '__%')
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

--Sequenz, Create und Trigger für Tabelle für Lagerort-Verwaltung
CREATE SEQUENCE lagerort_id_seq AS INTEGER START 1 INCREMENT 1 MAXVALUE 999999
;
CREATE TABLE lagerort(
  lagerort_id NUMERIC(6) PRIMARY KEY,
  e_id NUMERIC(5) NOT NULL REFERENCES ersatzteil,
  lager_id NUMERIC(2) NOT NULL REFERENCES lager,
  anzahl NUMERIC(2) NOT NULL,
  mindestbestand NUMERIC(2) NOT NULL,
  letzter_abgang TIMESTAMP(0) WITHOUT TIME ZONE,
  letzter_zugang TIMESTAMP(0) WITHOUT TIME ZONE,
  CONSTRAINT anzahl_darf_nicht_negativ_sein CHECK
    (anzahl>-1),
  CONSTRAINT mindestbestand_muss_mind_1_sein CHECK
    (mindestbestand>0),
  UNIQUE(e_id, lager_id)
);
CREATE FUNCTION teil_entnommen() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
  BEGIN
  IF (OLD.anzahl > NEW.anzahl) THEN NEW.letzter_abgang = CURRENT_TIMESTAMP;
  END IF;
  RETURN NEW;
  END
   $$;
CREATE TRIGGER entnahme BEFORE UPDATE OF anzahl ON lagerort
FOR EACH ROW EXECUTE PROCEDURE teil_entnommen()
;
CREATE FUNCTION teil_zugefuehrt() RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
  BEGIN
  IF (OLD.anzahl>NEW.anzahl) THEN NEW.letzter_abgang = CURRENT_TIMESTAMP;
  END IF;
  RETURN NEW;
  END
   $$;
CREATE TRIGGER zufuehrung BEFORE UPDATE OF anzahl ON lagerort
FOR EACH ROW EXECUTE PROCEDURE teil_zugefuehrt()
;
