#!/bin/bash 
#trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

# Shutdown in 1 min. This is a hack to allow the SD mechanism to signal
# that this script finished running. OTherwise it would get interrupted 
# in the middle of the script and never finish. Be sure to run this script 
# in such a manner that guarantees this is the only script running to avoid 
# the same thing happening as described above
echo "WHAT THE HELL IS GOING ON" > /tmp/out
systemctl stop os-collect-config.service
OUTPUT="$(/sbin/reboot)"
echo $OUTPUT > /tmp/my_output

# Insert Script Here
echo "Success" > $heat_outputs_path.status
