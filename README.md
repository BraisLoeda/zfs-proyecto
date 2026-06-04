# zfs-proyecto
Repositorio del proyecto final de ASIR, sobre "ZFS". Brais Loeda Estremado
# Examinando as posibilidades de ZFS
## Despregue dun servidor Samba, NFS e iSCSI sobre ZFS con replicación

## Descripción
Proyecto de fin de ciclo consistente en el despliegue de un servidor de 
almacenamiento unificado basado en ZFS que ofrece los tres protocolos de 
acceso más comunes: NFS, Samba e iSCSI, con replicación entre servidores.

## Infraestructura
| Máquina | Rol |
|---|---|
| zfs-primary | Servidor principal (NFS + Samba + iSCSI) |
| zfs-replica | Servidor de réplica |
| cliente-linux | Cliente de pruebas |

## Fases del proyecto
1. Documentación y preparación
2. Implementación básica de ZFS
3. Despliegue de servicios (NFS, Samba, iSCSI)
4. Replicación
5. Pruebas y validación
6. Documentación final

## Tecnologías utilizadas
- ZFS on Linux
- NFS (nfs-kernel-server)
- Samba
- iSCSI (targetcli/LIO)
- Debian Stable
- VirtualBox