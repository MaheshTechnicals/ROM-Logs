rm -rf .repo/local_manifests build &&

repo init -u https://github.com/Evolution-X/manifest -b udc --git-lfs &&

git clone -b evo https://github.com/MaheshTechnicals/local_manifests_miatoll .repo/local_manifests &&

/opt/crave/resync.sh &&

source build/envsetup.sh &&

lunch lineage_miatoll-userd &&

make installclean &&

evolution &&

cd frameworks/native &&

git branch
