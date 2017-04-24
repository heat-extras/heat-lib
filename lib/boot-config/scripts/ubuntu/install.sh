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

# Install Pip 
apt-get -y update
apt-get -y install python-pip git gcc python-dev libyaml-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev

# Upgrade Pip 
pip install --upgrade pip 

# Install Agents using pip 
pip install pytz os-collect-config os-apply-config os-refresh-config dib-utils heat-cfntools

# Install Ansible 
apt-add-repository ppa:ansible/ansible -y 
apt-get -y update 
apt-get install -y ansible 

# Install Salt 
add-apt-repository ppa:saltstack/salt -y
apt-get -y update
apt-get install -y salt-minion
pip install --upgrade salt

cfn-create-aws-symlinks
