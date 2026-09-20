# 2. Generación del par de claves del aula

Veyon soporta dos métodos de autenticación: por usuario/contraseña del sistema ("logon") o por **fichero de clave** (par asimétrico). Vamos a usar el segundo, con **un único par de claves para toda el aula**, que llamaremos `Docent`.

Esto se hace una sola vez, en el equipo del profesor.

## 2.1 Abrir el Configurador de Veyon

```bash
veyon-configurator
```

La gestión de autenticación está repartida en **dos páginas distintas** del Configurador:

- **"Autenticación" (Authentication)**: para elegir el método (logon vs. clave).
- **"Claves de autenticación" (Authentication keys)**: para crear/exportar/importar el propio par de claves.

## 2.2 Fijar el método de autenticación

En la página **"Autenticación" (Authentication)**, en **Método**, selecciona **"Autenticación mediante fichero de clave" (Key file authentication)**.

> Importante: este mismo método debe quedar seleccionado en **todos** los equipos (profesor y alumnos). Si un equipo usa "logon" y otro "clave", la conexión fallará. El valor por defecto de Veyon es "logon", así que hay que cambiarlo explícitamente.

## 2.3 Crear el par de claves

Ve a la página **"Claves de autenticación" (Authentication keys)**:

1. Pulsa **"Crear par de claves" (Create key pair)**.
2. Ponle un nombre identificativo al par, por ejemplo `Docent` (este nombre es el que luego usarán también los alumnos al importar la clave pública, y el que se usa como nombre de subcarpeta en el almacén de claves).
3. Veyon genera automáticamente:
   - Una **clave privada**, guardada solo en este equipo (bajo el directorio base de claves privadas que se ve en la propia página).
   - Una **clave pública**, con el mismo nombre.

No se necesita contraseña adicional para la clave salvo que quieras protegerla con una passphrase extra (opcional, más seguridad pero hay que introducirla cada vez que el Master la use).

## 2.4 Dar permiso de lectura a la clave privada (importante en Linux)

En Linux, la clave privada recién creada suele quedar con permisos de solo lectura para **root** (p. ej. en `/etc/veyon/keys/private/Docent/key`). Si luego abres **Veyon Master** con tu usuario normal (no root), verás el error *"Autenticación imposible / No se encontraron archivos de clave..."* aunque la clave exista, porque tu usuario no tiene permiso para leerla.

Para solucionarlo:

1. En **"Claves de autenticación" (Authentication keys)**, selecciona la clave **privada** `Docent`.
2. Pulsa **"Establecer grupo de acceso" (Set access group)**.
3. Elige un grupo del sistema del que sea miembro tu usuario (el que usas para iniciar sesión y abrir Veyon Master). Si no tienes uno adecuado, créalo y añade tu usuario, por ejemplo:
   ```bash
   sudo groupadd veyon-docents
   sudo usermod -aG veyon-docents $USER
   ```
   Después de crear el grupo y añadirte a él, **cierra sesión y vuelve a entrar** (los cambios de grupo no se aplican hasta el siguiente inicio de sesión).
4. Vuelve al Configurador y asigna ese grupo (`veyon-docents`) como grupo de acceso de la clave privada.
5. Comprueba los permisos desde terminal:
   ```bash
   ls -al /etc/veyon/keys/private/Docent/key
   ```
   Tu usuario debe poder leer ese fichero (pertenecer al grupo propietario, con permiso de lectura).

## 2.5 Exportar la clave pública para repartirla

Todavía en **"Claves de autenticación" (Authentication keys)**:

1. Selecciona la clave **pública** `Docent`.
2. Pulsa **"Exportar" (Export)**.
3. Guarda el fichero, por ejemplo como `veyon-aula-profesor.pem` (o la extensión que proponga el Configurador).

Este fichero es el que vas a repartir a **todos los alumnos**, sea cual sea su sistema operativo. **No exportes ni compartas nunca la clave privada.**

## 2.6 Cómo repartir la clave pública

Opciones razonables:

- Subirla como recurso en el curso de **Aules/Moodle** para que los alumnos la descarguen.
- Compartirla por USB o carpeta compartida del aula el primer día de clase.

## 2.7 Copia de seguridad de la clave privada

Si el equipo del profesor se reinstala o cambia, perderás la clave privada y tendrás que volver a generar el par **y volver a repartir la nueva clave pública** a todos los alumnos. Se recomienda:

- Exportar también la clave **privada** (botón "Exportar" sobre la clave privada) y guardarla en un lugar seguro (no accesible a los alumnos), por ejemplo cifrada en el almacenamiento del centro.

## 2.8 Alternativa por línea de comandos (`veyon-cli`)

Todo lo anterior se puede hacer también con `veyon-cli`, útil si quieres automatizar o documentar exactamente lo ejecutado. Los subcomandos relevantes son del grupo `authkeys`:

```bash
# Ver la ayuda y sintaxis exacta de tu versión instalada
veyon-cli authkeys --help

# Crear el par de claves para el nombre "Docent"
veyon-cli authkeys create Docent

# Exportar la clave pública a un fichero para repartir
veyon-cli authkeys export Docent public /ruta/veyon-aula-profesor.pem
```

> La sintaxis concreta de `veyon-cli authkeys` puede variar ligeramente entre versiones de Veyon: ejecuta siempre `veyon-cli authkeys --help` para confirmarla antes de usarla en producción.

## 2.9 Siguiente paso

Continúa en [`03-configuracion-aula.md`](03-configuracion-aula.md) para configurar cómo el Master va a encontrar los portátiles del aula.
