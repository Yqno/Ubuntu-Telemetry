# Ubuntu-Telemetry
This script blocks and disables telemetry data in Ubuntu 

by performing the following actions:

* Stops the Ubuntu telemetry service
* Disables the Ubuntu telemetry service
* Removes the Ubuntu telemetry service
* Ensures that no telemetry data is sent by changing the relevant settings in the configuration file for apport and whoopsie
* Disables the collection of usage statistics in GNOME
* Removes the Amazon link from the Dash in GNOME
* Blocks the UFW tracking server



To use the script, simply run it on your Ubuntu machine using the following command:

``` chmod +x fxcktelemetry.sh ```
and 

``` ./fxcktelemetry.sh ```
