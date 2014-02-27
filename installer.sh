#!/bin/sh

#
# Basic Glassfish4 Installer Script
# Author: Halid Altuner
# Contact: halid@halid.org
# github.com/halid/glassfish4-installer
# 
#
# This script running only Debian based distributions

# Configurations
GLASSFISH_USER_DIR=/opt/glassfish
GLASSFISH_HOME=$GLASSFISH_USER_DIR/glassfish

function startGlassfish {
   cd $GLASSFISH_HOME/bin
   ./asadmin start-domain domain1
}

function answerStartGlassfish () {
    while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) exit;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Required packages installation
clear
echo "Required packages installing..."
sleep 2
apt-get -y install unzip ntpdate
echo "Required packages has been successfully installed"
sleep 2

# Java7 Installation
clear
echo "Oracle JDK 1.7 Installing..."
sleep 2
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list
apt-get update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install oracle-java7-installer -y --force-yes
echo "Oracle JDK 1.7 has been successfully installed"
sleep 2

# add glassfish user & and date time sync
adduser --system --group glassfish --home $GLASSFISH_USER_DIR --shell /bin/bash
cp -f /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
ntpdate ntp.ulakbim.gov.tr

# tune max connections & kernel hacking
clear
echo "Tuning system..."
sleep 2
echo "67108864" > /proc/sys/kernel/shmmax
echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time
ulimit -n 65536
sysctl -w fs.file-max=262144
echo \
"session    required   pam_limits.so" >> /etc/pam.d/common-session
echo \
"
glassfish   soft  nofile  65536
glassfish   hard  nofile  65536
" > /etc/security/limits.conf

echo \
"
fs.file-max = 262144
kernel.pid_max = 262144
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
net.core.rmem_max = 25165824
net.core.rmem_default = 25165824
net.core.wmem_max = 25165824
net.core.wmem_default = 131072
net.core.netdev_max_backlog = 8192
net.ipv4.tcp_window_scaling = 1
net.core.optmem_max = 25165824
net.core.somaxconn = 3000
net.ipv4.ip_local_port_range = 1024 65535
kernel.shmmax = 4294967296
vm.max_map_count = 262144
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
" > /etc/sysctl.conf && sysctl -w

# Glassfish Installation

cd $GLASSFISH_USER_DIR
wget -c http://dlc.sun.com.edgesuite.net/glassfish/4.0/release/glassfish-4.0.zip
unzip glassfish-4.0.zip
rm glassfish-4.0.zip
mv $GLASSFISH_USER_DIR/glassfish4 $GLASSFISH_USER_DIR/glassfish
chown -R glassfish:glassfish $GLASSFISH_USER_DIR

chmod -R ug+rwx $GLASSFISH_HOME/bin
chmod -R ug+rwx $GLASSFISH_HOME/glassfish/bin
chmod -R ug+rwx $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/

chmod -R o-rwx $GLASSFISH_HOME/bin
chmod -R o-rwx $GLASSFISH_HOME/glassfish/bin
chmod -R o-rwx $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/
echo "Glassfish 4.0 has been successfully installed."
clear

read -p "Do you wish to start Glassfish? (y/n) " glassfishStartAnswer
if [ "$glassfishStartAnswer" = "y" ]; then
  startGlassfish
else
  echo "You need more bash programming"
fi
