#!/usr/bin/env python3
import os
import requests
from datetime import datetime, timedelta


ABUSE_IPS_DIR = "abuse-ipdb"
OUTFILE = f"{ABUSE_IPS_DIR}/abusedb-ips"

URL = "https://api.abuseipdb.com/api/v2/blacklist"
LIMIT = str(30000)
BAD_IPS_URL = "https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-ip-addresses.list"

API_KEY = os.getenv('ABUSE_IPDB_API_KEY')

querystring = {
    'limit': LIMIT
}

headers = {
    'Accept': 'text/plain',
    'Key': API_KEY
}

os.makedirs(ABUSE_IPS_DIR, exist_ok=True)

# Collect all IPs in a set to deduplicate
all_ips = set()

# Fetch AbuseIPDB list
response = requests.request(method='GET', url=URL, headers=headers, params=querystring)

for line in response.text.splitlines():
    ip = line.strip()
    if ip:
        all_ips.add(ip)

# Fetch bad IP addresses list
bad_ips_response = requests.get(BAD_IPS_URL)

for line in bad_ips_response.text.splitlines():
    ip = line.strip()
    if ip:
        all_ips.add(ip)

# Write deduplicated IPs to file
with open(OUTFILE, 'w') as f:
    for ip in sorted(all_ips):
        f.write(f'{ip}\n')


