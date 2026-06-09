#!/bin/bash
# zfs-replicar.sh — Replica los datasets de tank en zfs1 hacia backup en zfs2.
# Ejecutar como usuario repl.
# Programar en cron: 10 0 * * * repl /usr/local/bin/zfs-replicar.sh

set -euo pipefail

DATASETS="nfs samba iscsi-lun0"
REMOTO="repl@192.168.56.20"
LOG="/var/log/zfs-replicar.log"

echo "[$(date)] Iniciando replicación..." >> "$LOG"

for DS in $DATASETS; do
    ULTIMO=$(zfs list -t snapshot -o name -s creation | \
        grep "^tank/$DS@" | tail -1)

    if [ -z "$ULTIMO" ]; then
        echo "[$(date)] $DS: no hay snapshots, saltando..." >> "$LOG"
        continue
    fi

    ANTERIOR=$(zfs list -t snapshot -o name -s creation | \
        grep "^tank/$DS@" | tail -2 | head -1)

    if [ -n "$ANTERIOR" ] && [ "$ANTERIOR" != "$ULTIMO" ]; then
        echo "[$(date)] $DS: enviando incremental $ANTERIOR -> $ULTIMO..." >> "$LOG"
        zfs send -i "$ANTERIOR" "$ULTIMO" | \
            ssh "$REMOTO" zfs receive "backup/$DS" >> "$LOG" 2>&1
    else
        echo "[$(date)] $DS: enviando snapshot completo $ULTIMO..." >> "$LOG"
        zfs send "$ULTIMO" | \
            ssh "$REMOTO" zfs receive -F "backup/$DS" >> "$LOG" 2>&1
    fi

    echo "[$(date)] $DS: replicación completada." >> "$LOG"
done

echo "[$(date)] Replicación finalizada." >> "$LOG"