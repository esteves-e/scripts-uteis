#!/bin/bash

IP_LIST="ips.txt"
LIVE_HOSTS="hosts_ativos_udp.txt"
OUTPUT_DIR="resultados"
mkdir -p "$OUTPUT_DIR"

echo "[*] Verificando hosts ativos..."
nmap -sn -iL "$IP_LIST" -oG - | awk '/Up$/{print $2}' > "$LIVE_HOSTS"

echo "[*] Varredura em paralelo nos hosts ativos..."

cat "$LIVE_HOSTS" | parallel -j 10 "nmap -sU -Pn --top-ports 50 {} -oN $OUTPUT_DIR/{}_udp.txt"

echo "[*] Varredura concluída. Resultados estão em $OUTPUT_DIR/"
