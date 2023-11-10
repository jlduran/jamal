#!/bin/sh
set -e

export NO_LIB32="yes"
export NO_SRC="yes"
FREEBSD_VERSION="13.2-RELEASE"
JAIL_NAME="host"
PWD="${PWD:-.}"

# Install dependencies
pkg install -y git-tiny poudriere-devel

# Set the poudriere(8) ZPOOL environment variable
sed -i "" -E 's/^#?ZPOOL=zroot$/ZPOOL=zroot/' \
    /usr/local/etc/poudriere.conf

# Configure ALLOW_MAKE_JOBS
sed -i "" -E 's/^#?ALLOW_MAKE_JOBS_PACKAGES=.*$/ALLOW_MAKE_JOBS_PACKAGES="pkg gcc* llvm* node* rust*"/' \
    /usr/local/etc/poudriere.conf

# Make the poudriere(8) DISTFILES_CACHE directory
mkdir -p /usr/ports/distfiles

# Create/update the base jail
if [ "$(poudriere jail -lq | awk '/host/ { print $1 }')" = "host" ]; then
	poudriere jail -u -j "$JAIL_NAME"
else
	poudriere jail -c -j "$JAIL_NAME" -v "$FREEBSD_VERSION" -K GENERIC
fi

# Create/update the ports tree
if [ "$(poudriere ports -lq | awk '/latest/ { print $1 }')" = "latest" ]; then
	poudriere ports -u -p latest
else
	poudriere ports -c -U https://git.freebsd.org/ports.git -B main -p latest
fi
if [ "$(poudriere ports -lq | awk '/patches/ { print $1 }')" != "patches" ]; then
	poudriere ports -c -M "$PWD"/ports -m null -p patches
fi

# Build the ports
poudriere bulk -j "$JAIL_NAME" -b latest -p latest -O patches \
    -f pkglist."${JAIL_NAME}"

# Create the artifacts directory
mkdir -p artifacts

# Create the boot environment
poudriere image -t zfs+send+be -j "$JAIL_NAME" -s 4G -p latest -n "$JAIL_NAME" \
    -f pkglist."${JAIL_NAME}" -c overlaydir."${JAIL_NAME}" -o artifacts
