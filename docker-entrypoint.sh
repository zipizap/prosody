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

export ALLOW_REGISTRATION=${ALLOW_REGISTRATION:-true}
export DOMAIN_HTTP_UPLOAD=${DOMAIN_HTTP_UPLOAD:-"upload.$DOMAIN"}
export DOMAIN_MUC=${DOMAIN_MUC:-"conference.$DOMAIN"}
export DOMAIN_PROXY=${DOMAIN_PROXY:-"proxy.$DOMAIN"}
export DOMAIN_PUBSUB=${DOMAIN_PUBSUB:-"pubsub.$DOMAIN"}
export LOG_LEVEL=${LOG_LEVEL:-"info"}
export C2S_REQUIRE_ENCRYPTION=${C2S_REQUIRE_ENCRYPTION:-true}
export S2S_REQUIRE_ENCRYPTION=${S2S_REQUIRE_ENCRYPTION:-true}
export S2S_SECURE_AUTH=${S2S_SECURE_AUTH:-true}
export PROSODY_ADMINS=${PROSODY_ADMINS:-""}

exec "$@"
