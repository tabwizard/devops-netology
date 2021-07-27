#!/usr/bin/env bash
sudo apt-get update -y
sudo apt-get install -y apache2
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform using External Script!"  >  /var/www/html/index.html
sudo ufw allow 'Apache'
sudo systemctl enable --now apache2.service