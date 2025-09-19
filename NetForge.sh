
#!/usr/bin/env bash
#
# NetForge v8 - AP + Portal cautivo con NoDogSplash
#

set -euo pipefail
IFS=$'\n\t'

PORTAL_DIR="/etc/nodogsplash/htdocs"
DB_FILE="$PORTAL_DIR/users.db"
AP_PID_FILE="/tmp/netforge_ap.pid"
PORTAL_PID_FILE="/tmp/netforge_portal.pid"
AP_LOG_FILE="/tmp/netforge_ap.log"
PORTAL_LOG_FILE="/tmp/netforge_portal.log"

# -----------------------
# Helpers
# -----------------------
info()  { echo -e "\n\033[1;34m==>\033[0m $*"; }
warn()  { echo -e "\n\033[1;33m!!\033[0m $*"; }
error() { echo -e "\n\033[1;31mERROR:\033[0m $*" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
  error "Ejecuta como root: sudo $0"
fi

# -----------------------
# Dependencias
# -----------------------
function install_deps() {
  info "Instalando dependencias..."
  apt update
  apt upgrade -y
  apt install -y build-essential git util-linux procps hostapd iproute2 iw haveged dnsmasq \
                openssl libmicrohttpd-dev \

  # Instalar create_ap si no existe
  if ! command -v create_ap >/dev/null 2>&1; then
    info "Instalando create_ap..."
    git clone https://github.com/oblique/create_ap /opt/create_ap
    cd /opt/create_ap
    make install
  fi

  # Instalar NoDogSplash si no existe
  if ! command -v nodogsplash >/dev/null 2>&1; then
    info "Instalando NoDogSplash desde GitHub..."
    git clone https://github.com/nodogsplash/nodogsplash.git /opt/nodogsplash
    cd /opt/nodogsplash
    make
    make install
    systemctl enable nodogsplash
    info "NoDogSplash instalado y habilitado como servicio"
  else
    info "NoDogSplash ya instalado"
  fi

  info "Todas las dependencias instaladas"
}

# -----------------------
# Portal con NoDogSplash
# -----------------------
function start_portal() {
  # Verificar NoDogSplash
  if ! command -v nodogsplash >/dev/null 2>&1; then
    error "NoDogSplash no está instalado"
  fi

# Crear carpetas de configuracion y mover archivos de configuración a dichas carpetas
mkdir -p /etc/nodogsplash/htdocs/
cp -f splash.html /etc/nodogsplash/htdocs/ 2>/dev/null || warn "splash.html no encontrado"
cp -f splash.css /etc/nodogsplash/htdocs/ 2>/dev/null || warn "splash.css no encontrado"
cp -f login.php /etc/nodogsplash/htdocs/ 2>/dev/null || warn "login.php no encontrado"
mkdir -p /etc/nodogsplash/
cp -f nodogsplash.conf /etc/nodogsplash/ 2>/dev/null || warn "nodogsplash.conf no encontrado"

  # Reiniciar NoDogSplash
  systemctl restart nodogsplash
  info "Portal cautivo activo (NoDogSplash) y clientes bloqueados hasta autenticarse"
}

function stop_portal() {
  systemctl stop nodogsplash
  info "Portal detenido"
}

# -----------------------
# AP
# -----------------------
function start_ap() {
    ip a
    
    read -r -p "Interfaz Wi-Fi [ejemplo: wlp3s0 o wl0]: " WIFI_IF

    read -r -p "Interfaz WAN [ejemplo enp4s0 o eth0]: " WAN_IF


    read -r -p "SSID: (Invitados_HotspotWiFi)" SSID
    SSID=${SSID:-Invitados_HotspotWiFi}

    echo "Seguridad:"
    echo "0) Abierta"
    echo "1) WPA/WPA2"
    read -r -p "Opción [0]: " SEC
    SEC=${SEC:-0}

    PASS_OPT=""
    if [[ "$SEC" == "1" ]]; then
        while true; do
            read -rs -p "Contraseña (min 8): " P1; echo
            read -rs -p "Repite: " P2; echo
            [[ "$P1" == "$P2" && ${#P1} -ge 8 ]] && { PASS_OPT="$P1"; break; }
            echo "Contraseña inválida, inténtalo de nuevo."
        done
    fi

    read -r -p "¿Usar --no-virt? [Y/n]: " NOVIRT
    NOVIRT=${NOVIRT:-Y}
    [[ "${NOVIRT^^}" == "Y" ]] && VIRT="--no-virt" || VIRT=""

    if [[ -f "$AP_PID_FILE" ]] && kill -0 "$(cat $AP_PID_FILE)" 2>/dev/null; then
        echo "AP ya está en ejecución (PID $(cat $AP_PID_FILE))"
        return 1
    fi

    CREATE_AP_BIN=$(command -v create_ap)
    if [ -z "$CREATE_AP_BIN" ]; then
        echo "Error: create_ap no está instalado ni en el PATH"
        exit 1
    fi

    echo "Iniciando AP..."
    if [[ -n "$PASS_OPT" ]]; then
        "$CREATE_AP_BIN" $VIRT "$WIFI_IF" "$WAN_IF" "$SSID" "$PASS_OPT" > "$AP_LOG_FILE" 2>&1 &
    else
        "$CREATE_AP_BIN" $VIRT "$WIFI_IF" "$WAN_IF" "$SSID" > "$AP_LOG_FILE" 2>&1 &
    fi

    AP_PID=$!
    echo "$AP_PID" > "$AP_PID_FILE"
    echo "==> AP iniciado (PID $AP_PID)"
    echo "==> Logs en $AP_LOG_FILE"
}

function stop_ap() {
    if [[ -f "$AP_PID_FILE" ]] && kill -0 "$(cat $AP_PID_FILE)" 2>/dev/null; then
        kill "$(cat $AP_PID_FILE)"
        rm -f "$AP_PID_FILE"
        echo "==> AP detenido"
    else
        echo "==> No hay AP en ejecución"
    fi
}

# -----------------------
# Menú
# -----------------------
function menu() {
  while true; do
    echo -e "\n\033[1;32mNetForge v8 - Menú\033[0m"
    echo "1) Instalar dependencias"
    echo "2) Iniciar AP"
    echo "3) Detener AP"
    echo "4) Iniciar portal (NoDogSplash)"
    echo "5) Detener portal"
    echo "0) Salir"
    read -r -p "Opción: " OPC
    case "$OPC" in
      1) install_deps ;;
      2) start_ap ;;
      3) stop_ap ;;
      4) start_portal ;;
      5) stop_portal ;;
      0) exit 0 ;;
      *) echo "Opción inválida" ;;
    esac
  done
}

menu
