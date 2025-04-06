#!/bin/bash

# Ubuntu 24.04 GNOME Desktop & XRDP Setup Script
# For ARM-based VMs on Oracle Cloud with SSH key authentication

# Exit on error
set -e

echo "=== Starting Ubuntu 24.04 GNOME Desktop & XRDP Setup ==="
echo "This script will set up a password for XRDP, install GNOME Desktop, and configure XRDP"

# Update system
echo "=== Updating system packages ==="
sudo apt update && sudo apt upgrade -y

# Set up password for current user if none exists
current_user=$(whoami)
echo "=== Setting up password for XRDP authentication ==="
echo "XRDP requires a password for login. Let's create one for user $current_user"
echo "Please enter a new password for your user account:"
sudo passwd $current_user

# Install GNOME Desktop
echo "=== Installing GNOME Desktop ==="
sudo DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop gnome-core

# Install XRDP
echo "=== Installing XRDP ==="
sudo apt install -y xrdp

# Configure XRDP
echo "=== Configuring XRDP ==="
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Configure XRDP to use GNOME session
echo "=== Setting GNOME as default session ==="
sudo bash -c 'cat > /etc/xrdp/startwm.sh << EOF
#!/bin/sh
# xrdp X session starter script
if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
fi
# Start GNOME session
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export DESKTOP_SESSION=ubuntu
exec /usr/bin/gnome-session
EOF'

sudo chmod +x /etc/xrdp/startwm.sh

# Fix GNOME session authentication issues
echo "=== Fixing session authentication ==="
# Create polkit directory if it doesn't exist
sudo mkdir -p /etc/polkit-1/localauthority/50-local.d/

# Now create the policy file
sudo bash -c 'cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla << EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF'

# Fix session management
echo "=== Setting up session management permissions ==="
sudo bash -c 'cat > /etc/polkit-1/localauthority/50-local.d/46-allow-update-brightness.pkla << EOF
[Allow users to change system settings]
Identity=unix-user:*
Action=org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions;org.freedesktop.login1.power-off;org.freedesktop.login1.power-off-multiple-sessions
ResultAny=yes
ResultInactive=yes
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

# Fix XRDP login issues
echo "=== Creating .xsession file ==="
cat > ~/.xsession << EOF
#!/bin/sh
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export DESKTOP_SESSION=ubuntu
export GNOME_SHELL_SESSION_MODE=ubuntu
exec /usr/bin/gnome-session
EOF
chmod +x ~/.xsession

# Configure firewall
echo "=== Configuring firewall ==="
sudo ufw allow 3389/tcp
sudo ufw reload || true

# Configure Oracle Cloud Security Lists (informational only)
echo "=== IMPORTANT: Oracle Cloud Firewall Configuration ==="
echo "Make sure to add an Ingress Rule in your VM's Security List for TCP port 3389"
echo "This can be done in the Oracle Cloud Console under Networking > Virtual Cloud Networks > Security Lists"

# Add user to correct groups
echo "=== Adding user to necessary groups ==="
sudo usermod -a -G ssl-cert $current_user

# Disable screen locking for better RDP experience
echo "=== Disabling screen locking for better RDP experience ==="
gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
gsettings set org.gnome.desktop.lockdown disable-lock-screen true 2>/dev/null || true
gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true

# Create XRDP pulseaudio configuration
echo "=== Setting up audio for XRDP ==="
sudo bash -c 'cat > /etc/xrdp/pulse/default.pa << EOF
#!/usr/bin/pulseaudio -nF
load-module module-native-protocol-unix
load-module module-null-sink sink_name=sink
load-module module-native-protocol-tcp auth-anonymous=1
load-module module-always-sink
EOF'

# Configure PAM to prevent XRDP password issues
echo "=== Fixing PAM configuration ==="
sudo sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/xrdp-sesman

# Restart XRDP for changes to take effect
echo "=== Restarting XRDP ==="
sudo systemctl restart xrdp

# Add additional desktop software (optional)
echo "=== Installing additional desktop software ==="
sudo apt install -y firefox thunderbird vlc file-roller gnome-system-monitor

# Clean up
echo "=== Cleaning up ==="
sudo apt autoremove -y
sudo apt clean

echo "=== Setup completed! ==="
echo "You can now connect to your VM using any RDP client on port 3389"
echo "IP address: $(hostname -I | awk '{print $1}')"
echo "Username: $current_user"
echo "Use the password you just created when connecting via RDP"
echo "=== Reboot is recommended! ==="
echo "Run 'sudo reboot' after this script completes for all changes to take effect"
