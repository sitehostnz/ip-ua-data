#!/bin/bash
ALLOWED_IPS_DIR="allowed-ips"
mkdir -p "$ALLOWED_IPS_DIR"

# GoogleBot (https://developers.google.com/search/docs/crawling-indexing/verifying-googlebot#use-automatic-solutions)
wget -q -O - https://developers.google.com/static/search/apis/ipranges/googlebot.json|jq -r '.prefixes[] | [.ipv4Prefix,.ipv6Prefix] | map(select(. != null)) | .[]' > "$ALLOWED_IPS_DIR/GoogleBot"

# BingBot (https://www.bing.com/webmasters/help/verify-bingbot-2195837f)
wget -q -O - http://www.bing.com/toolbox/bingbot.json|jq -r '.prefixes[] | [.ipv4Prefix,.ipv6Prefix] | map(select(. != null)) | .[]' > "$ALLOWED_IPS_DIR/BingBot"

# Cloudflare (https://www.cloudflare.com/ips/)
wget -q -O - https://www.cloudflare.com/ips-v4 > "$ALLOWED_IPS_DIR/Cloudflare"
##needs a new line after
echo >> "$ALLOWED_IPS_DIR/Cloudflare"
wget -q -O - https://www.cloudflare.com/ips-v6 >> "$ALLOWED_IPS_DIR/Cloudflare"
echo >> "$ALLOWED_IPS_DIR/Cloudflare"

# Fastly (https://developer.fastly.com/reference/api/utils/public-ip-list/)
wget -q -O - https://api.fastly.com/public-ip-list|jq -r '.addresses[], .ipv6_addresses[]' > "$ALLOWED_IPS_DIR/Fastly"
