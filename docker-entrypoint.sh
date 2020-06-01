#!/bin/bash
set -e

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl $*
    exit 0;
fi

if [ "$LOCAL" -a "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register $LOCAL $DOMAIN $PASSWORD
fi

if [ -z "$DOMAIN" ]; then
  echo "[ERROR] DOMAIN must be set!"
  exit 1
fi

export DOMAIN_HTTP_UPLOAD=${DOMAIN_HTTP_UPLOAD:-"upload.$DOMAIN"}
export DOMAIN_MUC=${DOMAIN_MUC:-"conference.$DOMAIN"}
export DOMAIN_PROXY=${DOMAIN_PROXY:-"proxy.$DOMAIN"}

exec "$@"
