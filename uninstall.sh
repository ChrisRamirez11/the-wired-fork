#!/bin/bash
# Desinstala Remo. Conserva el historial salvo que se pida --purge.
#
#   ./uninstall.sh           quita el comando
#   ./uninstall.sh --purge   quita también el historial (~/remo)

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
PURGE=0
[[ "${1:-}" == "--purge" ]] && PURGE=1

removed=0

if [[ -e "$INSTALL_DIR/remo" || -L "$INSTALL_DIR/remo" ]]; then
    rm -f "$INSTALL_DIR/remo"
    echo "Eliminado $INSTALL_DIR/remo"
    removed=1
fi

# Instalaciones antiguas (versiones anteriores copiaban a /usr/local/bin con sudo)
for legacy in /usr/local/bin/the-wired /usr/local/bin/excepciones.json; do
    if [[ -e "$legacy" ]]; then
        sudo rm -f "$legacy"
        echo "Eliminado $legacy (instalación antigua)"
        removed=1
    fi
done

if [[ "$PURGE" == "1" && -d "$HOME/remo" ]]; then
    rm -rf "$HOME/remo"
    echo "Eliminado el historial ($HOME/remo)"
fi

if [[ "$removed" == "0" ]]; then
    echo "remo no estaba instalado."
else
    echo "remo desinstalado."
    if [[ "$PURGE" == "0" ]]; then
        echo "El historial sigue en $HOME/remo (bórralo con --purge)."
    fi
fi
