# Ubuntu-Telemetry
This script blocks and disables telemetry data in Ubuntu 

by performing the following actions:
* disabling the Ubuntu telemetry service, removing it, ensuring no telemetry data is sent.
* disabling GNOME usage statistics collection, and removing the Amazon link from GNOME dash. 
* disables telemetry in pre-installed programs or repositories 
* Blocks the UFW tracking server if UFW is Installed


To use the script, simply run it on your Ubuntu machine using the following command:

``` chmod +x fxcktelemetry.sh ```
and 

``` sudo ./fxcktelemetry.sh ```
