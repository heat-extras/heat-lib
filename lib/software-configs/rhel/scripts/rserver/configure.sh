#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

echo "www-port=$port" > /etc/rstudio/rserver.conf

systemctl restart rstudio-server.service

# Insert Script Here
echo "Success" > $heat_outputs_path.status
