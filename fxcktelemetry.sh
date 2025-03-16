#!/bin/bash

# Script to disable various telemetry and tracking services on Ubuntu
# Must be run with sudo privileges

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a /var/log/telemetry_disable.log
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Create log file if it doesn't exist
touch /var/log/telemetry_disable.log 2>/dev/null || {
    echo -e "${RED}Cannot create log file${NC}"
    exit 1
}

log "INFO" "Starting telemetry disable script"

# Function to stop and disable service
disable_service() {
    local service="$1"
    if systemctl is-active "$service" &>/dev/null; then
        systemctl stop "$service" && log "INFO" "Stopped $service" || log "ERROR" "Failed to stop $service"
    fi
    if systemctl is-enabled "$service" &>/dev/null; then
        systemctl disable "$service" && log "INFO" "Disabled $service" || log "ERROR" "Failed to disable $service"
    fi
}

# Function to remove package if installed
remove_package() {
    local package="$1"
    if dpkg -l "$package" &>/dev/null; then
        apt-get purge -y "$package" && log "INFO" "Removed $package" || log "ERROR" "Failed to remove $package"
    fi
}

# Backup configuration files
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d)" && log "INFO" "Backed up $file" || log "ERROR" "Failed to backup $file"
    fi
}

# Disable Ubuntu telemetry service
disable_service "ubuntu-report.service"
remove_package "ubuntu-report"

# Configure crash reporting
for file in /etc/default/apport /etc/default/whoopsie; do
    backup_file "$file"
    [ -f "$file" ] && {
        sed -i 's/ReportCrashes=true/ReportCrashes=false/g' "$file" 2>/dev/null || log "ERROR" "Failed to modify $file"
        sed -i 's/enabled=1/enabled=0/g' "$file" 2>/dev/null || log "ERROR" "Failed to modify $file"
    }
done

# Disable GNOME telemetry
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.privacy send-software-usage-stats false 2>/dev/null && \
        log "INFO" "Disabled GNOME usage stats" || log "ERROR" "Failed to disable GNOME usage stats"
    gsettings set com.canonical.Unity.Lenses remote-content-search 'none' 2>/dev/null && \
        log "INFO" "Disabled Unity remote search" || log "ERROR" "Failed to disable Unity remote search"
    gsettings set org.gnome.desktop.privacy disable-hotplug-events true 2>/dev/null && \
        log "INFO" "Disabled hotplug events" || log "ERROR" "Failed to disable hotplug events"
else
    log "WARNING" "gsettings not found, skipping GNOME settings"
fi

# Configure UFW rules
if command -v ufw >/dev/null; then
    ufw status | grep -q "Status: active" || {
        ufw enable
        log "INFO" "Enabled UFW"
    }
    
    for ip in "91.189.89.199" "162.213.33.8" "162.213.33.9"; do
        ufw reject out to "$ip" && log "INFO" "Blocked outbound traffic to $ip" || log "ERROR" "Failed to block $ip"
    done
else
    log "WARNING" "UFW not found, skipping firewall rules"
fi

# Disable additional systemd services
services=("systemd-coredump" "systemd-timedated" "systemd-resolved" "systemd-timesyncd")
for service in "${services[@]}"; do
    disable_service "$service"
    remove_package "$service"
done

# Configure additional telemetry settings
for file in /etc/apport/crashdb.conf /etc/systemd/coredump.conf; do
    backup_file "$file"
    [ -f "$file" ] && {
        sed -i 's/^enabled=1$/enabled=0/g' "$file" 2>/dev/null
        sed -i 's/^#*\s*submit_crash.*$/submit_crash=false/g' "$file" 2>/dev/null
    }
done

# Configure Canonical partner repository
partner_list="/etc/apt/sources.list.d/canonical_partner.list"
backup_file "$partner_list"
echo "deb http://archive.canonical.com/ $(lsb_release -sc) partner" > "$partner_list" 2>/dev/null && \
    log "INFO" "Configured Canonical partner repository" || log "ERROR" "Failed to configure partner repository"

# Prevent unity-webapps installation
webapps_pref="/etc/apt/preferences.d/no-unity-webapps"
cat > "$webapps_pref" << EOF
Package: unity-webapps-common
Pin: version *
Pin-Priority: -1
EOF
[ $? -eq 0 ] && log "INFO" "Configured webapps pin" || log "ERROR" "Failed to configure webapps pin"

# Update package lists and remove webapps
apt-get update -qq && log "INFO" "Updated package lists" || log "ERROR" "Failed to update package lists"
remove_package "unity-webapps-common"

log "INFO" "Telemetry disable process completed successfully"
echo -e "${GREEN}Telemetry successfully disabled${NC}"

# Clean up old backups (keep last 5)
find /etc -name "*.bak.*" -type f | sort -r | tail -n +6 | xargs -I {} rm -f {} && \
    log "INFO" "Cleaned up old backups" || log "WARNING" "Failed to clean up old backups"
