rm -rf .repo/local_manifests build &&

repo init --depth=1 -u https://github.com/AfterlifeOS/android_manifest.git -b 14 --git-lfs &&

git clone -b afterlife https://github.com/MaheshTechnicals/local_manifests_miatoll .repo/local_manifests &&

/opt/crave/resync.sh &&

source build/envsetup.sh &&

goafterlife miatoll
