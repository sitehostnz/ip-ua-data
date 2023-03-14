#!/bin/bash
GEO_IPS_DIR="geo-ips"
rm -rf "$GEO_IPS_DIR"
mkdir -p "$GEO_IPS_DIR"

CONTAINER=$(docker ps -q)

wget -q -O - https://iptoasn.com/data/ip2country-v4.tsv.gz|gunzip > /tmp/ip2country-v4.tsv
wget -q -O - https://iptoasn.com/data/ip2country-v6.tsv.gz|gunzip > /tmp/ip2country-v6.tsv

docker cp /tmp/ip2country-v4.tsv "${CONTAINER}":/tmp/ip2country-v4.tsv
docker cp /tmp/ip2country-v6.tsv "${CONTAINER}":/tmp/ip2country-v6.tsv
docker exec -u postgres "${CONTAINER}" mkdir /tmp/pgexport

export PGPASSWORD="postgres"
psql -h localhost -p 5432 -U postgres ipdata -c "CREATE TABLE iptable(ipstart INET NOT NULL,ipend INET NOT NULL, country TEXT NOT NULL);"

psql -h localhost -p 5432 -U postgres ipdata -c "COPY iptable FROM '/tmp/ip2country-v4.tsv' DELIMITER E'\t';"
psql -h localhost -p 5432 -U postgres ipdata -c "COPY iptable FROM '/tmp/ip2country-v6.tsv' DELIMITER E'\t';"
#special case for when country is empty
psql -h localhost -p 5432 -U postgres ipdata -c "UPDATE iptable SET country='Unknown' WHERE country = '';"

psql -h localhost -p 5432 -U postgres ipdata <<'EOF'
DO $$
DECLARE
rec record;
filename text;
BEGIN
FOR rec IN SELECT DISTINCT country FROM iptable LOOP
filename := '/tmp/pgexport/' || rec.country;
EXECUTE format('COPY (SELECT inet_merge(ipstart,ipend) AS cidr FROM iptable WHERE country = %L ORDER BY cidr) TO %L', rec.country, filename);
END LOOP;
END $$;
EOF

docker exec "${CONTAINER}" tar -cf /tmp/pgexport.tar /tmp/pgexport
docker cp "${CONTAINER}":/tmp/pgexport.tar "$GEO_IPS_DIR"/pgexport.tar
cd "$GEO_IPS_DIR"
tar --strip-components=2 -xf pgexport.tar
rm -f pgexport.tar
cd
