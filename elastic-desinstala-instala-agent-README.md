# Automação de Instalação e Reinstalação do Elastic Agent (Windows)

Este projeto tem como objetivo simplificar o processo de instalação e reinstalação do Elastic Agent em sistemas Windows, de forma segura e automatizada, assegurando que versões anteriores sejam corretamente removidas antes da nova implantação.

## Funcionalidades

- Verificação da instalação existente do Elastic Agent e desinstalação segura, se necessário.
- Download automatizado da versão especificada do Elastic Agent.
- Extração e organização dos arquivos de instalação.
- Instalação do Elastic Agent com registro automático no Fleet Server (Elastic Cloud).
- Tratamento de erros com mensagens detalhadas para rápida identificação de falhas.

## Requisitos

- Windows PowerShell 5.1 ou superior.
- Permissão para execução de scripts no ambiente (`Set-ExecutionPolicy Bypass`).
- Conexão com a internet para download do pacote Elastic Agent.

## Configuração Inicial

Defina as variáveis no início do script:

- `$zipFile`: Nome do arquivo ZIP do Elastic Agent.
- `$downloadUrl`: URL de download do Elastic Agent.
- `$destinationFolder`: Pasta de destino para extração dos arquivos.
- `$elasticAgentPath`: Caminho padrão de instalação do Elastic Agent no Windows (`C:\Program Files\Elastic\Agent`).
- `$enrollmentToken`: Token de registro do agente no Fleet Server.
- `$fleetUrl`: URL do Fleet Server no Elastic Cloud.

### Exemplo de configuração:

```powershell
$zipFile = "elastic-agent-8.17.2-windows-x86_64.zip"
$downloadUrl = "https://artifacts.elastic.co/downloads/beats/elastic-agent/$zipFile"
$destinationFolder = "elastic-agent"
$elasticAgentPath = "C:\Program Files\Elastic\Agent"
$enrollmentToken = "seu_token_aqui"
$fleetUrl = "https://sua_fleet_url.fleet.region.elastic-cloud.com:443"
```

## Instruções de Execução

1. Abra o PowerShell como Administrador.
2. Permita a execução de scripts temporariamente:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

3. Execute o script.

Durante a execução, o script irá:

- Verificar se há uma instalação anterior do Elastic Agent e, se existir, desinstalar corretamente.
- Baixar a versão especificada do Elastic Agent (caso o arquivo ZIP ainda não esteja presente).
- Extrair o conteúdo do ZIP para o diretório configurado.
- Instalar o Elastic Agent utilizando o Enrollment Token e a URL do Fleet Server.

## Fluxo de Execução

- Verifica se o Elastic Agent já está instalado.
- Caso instalado:
  - Para o serviço do Elastic Agent.
  - Executa a desinstalação.
  - Remove pastas residuais.
- Verifica e realiza o download do pacote, se necessário.
- Extrai o pacote e organiza os arquivos.
- Instala o Elastic Agent e realiza o enrollment no Fleet.

## Mensagens de Log

Durante o processo, o script fornece feedback visual no terminal, utilizando cores para destacar o status de cada operação:

- Informações: Ciano
- Ações em andamento: Amarelo
- Erros: Vermelho
- Sucesso: Verde

## Considerações

- O script assume que o Elastic Agent será instalado em seu caminho padrão.
- Em caso de erro de conexão ou falha no download, a execução será interrompida automaticamente.
- Certifique-se de fornecer um Enrollment Token válido e a URL correta do Fleet Server para que o registro seja bem-sucedido.

## Melhorias Futuras

- Implementar parametrização dinâmica de versão e token via entrada do usuário.
- Melhorar logs com geração de arquivo de log detalhado.
- Adicionar verificação da versão instalada do Elastic Agent antes da reinstalação.

## Contribuições

Contribuições são bem-vindas!  
Sinta-se à vontade para sugerir melhorias, abrir issues ou enviar pull requests.
