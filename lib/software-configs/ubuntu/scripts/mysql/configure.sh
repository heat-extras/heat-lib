#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

service mysql stop

mkdir -p $data_directory 

sed -i "s~/var/run/mysqld/mysqld.sock~$data_directory/mysqld.sock~g" /etc/mysql/my.cnf
sed -i "s~/var/lib/mysql~$data_directory~g" /etc/mysql/my.cnf
sed -i "s~/var/run/mysqld/mysqld.sock~$data_directory/mysqld.sock~g" /etc/mysql/debian.cnf

cp -r /var/lib/mysql/* $data_directory/
chown -R mysql:mysql $data_directory/

service mysql start

if [ $root_password = "autogenerate" ]; then
  root_password=`date +%s | sha256sum | base64 | head -c 8`
  echo $root_password > $heat_outputs_path.root_password
else
  echo "Password was supplied" > $heat_outputs_path.root_password
fi

mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('$root_password') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF


echo "Success" > $heat_outputs_path.status 
