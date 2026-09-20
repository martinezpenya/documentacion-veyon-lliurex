# Documentación Veyon para el aula

Esta documentación explica cómo desplegar [Veyon](https://veyon.io) en un aula con:

- Un **equipo del profesor** (servidor/maestro) con **Lliurex** (basado en Ubuntu 24.04 "noble").
- Portátiles de alumnos con **Linux**, **Windows** o **macOS** (BYOD), conectados a la misma red/VLAN del aula con IP dinámica (DHCP).
- Autenticación mediante **un único par de claves pública/privada** para toda el aula (sin usuario/contraseña).

## Arquitectura de Veyon

Veyon se compone de dos piezas que se instalan por separado:

| Componente | Dónde se instala | Qué hace |
|---|---|---|
| **Veyon Master** | Solo en el equipo del profesor | Consola gráfica desde la que se ve/controla el aula |
| **Veyon Service** | En cada portátil de alumno (y también en el del profesor) | Agente en segundo plano que permite ser visto/controlado |
| **Veyon Configurator** | En todos los equipos | Herramienta gráfica de configuración (claves, red, permisos) |
| **veyon-cli** | Opcional, en todos los equipos | Misma configuración que el Configurator pero por línea de comandos, útil para automatizar |

La comunicación entre Master y Service se hace por **TCP, puerto 11100** (valor por defecto).

## Orden de lectura recomendado

1. [`01-instalacion-servidor.md`](01-instalacion-servidor.md) — instalar Veyon en el equipo del profesor.
2. [`02-generacion-claves.md`](02-generacion-claves.md) — generar el par de claves del aula y exportar la clave pública.
3. [`03-configuracion-aula.md`](03-configuracion-aula.md) — crear el aula y añadir los portátiles desde el Configurador (no desde Master).
4. Reparte a cada alumno el manual de su sistema operativo junto con el fichero de **clave pública** (nunca la privada):
   - [`04-manual-alumno-linux.md`](04-manual-alumno-linux.md)
   - [`05-manual-alumno-windows.md`](05-manual-alumno-windows.md)
   - [`06-manual-alumno-macos.md`](06-manual-alumno-macos.md)
5. Si algo falla, consulta [`07-resolucion-problemas.md`](07-resolucion-problemas.md).

## Idea clave sobre las claves

- Veyon usa un par de claves **asimétrico**, identificado por un nombre (en este caso, `Docent`).
- La **clave privada** se genera desde **Veyon Configurator** (no desde Master) y se queda **únicamente en el equipo del profesor**. Nunca se distribuye.
- La **clave pública** es la que se reparte e importa en **todos** los portátiles de alumnos (Service). Con ella, cada equipo puede comprobar que las peticiones de control vienen realmente del profesor.
- Repartir la clave pública no es un riesgo de seguridad (es pública por diseño), pero conviene distribuirla por un canal fiable (p. ej. el curso en Aules/Moodle, o un USB en clase) para asegurarse de que los alumnos importan la clave correcta.
