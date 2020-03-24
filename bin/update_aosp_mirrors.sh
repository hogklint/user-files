#!/bin/bash

MIRRORS_DIR="/home/common/mirrors"
ASDF4_MIRROR="$MIRRORS_DIR/asdf4"
ASDF2_MIRROR="$MIRRORS_DIR/asdf2"
REPO_TOOL="/home/jimmieh/local/android/repo"

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

pushd $ASDF4_MIRROR
$REPO_TOOL sync
popd

pushd $ASDF2_MIRROR
$REPO_TOOL sync
popd
