#!/usr/bin/env python3
import io
import os
import shutil
import requests
import zipfile
import ipaddress
import re
import netaddr

HOSTING_IPS_DIR = "public-cloud-ips"

# Remove existing directory (if any) and create a new one
if os.path.exists(HOSTING_IPS_DIR):
  shutil.rmtree(HOSTING_IPS_DIR)
os.mkdir(HOSTING_IPS_DIR)

# Process upstream IP data
url = "https://github.com/NikolaiT/IP-Address-API/raw/main/databases/hostingRanges.tsv.zip"

response = requests.get(url)
zipfile_bytes = io.BytesIO(response.content)
with zipfile.ZipFile(zipfile_bytes) as z:
    with z.open("hostingRanges.tsv", "r") as f:
      for line in f:
        line = line.decode('utf-8')
        ip_range = line.strip().split('\t')
        # sometimes the last field is empty, so we use a trimmed version of the company name
        provider = ip_range[2].strip() if len(ip_range) >= 3 and ip_range[2] else re.sub(r'\W+', '', ip_range[0].strip())

        if '/' in ip_range[1]:  # range is already a CIDR prefix
          subnets = [ip_range[1].strip()]  # use the provided CIDR as is
        else:  # range is specified as two IPs
          # Get the IP address range as a list
          ip_range_list = ip_range[1].strip().split(' - ')
          # Parse first and last IP addresses from input
          first = ipaddress.ip_address(ip_range_list[0].strip())
          last = ipaddress.ip_address(ip_range_list[1].strip())
          # Summarize IP address range to get the CIDR
          subnets = ipaddress.summarize_address_range(first, last)

        # Summarize IP address range and write resulting subnets to file
        if len(provider) <= 64:
          with open(os.path.join(HOSTING_IPS_DIR,provider), 'a') as provider_file:
            for subnet in subnets:
              provider_file.write(str(subnet) + "\n")

for filename in os.listdir(HOSTING_IPS_DIR):
  filepath = os.path.join(HOSTING_IPS_DIR, filename)
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
