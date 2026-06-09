#!/usr/bin/env bash
# setup-nfs.sh — Configura el servicio NFS sobre ZFS.
# Ejecutar en zfs1 como root:  sudo ./setup-nfs.sh
set -euo pipefail

# ----- Variables (modificar si cambia el entorno) -----
DATASET="tank/nfs"                         # dataset de ZFS que se va a exportar
EXPORT_DIR="/tank/nfs"                     # punto de montaje del dataset
NET="192.168.100.0/24"                      # red de clientes autorizada
OPTS="rw,sync,no_subtree_check,root_squash"

echo ">> 1/4 Instalando el servidor NFS..."
apt update
apt install -y nfs-kernel-server

echo ">> 2/4 Comprobando que existe el dataset $DATASET..."
zfs list "$DATASET" >/dev/null 2>&1 || zfs create "$DATASET"

echo ">> 3/4 Añadiendo la exportación a /etc/exports (si no existe ya)..."
LINE="$EXPORT_DIR   $NET($OPTS)"
grep -qxF "$LINE" /etc/exports 2>/dev/null || echo "$LINE" >> /etc/exports

echo ">> 4/4 Aplicando y activando el servicio..."
exportfs -ra
systemctl enable --now nfs-kernel-server

echo ">> Hecho. Exportaciones activas:"
exportfs -v
