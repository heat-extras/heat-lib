#!/bin/bash 

CMD=`which setenforce`
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

if [ -z $CMD ]; then 
  echo "Selinux was not enabled on this system or the utils used to manage it are not available"  > $heat_outputs_path.status
  exit 0 
fi

# Disable Selinux
setenforce 0

# Make the change persistent
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Insert Script Here
echo "Success" > $heat_outputs_path.status
