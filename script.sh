rm -rf .repo/local_manifests build &&

repo init -u https://github.com/alphadroid-project/manifest -b alpha-14 --git-lfs &&

git clone -b miatoll https://github.com/MaheshTechnicals/local_manifests_miatoll .repo/local_manifests &&

/opt/crave/resync.sh &&

source build/envsetup.sh &&

lunch lineage_miatoll-userdebug &&

make installclean &&

make bacon &&

cd frameworks/native &&

git branch
