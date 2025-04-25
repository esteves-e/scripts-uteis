Relatório SNMP de Firewalls Sophos XGS107 / XGS108
Este projeto foi desenvolvido com o objetivo de automatizar a coleta de informações estratégicas de dispositivos de segurança Sophos XGS107/XGS108, utilizando o protocolo SNMPv3, e gerar relatórios estruturados nos formatos CSV e PDF para facilitar a gestão e a análise dos ativos de rede.

Funcionalidades
Coleta de dados essenciais como:

Nome do Firewall

Código do Firewall

Versão do Firmware

Tempo de Uptime

Status das interfaces WAN1 e WAN2

Data de Expiração de Licença

Varredura (walk) de interfaces de rede para identificação e monitoramento de status adicionais (ex: Port, GuestAP, PortF1).

Tradução automática dos estados das interfaces para status legíveis (UP, DOWN, TESTING, UNPLUGGED) com indicadores visuais.

Geração automática de relatórios:

CSV (para análise em planilhas)

PDF (pronto para distribuição e arquivamento)

Utilização de indicadores visuais (emojis) para facilitar a identificação rápida de estados críticos.

Dependências
Antes de executar o script, é necessário instalar os seguintes pacotes Python:

pip install pysnmp reportlab

Configuração Inicial
Variáveis de Ambiente SNMP
No início do script, configure as credenciais de acesso SNMPv3:

USER = "ENV_USER"
AUTH_PASS = "ENV_AUTH_PASS"
PRIV_PASS = "SNMP_PRIV_PASS"

Arquivo de IPs
Crie um arquivo de texto (.txt) contendo a lista dos endereços IP dos dispositivos a serem monitorados, um IP por linha:

Exemplo de conteúdo do arquivo:

192.168.1.1
192.168.1.2
192.168.1.3

Atualize a variável no script para apontar para o caminho correto do arquivo:

IP_FILE = "CAMINHO_DO_IP/firewall_ips.txt"

Instruções de Execução
Certifique-se de que o script e o arquivo de IPs estão corretamente configurados.

Execute o script utilizando o Python 3:

python3 relatorio_snmp_pdf_csv.py

Após a execução, os relatórios serão gerados automaticamente no diretório corrente, nomeados com a data da coleta:

relatorio_firewall_YYYY-MM-DD.csv
relatorio_firewall_YYYY-MM-DD.pdf

Estrutura dos Dados Coletados

Dado	Informação
Firewall	Nome do dispositivo
Código do Firewall	Código serial único
Versão do Firmware	Versão instalada
Tempo de Uptime	Formato dias/horas/minutos
WAN1 Status	Status da primeira interface WAN
WAN2 Status	Status da segunda interface WAN
Licença Expiração	Data de expiração da licença
Interface PortX	Status individual de cada porta
Considerações Técnicas
O protocolo utilizado é o SNMPv3 com autenticação e criptografia (authPriv), garantindo segurança na coleta.

O script possui tolerância a falhas de coleta, com timeouts ajustados e tentativa de repetição.

Em caso de falhas ou ausência de resposta, será indicado "ERRO ❌" nos campos afetados.

Roadmap de Melhorias
Suporte a múltiplos modelos Sophos e customização de OIDs por modelo.

Externalização de variáveis de ambiente via arquivo de configuração (.env).

Tratamento avançado de falhas SNMP com logs detalhados.

Contribuições
Contribuições, sugestões de melhorias e correções são muito bem-vindas.
Sinta-se à vontade para colaborar visando aprimorar ainda mais a eficiência e a robustez deste projeto.
