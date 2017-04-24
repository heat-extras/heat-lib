#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

service mysql start

echo "Success" > $heat_outputs_path.status
