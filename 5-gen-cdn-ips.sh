#!/bin/bash
CDN_IPS_DIR="cdn-ips"
mkdir -p "$CDN_IPS_DIR"

# AWS Cloudfront (https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html)
wget -q -O - https://ip-ranges.amazonaws.com/ip-ranges.json| jq -r '.prefixes[] | select(.service=="CLOUDFRONT") | .ip_prefix' > "$CDN_IPS_DIR/AWSCloudfront"

# Bunny CDN (https://support.bunny.net/hc/en-us/articles/115003578911-How-to-detect-when-BunnyCDN-PoP-servers-are-accessing-your-backend)
wget -q -O - https://bunnycdn.com/api/system/edgeserverlist | tr -d '[]"' | sed -e 's/,/\n/g' -e 's/$/\n/' > "$CDN_IPS_DIR/BunnyCDN"
wget -q -O - https://bunnycdn.com/api/system/edgeserverlist/Ipv6 | tr -d '[]"' | sed -e 's/,/\n/g' -e 's/$/\n/' >> "$CDN_IPS_DIR/BunnyCDN"

# Cloudflare (https://www.cloudflare.com/ips/)
wget -q -O - https://www.cloudflare.com/ips-v4 | sed '$a\' > "$CDN_IPS_DIR/Cloudflare"
wget -q -O - https://www.cloudflare.com/ips-v6 | sed '$a\' >> "$CDN_IPS_DIR/Cloudflare"

# Fastly (https://developer.fastly.com/reference/api/utils/public-ip-list/)
wget -q -O - https://api.fastly.com/public-ip-list|jq -r '.addresses[], .ipv6_addresses[]' > "$CDN_IPS_DIR/Fastly"

# Imperva (https://docs.imperva.com/howto/c85245b7)
wget -q -O - --post-data "resp_format=text" https://my.imperva.com/api/integration/v1/ips > "$CDN_IPS_DIR/Imperva"

# RedShield (https://support.redshield.co/hc/en-gb/articles/207524203-Firewall-Settings-for-RedShield-Cloud)
wget -q -O - https://www.redshield.co/ipv4 | sed -e 's/ /\n/g' -e 's/$/\n/' > "$CDN_IPS_DIR/RedShield"
