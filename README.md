# Ersatzteilmanagement 
Dieses Repository beinhaltet das Projekt "Ersatzteilmanagement", welches zum Modul "Datenbank-Programmierung" gehört.

##Port
Postgre: 5436

##Der erste Start
1. docker und docker-compose für das System installieren
2. 

##Skripts zur Steuerung des Docker-Containers befinden sich im Ordner bash-skripts

db_start.sh: sudo docker-compose build -> sudo docker-compose start
db_clear.sh: sudo rm -r data
db_reset.sh: sudo rm -r data -> sudo docker-compose build -> sudo docker-compose start

##Anwendungsprogramme
###Java
Befehl im Terminal: java -jar <Anwendung>

Anwendung1.jar  : Lagerverwaltung (SELECT und UPDATE) -> Aktualisierung der bestehenden Anzahl in einem Lager
Anwendung2.jar  : Lieferanten- und Ersatzteilverwaltung (INSERT und DELETE) -> Hinzufügen bzw. Entfernen von Lieferanten/Ersatzteilen

###Bash
Befehl im Terminal: bash <Anwendung>
rollup.sh : DatawareHouse-Report -> Zeigt den Wert aller gelagerten Ersatzteile pro Standort
