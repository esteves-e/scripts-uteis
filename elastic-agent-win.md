# 🚀 Elastic Agent - Instalação e Enroll Automático (Windows)

Este repositório contém um script **PowerShell** para instalação e matrícula automática do **Elastic Agent** em ambientes Windows.  
O script foi projetado para simplificar o processo de deploy, tornando-o **idempotente** (pode rodar várias vezes sem quebrar) e confiável em ambientes corporativos.

---

## ✨ Recursos principais

- ✅ **Auto-elevação (UAC)** – se o script não for iniciado como administrador, ele se relança elevado.  
- ✅ **Transcript de execução** – gera log detalhado da execução em `%TEMP%`.  
- ✅ **Download com retry** – até 3 tentativas de download do pacote do Elastic Agent.  
- ✅ **Uso de arquivo local** – se o `.zip` do agente já estiver na mesma pasta do script, ele será usado em vez de baixar.  
- ✅ **Verificação de hash SHA512** (opcional) para garantir integridade do pacote.  
- ✅ **Desinstalação limpa** – para o serviço, remove diretórios de instalação anteriores e evita conflitos.  
- ✅ **Instalação silenciosa** com opções de:
  - `--policy` (Política do Fleet)
  - `--tag` (tags de agente)
  - `--certificate-authorities` (CA customizada)
  - `--proxy-url` (proxy corporativo)
  - `--insecure` (quando usa certificado autoassinado)
- ✅ **Checagem pós-instalação** – confirma criação e execução do serviço *Elastic Agent*.

---

## 📂 Estrutura do script

- **Uninstall-ElasticAgent**  
  Desinstala o agente existente (se houver) e remove dados residuais.

- **Ensure-Connectivity**  
  Verifica se há conectividade TCP 443 com o *Fleet Server* antes da matrícula.

- **Download/Copy ZIP**  
  1. Se o ZIP estiver na mesma pasta do script, ele é usado.  
  2. Caso contrário, verifica em `%TEMP%`.  
  3. Se não encontrar, baixa do site oficial da Elastic.

- **Expand-Archive**  
  Extrai os binários e ajusta a estrutura de pastas.

- **Install Elastic Agent**  
  Executa a instalação silenciosa com os parâmetros configurados.

---

## ⚙️ Configuração

No início do script há um bloco **CONFIG** com variáveis que precisam ser ajustadas:

```powershell
$ZipVersion      = "9.0.5"
$FleetUrl        = "https://fleet-prd-2rdatatel.siem.eskudo.io:443"
$EnrollmentToken = "<seu-token-aqui>"

# (Opcional)
$PolicyID        = ""                          # ID da política no Fleet
$AgentTags       = @("env:prod","location:rio") # tags personalizadas
$CaCertPath      = ""                          # caminho de CA customizada
$ProxyURL        = ""                          # proxy corporativo
```

▶️ Execução
Copie o script .ps1 e o pacote .zip do Elastic Agent para a mesma pasta (ou deixe que o script baixe automaticamente).

Abra o PowerShell como Administrador.

Execute:

```powershell
.\Install-ElasticAgent.ps1
```

📜 Logs
Um transcript de execução é salvo em %TEMP%/elastic-agent-enroll_YYYYMMDD_HHMMSS.log.

Em caso de erro, consulte também os logs do Elastic Agent em:

```powershell
C:\Program Files\Elastic\Agent\data\elastic-agent-*
```

🛡️ Compatibilidade
Windows 10 / 11

Windows Server 2016, 2019, 2022

Requer PowerShell 5 ou superior

📌 Observações
Caso utilize certificados autoassinados, configure $InsecureTLS = $true ou aponte o caminho da CA com $CaCertPath.

Para distribuição em larga escala, o script pode ser empacotado em:

GPO (Startup Script)

Intune (Win32 app)

Chocolatey / winget
