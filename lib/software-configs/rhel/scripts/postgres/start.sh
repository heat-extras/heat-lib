#!/bin/bash 
trap 'echo "Failed" > $heat_outputs_path.status; exit;' ERR

systemctl start postgresql.service

echo "Success" > $heat_outputs_path.status
