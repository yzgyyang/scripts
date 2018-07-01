#!/bin/sh -x

# NAT

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
echo "security.jail.allow_raw_sockets=1" >> /etc/sysctl.conf

# Install gitlab_runner
pkg install --yes gitlab-runner
sysrc gitlab_runner_enable="YES"

# Register gitlab_runner
gitlab-runner register

# You need to manually start builds processing: 
# $ gitlab-runner run    