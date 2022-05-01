#!/usr/bin/env bash

# This file is part of Pokas.
#
# Pokas is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pokas is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pokas. If not, see <https://www.gnu.org/licenses/>.

# ######################################################################################################################
# VARIABLES
# ######################################################################################################################

# General
export PROGRAM_NAME="pokas"

# Directories
export BUILD_DIR="build"
export CMD_DIR="cmd"
export DIST_DIR="dist"

# Go
export CGO_ENABLED=0
export GO111MODULE="on"
export GO15VENDOREXPERIMENT=1

# ######################################################################################################################
# FUNCTIONS
# ######################################################################################################################

_get_commit() {
    COMMIT=$(git rev-parse --short HEAD)

    if [ "$COMMIT" == "" ]; then
        echo "unknown"
    else
        echo $COMMIT
    fi
}

_get_version() {
    REV="unknown"

    if [ "$CI" == "" ]; then
        REV=$(git rev-list --tags --max-count=1)

        if [ "$REV" == "" ]; then
            REV=$(git describe --always --tags)
        fi
    else
        if [ "$GITHUB_SHA" != "" ]; then
            REV=$GITHUB_SHA
        fi
    fi

    echo $REV
}

_build() {
    BUILD_ARCH=$(echo $2 | cut -d/ -f2)
    BUILD_COMMIT=$(_get_commit)
    BUILD_OS=$(echo $2 | cut -d/ -f1)
    BUILD_TIME=$(date --rfc-3339=seconds)
    BUILD_VERSION=$(_get_version)
    BUILD_LDFLAGS="-X 'main.BuildTime=$BUILD_TIME' -X 'main.Commit=$BUILD_COMMIT' -X 'main.Version=$BUILD_VERSION'"
    BUILD_FILE="$BUILD_DIR/$BUILD_OS-$BUILD_ARCH/$PROGRAM_NAME"
    RELEASE=$1

    if [ "$RELEASE" == "yes" ]; then
        BUILD_LDFLAGS="$BUILD_LDFLAGS -w -s"
    fi

    echo "---------------------------------------------------------------------"
    echo "Building $PROGRAM_NAME for..."
    echo "---------------------------------------------------------------------"
    echo "Arch:      $BUILD_ARCH"
    echo "OS:        $BUILD_OS"
    echo "Timestamp: $BUILD_TIME"
    echo "Commit:    $BUILD_COMMIT"
    echo "Version:   $BUILD_VERSION"
    echo "Release:   $RELEASE"
    echo "Flags:     $BUILD_LDFLAGS"
    echo "---------------------------------------------------------------------"
    echo ""

    GOOS=$BUILD_OS                       \
    GOARCH=$BUILD_ARCH                   \
    go build                             \
        -o "$BUILD_FILE"                 \
        -mod=vendor                      \
        -ldflags="$BUILD_LDFLAGS"        \
        "$CMD_DIR/$PROGRAM_NAME/main.go"

    if [ "$RELEASE" == "yes" ]; then
        TARBALL="$DIST_DIR/$PROGRAM_NAME-$BUILD_VERSION-$BUILD_OS-$BUILD_ARCH.tar.gz"

        echo "---------------------------------------------------------------------"
        echo "Releasing $TARBALL"
        echo "---------------------------------------------------------------------"

        tar -czvf "$TARBALL" -C $(dirname $BUILD_FILE) .

        echo "---------------------------------------------------------------------"
        echo ""

        if [ "$CI" != "" ]; then
            echo "::set-output name=version::$BUILD_VERSION"
        fi
    fi
}

_usage() {
    echo "Usage: $0 [-r] -p <string>"
    echo ""
    echo "    -r  release mode"
    echo "    -p  platform, example: linux/amd64"
    echo ""
    echo "Please, run this script from the root of the repository."
}

# ######################################################################################################################
# MAIN
# ######################################################################################################################

if [ -d ".git" ]; then
    RELEASE="no"

    while getopts "p:r" o; do
        case "${o}" in
            p)
                PLATFORM=$OPTARG
                ;;
            r)
                RELEASE="yes"
                ;;
            *)
                _usage
                ;;
        esac
    done

    _build $RELEASE $PLATFORM
else
    _usage
    exit 1
fi
