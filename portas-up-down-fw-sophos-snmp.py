# Configuração de OIDS baseado no SophosFirewall XGS107 / 108

import csv
from datetime import datetime, timedelta
from pysnmp.hlapi import *
from pysnmp.hlapi import usmHMAC192SHA256AuthProtocol, usmAesCfb128Protocol
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, Spacer
from reportlab.lib.styles import getSampleStyleSheet

# SNMP config
USER = "ENV_USER"
AUTH_PASS = "ENV_AUTH_PASS"
PRIV_PASS = "SNMP_PRIV_PASS"
IP_FILE = "CAMINHO_DO_IP/firewall_ips.txt" #  Coloque aqui o caminho para seu arquivo de IPs

OIDS = {
    "Firewall Name": "1.3.6.1.4.1.2604.5.1.1.1.0",
    "Firewall Code": "1.3.6.1.4.1.2604.5.1.1.4.0",
    "Firmware Version": "1.3.6.1.4.1.2604.5.1.1.3.0",
    "Uptime": "1.3.6.1.4.1.2604.5.1.2.2.0",
    "WAN1 Status": "1.3.6.1.2.1.2.2.1.8.1",
    "WAN2 Status": "1.3.6.1.2.1.2.2.1.8.2",
    "License Expiration": "1.3.6.1.4.1.2604.5.1.5.1.2.0",
}

def snmp_get(ip, oid):
    for (errorIndication, errorStatus, _, varBinds) in getCmd(
        SnmpEngine(),
        UsmUserData(USER, AUTH_PASS, PRIV_PASS,
                    authProtocol=usmHMAC192SHA256AuthProtocol,
                    privProtocol=usmAesCfb128Protocol),
        UdpTransportTarget((ip, 161), timeout=2, retries=1),
        ContextData(),
        ObjectType(ObjectIdentity(oid))):
        if errorIndication or errorStatus:
            return "ERRO ❌"
        for varBind in varBinds:
            return varBind[1].prettyPrint()

def snmp_walk(ip, base_oid):
    results = {}
    for (errorIndication, errorStatus, _, varBinds) in nextCmd(
        SnmpEngine(),
        UsmUserData(USER, AUTH_PASS, PRIV_PASS,
                    authProtocol=usmHMAC192SHA256AuthProtocol,
                    privProtocol=usmAesCfb128Protocol),
        UdpTransportTarget((ip, 161), timeout=2, retries=1),
        ContextData(),
        ObjectType(ObjectIdentity(base_oid)),
        lexicographicMode=False):
        if errorIndication or errorStatus:
            break
        for varBind in varBinds:
            oid, value = varBind
            index = int(oid.prettyPrint().split('.')[-1])
            results[index] = value.prettyPrint()
    return results

def traduzir_status_porta(status):
    return {
        "1": "UP ✅",
        "2": "DOWN ❌",
        "3": "TESTING ⚠",
        "4": "UNPLUGGED ❌"
    }.get(status, "ERRO ❌")

def formatar_uptime(timeticks):
    try:
        segundos = int(timeticks) / 100
        tempo = timedelta(seconds=segundos)
        dias = tempo.days
        horas, resto = divmod(tempo.seconds, 3600)
        minutos, _ = divmod(resto, 60)
        return f"{dias}d {horas}h {minutos}m"
    except:
        return "ERRO ❌"

def gerar_pdf(relatorios, nome_arquivo_pdf):
    doc = SimpleDocTemplate(nome_arquivo_pdf, pagesize=A4)
    elements = []
    styles = getSampleStyleSheet()

    elements.append(Paragraph("Relatório de Firewalls", styles['Heading1']))
    elements.append(Paragraph(f"Data de geração: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", styles['Normal']))
    elements.append(Spacer(1, 12))

    for firewall in relatorios:
        elements.append(Paragraph(f" IP: {firewall['ip']}", styles['Heading3']))
        dados = firewall['dados']

        table_data = [["Dado", "Informação"]]
        for chave, valor in dados.items():
            table_data.append([chave, valor])

        t = Table(table_data, hAlign="LEFT", colWidths=[200, 300])
        t.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE')
        ]))

        elements.append(t)
        elements.append(Spacer(1, 24))

    doc.build(elements)

# Coleta SNMP
relatorios = []
with open(IP_FILE, "r") as ip_file:
    ips = [line.strip() for line in ip_file.readlines() if line.strip()]

for ip in ips:
    dados = {
        "Firewall": snmp_get(ip, OIDS["Firewall Name"]),
        "Código do Firewall": snmp_get(ip, OIDS["Firewall Code"]),
        "Versão do Firmware": snmp_get(ip, OIDS["Firmware Version"]),
        "Tempo de Uptime": formatar_uptime(snmp_get(ip, OIDS["Uptime"])),
        "WAN1 Status": traduzir_status_porta(snmp_get(ip, OIDS["WAN1 Status"])),
        "WAN2 Status": traduzir_status_porta(snmp_get(ip, OIDS["WAN2 Status"])),
        "Licença Expiração": snmp_get(ip, OIDS["License Expiration"]),
    }

    descrs = snmp_walk(ip, "1.3.6.1.2.1.2.2.1.2")
    status = snmp_walk(ip, "1.3.6.1.2.1.2.2.1.8")

    for idx, descr in descrs.items():
        if descr.startswith("Port") or descr in ["GuestAP", "PortF1"]:
            estado = traduzir_status_porta(status.get(idx, "0"))
            dados[f"Interface {descr}"] = estado

    relatorios.append({"ip": ip, "dados": dados})

# Gerar CSV e PDF
data_str = datetime.now().strftime('%Y-%m-%d')
csv_filename = f"relatorio_firewall_{data_str}.csv"
pdf_filename = f"relatorio_firewall_{data_str}.pdf"

with open(csv_filename, mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["======================== RELATÓRIO DE FIREWALLS ========================"])
    writer.writerow(["Data de Geração", datetime.now().strftime("%Y-%m-%d %H:%M:%S")])
    writer.writerow([])

    for fw in relatorios:
        writer.writerow(["======================================================================="])
        writer.writerow([f" IP: {fw['ip']}"])
        writer.writerow(["======================================================================="])
        writer.writerow(["Dado", "Informação"])
        for k, v in fw["dados"].items():
            writer.writerow([k, v])
        writer.writerow([])

gerar_pdf(relatorios, pdf_filename)
print(f"Relatórios salvos como:\n CSV: {csv_filename}\n PDF: {pdf_filename}")
