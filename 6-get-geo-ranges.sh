#!/bin/bash
GEO_IPS_DIR="geo-ips"
rm -rf "$GEO_IPS_DIR"
mkdir -p "$GEO_IPS_DIR"

wget -q -O - https://iptoasn.com/data/ip2country-v4.tsv.gz|gunzip|while read -r range_start range_end country_code ; do
  if [ "$country_code" = "" ]; then
    country_code="Unknown"
  fi
  ipcalc-ng --no-decorate -d ${range_start}-${range_end} >> "$GEO_IPS_DIR/${country_code}"
  done

wget -q -O - https://iptoasn.com/data/ip2country-v6.tsv.gz|gunzip|while read -r range_start range_end country_code ; do
  if [ "$country_code" = "" ]; then
    country_code="Unknown"
  fi
  ipcalc-ng --no-decorate -d ${range_start}-${range_end} >> "$GEO_IPS_DIR/${country_code}"
  done
