#!/usr/bin/env python3
import os
import shutil
import requests
import gzip
import ipaddress
import netaddr

GEO_IPS_DIR = "geo-ips"

# Remove existing directory (if any) and create a new one
if os.path.exists(GEO_IPS_DIR):
  shutil.rmtree(GEO_IPS_DIR)
os.mkdir(GEO_IPS_DIR)

# Process upstream IP to country data
ip2country_v4_url = "https://iptoasn.com/data/ip2country-v4.tsv.gz"
ip2country_v6_url = "https://iptoasn.com/data/ip2country-v6.tsv.gz"

for url in [ip2country_v4_url, ip2country_v6_url]:
  response = requests.get(url, stream=True)
  with gzip.open(response.raw, 'rt') as f:
    for line in f:
      ip_range = line.strip().split()

      # Parse first and last IP addresses from input
      first = ipaddress.ip_address(ip_range[0])
      last = ipaddress.ip_address(ip_range[1])
      country = ip_range[2] if len(ip_range) > 2 and ip_range[2] else "Unknown"
      # Summarize IP address range and write resulting subnets to file
      subnets = ipaddress.summarize_address_range(first, last)

      with open(os.path.join(GEO_IPS_DIR,country), 'a') as country_file:
        for subnet in subnets:
          country_file.write(str(subnet) + "\n")

for filename in os.listdir(GEO_IPS_DIR):
  filepath = os.path.join(GEO_IPS_DIR, filename)
  if os.path.isfile(filepath):
    with open(filepath, 'r') as f:
      lines = f.read().splitlines()
      cidrs = []
      for line in lines:
        cidrs.append(netaddr.IPNetwork(line))

      supercidrs = netaddr.cidr_merge(cidrs)

    # Write the aggregated output back to the file
    with open(filepath, 'w') as f:
      for cidr in supercidrs:
        f.write(str(cidr) + "\n")
