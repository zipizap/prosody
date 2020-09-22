#!/usr/bin/env bash

DOMAIN="${1?Usage: $0 10.147.17.38.xip.io}"
./generate_selfsigned_CA_and_cert.sh $DOMAIN

rm -rf ./certs &>/dev/null || true \
&& mkdir -p ./certs/{,conference.,proxy.,upload.}$DOMAIN \
&& chmod 777 certs \
&& mkdir -p data \
&& chmod 777 data \
&& chmod -v 444 privkey.pem \
&& chmod -v 444 fullchain.pem \
&& \
(
  for a_dir in / conference. proxy. upload.; do
    cp -v fullchain.pem ./certs/${a_dir}$DOMAIN/fullchain.pem
    cp -v privkey.pem ./certs/${a_dir}$DOMAIN/privkey.pem
  done
) \
&& echo "== all done =="
