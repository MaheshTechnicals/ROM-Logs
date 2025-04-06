#!/bin/bash

# Fix for the polkit directory not existing
echo "=== Creating polkit directory and fixing session authentication ==="
sudo mkdir -p /etc/polkit-1/localauthority/50-local.d/

# Create the colord policy file
sudo bash -c 'cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla << EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF'

# Fix black screen issue with XRDP in GNOME
echo "=== Fixing potential black screen issues ==="
sudo bash -c 'cat > /etc/xrdp/sesman.ini << EOF
[Globals]
ListenAddress=127.0.0.1
ListenPort=3350
EnableUserWindowManager=true
UserWindowManager=startwm.sh
DefaultWindowManager=startwm.sh

[Security]
AllowRootLogin=true
MaxLoginRetry=4
TerminalServerUsers=tsusers
TerminalServerAdmins=tsadmins

[Sessions]
X11DisplayOffset=10
MaxSessions=50
KillDisconnected=false
IdleTimeLimit=0
DisconnectedTimeLimit=0
Policy=Default

[Logging]
LogFile=xrdp-sesman.log
LogLevel=INFO
EnableSyslog=true
SyslogLevel=INFO

[X11rdp]
param=--no-auth
param=--use-xfs

[Xvnc]
param=-bs
param=-ac
param=-nolisten
param=tcp
param=-localhost
param=-dpi
param=96
EOF'

# Restart XRDP for changes to take effect
echo "=== Restarting XRDP ==="
sudo systemctl restart xrdp

echo "=== Fix completed! ==="
echo "You should now be able to connect to your VM using any RDP client on port 3389"
echo "IP address: $(hostname -I | awk '{print $1}')"
echo "=== Reboot is recommended! ==="
echo "Run 'sudo reboot' after this script completes for all changes to take effect"
