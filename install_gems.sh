#!/bin/sh

# Created by John Alberts
# Last modified: 10/27/2009
# 
# Error Codes:
#  1 - Not running as root
#  2 - Invalid hostname
#  3 - Failed to get rubygem-chef rpm
#  4 - Failed to get gem sources
#  5 - Failed to find Gems source extraction directory


GEM_SOURCE_URL="http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz"


if ! ( whoami | grep root > /dev/null 2>&1); then
  echo "YOU MUST BE ROOT TO RUN THIS SCRIPT"'!'
  exit 1
fi

if ! ( ping -c1 -q `hostname -f` > /dev/null 2>&1 ); then
  echo "hostname -f must be a valid fqdn for Chef to work properly"'!'
  exit 2
fi

echo "Installing Ruby dependencies..."

yum install -y ruby ruby-devel ruby-docs ruby-ri ruby-irb ruby-rdoc
RETVAL=$?

echo
echo

if [[ ${RETVAL} -ne 0 ]]; then
  echo "RUBY INSTALLATION FAILED"'!'
  exit 3
fi

echo "Installing Ruby gems from source..."

wget ${GEM_SOURCE_URL} -O /tmp/gemsource.tgz
RETVAL=$?

if [[ ${RETVAL} -ne 0 ]]; then
  echo "wget failed to retrieve gem source tarball using:"
  echo "  ${GEM_SOURCE_URL}"
  exit 4
else
  echo "Fetched sources"
  echo "Extracting and installing Gems..."
fi

tar zxf /tmp/gemsource.tgz -C /tmp

GEMS_VER=`basename ${GEM_SOURCE_URL} | sed  's/\.tgz//'`
echo "Extracted Ruby gems version: ${GEMS_VER}"
echo "Installing gems"
echo "This may take a while..."

if [[ ! -d /tmp/${GEMS_VER} ]]; then
  echo "Couldn't find Gems extraction directory, /tmp/${GEMS_VER}"
  exit 5
fi


ruby /tmp/${GEMS_VER}/setup.rb

echo "Gems installation complete"
echo "Adding opscode sources"

gem sources -a http://gems.opscode.com

echo "Installation completed."

