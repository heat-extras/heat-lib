#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

#TODO Input Validation

proxy_conf_file="/etc/apache2/sites-enabled/reverse_proxy.conf"
touch $proxy_conf_file

path=`echo $proxy_pass | awk '{print $1}'`
destination_path=`echo $proxy_pass | awk '{print $2}'`

if [ $proxy_pass_reverse = "none" ]; then
  destination_reverse_path=$destination_path
else
  destination_reverse_path=`echo $proxy_reverse_pass | awk '{print $}'`
fi

cat >> $proxy_conf_file << EOF
<Location $path>
  ProxyPass $destination_path
  ProxyPassReverse $destination_reverse_path
  Order allow,deny
  Allow from all
</Location>
EOF

service apache2 restart
   
echo "Success" > $heat_outputs_path.status
