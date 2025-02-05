#!/bin/bash
  apt-get update -y
  apt-get install nginx -y
  systemctl start nginx
  echo "Hello From Terraform" > /var/www/html/index.html
