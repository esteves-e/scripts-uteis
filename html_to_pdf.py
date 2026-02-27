from playwright.sync_api import sync_playwright, TimeoutError as PWTimeoutError
from urllib.parse import urlparse
import os
import re
import datetime

def filename_from_url(url: str) -> str:
    p = urlparse(url)
    path = p.path.strip("/")

    if not path:
        name = p.netloc
    else:
        name = path.replace("/", "_")

    # Remove caracteres inválidos no Windows
    name = re.sub(r'[<>:"\\|?*]', "_", name)

    # Evita nomes muito longos
    return name[:150] or "pagina"

os.makedirs("pdfs", exist_ok=True)
today = datetime.datetime.now().strftime("%Y-%m-%d")

with open("links.txt", "r", encoding="utf-8") as f:
    urls = [line.strip() for line in f if line.strip() and not line.strip().startswith("#")]

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context(
        viewport={"width": 1280, "height": 720},
        locale="pt-BR"
    )
    page = context.new_page()

    for url in urls:
        print(f"\nBaixando: {url}")

        try:
            try:
                page.goto(url, wait_until="networkidle", timeout=45000)
            except PWTimeoutError:
                print("  ⚠ networkidle demorou; usando domcontentloaded + espera extra...")
                page.goto(url, wait_until="domcontentloaded", timeout=120000)

            # Espera extra para páginas SPA renderizarem completamente
            page.wait_for_timeout(4000)

            name = filename_from_url(url)
            output_file = f"pdfs/{name}_{today}.pdf"

            page.pdf(
                path=output_file,
                format="A4",
                print_background=True,
                prefer_css_page_size=True,
                display_header_footer=True,
                margin={"top": "18mm", "bottom": "18mm", "left": "12mm", "right": "12mm"},
                header_template=f"""
                    <div style="font-size:8px; width:100%; padding:0 10mm; color:#444;">
                        <span>{url}</span>
                    </div>
                """,
                footer_template=f"""
                    <div style="font-size:8px; width:100%; padding:0 10mm; text-align:right; color:#444;">
                        <span>{today} - Página <span class="pageNumber"></span>/<span class="totalPages"></span></span>
                    </div>
                """
            )

            print(f"  ✅ OK: {output_file}")

        except Exception as e:
            print(f"  ❌ Falhou nesta URL, mas continuando. Erro: {e}")

    browser.close()

print("\n✔ Concluído. PDFs salvos na pasta /pdfs")
