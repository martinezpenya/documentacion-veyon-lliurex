# 7. Resolución de problemas

## El equipo del alumno no aparece en la consola del profesor

1. **¿Está `veyon-service` en marcha?**
   - Linux/macOS: `pgrep -fa veyon-service`
   - Windows: comprobar en el Administrador de tareas que `veyon-service.exe` está en ejecución.
2. **¿Están en la misma red/VLAN?** La detección automática por red (broadcast) solo funciona dentro de la misma subred. Si el portátil está en una red de invitados/VLAN distinta a la del aula, no se detectará: conéctalo a la red correcta.
3. **¿Bloquea el firewall el puerto 11100/TCP?** Revisa firewall del propio portátil (ufw / Firewall de Windows / Firewall de macOS) y, si el centro tiene firewall de red entre VLANs, confirma que permite ese puerto entre alumnos y profesor.
4. **macOS:** la causa más habitual es no haber concedido los permisos de **Grabación de pantalla** y **Accesibilidad** a Veyon Service (ver [`06-manual-alumno-macos.md`](06-manual-alumno-macos.md)).
5. Comprueba que el equipo está dado de alta en la Ubicación del aula con el hostname o la IP fija correctos (ver [`03-configuracion-aula.md`](03-configuracion-aula.md), sección 3.2). Si usaste hostname, comprueba primero que resuelve (siguiente punto).

## El hostname del alumno no resuelve (`ping <hostname>` falla, pero `ping <IP>` funciona)

Comprobado en esta instalación: la VLAN del aula no resuelve nombres de equipo (ni por NetBIOS ni por mDNS/DNS), aunque los portátiles están accesibles por IP. Veyon **no admite dar de alta un equipo solo por MAC** — la MAC es un campo opcional exclusivo para Wake-on-LAN; para conectar necesita hostname o IP.

Solución: en vez de fiar la identificación a un hostname que no resuelve, fija la IP de cada portátil con una **reserva DHCP por dirección MAC** en el DHCP del centro, y da de alta esa IP fija en el Configurador (ver [`03-configuracion-aula.md`](03-configuracion-aula.md), sección 3.2, Opción A). Así el portátil sigue recibiendo la IP "por DHCP" pero siempre la misma.

## El equipo aparece pero falla la autenticación / no se puede conectar

1. Comprueba que en **ambos** equipos (profesor y alumno) el método de autenticación configurado en `veyon-configurator` es **el mismo**: "Autenticación mediante fichero de clave" (Key file authentication). Si uno tiene "logon" y otro "clave", fallará.
2. Comprueba que el alumno ha importado la clave **pública** correcta (la llamada `Docent`, generada en el equipo del profesor), y no una clave antigua o de otro aula.
3. Si el profesor ha regenerado el par de claves (por ejemplo tras reinstalar su equipo), hay que **volver a repartir e importar** la nueva clave pública en todos los portátiles: la clave antigua deja de ser válida.

## Error "Autenticación imposible / No se encontraron archivos de clave..." al abrir Veyon Master (Linux)

Este mensaje aparece aunque la clave exista, si tu usuario normal no tiene permiso de lectura sobre el fichero de la clave **privada** (en Linux suele quedar accesible solo para `root` al crearla). La solución es asignarle un grupo de acceso del que sea miembro tu usuario, desde **"Claves de autenticación"** en el Configurador. Pasos detallados en [`02-generacion-claves.md`](02-generacion-claves.md), sección 2.4.

## Puertos y protocolo usados por Veyon

- **TCP 11100**: comunicación entre Veyon Master y Veyon Service (control remoto, autenticación).
- La detección automática de equipos usa tráfico de difusión (broadcast/anuncio) dentro de la misma subred; no atraviesa routers ni VLANs distintas.

## Cambios de versión

Los nombres exactos de menús, botones o rutas de los ficheros de configuración pueden variar ligeramente entre versiones de Veyon. Ante cualquier duda, consulta la documentación oficial en **https://docs.veyon.io**.
