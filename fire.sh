#!/bin/bash

# Clean the previous build outputs
make clean

# Source the build environment setup script
. build/envsetup.sh

# Enable ccache and set its maximum size to 50GB
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)  # Ensure ccache is correctly set
ccache -M 50G

# Set up the build environment for the specified device
lunch lineage_miatoll-userdebug

# Start the build process with the number of concurrent jobs equal to the number of available CPU cores
mka bacon -j$(nproc --all)
