#!/bin/sh

########################################
# Created by John Alberts
# Last modified: 11/16/2010
# 
# Error Codes:
#  1 - Not running as root
#  2 - Invalid hostname
#  3 - Failed to get remove Ruby OS packages
#  4 - Failed to compile and install Ruby
#  5 - Failed to install Chef gems.
#
# NOTES:
#  This only works on CentOS 5.  Only tested on x86_64
#
#########################################


RUBY_SOURCE_URL="ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p0.tar.gz"

if ! ( whoami | grep root > /dev/null 2>&1); then
  echo "YOU MUST BE ROOT TO RUN THIS SCRIPT"'!'
  exit 1
fi

if ! ( ping -c1 -q `hostname -f` > /dev/null 2>&1 ); then
  echo "hostname -f must be a valid fqdn for Chef to work properly"'!'
  exit 2
fi

echo "Removing already installed Ruby OS packages..."
yum -y erase $(yum list | grep installed | grep ruby | sed -n 's/\([^.]*\)\.\(x86_64\|i386\).*$/\1/p' | tr '\n' ' ')
RETVAL=$?

echo;echo
if [[ ${RETVAL} -ne 0 ]]; then
  echo "Failed to remove Ruby OS packages"'!'
  exit 3
fi

echo "Installing Ruby and dependencies..."
yum -y install gcc gcc-c++

mkdir /tmp/sources
cd /tmp/sources

wget "${RUBY_SOURCE_URL}"
tar -xvzf $(basename ${RUBY_SOURCE_URL})
cd $(basename ${RUBY_SOURCE_URL/.tar.gz})
./configure
make
make install
RETVAL=$?

echo;echo

if [[ ${RETVAL} -ne 0 ]]; then
  echo "RUBY INSTALLATION FAILED"'!'
  exit 4
fi

echo "Installing Ruby gems from source..."

echo 'gem: --no-ri --no-rdoc' > /root/.gemrc

gem install chef
RETVAL=$?
echo;echo

if [[ ${RETVAL} -ne 0 ]]; then
  echo "CHEF INSTALLATION FAILED"'!'
  exit 5
fi

echo "Installation completed."

