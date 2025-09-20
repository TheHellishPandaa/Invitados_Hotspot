# Invitados_Hotspot

🔹 Invitados_Hotspot es una herramienta en Bash que permite crear un punto de acceso Wi-Fi (AP) con un portal cautivo utilizando NoDogSplash y create_ap
Ideal para montar redes de invitados, laboratorios de pruebas o hotspots con autenticación simple.

✨ Características

 **Configuración automática de dependencias necesarias.**

**Creación de punto de acceso Wi-Fi**

**SSID personalizable.**

**Seguridad abierta o WPA/WPA2.**

**Integración con NoDogSplash para mostrar un portal cautivo.**

**Portal personalizable con HTML, CSS e imágenes.**

**Posibilidad De crear Una Red WiFi Totalmente aislada de tu red principal (para ello edita /etc/nodogsplash/nodogsplash.conf y en dicho archivo introduce FirewallRule block to "direccion_ip_de_red/mascara"**

**Control mediante un menú interactivo:**

**Iniciar/detener AP.**

**Iniciar/detener portal cautivo.**

**Instalar dependencias.**

**Manejo de logs y procesos con PIDs en /tmp.**

   **------- 📦 Requisitos -------**

**Distribución basada en Debian/Ubuntu.**

**Permisos de root.**

**Interfaz Wi-Fi compatible con modo AP.**

**Interfaz WAN (Ethernet o Wi-Fi con salida a Internet).**

🚀 Instalación

Clona el repositorio y entra en el directorio:

```bash
git clone https://github.com/TheHellishPandaa/Invitados_Hotspot.git
```
```bash
cd Invitados_Hotspot
```
Haz el script ejecutable

```bash
chmod +x invitados_hotspot.sh
```

Ejecuta el script como root

    sudo ./invitados_hotspot.sh

Se abrirá un menú interactivo:

Invitados_Hotspot.

1) Instalar dependencias
2) Iniciar AP
3) Detener AP
4) Iniciar portal (NoDogSplash)
5) Detener portal
0) Salir

*** ------ 📜 Licencia -------- ***

Este proyecto se distribuye bajo la licencia MIT.
Eres libre de usarlo, modificarlo y distribuirlo bajo tus propios términos.

