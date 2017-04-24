#!/bin/bash
set -eux

# os-apply-config templates directory
oac_templates=/usr/libexec/os-apply-config/templates
mkdir -p $oac_templates/etc

# initial /etc/os-collect-config.conf
cat <<EOF >/etc/os-collect-config.conf
[DEFAULT]
command = os-refresh-config
EOF

# template for building os-collect-config.conf for polling heat
cat <<EOF >$oac_templates/etc/os-collect-config.conf
$occ_conf
EOF
mkdir -p $oac_templates/var/run/heat-config

# template for writing heat deployments data to a file
echo "{{deployments}}" > $oac_templates/var/run/heat-config/heat-config

# os-refresh-config scripts directory
# This moves to /usr/libexec/os-refresh-config in later releases
#orc_scripts=/opt/stack/os-config-refresh
orc_scripts=/usr/libexec/os-refresh-config
for d in pre-configure.d configure.d migration.d post-configure.d; do
    install -m 0755 -o root -g root -d $orc_scripts/$d
done

# os-refresh-config script for running os-apply-config
cat <<EOF >$orc_scripts/configure.d/20-os-apply-config
$orc_oac
EOF
chmod 700 $orc_scripts/configure.d/20-os-apply-config

# os-refresh-config script for running heat config hooks
cat <<EOF >$orc_scripts/configure.d/55-heat-config
$heat_config_script
EOF
chmod 700 $orc_scripts/configure.d/55-heat-config

###
# Hooks
###

# config hook directory for shell scripts
hooks_dir=/var/lib/heat-config/hooks
mkdir -p $hooks_dir

# install heat-config-notify command
cat <<EOF >/usr/bin/heat-config-notify
$heat_config_notify
EOF
chmod 755 /usr/bin/heat-config-notify

# install hook for configuring with shell scripts
cat <<EOF >$hooks_dir/script
$hook_script
EOF
chmod 755 $hooks_dir/script

# install hook for configuring with ansible scripts
cat <<EOF >$hooks_dir/ansible
$hook_ansible
EOF
chmod 755 $hooks_dir/ansible

# install hook for configuring with puppet scripts
cat <<EOF >$hooks_dir/puppet
$hook_puppet
EOF
chmod 755 $hooks_dir/puppet

# install hook for configuring with salt scripts
cat <<EOF >$hooks_dir/salt
$hook_salt
EOF
chmod 755 $hooks_dir/salt

# run once to write out /etc/os-collect-config.conf
cat /etc/os-collect-config.conf
export LC_ALL=en_US.UTF-8

os-collect-config --one-time --debug

cat /etc/os-collect-config.conf

# run again to poll for deployments and run hooks
os-collect-config --one-time --debug
