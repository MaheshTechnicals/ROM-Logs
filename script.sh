rm -rf .repo/local_manifests build &&

repo init -u https://github.com/OrionOS-prjkt/android -b 14.0 --git-lfs &&

git clone -b orion https://github.com/MaheshTechnicals/local_manifests_miatoll .repo/local_manifests &&

/opt/crave/resync.sh &&

source build/envsetup.sh &&

lunch orion_miatoll-ap2a-userdebug &&

make installclean &&

mka space
