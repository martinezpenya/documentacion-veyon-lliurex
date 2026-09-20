#!/usr/bin/env bash
# Genera un CSV de equipos para importar con:
#   veyon-cli networkobjects import <fichero.csv> --format "%type%;%name%;%host%;%mac%;%location%"
#
# Uso: ./generar-csv-aula.sh <ip_inicio> <ip_fin> <nombre_aula> [fichero_salida.csv]
# Ejemplo: ./generar-csv-aula.sh 192.168.10.100 192.168.10.200 Aula-101

set -euo pipefail

uso() {
    echo "Uso: $0 <ip_inicio> <ip_fin> <nombre_aula> [fichero_salida.csv]" >&2
    echo "Ejemplo: $0 192.168.10.100 192.168.10.200 Aula-101" >&2
    exit 1
}

[ "$#" -ge 3 ] || uso

ip_inicio="$1"
ip_fin="$2"
aula="$3"
salida="${4:-${aula}.csv}"

ip_a_entero() {
    local ip="$1" a b c d
    IFS=. read -r a b c d <<< "$ip"
    echo $(( (a << 24) + (b << 16) + (c << 8) + d ))
}

entero_a_ip() {
    local n="$1"
    echo "$(( (n >> 24) & 255 )).$(( (n >> 16) & 255 )).$(( (n >> 8) & 255 )).$(( n & 255 ))"
}

for ip in "$ip_inicio" "$ip_fin"; do
    if ! [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        echo "Error: '$ip' no es una IPv4 válida." >&2
        exit 1
    fi
    for octeto in "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"; do
        if [ "$octeto" -gt 255 ]; then
            echo "Error: '$ip' tiene un octeto fuera de rango (0-255)." >&2
            exit 1
        fi
    done
done

inicio_int=$(ip_a_entero "$ip_inicio")
fin_int=$(ip_a_entero "$ip_fin")

if [ "$inicio_int" -gt "$fin_int" ]; then
    echo "Error: la IP de inicio ($ip_inicio) es mayor que la IP de fin ($ip_fin)." >&2
    exit 1
fi

total=$(( fin_int - inicio_int + 1 ))
digitos=3
[ "${#total}" -gt "$digitos" ] && digitos=${#total}

> "$salida"
n=1
for (( ip_int = inicio_int; ip_int <= fin_int; ip_int++ )); do
    ip=$(entero_a_ip "$ip_int")
    nombre=$(printf "alu%0${digitos}d" "$n")
    echo "computer;${nombre};${ip};;${aula}" >> "$salida"
    n=$(( n + 1 ))
done

echo "Generado '$salida' con $total equipo(s) para la ubicación '$aula'." >&2
echo "Import con: veyon-cli networkobjects import $salida --format \"%type%;%name%;%host%;%mac%;%location%\"" >&2
