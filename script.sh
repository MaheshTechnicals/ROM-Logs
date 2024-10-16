crave run --no-patch -- bash -c "
# Remove existing local manifests and reinitialize the repo
rm -rf .repo/local_manifests &&
repo init --depth=1 --no-repo-verify \
    -u https://github.com/BlissRoms/platform_manifest.git \
    -b universe --git-lfs -g default,-mips,-darwin,-notdefault &&

# Resync the repo
/opt/crave/resync.sh &&

# Remove old device, vendor, kernel, and frameworks/native directories
rm -rf device/xiaomi/miatoll &&
rm -rf vendor/xiaomi/miatoll &&
rm -rf kernel/xiaomi/sm6250 &&
rm -rf hardware/xiaomi &&
rm -rf hardware/sony/timekeep &&
rm -rf frameworks/native &&

# Clone new device, vendor, kernel, and hardware trees
git clone -b 15 https://github.com/clarencekopitiam/kernel_xiaomi_sm6250.git kernel/xiaomi/sm6250 --depth=1 &&
git clone -b lineage-21.0 https://github.com/clarencekopitiam/vendor_xiaomi_miatoll.git vendor/xiaomi/miatoll --depth=1 &&
git clone -b lineage-21 https://github.com/LineageOS/android_hardware_xiaomi.git hardware/xiaomi --depth=1 &&
git clone -b lineage-21 https://github.com/LineageOS/android_hardware_sony_timekeep.git hardware/sony/timekeep --depth=1 &&
git clone https://github.com/clarencelol/vendor_xiaomi_miuicamera.git vendor/xiaomi/miuicamera --depth=1 &&
git clone -b alpha https://github.com/MaheshTechnicals/vendor_lineage-priv.git vendor/lineage-priv/keys --depth=1 &&

# Clone the frameworks/native repository
git clone -b alpha-14 https://github.com/MaheshTechnicals/frameworks_native-alpha.git frameworks/native --depth=1 &&

# Setup the build environment
. build/envsetup.sh &&
lunch lineage_miatoll-userdebug &&

# Build the ROM
make bacon
"
