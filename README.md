# Ersatzteilmanagement 
Dieses Repository beinhaltet das Projekt "Ersatzteilmanagement", welches zum Modul "Datenbank-Programmierung" gehört.
Der Projektbericht befindet sich in diesem Repository unter dem Namen **Projektbericht.pdf**

**Port**
Postgre: 5436

**Der erste Start**
1. docker und docker-compose für das System installieren
2. .env.example -> Password ändern und in .env umbenennen
3. docker-compose build 
4. docker-compose up

**DB-Zurücksetzen**
1. docker-compose down
2. /data löschen (rm -r data)
3. docker compose build
4. docker compose start

**Nutzer**
1. admin
2. lagerist
3. abteilungsleiter 

**Anwendungsprogramme**  
*Java*  
Befehl im Terminal: java -jar [Anwendung]  
  
Anwendung1.jar  : Lagerverwaltung (SELECT und UPDATE)-> Aktualisierung der bestehenden Anzahl in einem Lager  
Anwendung2.jar  : Lieferanten- und Ersatzteilverwaltung (INSERT und DELETE) -> Hinzufügen bzw. Entfernen von Lieferanten/Ersatzteilen  

*Bash*  
Befehl im Terminal: bash [Anwendung]  

recursive.sh 	: Rekursive Anfrage -> Listet die Lieferanten nach Standort und Abteilung auf  
rollup.sh       : DatawareHouse-Report -> Zeigt den Wert aller gelagerten Ersatzteile pro Standort

