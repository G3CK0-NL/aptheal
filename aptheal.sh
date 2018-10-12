#!/bin/bash
#
# Apt healer script
#
# This script is provided as-is, I am not responsible for any damage this script causes!
# https://github.com/G3CK0-NL/aptheal.git
#
# Created by: G3CK0


# Check if you have IDDQD
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root"
  exit 1
fi

if [ -e /var/lib/apt/lists/lock ]
then
  echo "WARNING: Make sure there are no package managers running, or you might break more..."
  echo "Are you SURE apt/dpkg/synaptic is not running? Check using 'ps aux'!!!"
  read -p "Press [enter] to continue or Ctrl-C to abort "
fi

echo "Killing package managers..."
killall apt
killall apt-get
killall dpkg

echo "Deleting apt locks..."
rm -vf /var/lib/apt/lists/lock
rm -vf /var/cache/apt/archives/lock

echo "Trying to fix apt..."
apt-get clean
apt-get install -y -f
dpkg --configure -a
apt-get update -y --fix-missing

echo "Cleaning up..."
apt-get clean -y
apt-get autoclean -y
apt-get autoremove -y

echo "Apt itself should be ok now, installing debsums..."
apt-get install -y debsums

echo "Trying to find corrupted/missing files owned by packages (this might take a while)..."
# Debsums will output as follows:
#  - changed file: full path to stdout		/usr/share/vim/vim80/debian.vim
#  - missing file: error string to stderr	debsums: missing file /usr/share/vim/vim80/debian.vim (from vim-tiny package)
# using cut to get the fourth item, if its not there (the case with changed files), cut returns the full string.
BROKEN_FILES=`debsums -c 2>&1 | cut -d' ' -f4`
if [ ! -z "${BROKEN_FILES}" ]
then
  echo "Found corrupted and/or missing files, package(s) involved:"
  BROKEN_PACKAGES=`dpkg -S ${BROKEN_FILES} | cut -d':' -f1 | sort -u`
  echo "${BROKEN_PACKAGES}"
  echo "Reinstalling these packages..."
  apt-get install -f --reinstall ${BROKEN_PACKAGES}
fi

echo "Done"
