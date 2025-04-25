# Script de Simulação de Ataques para Geração de Alertas no Elastic SIEM

Este script Bash automatiza a simulação de múltiplos tipos de ataques cibernéticos, com o objetivo de gerar alertas e eventos para fins de testes e validação de regras no Elastic SIEM.

## Funcionalidades

- Scan de rede utilizando Nmap e ARP-Scan
- Ataques de brute-force em serviços SSH e FTP com Hydra
- Simulação de escalada de privilégios via sudo
- Simulação de dump de credenciais com Mimikatz (fake)
- Exploração de vulnerabilidades SMB (EternalBlue) via Metasploit
- Exfiltração de dados utilizando Curl e Netcat
- Movimentação lateral via tentativas de conexão SSH
- Captura de pacotes de rede com Tcpdump
- Simulação de DDoS utilizando Iperf e Ping Flood
- Acesso não autorizado a diretórios sensíveis
- Captura simulada de senhas Wi-Fi via Aircrack-ng
- Enumeração de compartilhamentos SMB com Enum4Linux
- Persistência com backdoor Socat
- Cópia de arquivos de credenciais (/etc/passwd e /etc/shadow)
- Criação simulada de rootkit (arquivo `/etc/ld.so.preload`)

## Requisitos

- Distribuição Linux com Bash
- Ferramentas instaladas:
  - `nmap`
  - `arp-scan`
  - `hydra`
  - `msfconsole` (Metasploit)
  - `curl`
  - `netcat`
  - `ssh`
  - `tcpdump`
  - `iperf`
  - `ping`
  - `aircrack-ng`
  - `enum4linux`
  - `socat`

> Certifique-se de que todas as ferramentas estão instaladas e acessíveis no seu ambiente de testes.

## Instruções de Execução

1. Torne o script executável:

```bash
chmod +x simulador_ataques.sh
```

2. Execute o script com permissões de administrador/root:

```bash
sudo ./simulador_ataques.sh
```

O script irá iniciar a sequência de simulações automaticamente, com breves pausas entre cada etapa para permitir o registro adequado dos eventos.

## Fluxo de Simulações

1. Scan de rede (Nmap + ARP-Scan)
2. Ataques de brute-force (Hydra em SSH e FTP)
3. Simulação de abuso de sudo
4. Simulação de dump de credenciais (Mimikatz fake)
5. Exploração SMB com EternalBlue
6. Exfiltração de dados (Curl e Netcat)
7. Movimentação lateral via SSH
8. Captura de pacotes com Tcpdump
9. Ataque DDoS simulado (Iperf + Ping Flood)
10. Acesso a arquivos sensíveis
11. Captura de senhas Wi-Fi simulada
12. Enumeração de SMB (Enum4Linux)
13. Implantação de backdoor com Socat
14. Backup não autorizado de credenciais
15. Simulação de rootkit via arquivo `/etc/ld.so.preload`

## Considerações Importantes

- **Ambiente Controlado:** Execute este script apenas em ambientes de teste devidamente autorizados.
- **Impacto:** Algumas ações podem gerar tráfego suspeito e sobrecarregar a rede ou serviços.
- **Finalidade:** Uso exclusivo para treinamento, homologação de alertas e testes de SIEM.
- **Responsabilidade:** O uso indevido deste script fora de ambientes controlados é de inteira responsabilidade do usuário.

## Melhorias Futuras

- Implementar opção de escolha manual de quais ataques executar.
- Gerar logs detalhados das atividades para análise posterior.
- Adicionar opção para configurar IPs e ranges dinamicamente.
- Melhorar detecção de erros durante execução de comandos.

## Contribuições

Contribuições, correções ou sugestões de novas simulações são bem-vindas!  
Sinta-se à vontade para abrir issues ou enviar pull requests.

---
