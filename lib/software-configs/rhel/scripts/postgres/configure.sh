#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR


mkdir /etc/systemd/system/postgresql.service.d
mkdir -p $data_directory
chown postgres:postgres $data_directory
cd $data_directory

generate_systemd_config () {
cat > /etc/systemd/system/postgresql.service.d/override.conf << EOF
.include /lib/systemd/system/postgresql.service
[Service]
Environment=PGDATA=$data_directory
EOF
}

generate_auth_config () {
cat > $data_directory/pg_hba.conf << EOF
local   all             postgres                                 trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
EOF
}

generate_systemd_config 

# Init DB
su postgres -c "initdb -D $data_directory"

if [ $postgres_password = "autogenerate" ]; then
  postgres_password=`date +%s | sha256sum | base64 | head -c 8`
  echo $postgres_password > $heat_outputs_path.postgres_password
else
  echo "Password was supplied" > $heat_outputs_path.postgres_password
fi
echo $postgres_password | passwd postgres --stdin

generate_auth_config

echo "Success" > $heat_outputs_path.status
