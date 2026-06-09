#!/bin/bash
# zfs-snapshot.sh — Toma un snapshot diario de cada dataset del pool tank.
# Programar en cron: 0 0 * * * root /usr/local/bin/zfs-snapshot.sh

set -euo pipefail

FECHA=$(date +%Y%m%d-%H%M)
DATASETS="tank/nfs tank/samba tank/iscsi-lun0"

echo "[$(date)] Iniciando snapshots..."

for DS in $DATASETS; do
    zfs snapshot "$DS@$FECHA"
    echo "[$(date)] Snapshot creado: $DS@$FECHA"
done

echo "[$(date)] Snapshots completados."