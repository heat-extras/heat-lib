#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

udevadm trigger --subsystem-match=block --action=add
# Sleep for 10 seconds while waiting for trigger
sleep 10

voldata_dev="/dev/disk/by-id/virtio-$(echo ${voldata_id} | cut -c -20)"
if [ $make_fs = "true" ]; then 
  mkfs.ext4 ${voldata_dev}
fi

# Check if there is anything in the mount directory 
# and if so, the data should be avilable on the mounted volume
if [ -d "$mount_path" ]; then
  base_dir=`basename $mount_path`
  mv $mount_path /tmp/$base_dir

  mkdir -pv $mount_path
  echo "${voldata_dev} $mount_path ext4 defaults 1 2" >> /etc/fstab
  mount $mount_path

  mv /tmp/$base_dir/* $mount_path
else
  mkdir -pv $mount_path
  echo "${voldata_dev} $mount_path ext4 defaults 1 2" >> /etc/fstab
  mount $mount_path
fi
echo "Success" > $heat_outputs_path.status
