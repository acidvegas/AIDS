#!/bin/sh
# Firewall script for Raspberry Pi - developed by acidvegas (https://git.acid.vegas/AIDS)

# Configuration
MAIN="10.0.0.10"
NODES="10.0.0.1 10.0.0.2 10.0.0.3 10.0.0.4"
SSH_PORT=2023

# Kernel hardening
{
    echo "net.ipv4.conf.all.accept_source_route = 0"
    echo "net.ipv6.conf.all.accept_source_route = 0"
    echo "net.ipv4.conf.all.rp_filter = 1"
    echo "net.ipv4.conf.default.rp_filter = 1"
    echo "net.ipv4.conf.all.accept_redirects = 0"
    echo "net.ipv6.conf.all.accept_redirects = 0"
    echo "net.ipv4.conf.default.accept_redirects = 0"
    echo "net.ipv6.conf.default.accept_redirects = 0"
    echo "net.ipv4.conf.all.log_martians = 1"
    echo "kernel.randomize_va_space = 2"
    echo "fs.suid_dumpable = 0"
} > /etc/sysctl.d/99-harden.conf

# Disable ICMP replies
sed -i '/-A ufw-before-\(input\|forward\) -p icmp --icmp-type \(destination-unreachable\|time-exceeded\|parameter-problem\|echo-request\)/s/^/# /' /etc/ufw/before.rules

# Enable UFW and set defaults
ufw reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH from main
ufw allow from $MAIN to any port $SSH_PORT proto tcp

# Allow nodes to use our local DNS server
for node in $NODES; do
    ufw allow from $node to any port 53 proto udp
    ufw allow from $node to any port 53 proto tcp
done

ufw enable
ufw reload