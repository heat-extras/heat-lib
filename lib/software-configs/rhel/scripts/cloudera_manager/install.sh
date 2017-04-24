#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

# Installing Cloudera Manger 
yum install -y wget 
wget http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
chmod u+x cloudera-manager-installer.bin
./cloudera-manager-installer.bin --no-prompt --i-agree-to-all-licenses --noreadme --nooptions

# Insert Script Here
echo "Success" > $heat_outputs_path.status
