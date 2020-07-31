INSERT INTO land(land_id, land_name) values
('DE', 'Deutschland'),
('BE', 'Belgien'),
('FR', 'Frankreich'),
('AT', 'Österreich'),
('CN', 'China'),
('US', 'Vereinigte Staaten von Amerika');

INSERT INTO regierungsbezirk(regbez_id, land_id, regbez_name) values
('DE:BW', 'DE', 'Baden-Württemberg'),
('DE:BY', 'DE', 'Bayern'),
('DE:BE', 'DE', 'Berlin'),
('DE:BB', 'DE', 'Brandenburg'),
('DE:HB', 'DE', 'Bremen'),
('DE:HH', 'DE', 'Hamburg'),
('DE:HE', 'DE', 'Hessen'),
('DE:MV', 'DE', 'Mecklemburg-Vorpommern'),
('DE:NI', 'DE', 'Niedersachsen'),
('DE:NW', 'DE', 'Nordrhein-Westfahlen'),
('DE:RP', 'DE', 'Reinland-Pfalz'),
('DE:SL', 'DE', 'Saarland'),
('DE:SN', 'DE', 'Sachsen'),
('DE:ST', 'DE', 'Sachsen-Anhalt'),
('DE:SH', 'DE', 'Schleswig-Holstein'),
('DE:TH', 'DE', 'Thüringen'),
('US:TX', 'US', 'Texas'),
('US:VA', 'US', 'Virginia'),
('CN-AH', 'CN', 'Anhui'),
('CN-HA', 'CN', 'Henan'),
('AT-5', 'AT', 'Salzburg'),
('AT-2', 'AT', 'Kärnten'),
('FR:BRE','FR','Bretagne'),
('FR:IDF','FR','Ile-de-France'),
('FR:COR','FR','Korsika'),
('BE:WBR','BE','Provinz Wallonisch-Brabant'),
('BE:VOV','BE','Provinz Ostflandern'),
('BE:BRU','BE','Region Brüssel-Hauptstadt');

INSERT INTO stadt(stadt_id, regbez_id, stadt_name, plz) values
(default, 'DE:ST', 'Lutherstadt Wittenberg', '06886'),
(default, 'DE:ST', 'Halle(Saale)', '06110'),
(default, 'DE:ST', 'Halle(Saale)', '06108'),
(default, 'DE:BB', 'Potsdam', '14467'),
(default, 'DE:BY', 'Nürnberg', '90403'),
(default, 'DE:BY', 'Ingelfingen', '74653'),
(default, 'US:TX', 'Austin', '78652'),
(default, 'US:TX', 'Houston', '77001'),
(default, 'AT-2', 'Klagenfurt am Wörthersee', '9010'),
(default, 'AT-5', 'Salzburg', '5020'),
(default, 'AT-5', 'Salzburg', '5082'),
(default, 'DE:NW', 'Düsseldorf', '40468'),
(default, 'DE:SH', 'Glinde', '21509'),
(default, 'DE:BW', 'Weil am Rhein', '79756'),
(default, 'DE:NW', 'Essen', '45145');

INSERT INTO standort(standort_id, stadt_id, standort_name, anschrift) values
('10', '1', 'Werk Wittenberg', 'Heuweg 5'),
('11', '2', 'Werk Halle I',  'Torstraße 1'),
('12', '3', 'Werk Halle II',  'Mansfelder Str. 11'),
('20', '6', 'Werk Austin 1', '75th South 86'),
('21', '6', 'Werk Austin 2', '76th South 155'),
('31', '8','Standort Klagenfurt', 'Salzburger Alee 142');

INSERT INTO  abteilung(abteilung_id, standort_id, abteilung_name) values
('1001', '10', 'Annahme'),
('1051', '10', 'CIP 1'),
('1049', '10', 'Versand'),
('3109', '31', 'Verpackung'),
('1102', '11', 'Abfuellung'),
('1103', '11', 'Trocknung'),
('3151', '31', 'CIP 1'),
('3152', '31', 'CIP 2');

INSERT INTO lager(lager_id, standort_id, lager_name) values
('1081', '10', 'Wittenberg L1'),
('1082', '10', 'Wittenberg L2'),
('3181', '31', 'Klagenfurt L1'),
('1181', '11', 'Halle 1L1'),
('2181', '21', 'Austin I Storage 1');

INSERT INTO eclass(eclass, eclass_beschreibung) values
('36-41-03-05', 'Schraubenspindelpumpe'),
('36-41-91-90', 'Dosierpumpe'),
('36-41-01-00', 'Kreiselpumpe'),
('27-22-06-01', 'Magnetventil'),
('37-01-02-03', 'Regelventil'),
('37-01-18-01', 'Membranventil'),
('27-20-13-00', 'Druckaufnehmer'),
('27-27-31-00', 'Stömungswächter'),
('27-20-05-18', 'Füllstandsmessgerät'),
('27-18-07-01', 'Klima-Schaltschrank'),
('36-09-05-01', 'Druckluftfilter'),
('22-41-11-00', 'Luftfilter für Lüftungssystem'),
('27-24-22-00', 'Speicherprogrammierte Steuerung'),
('36-43-04-03', 'Seitenkanalkompreossor'),
('22-41-15-03', 'Kondensatpumpe'),
('36-10-01-04', 'Dekantiergeräte (für Flüssigkeiten)');

INSERT INTO lieferant(lieferant_id, lieferant_name, anschrift, stadt_id, email, ansprechpartner)values
(default, 'Bürkert GmbH & Co.KG', 'Christian-Bürkert-Straße 13-17', 6, 'vertrieb@bürkert.de', NULL),
(default, 'Gea Group Aktiengesellschaft', 'Peter-Müller-Straße 12', 12, 'info@gea.com', 'Herr Müller'),
(default, 'Alfa Laval Mid Europe GmbH', 'Wilhelm-Bergner-Straße 7', 13, 'info.mideurope@alfalaval.com', NULL),
(default, 'Endress+Hauser (Deutschland) GmbH+Co.KG', 'Colmarer Straße 6',  14, 'info.de@endress.com', NULL),
(default, 'ifm electronic gmbh', 'Friedrichstraße 1', 15, 'info@ifm.com', NULL),
(default, 'Flowserve Essen GmbH', 'Schederhofstr. 71', 15, 'fcd@flowserve.com', null);

INSERT INTO ersatzteil(e_id, eclass, lieferant_id, kennzeichnung, kosten, p_id) values
(default, '27-22-06-01', 1, '6213', 149.95, 'a'),
(default, '36-41-01-00', 3, 'LKH', 489.49, 'b'),
(default, '36-10-01-04', 2, 'CF-4000', 629.99, 'c'),
(default, '27-20-13-00', 4, 'CerabarM', 134.49, 'b'),
(default, '27-20-13-00', 4, 'CeraphanT', 139.99, 'a'),
(default, '27-27-31-00', 5, 'SI2200', 45.49, 'a'),
(default, '37-01-02-03', 6, 'KVS', 104.95 ,'b');

INSERT INTO zuordnung (e_id, abteilung_id) values
(1, '1001'),
(1, '1051'),
(1, '3101'),
(2, '3151'),
(2, '3152'),
(3, '1103'),
(4, '1001'),
(5, '1001'),
(6, '1001');

INSERT INTO lagerort(lagerort_id, e_id, lager_id, mindestbestand, anzahl) VALUES
(default, 1, '1081', 2, 5),
(default, 2, '1081', 5, 7),
(default, 3, '1081', 1, 4),
(default, 4, '1081', 5, 5),
(default, 5, '1081', 7, 8),
(default, 6, '1081', 4, 6),
(default, 1, '1082', 5, 8),
(default, 2, '1082', 2, 8),
(default, 3, '1082', 4, 5),
(default, 4, '1082', 6, 8),
(default, 5, '1082', 5, 7),
(default, 6, '1082', 3, 4),
(default, 1, '3181', 5, 7),
(default, 2, '3181', 2, 4),
(default, 3, '3181', 4, 7),
(default, 4, '3181', 6, 9),
(default, 5, '3181', 5, 11),
(default, 6, '3181', 3, 3);







