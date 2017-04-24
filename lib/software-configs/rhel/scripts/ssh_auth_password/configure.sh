#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd.service

# Insert Script Here
echo "Success" > $heat_outputs_path.status
