#!/bin/bash 
# Moved trap b/c the `getent passwd` command will fail (return non-zero exit 
# status) if the user does not exist 

#Check if user exists
getent passwd $username >/dev/null 2>&1 && exists=true || exists=false
user_home_folder="/home/$username"

###################
### Create User ###
###################
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR
if ! $exists; then 
  useradd -m -d $user_home_folder -s /bin/bash $username
fi

################
### SSH Key ####
################
if [ $ssh_key = "autogenerate" ] && ! $exists; then 
  # Generate Key
  mkdir $user_home_folder/.ssh
  ssh-keygen -t rsa -N "" -f $user_home_folder/.ssh/$username.key

  # Set up authorized keys with newly generated pub key
  touch $user_home_folder/.ssh/authorized_keys
  cat $user_home_folder/.ssh/$username.key.pub >> $user_home_folder/.ssh/authorized_keys
  chmod 600 $user_home_folder/.ssh/authorized_keys
  chown -R $username:$username $user_home_folder/.ssh

  # Output private key to stack output
  cat $user_home_folder/.ssh/$username.key | base64 | tr -d '\n' > $heat_outputs_path.private_key

elif ! $exists; then
  # Set up authorized keys with provided key 
  touch $user_home_folder/.ssh/authorized_keys
  cat $user_home_folder/.ssh/$username.key.pub >> $user_home_folder/.ssh/authorized_keys
  chmod 600 $user_home_folder/.ssh/authorized_keys

  # Flag output that public key was supplied
  echo "Public key was supplied" > $heat_outputs_path.private_key
fi

################
### Password ###
################
if [ $password = "autogenerate" ] && ! $exists; then 
  # Generate password
  random_pw=`date +%s | sha256sum | base64 | head -c 8`
  
  # Set password
  echo $random_pw | passwd $username --stdin

  # Output generated password to stack output
  echo $random_pw > $heat_outputs_path.password

elif ! $exists; then
  # Set password
  echo $password | passwd $username --stdin

  # Flag output that password was supplied
  echo "Password was supplied" > $heat_outputs_path.password
fi

###################
### Sudoer Flag ###
###################
if [ $sudoer = "true" ] && ! $exists; then
  # Add user to sudoers file
  echo "$username  ALL=(ALL:ALL) ALL" >> /etc/sudoers
  
  # Flag user is sudoer
  echo "true" > $heat_outputs_path.sudoer

elif ! $exists; then
  # Flag user is not sudoer
  echo "false" > $heat_outputs_path.sudoer
fi

#####################
### Disabled Flag ###
#####################
if [ $disabled = "true" ]; then
  # Set user login to nologin
  chsh -s /sbin/nologin $username

  # Flag output that password was supplied
  echo "true" > $heat_outputs_path.disabled

else
  # Set user login to /bin/bash
  chsh -s /bin/bash $username
  echo "false" > $heat_outputs_path.disabled
fi

# Mark as successful 
echo "Success" > $heat_outputs_path.status
