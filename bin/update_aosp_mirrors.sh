#!/bin/bash

MIRRORS_DIR="/home/common/mirrors"
ASDF4_MIRROR="$MIRRORS_DIR/asdf4"
ASDF2_MIRROR="$MIRRORS_DIR/asdf2"
ASDF225_MIRROR="$MIRRORS_DIR/asdf225"
REPO_TOOL="/home/jimmieh/local/android/repo"
LOCK_FILE=/tmp/update_aosp_mirrors.lock

# Setup:
# mkdir -p $MIRRORS_DIR/{asdf4,asdf2}
# pushd $ASDF4_MIRROR
# repo init --mirror -u <ASDF4_repo> -b devel -m <manifest>
# popd
#
# pushd $ASDF2_MIRROR
# repo init --mirror -u <asdf2 repo> -b master -m <manifest> --reference $ASDF4_MIRROR
# popd

function error()
{
    echo "$(basename $0) error: $@" >&2
    exit 1
}

[ -d "$ASDF4_MIRROR" ] || error "Could not find ASDF4 mirror dir"
[ -d "$ASDF2_MIRROR" ] || error "Could not find ASDF2 mirror dir"
[ -f $REPO_TOOL ] || error "Repo tool not found"

if [ -f "$LOCK_FILE" ] && [ $(( $(date +%s) - $(stat --printf=%Y "$LOCK_FILE") )) -lt 60000 ]
then
    echo "Sync already running"
    exit 0
fi

touch "$LOCK_FILE"
trap "rm -rf $LOCK_FILE" EXIT

function sync_manifest()
{
    pushd .repo/manifests
    git checkout .
    git fetch
    $REPO_TOOL sync -l
    xmlstarlet ed -L -P -d "/manifest/project[@clone-depth]" platform-google-android*.xml
    popd
}

function clean_asdf2()
{
    pushd .repo/manifests
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/platform/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9\"]" platform-intel.xml
    xmlstarlet ed -L -P -d "/manifest/project[@name=\"aosp/platform/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9\"]" platform-intel.xml
    popd
}

function clean_asdf225()
{
    pushd .repo/manifests
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/device/amlogic/yukawa-kernel\"]" platform-caf.xml
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/device/google/crosshatch-kernel\"]" platform-caf.xml
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/device/google/wahoo-kernel\"]" platform-caf.xml
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/device/linaro/hikey-kernel\"]" platform-caf.xml
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/device/linaro/poplar-kernel\"]" platform-caf.xml
    xmlstarlet ed -L -P -d "/manifest/remove-project[@name=\"aosp/device/ti/beagle-x15-kernel\"]" platform-caf.xml
    popd
}

pushd $ASDF4_MIRROR
sync_manifest
$REPO_TOOL sync -c --optimized-fetch --prune --nmu
popd

pushd $ASDF2_MIRROR
sync_manifest
clean_asdf2
$REPO_TOOL sync -c --optimized-fetch --prune --nmu
popd

pushd $ASDF225_MIRROR
sync_manifest
clean_asdf225
$REPO_TOOL sync -c --optimized-fetch --prune --nmu
popd
