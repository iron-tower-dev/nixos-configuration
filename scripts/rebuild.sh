#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating pre-rebuild snapshot..."
if sudo snapper -c root create --description "pre-rebuild" --type pre; then
  echo "==> Snapshot created successfully."
else
  echo "WARNING: Failed to create pre-rebuild snapshot. Continuing anyway." >&2
fi

echo "==> Running nixos-rebuild switch..."
sudo nixos-rebuild switch --flake .# "$@"

echo "==> Rebuild complete."
