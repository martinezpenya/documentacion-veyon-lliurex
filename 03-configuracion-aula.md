# 3. Configuración del aula en la consola del profesor

Como los portátiles de los alumnos están en la **misma red/VLAN** del aula pero con **IP dinámica** (DHCP), no conviene añadirlos por la IP que tengan en un momento dado: hace falta una identificación que no cambie.

> **Nota (verificado en la instalación real):** Veyon, al dar de alta un equipo, solo puede conectarse por **hostname o IP** (la MAC es un campo opcional que solo sirve para Wake-on-LAN, no para identificar/conectar el equipo). En la resolución de nombres por hostname depende de la red del centro (NetBIOS/mDNS/DNS); en esta aula se comprobó que el hostname **no resuelve** (`ping <hostname>` falla) aunque `ping <IP>` sí funciona. Por eso el método recomendado aquí es la **reserva DHCP por MAC** (sección 3.2), que da a cada portátil una IP fija sin dejar de usar DHCP.

> **Importante:** crear el aula y dar de alta los equipos (secciones 3.1 y 3.2) se hace desde **`veyon-configurator`**, no desde Veyon Master. Master (sección 3.3) solo sirve para **ver/controlar** los equipos una vez ya están dados de alta; en Master no hay botón para añadirlos.

Todo lo de las secciones 3.1 y 3.2 se configura desde `veyon-configurator`, en el equipo del profesor.

## 3.1 Crear la ubicación (aula)

Veyon organiza los equipos en **ubicaciones** (aulas/salas) desde la página del Configurador llamada **"Ubicaciones y equipos" (Locations & computers)**. Esta página gestiona el backend **"Integrado" (Builtin)** del Directorio de objetos de red, que es el que usa Veyon **por defecto** (no requiere instalar nada adicional).

1. Abre `veyon-configurator`.
2. Ve a la página **"Ubicaciones y equipos" (Locations & computers)**.
3. Verás **dos listas**: la de la izquierda son las **ubicaciones**; la de la derecha son los **equipos de la ubicación que tengas seleccionada** a la izquierda (por eso está vacía/deshabilitada hasta que no seleccionas una ubicación).
4. Debajo de la lista de la **izquierda** hay dos botones pequeños (normalmente iconos, no texto: un **"+"** y un **"-"**, a veces sin más etiqueta). Pulsa el **"+"** de esa lista para añadir una ubicación.
5. Escribe el nombre del aula, por ejemplo `Aula-101`, y confirma.
6. Haz clic sobre `Aula-101` en la lista de la izquierda para **seleccionarla**: ahora la lista de la derecha (equipos) se activa.

> Puedes renombrar una ubicación haciendo doble clic sobre ella en el panel izquierdo.

## 3.2 Añadir los portátiles del aula (manual, sin plugins de pago)

Antes de dar de alta un equipo, comprueba **desde el equipo del profesor** cuál de las dos opciones funciona en tu red:

```
ping <hostname-del-alumno>
ping <IP-del-alumno>
```

- Si el `ping` por **hostname** resuelve correctamente, puedes usar el hostname (no cambia aunque cambie la IP) y saltarte la reserva DHCP.
- Si el `ping` por hostname **falla** pero por IP funciona (caso comprobado en esta instalación: la VLAN del aula no resuelve nombres), tienes dos alternativas: fijar la IP de cada portátil con una **reserva DHCP por MAC** (Opción A) o, más rápido de mantener, dar de alta **todo el rango de IPs del DHCP** de una vez (Opción C) y filtrar luego por los equipos encendidos.

### Opción A — Reserva DHCP por MAC + IP fija (recomendada en esta aula)

1. Obtén la **MAC** de cada portátil (en Windows: `Configuración > Red e Internet > [tu red] > Propiedades`, o `ipconfig /all` en `cmd`, campo "Dirección física").
2. En el DHCP del centro (el router/servidor que reparte IPs en la VLAN del aula), crea una **reserva** que asigne siempre la misma IP a esa MAC. La forma exacta depende del equipo de red del centro; si no lo administras tú, pide a quien gestione la red que la cree (una por cada portátil del aula).
3. Anota la IP reservada de cada alumno: seguirá siendo "por DHCP", pero fija en la práctica.

### Opción B — Hostname (solo si el `ping` por hostname te ha funcionado)

Usa el nombre de equipo tal cual aparece en el sistema operativo del alumno (p. ej. `portatil-alumno05` o `portatil-alumno05.local`).

### Opción C — Dar de alta todo el rango de IPs del DHCP (alta masiva, sin depender de reservas ni de hostname)

En vez de averiguar la MAC de cada portátil y pedir una reserva DHCP por alumno, puedes registrar en Veyon **todo el rango de IPs que reparte el DHCP** de esa VLAN (no toda la subred entera, solo el rango del pool DHCP — así evitas ruido de la puerta de enlace, impresoras, etc.). Como los portátiles van a caer siempre dentro de ese rango, no importa qué IP le toque a cada uno en cada sesión: simplemente filtras luego los que estén realmente encendidos.

**1. Genera el CSV con el script `scripts/generar-csv-aula.sh` de este repositorio:**

```
./scripts/generar-csv-aula.sh 192.168.10.100 192.168.10.200 Aula-101
```

- `192.168.10.100` / `192.168.10.200`: primera y última IP del rango del DHCP del aula (consúltalo en el servidor/router que reparte las IPs de esa VLAN si no lo administras tú).
- `Aula-101`: nombre de la ubicación, debe coincidir **exactamente** con la que ya creaste en el paso 3.1.
- Opcional, un cuarto parámetro con el nombre del fichero de salida. Si no se indica, el CSV se crea en la carpeta desde la que lanzas el script con el nombre `<ubicación>.csv`.

Esto genera `Aula-101.csv` con una línea por cada IP del rango, con nombres genéricos `alu001`, `alu002`, etc.:

```
computer;alu001;192.168.10.100;;Aula-101
computer;alu002;192.168.10.101;;Aula-101
...
```

> Si no conoces el rango exacto del pool DHCP, puedes dar de alta la subred completa del aula (p. ej. de `.1` a `.253` o `.254` en una `/24`). Así también quedarán registradas la puerta de enlace, impresoras u otros equipos de la VLAN, pero no molestan: no tienen `veyon-service`, así que Master los oculta con el filtro **"Solo mostrar equipos encendidos"** (paso 3). El CSV generado es un fichero de trabajo: no lo subas al repositorio.

**2. Impórtalo con `veyon-cli`, en el equipo del profesor** (el mismo donde corren `veyon-configurator` y `Veyon Master`; el backend Builtin guarda los datos en la configuración local de esa máquina):

```
veyon-cli networkobjects import Aula-101.csv --format "%type%;%name%;%host%;%mac%;%location%"
```

Si el import no aparece luego en el Configurador ni en Master, prueba con `sudo veyon-cli networkobjects import ...`: en Linux, la configuración de Veyon suele guardarse a nivel de sistema, igual que ocurre con la clave privada (ver [`02-generacion-claves.md`](02-generacion-claves.md), sección 2.4) — si el import se ejecuta como usuario normal puede escribir en una configuración distinta a la que lee Master.

**3. Comprueba el resultado:**

- Abre `veyon-configurator` → **"Ubicaciones y equipos"**: selecciona `Aula-101` y confirma que aparecen las entradas `alu001`, `alu002`... en la lista de la derecha.
- Abre **Veyon Master** y activa el botón de la barra de estado **"Solo mostrar equipos encendidos"** ("Only show powered on computers"): con esto solo verás las IPs del rango que en ese momento tienen `veyon-service` respondiendo, ocultando el resto.
- Opcional: en `veyon-configurator` → página **Master** → interfaz de usuario, puedes cambiar el **"Título de miniatura de equipo"** a "Dirección de host y usuario" para ver, junto a la IP, el usuario que ha iniciado sesión (este dato lo reporta en tiempo real el propio `veyon-service`).

> Pendiente de confirmar en pantalla real: qué texto exacto aparece en la miniatura/tooltip cuando el equipo se dio de alta solo por IP (sin nombre de host real). Anota lo que veas la primera vez que lo pruebes para dejarlo fijado aquí.

### Dar de alta el equipo en el Configurador (Opciones A y B, manual)

Con la ubicación `Aula-101` ya **seleccionada** en la lista de la izquierda (paso anterior):

1. Debajo de la lista de la **derecha** (equipos), busca los mismos botones pequeños **"+"** / **"-"** (pueden ser solo iconos, sin texto "Añadir equipo"; si la lista de la derecha sigue sin reaccionar, comprueba que la ubicación de la izquierda está realmente resaltada/seleccionada, no solo visible).
2. Pulsa el **"+"** de la lista de la derecha para dar de alta un equipo.
3. **Nombre de equipo**: el que quieras, p. ej. `PC-Alumno-05`.
4. **Nombre de host / IP**: introduce la **IP fija reservada** (Opción A) o el **hostname** (Opción B), según lo que haya funcionado en el paso del `ping`.
5. Repite para cada alumno del aula.

Puedes editar cualquier entrada haciendo doble clic sobre ella (por si un alumno cambia de portátil o de nombre de equipo).

Esta gestión manual usa el backend **"Integrado" (Builtin)**, que es el que trae Veyon por defecto: **no hace falta instalar ni pagar ningún add-on**. La detección automática por red ("Network Discovery") existe como complemento **de pago** de Veyon Solutions; si no quieres usarlo, ignóralo — la lista manual funciona perfectamente para un aula con un número de alumnos manejable.

## 3.3 Probar la conexión

1. Con un portátil de alumno ya configurado (ver manuales de alumno más abajo) encendido y conectado a la red del aula.
2. Desde **Veyon Master**, el equipo debería aparecer dentro de `Aula-101`.
3. Haz doble clic sobre su miniatura para comprobar que puedes ver/controlar la pantalla. Si pide autenticación y falla, revisa [`07-resolucion-problemas.md`](07-resolucion-problemas.md).

## 3.4 Siguiente paso

Reparte a cada alumno el manual de instalación correspondiente a su sistema operativo, junto con el fichero de clave pública generado en el paso 2:

- [`04-manual-alumno-linux.md`](04-manual-alumno-linux.md)
- [`05-manual-alumno-windows.md`](05-manual-alumno-windows.md)
- [`06-manual-alumno-macos.md`](06-manual-alumno-macos.md)
