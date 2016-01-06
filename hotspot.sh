#!/bin/bash

# This script to used to create hotspot on laptop.
# You need to install dnsmasq and hostapd first.
# Works on ubuntu 15.04.

trap ctrl_c INT
function ctrl_c() {
	echo "** Trapped CTRL-C"
	# Stop
	# Disable NAT
	sudo iptables -D POSTROUTING -t nat -o eth0 -j MASQUERADE
	# Disable routing
	sudo sysctl net.ipv4.ip_forward=0
	# Disable DHCP/DNS server
	sudo service dnsmasq stop
	sudo service hostapd stop
	sudo /etc/init.d/network-manager restart
	sleep 3
	sudo nmcli r wifi on
}
# Start
# Configure IP address for WLAN
sudo nmcli r wifi on
sudo /etc/init.d/network-manager restart
sleep 3
sudo nmcli r wifi off
sudo rfkill unblock wlan
sleep 1
sudo ifconfig wlan0 192.168.150.1/24 up
# Start DHCP/DNS server
sudo service dnsmasq restart
# Enable routing
sudo sysctl net.ipv4.ip_forward=1
# Enable NAT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# Run access point daemon
sudo hostapd /etc/ap-hotspot.conf
