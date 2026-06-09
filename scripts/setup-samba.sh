#!/usr/bin/env bash
# setup-samba.sh — Configura el servicio Samba sobre ZFS.
# Ejecutar en zfs1 como root:  sudo ./setup-samba.sh
set -euo pipefail

# ----- Variables -----
DATASET="tank/samba"
SHARE_DIR="/tank/samba"
SHARE_NAME="datos"
SMB_USER="smbuser"
SMB_GROUP="sambausers"

echo ">> 1/6 Instalando Samba..."
apt update
apt install -y samba

echo ">> 2/6 Comprobando que existe el dataset $DATASET..."
zfs list "$DATASET" >/dev/null 2>&1 || zfs create "$DATASET"

echo ">> 3/6 Creando grupo y usuario de servicio..."
getent group "$SMB_GROUP" >/dev/null || groupadd "$SMB_GROUP"
id "$SMB_USER" >/dev/null 2>&1 || useradd -M -s /usr/sbin/nologin -G "$SMB_GROUP" "$SMB_USER"

echo ">> 4/6 Defina la contraseña de Samba para '$SMB_USER' (se pedirá ahora):"
smbpasswd -a "$SMB_USER"
smbpasswd -e "$SMB_USER"

echo ">> 5/6 Ajustando permisos del directorio compartido..."
chgrp -R "$SMB_GROUP" "$SHARE_DIR"
chmod 2770 "$SHARE_DIR"

echo ">> 6/6 Añadiendo el recurso [$SHARE_NAME] a smb.conf (si no existe)..."
if ! grep -q "^\[$SHARE_NAME\]" /etc/samba/smb.conf; then
cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
   comment = Compartición sobre ZFS
   path = $SHARE_DIR
   browseable = yes
   read only = no
   guest ok = no
   valid users = @$SMB_GROUP
   force group = $SMB_GROUP
   create mask = 0660
   directory mask = 2770
EOF
fi

testparm -s
systemctl restart smbd nmbd
systemctl enable smbd nmbd
echo ">> Hecho."
