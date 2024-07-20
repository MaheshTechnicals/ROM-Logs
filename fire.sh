#!/bin/bash

# Clean the previous build outputs
make clean

# Source the build environment setup script
. build/envsetup.sh

# Enable ccache and set its maximum size to 50GB
export USE_CCACHE=1
ccache -M 50G

# Set up the build environment for the specified device
breakfast miatoll

# Start the build process with the number of concurrent jobs equal to the number of available CPU cores
make bacon -j$(nproc --all)
