#!/bin/sh
set -eu
: "${API_BASE_URL:?API_BASE_URL required}"
: "${OIDC_ISSUER:?OIDC_ISSUER required}"
: "${OIDC_CLIENT_ID:?OIDC_CLIENT_ID required}"
: "${OIDC_REDIRECT_URI:?OIDC_REDIRECT_URI required}"
envsubst '${API_BASE_URL} ${OIDC_ISSUER} ${OIDC_CLIENT_ID} ${OIDC_REDIRECT_URI}' < /etc/rac-config.json.template > /usr/share/nginx/html/config.json
