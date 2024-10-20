# Remove existing local manifests and reinitialize the repo
rm -rf .repo/local_manifests build &&

# Initialize the repo with the new source
repo init -u https://github.com/alphadroid-project/manifest -b alpha-14 --git-lfs &&

# Clone new local_manifests repository
git clone -b main https://github.com/MaheshTechnicals/local_manifests1 .repo/local_manifests &&

# Resync the repo
/opt/crave/resync.sh &&

# Setup the build environment
. build/envsetup.sh &&
lunch lineage_miatoll-userdebug &&

# Build the ROM
make bacon
