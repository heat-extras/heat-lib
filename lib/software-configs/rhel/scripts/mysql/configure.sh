#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

generate_config () {
cat > /etc/my.cnf << EOF
[mysqld]
datadir=$data_directory
socket=$data_directory/mysql.sock

symbolic-links=0

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d

[client]
socket = $data_directory/mysql.sock
EOF
}

generate_config 
rm /etc/my.cnf.d/mariadb-server.cnf

mkdir -p $data_directory
chown -R mysql:mysql $data_directory 
systemctl restart mariadb.service

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
