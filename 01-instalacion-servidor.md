# 1. Instalación de Veyon en el equipo del profesor (Lliurex / Ubuntu 24.04)

Lliurex está basado en Ubuntu 24.04 (noble), por lo que puedes usar directamente los paquetes oficiales de Veyon para Ubuntu.

## 1.1 Añadir el repositorio oficial de Veyon

> Los comandos exactos del repositorio (URL, nombre de la clave GPG) pueden cambiar entre versiones. Antes de ejecutarlos, comprueba la versión actual en **https://veyon.io/download** (selector "Linux → Ubuntu/Debian") y copia de ahí los comandos si difieren de los siguientes.

```bash
# Clave GPG del repositorio oficial
wget -qO- https://download.veyon.io/apt/veyon.gpg | sudo gpg --dearmor -o /usr/share/keyrings/veyon-archive-keyring.gpg

# Repositorio APT
echo "deb [signed-by=/usr/share/keyrings/veyon-archive-keyring.gpg] https://download.veyon.io/apt/ ./" | \
  sudo tee /etc/apt/sources.list.d/veyon.list

sudo apt update
```

### Alternativa: paquete `.deb` directo

Si el repositorio APT no está disponible para el códename de Lliurex/Ubuntu que tengas, descarga el `.deb` correspondiente desde las [publicaciones oficiales de GitHub](https://github.com/veyon/veyon/releases) e instálalo resolviendo dependencias con:

```bash
sudo apt install ./veyon_<version>_amd64.deb
```

## 1.2 Instalar Veyon

```bash
sudo apt install veyon
```

Esto instala en el mismo equipo:

- `veyon-master` (consola del profesor)
- `veyon-service` (agente, por si algún día quieres controlar también el equipo del profesor)
- `veyon-configurator` (configuración gráfica)
- `veyon-cli` (configuración por línea de comandos)

## 1.3 Comprobar que el servicio arranca

El Service se inicia automáticamente al iniciar sesión gráfica. Comprueba que está en ejecución:

```bash
pgrep -fa veyon-service
```

Si no aparece nada, arráncalo manualmente para probar:

```bash
veyon-service start &
```

## 1.4 Firewall (ufw)

Si tienes `ufw` activo, permite el tráfico entrante en el puerto usado por Veyon (TCP 11100) desde la red del aula, por ejemplo restringido a la subred del aula:

```bash
sudo ufw allow from 10.10.10.0/24 to any port 11100 proto tcp comment 'Veyon aula'
```

Sustituye `10.10.10.0/24` por la subred real de tu aula. Si no usas `ufw` o el firewall del centro lo gestiona otra herramienta, comprueba con tu administrador de red que el puerto 11100/TCP está abierto entre los portátiles y el equipo del profesor.

## 1.5 Siguiente paso

Continúa en [`02-generacion-claves.md`](02-generacion-claves.md) para crear el par de claves del aula.
