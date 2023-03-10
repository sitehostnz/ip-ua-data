#!/bin/bash
ALLOWED_IPS_DIR="allowed-ips"
mkdir -p "$ALLOWED_IPS_DIR"

# GoogleBot (https://developers.google.com/search/docs/crawling-indexing/verifying-googlebot#use-automatic-solutions)
wget -q -O - https://developers.google.com/static/search/apis/ipranges/googlebot.json|jq -r '.prefixes[] | [.ipv4Prefix,.ipv6Prefix] | map(select(. != null)) | .[]' > "$ALLOWED_IPS_DIR/GoogleBot"

# BingBot (https://www.bing.com/webmasters/help/verify-bingbot-2195837f)
wget -q -O - http://www.bing.com/toolbox/bingbot.json|jq -r '.prefixes[] | [.ipv4Prefix,.ipv6Prefix] | map(select(. != null)) | .[]' > "$ALLOWED_IPS_DIR/BingBot"

# Google - generic (eg: PageSpeed - https://centminmod.com/nginx_configure_cloudflare.html#pagespeed)
for subdomain in _netblocks _netblocks3 _netblocks2; do response=$(nslookup -q=TXT $subdomain.google.com 8.8.8.8); echo "$response" | grep -Eo '\<ip[46]:[^ ]+' | cut -c 5-; done > "$ALLOWED_IPS_DIR/Google"

