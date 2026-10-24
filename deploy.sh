#!/usr/bin/env bash
set -euo pipefail

# ---- CONFIGURE ME -----------------------------------------------------
VPS_USER="root"
VPS_HOST="158.220.104.6"
VPS_REPO_PATH="/home/deploy/watchlog-landing"
BRANCH="main"
# -------------------------------------------------------------------------

ssh "${VPS_USER}@${VPS_HOST}" bash -s <<EOF
set -euo pipefail

cd "${VPS_REPO_PATH}"

echo "==> Fetching latest ${BRANCH}"
git fetch origin
git checkout "${BRANCH}"
git pull origin "${BRANCH}"

echo "==> Deploy complete"
EOF
