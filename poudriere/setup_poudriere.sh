#!/bin/sh -x

# Install dsependencies
ASSUME_ALWAYS_YES=yes pkg bootstrap
pkg update
pkg upgrade --yes
pkg install --yes poudriere apache24 git

# Configure Poudriere
echo "NO_ZFS=yes" >> /usr/local/etc/poudriere.conf
echo "FREEBSD_HOST=https://download.FreeBSD.org" >> /usr/local/etc/poudriere.conf

# Populate Poudriere jails
poudriere jail -c -j 104Ri386 -v 10.4-RELEASE -a i386
poudriere jail -c -j 111Ramd64 -v 11.1-RELEASE -a amd64

# Install system ports tree
portsnap fetch extract
mkdir /usr/ports/distfiles

# Register system and development ports trees
poudriere ports -c
poudriere ports -c -F -f none -M ${HOME}/freebsd-ports -p development

# Install development ports tree
rm -rf ${HOME}/freebsd-ports/
git clone https://github.com/yzgyyang/freebsd-ports ${HOME}/freebsd-ports/

# Done, print ports and jails
poudriere jails -l
poudriere ports -l