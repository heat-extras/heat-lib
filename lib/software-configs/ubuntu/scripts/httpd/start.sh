#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

service apache2 restart

# Insert Script Here
echo "Success" > $heat_outputs_path.status
