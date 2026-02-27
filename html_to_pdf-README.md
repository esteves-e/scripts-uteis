# 📄 Web Documentation to PDF Generator

Script em Python utilizando **Playwright + Chromium** para converter
páginas web em PDF de forma automatizada, preservando layout real do
navegador (CSS moderno, JS, SPA).

Ideal para: - 📑 Editais e comprovação de documentação - 📚 Backup de
documentações técnicas - 🗂️ Arquivamento institucional - 🏢 Uso
corporativo / compliance

------------------------------------------------------------------------

## 🚀 Funcionalidades

-   ✅ Conversão em lote via `links.txt`
-   ✅ Renderização real do Chromium
-   ✅ Nome do PDF baseado no PATH completo da URL
-   ✅ Cabeçalho com URL
-   ✅ Rodapé com data + paginação
-   ✅ Tratamento de timeout automático
-   ✅ Continua mesmo se uma URL falhar
-   ✅ Compatível com páginas SPA modernas (React, Vue, etc.)

------------------------------------------------------------------------

## 📁 Estrutura do Projeto

. ├── gerar_pdfs.py 
. ├── links.txt 
. ├── pdfs/ 
. └── README.md

------------------------------------------------------------------------

## ⚙️ Requisitos

-   Python 3.10+
-   Playwright
-   Chromium (instalado via Playwright)

------------------------------------------------------------------------

## 🔧 Instalação

### 1️⃣ Instalar dependências

pip install playwright playwright install chromium

------------------------------------------------------------------------

## 📝 Como usar

### 1️⃣ Criar arquivo `links.txt`

Coloque uma URL por linha:

https://site.com/documentacao/manual https://site.com/docs/guia

Linhas iniciadas com `#` serão ignoradas.

------------------------------------------------------------------------

### 2️⃣ Executar

python gerar_pdfs.py

------------------------------------------------------------------------

## 📦 Saída

Os PDFs serão salvos na pasta:

/pdfs

Formato do nome:

docs_produto_manual_2026-02-27.pdf

-   PATH completo convertido em nome
-   Data da geração

------------------------------------------------------------------------

## 🧠 Como funciona

O script:

1.  Lê as URLs do `links.txt`
2.  Abre cada página com Chromium headless
3.  Aguarda carregamento seguro (`networkidle` com fallback)
4.  Aguarda renderização adicional
5.  Gera PDF com:
    -   CSS completo
    -   Plano de fundo
    -   URL no cabeçalho
    -   Data + paginação no rodapé

------------------------------------------------------------------------

## 🛡️ Tratamento de Erros

Se uma URL falhar: - O erro é exibido no console - O script continua
para a próxima URL

------------------------------------------------------------------------

## 📌 Personalização

Você pode alterar:

-   Margens do PDF
-   Formato (A4 / Letter)
-   Tempo de espera
-   CSS de impressão
-   Modo headless (visual)

------------------------------------------------------------------------

## 📜 Licença

Uso livre para fins pessoais, corporativos e institucionais.

------------------------------------------------------------------------

## 👨‍💻 Autor

Projeto criado por Eduardo Esteves
