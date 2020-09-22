#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__dbg_on_off=on  # on off
function shw_info { echo -e '\033[1;34m'"$@"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
function dbg { [[ "$__dbg_on_off" == "on" ]] || return; echo -e '\033[1;34m'"dbg $(date +%Y%m%d%H%M%S) ${BASH_LINENO[0]}\t: $@"'\033[0m';  }
#exec > >(tee -i /tmp/$(date +%Y%m%d%H%M%S.%N)__$(basename $0).log ) 2>&1
set -o errexit
  # NOTE: the "trap ... ERR" alreay stops execution at any error, even when above line is commente-out
  set -o pipefail
  set -o nounset
  #set -o xtrace

p() { shw_info "${@-}"; }

if [[ ! ${1-} ]]; then
  cat <<EOT
USAGE: $0 mydomain.com
EOT
  exit 1
fi

# https://stackoverflow.com/a/60516812
p #####################
p Become a Certificate Authority
p #####################
p
p Generate private key
p Keep it safe and dont share with anyone
if [[ ! -r myCA.privKey.key ]]; then
  #openssl genrsa -des3 -out myCA.privKey.key 2048
  set -x
  openssl genrsa -out myCA.privKey.key 4096
  set +x
fi
p Generate root certificate
p Send and share it with clients, for them to import this CA as trusted
SUBJ="
C=US
ST=NY
O=Local Developement
localityName=Local Developement
commonName=myCA
organizationalUnitName=Local Developement
emailAddress=fake@null.null
"
if [[ ! -r myCA.rootCert.pem ]]; then
  set -x
  openssl req -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -x509 -new -nodes -key myCA.privKey.key -sha256 -days 825 -out myCA.rootCert.pem
  set +x
fi

p
p #####################
p Create CA-signed certs
p #####################
 
NAME="${1}" # Use your own domain name
rm -fv \
  privkey.pem \
  cert.csr \
  config.ext \
  cert.crt \
  || true

SUBJ="
C=US
ST=NY
O=Local Developement
localityName=Local Developement
commonName=*.$NAME
organizationalUnitName=Local Developement
emailAddress=fake@null.null
"

p Generate a private key
set -x
openssl genrsa -out privkey.pem 4096
set +x
p Create a certificate-signing request
set -x
openssl req -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -new -key privkey.pem -out cert.csr
set +x
p Create a config file for the extensions
cat >config.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $NAME
DNS.2 = *.$NAME
EOF
p Create the signed certificate
set -x
openssl x509 -req -in cert.csr -CA myCA.rootCert.pem -CAkey myCA.privKey.key -CAcreateserial \
  -out cert.crt -days 825 -sha256 -extfile config.ext
set +x
rm cert.csr config.ext myCA.rootCert.srl
p Join cert.crt with myCA.rootCert.pem to form fullchain.pem
chmod 666 fullchain.pem
cat cert.crt myCA.rootCert.pem > fullchain.pem

p
p === Verify crt using myCA ===
set -x
openssl verify -CAfile myCA.rootCert.pem -verify_hostname anything.$NAME fullchain.pem
set +x
p

p   ./myCA.privKey.key
p   ./myCA.rootCert.pem
p   ./privkey.pem
p   ./cert.csr
p   ./cert.crt
p 
p   - Save myCA.privkey.pem in private and safe place
p   - Send to *clients* the myCA.rootCert.pem for them to import and trust it
p   - Use in *server* the privkey.pem and fullchain.pem
