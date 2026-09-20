# CLAUDE.md

Contexto para retomar este proyecto de documentación de Veyon.

## Qué es este repo

Documentación en Markdown (español) para desplegar Veyon en un aula real:

- Servidor/maestro: **Lliurex** (basado en Ubuntu 24.04 "noble").
- Alumnos BYOD con Linux, Windows o macOS, todos en la **misma VLAN**, **IP dinámica** (DHCP).
- Autenticación por **fichero de clave** (no logon), con un único par de claves para toda el aula llamado **`Docent`**.

Ficheros: `README.md` (índice) + `01`…`07` en orden de lectura. Ver `README.md` para la estructura completa.

## Decisiones y hechos verificados (no re-investigar)

- El nombre del par de claves es **`Docent`** (decisión del usuario, no `teacher`).
- **`veyon-configurator`** tiene páginas separadas para: **Autenticación** (elegir método), **Claves de autenticación** (crear/exportar/importar el par), y **Ubicaciones y equipos** (Locations & computers, gestiona el backend Builtin).
- **Crear el aula y añadir equipos se hace desde `veyon-configurator`, NUNCA desde Veyon Master.** Master solo sirve para visualizar/controlar equipos ya dados de alta. Este punto generó confusión una vez — no volver a mezclarlo.
- El backend **"Integrado" (Builtin)** de ubicaciones/equipos es el que usa Veyon por defecto y es **gratuito**; no requiere instalar nada.
- El complemento **"Network Discovery"** (detección automática de equipos por red) es un **add-on comercial de pago** de Veyon Solutions. El usuario no quiere usarlo — la documentación usa solo el alta manual por hostname (backend Builtin).
- En la página "Ubicaciones y equipos": lista de ubicaciones a la izquierda, lista de equipos de la ubicación seleccionada a la derecha; los botones de añadir/quitar son iconos "+"/"-" bajo cada lista, no botones con texto. Hay que seleccionar la ubicación primero para que la lista de equipos se active.
- **Instalador de Windows**: la pantalla de componentes muestra tres casillas reales: **Veyon Service** (marcar), **Veyon Master** (no marcar en alumnos), **Interception Driver** (marcar, necesario para bloqueo de teclado/ratón). "Veyon Configurator" no aparece como casilla: se instala junto con el Service.
- **SmartScreen/aviso de Windows** al descargar/ejecutar el instalador es normal en software libre sin certificado EV; no indica malware. Documentado en `05-manual-alumno-windows.md`.
- **Error "Autenticación imposible / No se encontraron archivos de clave..." en Linux**: causado porque la clave privada se crea con permisos solo para `root` y el usuario normal del profesor no puede leerla. Solución: en "Claves de autenticación", seleccionar la clave privada → "Establecer grupo de acceso" → asignar un grupo del que el usuario sea miembro (crear grupo + `usermod -aG` + cerrar sesión si hace falta). Documentado en `02-generacion-claves.md` §2.4 y en `07-resolucion-problemas.md`.

## Cómo trabajar en este repo

- Antes de documentar cualquier detalle de UI de Veyon que no esté ya verificado arriba, **contrastar con la documentación oficial** (`https://docs.veyon.io`) o pedir al usuario que confirme lo que ve en su pantalla — varias veces la memoria del modelo sobre menús exactos de Veyon ha sido incorrecta y se ha corregido a partir de lo que el usuario reportaba en su instalación real.
- El usuario prueba los pasos en su propio equipo (Lliurex) según se van escribiendo, así que los errores/capturas que reporte son la fuente de verdad por encima de lo que diga la documentación oficial genérica.
