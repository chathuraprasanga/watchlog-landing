#!/usr/bin/env bash
# One-time VPS setup. Run this ONCE from your local machine (like deploy.sh) —
# it SSHes into the VPS and does the setup there. Not run on every deploy.
set -euo pipefail

# ---- CONFIGURE ME (keep in sync with deploy.sh) ------------------------
VPS_USER="root"
VPS_HOST="158.220.104.6"
VPS_REPO_PATH="/home/deploy/watchlog-landing"
VPS_REPO_URL="https://github.com/chathuraprasanga/watchlog-landing.git"
DOMAIN="watchlog.xcorpion.xyz"
# -------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Copying nginx config to VPS"
scp "${SCRIPT_DIR}/nginx.conf" "${VPS_USER}@${VPS_HOST}:/tmp/${DOMAIN}.conf"

ssh "${VPS_USER}@${VPS_HOST}" bash -s <<EOF
set -euo pipefail

if [ ! -d "${VPS_REPO_PATH}" ]; then
  echo "==> Cloning repo to ${VPS_REPO_PATH}"
  git clone "${VPS_REPO_URL}" "${VPS_REPO_PATH}"
fi

echo "==> Installing nginx site config for ${DOMAIN}"
mv "/tmp/${DOMAIN}.conf" "/etc/nginx/sites-available/${DOMAIN}"
ln -sf "/etc/nginx/sites-available/${DOMAIN}" "/etc/nginx/sites-enabled/${DOMAIN}"
nginx -t
systemctl reload nginx

if ! command -v certbot &>/dev/null; then
  echo "==> Installing certbot"
  apt-get update -y
  apt-get install -y certbot python3-certbot-nginx
fi

echo "==> Requesting HTTPS certificate for ${DOMAIN}"
echo "    (DNS A record for ${DOMAIN} must already point at this VPS)"
# --keep-until-expiring reinstalls a still-valid existing cert instead of
# prompting (this script has no stdin to answer that prompt over SSH).
certbot --nginx -d "${DOMAIN}" --non-interactive --agree-tos --register-unsafely-without-email --keep-until-expiring

echo "==> Bootstrap complete."
EOF
