#!/bin/sh -x

# NAT
sysrc pf_enable="YES"
sysrc gateway_enable="YES"
mv /etc/pf.conf /etc/pf.conf.orig || true
# Assume IP_PUB, vtnet0
echo 'IP_PUB="45.63.11.65"' > /etc/pf.conf
echo 'IP_JAIL="192.168.0.2"' >> /etc/pf.conf
echo 'NET_JAIL="192.168.0.0/24"' >> /etc/pf.conf
echo 'PORT_JAIL="{80,443,2020}"' >> /etc/pf.conf
echo 'scrub in all' >> /etc/pf.conf
echo 'nat pass on vtnet0 from $NET_JAIL to any -> $IP_PUB' >> /etc/pf.conf
echo 'rdr pass on vtnet0 proto tcp from any to $IP_PUB port $PORT_JAIL -> $IP_JAIL' >> /etc/pf.conf
pfctl -nf /etc/pf.conf
service pf start

# pkg
ASSUME_ALWAYS_YES=yes pkg bootstrap
pkg update
pkg install --yes ezjail

# Install ezjail
ezjail-admin install -p
sysrc ezjail_enable="YES"

# Add net interface for jails
sysrc cloned_interfaces="lo1"
sysrc ipv4_addrs_lo1="192.168.0.1-9/29"
service netif cloneup

# Advanced network setting for jails
echo 'security.jail.allow_raw_sockets=1' >> /etc/sysctl.conf

# Install gitlab_runner
pkg install --yes gitlab-runner tmux
# It appears that gitlab-runner doesn't work well with FreeBSD's rc system
#sysrc gitlab_runner_enable="YES"

echo 'Register using `gitlab-runner register`'

echo 'You need to manually start builds processing:'
echo 'gitlab-runner run'
