#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

#TODO Input Validation

proxy_conf_file="/etc/httpd/conf.d/proxy.conf"
touch $proxy_conf_file 

echo "ProxyPass $proxy_pass" >> $proxy_conf_file
if [ $proxy_pass_reverse = "none" ]; then
  echo "ProxyPassReverse $proxy_pass" >> $proxy_conf_file
else
  echo "ProxyPassReverse $proxy_pass_reverse" >> $proxy_conf_file
fi

systemctl restart httpd.service

echo "Success" > $heat_outputs_path.status
