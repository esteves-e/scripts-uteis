# Verificação de Status de Firewalls via SNMPv3

Este projeto foi desenvolvido com o objetivo de automatizar a verificação de status de múltiplos firewalls Sophos, utilizando o protocolo SNMPv3, de forma segura e estruturada.

## Funcionalidades

- Verifica a conectividade SNMPv3 com a lista de firewalls fornecida.
- Obtém o nome de cada firewall consultado.
- Identifica e separa firewalls online e offline.
- Exibe de forma organizada a lista de firewalls que estão respondendo e os que não estão.

## Dependências

Antes de executar o script, é necessário instalar o seguinte pacote Python:

```bash
pip install pysnmp
```

## Configuração Inicial

### Variáveis de Ambiente SNMP

No início do script, configure as credenciais de acesso SNMPv3:

```python
USER = "ENV_USER"
AUTH_PASS = "ENV_AUTH_PASS"
PRIV_PASS = "ENV_PRIV_PASS"
```

### Lista de IPs

Defina a lista de IPs dos firewalls que deverão ser verificados:

```python
FIREWALLS = [
    "0.0.0.0",
    "1.1.1.1"
]
```

Cada IP deverá estar entre aspas e separado por vírgula.

### OID Utilizado

O OID utilizado para a verificação é:

```text
1.3.6.1.2.1.1.5.0
```

Este OID corresponde ao nome do dispositivo ("sysName").

## Instruções de Execução

Certifique-se de que o script esteja corretamente configurado.

Execute o script utilizando o Python 3:

```bash
python3 verifica_firewalls_snmp.py
```

O resultado será exibido no terminal, separando os firewalls em:

- Firewalls Online (com nome retornado)
- Firewalls Offline (sem resposta SNMP)

## Estrutura de Saída

Exemplo de saída no terminal:

```
Firewalls Online
192.168.1.1 - SophosFW1
192.168.1.2 - SophosFW2

Firewalls Offline
192.168.1.3
192.168.1.4
```

## Considerações Técnicas

- O protocolo utilizado é o SNMPv3 com autenticação e criptografia (authPriv).
- O timeout de resposta é de 2 segundos, com uma tentativa de retry.
- Firewalls que não responderem ao OID especificado dentro do tempo serão considerados offline.

## Melhorias Futuras

- Implementar paralelização para acelerar a verificação de grandes listas.
- Exportar os resultados para um arquivo CSV ou JSON.
- Permitir configuração de OID dinâmico para outros tipos de validação.

## Contribuições

Contribuições, sugestões de melhorias e correções são muito bem-vindas.  
Sinta-se à vontade para colaborar visando aprimorar ainda mais a eficiência e a robustez deste projeto.
