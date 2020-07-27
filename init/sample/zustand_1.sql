INSERT INTO land(land_id, land_name) values
('DE', 'Deutschland'),
('BE', 'Belgien'),
('FR', 'Frankreich'),
('AT', 'Österreich'),
('CN', 'China'),
('US', 'Vereinigte Staaten von Amerika');

INSERT INTO bundesland(bundesland_id, land_id, bundesland_name) values
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

INSERT INTO stadt(stadt_id, bundesland_id, stadt_name, plz) values
(default, 'DE:ST', 'Lutherstadt Wittenberg', '06886'),
(default, 'DE:ST', 'Halle(Saale)', '06110'),
(default, 'DE:ST', 'Halle(Saale)', '06108'),
(default, 'DE:BB', 'Potsdam', '14467'),
(default, 'DE:BY', 'Nürnberg', '90403'),
(default, 'US:TX', 'Austin', '78652'),
(default, 'US:TX', 'Houston', '77001'),
(default, 'AT-2', 'Klagenfurt am Wörthersee', '9010'),
(default, 'AT-5', 'Salzburg', '5020'),
(default, 'AT-5', 'Salzburg', '5082');

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
('1181', '11', 'Halle 1L1');



