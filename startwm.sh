#!/bin/sh
# Unset some environment variables
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

# Source the user profile (optional, but can help if you have custom environment settings)
if [ -r "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# Start the XFCE session; using 'exec' replaces the shell with the session process
exec startxfce4
