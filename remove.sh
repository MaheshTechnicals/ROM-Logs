#!/bin/bash

# Stop and disable services
echo "Stopping services..."
systemctl stop mysql nginx 2>/dev/null
systemctl disable mysql nginx 2>/dev/null

# Uninstall MySQL and remove data
echo "Uninstalling MySQL..."
apt remove --purge -y mysql-server mysql-client mysql-common
apt autoremove -y
rm -rf /var/lib/mysql /etc/mysql

# Uninstall all PHP versions
echo "Uninstalling all PHP versions..."
apt remove --purge -y php*
apt autoremove -y
rm -rf /etc/php

# Uninstall Nginx
echo "Uninstalling Nginx..."
apt remove --purge -y nginx nginx-common
apt autoremove -y
rm -rf /etc/nginx

# Clean up residual files
echo "Cleaning up residual files..."
rm -rf /var/log/mysql /var/log/nginx /tmp/*

# Reboot system
echo "Rebooting system..."
reboot
