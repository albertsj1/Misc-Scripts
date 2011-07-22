#!/bin/sh

########################################
# Created by John Alberts
# Last modified: 04/21/2011
# 
# Error Codes:
#  1 - Not running as root
#  2 - Invalid hostname
#  3 - Failed to get remove Ruby OS packages
#  4 - Failed to compile and install Ruby
#
# NOTES:
#  This only works on CentOS 5.  Only tested on x86_64
#
#########################################



#RUBY_SOURCE_URL="ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p136.tar.gz"
#RUBY_SOURCE_URL="http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz"
# The below URL only works from within the exlibrisgroup network.  Anyone else should use the URL above.
RUBY_SOURCE_URL="https://helpdesk.hosted.exlibrisgroup.com/downloads/ruby-1.9.2-p180.tar.gz"


if ! ( whoami | grep root > /dev/null 2>&1); then
  echo "YOU MUST BE ROOT TO RUN THIS SCRIPT"'!'
  exit 1
fi

if ! ( ping -c1 -q `hostname -f` > /dev/null 2>&1 ); then
  echo "hostname -f must be a valid fqdn for Chef to work properly"'!'
  exit 2
fi

echo "Removing already installed Ruby OS packages..."
PKGLIST="$(yum list | grep installed | grep ruby | sed -n 's/\([^.]*\)\.\(x86_64\|i386\).*$/\1/p' | tr '\n' ' ')"
if [[ $PKGLIST != "" ]]; then
  yum -y erase $PKGLIST
  RETVAL=$?
else
  RETVAL=0
fi

echo;echo
if [[ ${RETVAL} -ne 0 ]]; then
  echo "Failed to remove Ruby OS packages"'!'
  exit 3
fi

echo "Installing Ruby and dependencies..."
yum -y install gcc gcc-c++ zlib-devel openssl-devel readline-devel

mkdir /tmp/sources
cd /tmp/sources


# Get # cpu's to make this faster
if [[ ! $CPUS ]]; then
  CPUS="$(grep processor /proc/cpuinfo | wc -l)"
fi

wget "${RUBY_SOURCE_URL}"
tar -xvzf $(basename ${RUBY_SOURCE_URL})
cd $(basename ${RUBY_SOURCE_URL/.tar.gz})
./configure
make -j $CPUS
make -j $CPUS install
RETVAL=$?

echo;echo

if [[ ${RETVAL} -ne 0 ]]; then
  echo "RUBY INSTALLATION FAILED"'!'
  exit 4
fi

echo 'gem: --no-ri --no-rdoc' > /root/.gemrc

echo "Installation completed."

