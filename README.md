# Ubuntu-Telemetry
This script blocks and disables telemetry data in Ubuntu 

by performing the following actions:
* disabling the Ubuntu telemetry service, removing it, ensuring no telemetry data is sent.
* disabling GNOME usage statistics collection, and removing the Amazon link from GNOME dash. 
* disables telemetry in pre-installed programs or repositories 
* Blocks the UFW tracking server if UFW is Installed


To use the script, simply run it on your Ubuntu machine using the following command:

clone the repository with ```git clone```

then you go into the directory with ```cd Ubuntu-Telemetry```

then you give permission to run this Script with ``` chmod +x fxcktelemetry.sh ```
 
and Run this Script with ``` sudo ./fxcktelemetry.sh ```


