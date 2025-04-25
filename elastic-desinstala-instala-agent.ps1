//Permitir execução de scripts temporariamente
Set-ExecutionPolicy Bypass -Scope Process -Force

//Definir variáveis
$zipFile = "elastic-agent-8.17.2-windows-x86_64.zip" //Verificar a versão atual 
$downloadUrl = "https://artifacts.elastic.co/downloads/beats/elastic-agent/$zipFile"
$destinationFolder = "elastic-agent"
$elasticAgentPath = "C:\Program Files\Elastic\Agent" //Caminho padrão Windows
$enrollmentToken = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" //Altere o seu Token
$fleetUrl = "https://xxxxxxxxxxxxxxxx.fleet.eastus2.azure.elastic-cloud.com:443" //Altere sua fleet URL

//Verificar se o Elastic Agent já está instalado e desinstalá-lo antes da reinstalação
if (Test-Path "$elasticAgentPath\elastic-agent.exe") {
    Write-Host "Elastic Agent encontrado. Iniciando processo de desinstalação..." -ForegroundColor Cyan

    try {
        # Parar o serviço do Elastic Agent (se estiver rodando)
        Write-Host "Parando o serviço do Elastic Agent..." -ForegroundColor Yellow
        Get-Service -Name "Elastic Agent" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue

        # Executar a desinstalação do Elastic Agent
        Write-Host "Executando desinstalação..." -ForegroundColor Yellow
        & "$elasticAgentPath\elastic-agent.exe" uninstall --force

        # Aguardar a remoção completa do serviço
        Start-Sleep -Seconds 5

        # Confirmar se a desinstalação foi bem-sucedida
        if (Test-Path "$elasticAgentPath\elastic-agent.exe") {
            Write-Host "Falha ao desinstalar o Elastic Agent!" -ForegroundColor Red
            exit 1
        }

        # Remover diretório de instalação, se ainda existir
        if (Test-Path $elasticAgentPath) {
            Remove-Item -Recurse -Force $elasticAgentPath
        }

        Write-Host "Desinstalação concluída com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao desinstalar o Elastic Agent: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Elastic Agent não encontrado. Pulando a desinstalação." -ForegroundColor Yellow
}

//Verificar se o arquivo ZIP já existe
if (!(Test-Path $zipFile)) {
    Write-Host "Arquivo ZIP não encontrado. Iniciando o download..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
        if (!(Test-Path $zipFile)) {
            Write-Host "Erro ao baixar o Elastic Agent. Verifique a conexão." -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Erro ao baixar o Elastic Agent: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Arquivo ZIP já existe. Pulando o download." -ForegroundColor Yellow
}

//Remover pasta de instalação temporária (se existir)
if (Test-Path $destinationFolder) {
    Remove-Item $destinationFolder -Recurse -Force
}

//Extrair o Elastic Agent
Write-Host "Extraindo o Elastic Agent..." -ForegroundColor Cyan
try {
    Expand-Archive -LiteralPath $zipFile -DestinationPath $destinationFolder -Force
} catch {
    Write-Host "Erro ao extrair com Expand-Archive. Verifique se o arquivo ZIP está corrompido." -ForegroundColor Red
    exit 1
}

//Detectar se foi criada uma subpasta dentro de $destinationFolder
$subfolders = Get-ChildItem -Path $destinationFolder -Directory

if ($subfolders.Count -eq 1) {
    $subfolderPath = Join-Path $destinationFolder $subfolders.Name
    Write-Host "Movendo arquivos de $subfolderPath para $destinationFolder..." -ForegroundColor Yellow
    Move-Item -Path "$subfolderPath\*" -Destination $destinationFolder -Force
    Remove-Item -Recurse -Force $subfolderPath
}

//Verificar se a extração foi bem-sucedida
if (!(Test-Path "$destinationFolder\elastic-agent.exe")) {
    Write-Host "Erro crítico: Falha ao extrair os arquivos!" -ForegroundColor Red
    exit 1
}

Write-Host "Extração concluída com sucesso!" -ForegroundColor Green

//Instalar o Elastic Agent
Write-Host "Instalando o Elastic Agent..." -ForegroundColor Cyan
cd $destinationFolder
.\elastic-agent.exe install --url=$fleetUrl --enrollment-token=$enrollmentToken

Write-Host "Instalação concluída com sucesso!" -ForegroundColor Green

//Manter o terminal aberto após a execução
Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor Cyan
pause
