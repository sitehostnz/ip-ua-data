#!/bin/bash
BLOCKED_IPS_DIR="blocked-ips"
mkdir -p "$BLOCKED_IPS_DIR"

#https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
wget -q -O - https://hosts.ubuntu101.co.za/ngxubbb/bad-ips.list | sort -u | grep '[^[:blank:]]' > "$BLOCKED_IPS_DIR/nginx-ultimate-bad-bot-blocker.list"
