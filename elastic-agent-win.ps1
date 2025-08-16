<#
    Elastic Agent - Enroll Automático (Windows)
    Versão: 2025-08-16
    Requisitos: PowerShell 5+, executar como Administrador
#>

#region CONFIG
$ZipVersion        = "9.0.5"
$Arch              = "windows-x86_64"
$ZipFileName       = "elastic-agent-$ZipVersion-$Arch.zip"
$DownloadUrl       = "https://artifacts.elastic.co/downloads/beats/elastic-agent/$ZipFileName"

# (Opcional) SHA512 oficial do ZIP para verificação de integridade (deixe vazio para pular).
$ZipSha512         = ""

# Pastas
$DestinationFolder = Join-Path $env:TEMP "elastic-agent-install"
$UnzipFolder       = Join-Path $DestinationFolder "elastic-agent"
$ElasticAgentDir   = "C:\Program Files\Elastic\Agent"
$ProgramDataDir    = "C:\ProgramData\Elastic"   # pode conter dados residuais

# Fleet
$FleetUrl          = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"     # <— AJUSTE
$EnrollmentToken   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # <— AJUSTE

# TLS/CA
$InsecureTLS       = $false                        # true => instala com --insecure (autoassinado)
$CaCertPath        = ""                            # ex: "C:\certs\fleet-ca.pem" (opcional)

# Opções úteis
$PolicyID          = ""                            # ex: "7e0a8b30-...." (opcional)
$AgentTags         = @("env:prod","location:rio")  # personalize (opcional)
$ProxyURL          = ""                            # ex: "http://proxy.local:3128" (opcional)
$ExtraArgs         = @()                           # args extras

# Comportamento
$PurgeOldData      = $true     # remove diretórios residuais após uninstall
$RetriesDownload   = 3
$RetryDelaySec     = 5
$KeepZip           = $true     # manter o ZIP baixado na pasta de trabalho
$KeepWorkFolder    = $false    # manter pasta temporária
$TranscriptPath    = Join-Path $env:TEMP "elastic-agent-enroll_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
#endregion CONFIG

# Fail fast
$ErrorActionPreference = "Stop"

function Write-Info($msg){ Write-Host "[INFO ] $msg" -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host "[WARN ] $msg" -ForegroundColor Yellow }
function Write-Ok  ($msg){ Write-Host "[ OK  ] $msg" -ForegroundColor Green }
function Write-Err ($msg){ Write-Host "[ERR  ] $msg" -ForegroundColor Red }

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Elevation {
    if (-not (Test-Admin)) {
        Write-Warn "Este script precisa de privilégios de Administrador. Reabrindo elevado..."
        $psi = @{
            FilePath     = "powershell.exe"
            ArgumentList = @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`"")
            Verb         = "runas"
            WindowStyle  = "Normal"
        }
        try { Start-Process @psi } catch { Write-Err ("Falha ao elevar: {0}" -f $_) ; exit 2 }
        exit 0
    }
}

function Ensure-TLS12 {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Info "TLS 1.2 habilitado para downloads."
    } catch { Write-Warn "Não foi possível forçar TLS 1.2 (continuando)." }
}

function Invoke-Download($uri, $outFile) {
    for($i=1; $i -le $RetriesDownload; $i++){
        try {
            Write-Info ("Baixando ({0}/{1}): {2}" -f $i, $RetriesDownload, $uri)
            Invoke-WebRequest -Uri $uri -OutFile $outFile
            if (Test-Path $outFile) { return $true }
        } catch {
            Write-Warn ("Falha no download: {0}" -f $_.Exception.Message)
            if ($i -lt $RetriesDownload) { Start-Sleep -Seconds $RetryDelaySec }
        }
    }
    return $false
}

function Get-FileSha512($path){
    if (-not (Test-Path $path)) { return "" }
    $h = Get-FileHash -Algorithm SHA512 -Path $path
    return $h.Hash.ToLowerInvariant()
}

function Stop-ElasticAgent-Service {
    $svc = Get-Service -Name "Elastic Agent" -ErrorAction SilentlyContinue
    if ($null -ne $svc) {
        if ($svc.Status -ne "Stopped") {
            Write-Info "Parando serviço 'Elastic Agent'..."
            Stop-Service -Name "Elastic Agent" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3
        }
        Write-Info "Desabilitando serviço para evitar auto-restart durante uninstall..."
        Set-Service -Name "Elastic Agent" -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Uninstall-ElasticAgent {
    if (Test-Path (Join-Path $ElasticAgentDir "elastic-agent.exe")) {
        Write-Info "Desinstalando Elastic Agent existente..."
        Stop-ElasticAgent-Service

        $exe = "`"$ElasticAgentDir\elastic-agent.exe`""
        $proc = Start-Process -FilePath $exe -ArgumentList @("uninstall","--force") -PassThru -Wait -WindowStyle Hidden
        if ($proc.ExitCode -ne 0) { Write-Warn ("uninstall retornou código {0} (prosseguindo mesmo assim)." -f $proc.ExitCode) }
        Start-Sleep -Seconds 5
    } else {
        Write-Info "Elastic Agent não encontrado no caminho padrão."
    }

    if ($PurgeOldData) {
        foreach($p in @($ElasticAgentDir, $ProgramDataDir)){
            if (Test-Path $p){
                Write-Info ("Removendo diretório residual: {0}" -f $p)
                try { 
                    Remove-Item -Recurse -Force $p -ErrorAction Stop
                } catch {
                    Start-Sleep -Seconds 2
                    try { 
                        Remove-Item -Recurse -Force $p -ErrorAction Stop 
                    } catch { 
                        Write-Warn ("Falha ao remover {0}: {1}" -f $p, $_)
                    }
                }
            } else {
                Write-Info ("Diretório não encontrado, ignorando: {0}" -f $p)
            }
        }
    }
}

function Ensure-Connectivity {
    try {
        $uri = [uri]$FleetUrl
        $hostToTest = $uri.Host
        Write-Info ("Testando conectividade com Fleet: {0}:443" -f $hostToTest)
        $ok = Test-NetConnection -ComputerName $hostToTest -Port 443 -InformationLevel Quiet
        if (-not $ok) { Write-Warn ("Sem conectividade TCP 443 com {0}. A matrícula pode falhar." -f $hostToTest) }
    } catch {
        Write-Warn ("Não foi possível validar conectividade: {0}" -f $_)
    }
}

# ===== Início =====
try {
    Start-Transcript -Path $TranscriptPath -Append | Out-Null
    Ensure-Elevation
    Ensure-TLS12
    Ensure-Connectivity

    # Workspace
    if (-not (Test-Path $DestinationFolder)) { New-Item -ItemType Directory -Path $DestinationFolder | Out-Null }
    if (Test-Path $UnzipFolder) { Remove-Item -Recurse -Force $UnzipFolder }

    # Desinstalar se existir
    Uninstall-ElasticAgent

    # ===== ZIP: priorizar arquivo local ao lado do script =====
    $ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
    $LocalZipPath = Join-Path $ScriptDir $ZipFileName
    $ZipPath      = Join-Path $DestinationFolder $ZipFileName

    if (Test-Path $LocalZipPath) {
        Write-Info ("Encontrado ZIP local em {0}, copiando para pasta de trabalho..." -f $LocalZipPath)
        Copy-Item -Path $LocalZipPath -Destination $ZipPath -Force
    }
    elseif (-not (Test-Path $ZipPath)) {
        if (-not (Invoke-Download -uri $DownloadUrl -outFile $ZipPath)) {
            Write-Err ("Falha ao baixar {0} após {1} tentativas." -f $DownloadUrl, $RetriesDownload)
            exit 10
        }
    } else {
        Write-Info ("ZIP já existe em: {0}" -f $ZipPath)
    }
    # ==========================================================

    # Verificar Hash (opcional)
    if ($ZipSha512) {
        $calc = Get-FileSha512 $ZipPath
        if ($calc -ne $ZipSha512.ToLowerInvariant()) {
            Write-Err ("Hash SHA512 não confere! Esperado: {0} | Obtido: {1}" -f $ZipSha512, $calc)
            exit 11
        } else {
            Write-Ok "Hash SHA512 verificado."
        }
    }

    # Extrair
    Write-Info ("Extraindo para: {0}" -f $UnzipFolder)
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $UnzipFolder -Force

    # Achatar subpasta, se houver
    $subdirs = Get-ChildItem -Path $UnzipFolder -Directory
    if ($subdirs.Count -eq 1 -and -not (Test-Path (Join-Path $UnzipFolder "elastic-agent.exe"))) {
        $only = $subdirs[0].FullName
        Write-Info ("Achatando estrutura: movendo {0}\* para {1}" -f $only, $UnzipFolder)
        Get-ChildItem -Path $only -Force | Move-Item -Destination $UnzipFolder -Force
        Remove-Item -Recurse -Force $only
    }

    $AgentExe = Join-Path $UnzipFolder "elastic-agent.exe"
    if (-not (Test-Path $AgentExe)) { Write-Err "elastic-agent.exe não encontrado após extração."; exit 12 }

    # Montar argumentos de instalação (não-interativo)
    $args = @("install", "--url=$FleetUrl", "--enrollment-token=$EnrollmentToken", "--non-interactive")
    if ($InsecureTLS) { $args += "--insecure" }
    if ($CaCertPath)  { $args += "--certificate-authorities=`"$CaCertPath`"" }
    if ($PolicyID)    { $args += "--policy=$PolicyID" }
    foreach($t in $AgentTags){ if ($t) { $args += "--tag=$t" } }
    if ($ProxyURL)    { $args += "--proxy-url=`"$ProxyURL`"" }
    if ($ExtraArgs.Count -gt 0) { $args += $ExtraArgs }

    Write-Info ("Instalando Elastic Agent (silencioso)...
Cmd: `"{0}`" {1}" -f $AgentExe, ($args -join ' '))
    $proc = Start-Process -FilePath $AgentExe -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
    if ($proc.ExitCode -ne 0) {
        Write-Err ("Instalação retornou código {0}. Verifique o Transcript e os logs do Agent." -f $proc.ExitCode)
        exit 20
    }

    # Pós-instalação
    Start-Sleep -Seconds 5
    $svc = Get-Service -Name "Elastic Agent" -ErrorAction SilentlyContinue
    if ($null -eq $svc) {
        Write-Warn ("Serviço 'Elastic Agent' não foi criado. Verifique logs em '{0}\data\elastic-agent-*'." -f $ElasticAgentDir)
    } else {
        Write-Ok ("Serviço 'Elastic Agent' encontrado: Status={0}" -f $svc.Status)
        if ($svc.Status -ne "Running") {
            Write-Info "Tentando iniciar serviço..."
            try { Start-Service -Name "Elastic Agent"; Start-Sleep -Seconds 3 } catch { Write-Warn ("Falha ao iniciar serviço: {0}" -f $_) }
        }
    }

    Write-Ok "Instalação e enroll concluídos."

} catch {
    Write-Err ("Erro não tratado: {0}" -f $_.Exception.Message)
    exit 99
}
finally {
    # Limpeza
    try {
        if (-not $KeepWorkFolder -and (Test-Path $DestinationFolder)) {
            if ($KeepZip) {
                # remove tudo exceto o ZIP
                Get-ChildItem $DestinationFolder -Force |
                    Where-Object { $_.FullName -ne (Join-Path $DestinationFolder $ZipFileName) } |
                    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                Remove-Item -Recurse -Force $DestinationFolder -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Warn ("Falha ao limpar pasta temporária: {0}" -f $_)
    }
    try { Stop-Transcript | Out-Null } catch {}
}

Write-Host ""
Write-Ok ("Transcript salvo em: {0}" -f $TranscriptPath)
