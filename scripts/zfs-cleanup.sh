#!/bin/bash
# zfs-cleanup.sh — Elimina snapshots antiguos conservando solo los últimos 7.
# Programar en cron: 5 0 * * * root /usr/local/bin/zfs-cleanup.sh

set -euo pipefail

DATASETS="tank/nfs tank/samba tank/iscsi-lun0"
CONSERVAR=7

echo "[$(date)] Iniciando limpieza de snapshots..."

for DS in $DATASETS; do
    TOTAL=$(zfs list -t snapshot -o name -s creation | grep "^$DS@" | wc -l)
    
    if [ "$TOTAL" -gt "$CONSERVAR" ]; then
        ELIMINAR=$(zfs list -t snapshot -o name -s creation | \
            grep "^$DS@" | head -n -"$CONSERVAR")
        
        echo "[$(date)] Eliminando snapshots antiguos de $DS..."
        echo "$ELIMINAR" | xargs -r zfs destroy
        echo "[$(date)] Eliminados: $(echo "$ELIMINAR" | wc -l) snapshots."
    else
        echo "[$(date)] $DS: solo hay $TOTAL snapshots, no se elimina nada."
    fi
done

echo "[$(date)] Limpieza completada."