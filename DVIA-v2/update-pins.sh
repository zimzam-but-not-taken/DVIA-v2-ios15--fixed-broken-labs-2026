#!/usr/bin/env bash
# Regenerates the certificate / public key pins used by the
# "Network Layer Security" screen (TransportLayerProtectionViewController.swift).
#
# example.com is fronted by Cloudflare and rotates its leaf certificate every
# ~90 days, so the app pins the issuing CA chain. If Cloudflare switches CA
# the pinned requests will start failing; run this script, then paste the
# printed values into TransportLayerProtectionViewController.swift.
#
# Usage: ./update-pins.sh [host]   (default: example.com)
set -euo pipefail
HOST="${1:-example.com}"
DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

openssl s_client -connect "$HOST:443" -servername "$HOST" -showcerts </dev/null 2>/dev/null \
  | awk -v d="$TMP" '/BEGIN CERT/{i++} {print > (d "/chain" i ".pem")}'

echo "Chain served by $HOST:"
i=0
for pem in "$TMP"/chain*.pem; do
  i=$((i+1))
  subject=$(openssl x509 -in "$pem" -noout -subject | sed 's/.*CN *= *//')
  enddate=$(openssl x509 -in "$pem" -noout -enddate | cut -d= -f2)
  spki=$(openssl x509 -in "$pem" -noout -pubkey | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64)
  echo
  echo "[$i] $subject (expires $enddate)"
  echo "    pinnedPublicKeyHashes entry:   \"$spki\""
  echo "    pinnedCertificatesBase64 entry: \"$(openssl x509 -in "$pem" -outform DER | base64 | tr -d '\n')\""
done

# Index 2 is normally the issuing (intermediate) CA; that is what example.der holds.
if [ -f "$TMP/chain2.pem" ]; then
  openssl x509 -in "$TMP/chain2.pem" -outform DER -out "$DIR/example.der"
  echo
  echo "Wrote $DIR/example.der (intermediate CA: $(openssl x509 -in "$TMP/chain2.pem" -noout -subject | sed 's/.*CN *= *//'))"
fi
