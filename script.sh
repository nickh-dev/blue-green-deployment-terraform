#!/bin/bash

# Update the system and install nginx

sudo apt update
sudo apt install nginx -y

# Start and enable nginx service

systemctl start nginx
systemctl enable --now nginx