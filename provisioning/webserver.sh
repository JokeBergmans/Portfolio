#!/bin/bash

readonly debug_output='yes'
readonly cyan='\e[0;36m'
readonly reset='\e[0m'
debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf "${cyan}>>> %s${reset}\n" "${*}" 1>&2
  fi
}

# update system and install packages
debug "cleaning all"
yum clean all > /dev/null
debug "makecache fast"
yum makecache fast > /dev/null
debug "updating"
yum -y update > /dev/null
debug "installing packages"
yum -y install git epel-release httpd > /dev/null

# enable firewall 
debug "enable firewall"
systemctl start firewalld
systemctl enable firewalld

# configure firewall for apache
debug "configuring firewall"
firewall-cmd --permanent --add-port=80/tcp > /dev/null
firewall-cmd --permanent --add-port=443/tcp > /dev/null

# reload firewall
debug "reloading firewall"
firewall-cmd --reload > /dev/null

# start apache on boot
debug "restarting apache"
systemctl start httpd > /dev/null
systemctl enable httpd > /dev/null

# check status of apache
debug "checking apache status"
systemctl start httpd
systemctl status httpd

# copy project files to web space
debug "copying project files"
rm -rf /var/www/cgi-bin
cp -r /vagrant/{nl,en,assets} /var/www/html
