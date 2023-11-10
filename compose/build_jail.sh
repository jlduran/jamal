#!/bin/sh
set -e

JAIL_NAME="${JAIL_NAME:-$1}"
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

# Create the base jail
poudriere jail -c -j "$JAIL_NAME" -v "$FREEBSD_VERSION"

# Create the ports tree
poudriere ports -c -U https://git.freebsd.org/ports.git -B main -p latest
poudriere ports -c -M "$PWD"/ports -m null -p patches

# Build the ports
poudriere bulk -j "$JAIL_NAME" -b latest -p latest -O patches \
    -f pkglist."${JAIL_NAME}"

# Create the artifacts directory
mkdir artifacts

# Create the jail environment
poudriere image -t zfs+send+be -j "$JAIL_NAME" -s 4G -p latest -n "$JAIL_NAME" \
    -f pkglist."${JAIL_NAME}" -c overlaydir."${JAIL_NAME}" \
    -B compose/generate-je.sh -o artifacts
