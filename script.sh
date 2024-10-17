crave run --no-patch -- bash -c "
# Remove existing local manifests and reinitialize the repo
rm -rf .repo/local_manifests build &&

# Initialize the repo with the new source
repo init -u https://github.com/alphadroid-project/manifest -b alpha-14 --git-lfs &&

# Clone new local_manifests repository
git clone -b main https://github.com/MaheshTechnicals/local_manifests.git .repo/local_manifests &&

# Remove old directories
rm -rf device/xiaomi/miatoll &&
rm -rf vendor/xiaomi/miatoll &&
rm -rf kernel/xiaomi/sm6250 &&
rm -rf hardware/xiaomi &&
rm -rf hardware/sony/timekeep &&
rm -rf frameworks/native &&

# Resync the repo
/opt/crave/resync.sh &&

# Setup the build environment
. build/envsetup.sh &&
lunch lineage_miatoll-userdebug &&

# Build the ROM
make bacon
"
