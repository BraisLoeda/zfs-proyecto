#!/usr/bin/env bash
# setup-iscsi.sh — Configura el target iSCSI sobre un zvol de ZFS.
# Ejecutar en zfs1 como root (primera instalación):  sudo ./setup-iscsi.sh
set -euo pipefail

# ----- Variables -----
ZVOL="tank/iscsi-lun0"
ZVOL_SIZE="10G"
ZVOL_DEV="/dev/zvol/tank/iscsi-lun0"
TARGET_IQN="iqn.2026-01.local.zfs1:target0"
INITIATOR_IQN="iqn.2026-01.local.cliente-linux:init0"
PORTAL_IP="192.168.56.10"

echo ">> 1/4 Instalando targetcli..."
apt update
apt install -y targetcli-fb

echo ">> 2/4 Comprobando que existe el zvol $ZVOL..."
zfs list "$ZVOL" >/dev/null 2>&1 || zfs create -V "$ZVOL_SIZE" -o volblocksize=16k "$ZVOL"

echo ">> 3/4 Configurando el target LIO..."
targetcli /backstores/block create name=lun0 dev="$ZVOL_DEV"
targetcli /iscsi create "$TARGET_IQN"
targetcli /iscsi/"$TARGET_IQN"/tpg1/luns create /backstores/block/lun0
targetcli /iscsi/"$TARGET_IQN"/tpg1/acls create "$INITIATOR_IQN"
targetcli /iscsi/"$TARGET_IQN"/tpg1/portals delete 0.0.0.0 3260 || true
targetcli /iscsi/"$TARGET_IQN"/tpg1/portals create "$PORTAL_IP"

echo ">> 4/4 Guardando la configuración y activando el servicio..."
targetcli saveconfig
systemctl enable --now rtslib-fb-targetctl.service

echo ">> Hecho. Configuración del target:"
targetcli ls /iscsi
