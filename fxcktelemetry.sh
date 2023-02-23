#!/bin/bash

# Stoppe den Dienst für Ubuntu-Telemetrie
sudo systemctl stop ubuntu-report.service

# Deaktiviere den Dienst für Ubuntu-Telemetrie
sudo systemctl disable ubuntu-report.service

# Entferne den Dienst für Ubuntu-Telemetrie
sudo apt purge -y ubuntu-report

# Stelle sicher, dass keine Telemetriedaten gesendet werden
sudo sed -i 's/ReportCrashes=true/ReportCrashes=false/g' /etc/default/apport
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/whoopsie

# Deaktiviere das Sammeln von Nutzungsstatistiken in GNOME
gsettings set org.gnome.usage-statistics send-software-usage-stats false

# Entferne den Amazon-Link aus dem Dash in GNOME
gsettings set com.canonical.Unity.Lenses remote-content-search none

# Deaktiviere den UFW-Tracking-Server
sudo ufw deny out from any to 91.189.89.199

echo "Telemetrie-Daten wurden erfolgreich blockiert und deaktiviert."
