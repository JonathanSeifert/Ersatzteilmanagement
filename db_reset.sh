#/bin/bash

set -e

echo Lösche data-Ordner
sudo rm -r data
echo Baue docker-compose
sudo docker-compose build
echo Starte docker-compose
sudo docker-compose up
