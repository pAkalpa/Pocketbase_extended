#!/bin/sh
set -e

# If a data directory exists at /pb/pb_data and is writable, ensure pbuser owns it.
# This script runs as root (during container start) so it can chown mounted volumes.
DATA_DIR="/pb/pb_data"

if [ -d "$DATA_DIR" ]; then
  echo "Found data dir $DATA_DIR, fixing ownership to pbuser:pbgroup"
  chown -R 10001:10001 "$DATA_DIR" || true
fi

# If the binary is not executable somehow, fix permission
if [ -f "/pb/pb-app" ] && [ ! -x "/pb/pb-app" ]; then
  chmod 0755 /pb/pb-app || true
fi

# Exec tini and drop privileges to pbuser using su-exec
# If su-exec isn't available, fallback to running directly (shouldn't happen)
if command -v su-exec >/dev/null 2>&1; then
  exec /sbin/tini -- su-exec pbuser "$@"
else
  echo "su-exec not found, running without privilege drop"
  exec /sbin/tini -- "$@"
fi
