#!/bin/bash

# Stop Ubuntu telemetry service
sudo systemctl stop ubuntu-report.service

# Disable Ubuntu telemetry service
sudo systemctl disable ubuntu-report.service

# Remove Ubuntu telemetry service
sudo apt purge -y ubuntu-report

# Ensure no telemetry data is sent
sudo sed -i 's/ReportCrashes=true/ReportCrashes=false/g' /etc/default/apport
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/whoopsie

# Disable GNOME usage statistics collection
gsettings set org.gnome.usage-statistics send-software-usage-stats false

# Remove Amazon link from GNOME dash
gsettings set com.canonical.Unity.Lenses remote-content-search none

# Disable UFW tracking server
sudo ufw deny out from any to 91.189.89.199

echo "Telemetry data successfully blocked and disabled."

# Disable telemetry services
systemctl stop systemd-coredump systemd-timedated systemd-resolved systemd-timesyncd
systemctl disable systemd-coredump systemd-timedated systemd-resolved systemd-timesyncd
apt-get remove --purge systemd-coredump systemd-timedated systemd-resolved systemd-timesyncd

# Disable error reporting
sed -i 's/^enabled=1$/enabled=0/g' /etc/default/apport
sed -i 's/^#\\s*submit_crash.*$/submit_crash=false/g' /etc/apport/crashdb.conf
sed -i 's/^#\\s*enabled=1.*$/enabled=0/g' /etc/systemd/coredump.conf

# Block sending statistics to Ubuntu
sed -i 's/^send-usage-stats=.*/send-usage-stats=false/g' /etc/privacy.d/00_recommended.conf

# Disable telemetry in pre-installed programs or repositories
gsettings set com.canonical.Unity.Lenses remote-content-search 'none'
gsettings set org.gnome.desktop.privacy disable-hotplug-events true
echo "deb http://archive.canonical.com/ $(lsb_release -sc) partner" | sudo tee /etc/apt/sources.list.d/canonical_partner.list
echo "Package: unity-webapps-common
Pin: version *
Pin-Priority: -1" | sudo tee /etc/apt/preferences.d/no-unity-webapps
apt-get update
apt-get remove unity-webapps-common

# Block UFW tracking server
ufw reject out from any to 162.213.33.8
ufw reject out from any to 162.213.33.9

echo "Telemetry data successfully blocked and disabled in pre-installed programs and repositories."
