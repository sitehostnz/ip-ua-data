#!/bin/bash
CLOUD_IPS_DIR="public-cloud-ips"
mkdir -p "$CLOUD_IPS_DIR"

#Azure Cloud
wget -q -O - https://azureipranges.azurewebsites.net/Data/Public.json | jq -r '.values[] | select(.name == "AzureCloud") | .properties.addressPrefixes[]' > "$CLOUD_IPS_DIR/azure-cloud"

#AWS EC2
wget -q -O - https://ip-ranges.amazonaws.com/ip-ranges.json | grep 'EC2"' -B2 |grep -E 'ip_prefix|ipv6_prefix'|awk '{print $NF}'|sed -e 's/\"//g' -e 's/,//' > "$CLOUD_IPS_DIR/aws-ec2"

#CGP
wget -q -O - https://www.gstatic.com/ipranges/cloud.json | jq -r '(.prefixes[] | select(.ipv4Prefix != null) | .ipv4Prefix), (.prefixes[] | select(.ipv6Prefix != null) | .ipv6Prefix)' > "$CLOUD_IPS_DIR/google-cloud-platform"

#Digital Ocean
wget -q -O - https://www.digitalocean.com/geo/google.csv|awk -F, '{print $1}' > "$CLOUD_IPS_DIR/digital-ocean"
