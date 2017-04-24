#!/bin/bash
set -eux

# Proxy Configuration for Agent Installation 
if [ "$http_proxy_val" != "none" ]
then
  export http_proxy=$http_proxy_val
  export HTTP_PROXY=$http_proxy_val
  echo "Setting http_proxy var: $http_proxy"
fi

if [ "$https_proxy_val" != "none" ]
then
  export https_proxy=$https_proxy_val
  export HTTPS_PROXY=$https_proxy_val
  echo "Setting https_proxy var: $https_proxy"
fi

yum -y install https://www.rdoproject.org/repos/rdo-release.rpm
yum -y install python-zaqarclient python-oslo-log python-psutil os-collect-config os-apply-config os-refresh-config dib-utils 

# Install Hook Requirments TODO: move these in a more apporpriate place

# Ansible
yum -y install ansible 

# Puppet 
yum -y install puppet 

# Salt
yum -y install epel-release
yum -y install salt-minion 
