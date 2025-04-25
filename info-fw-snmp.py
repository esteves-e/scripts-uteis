from pysnmp.hlapi import *
from pysnmp.hlapi import usmHMAC192SHA256AuthProtocol, usmAesCfb128Protocol  

# Lista de IPs dos firewalls
FIREWALLS = [
    "0.0.0.0", "1.1.1.1" 
]

# Configuração SNMP
USER = "ENV_USER"
AUTH_PASS = "ENV_AUTH_PASS"
PRIV_PASS = "ENV_PRIV_PASS"

# OID para verificar se o firewall responde (Irá retornar o nome do fw)
OID_FW_NAME = "1.3.6.1.2.1.1.5.0"  

# Função para verificar se o firewall está online e obter seu nome
def get_firewall_status(target, user, auth_pass, priv_pass):
    for (errorIndication, errorStatus, errorIndex, varBinds) in getCmd(
            SnmpEngine(),
            UsmUserData(user, auth_pass, priv_pass, 
                        authProtocol=usmHMAC192SHA256AuthProtocol,  
                        privProtocol=usmAesCfb128Protocol),  
            UdpTransportTarget((target, 161), timeout=2, retries=1),
            ContextData(),
            ObjectType(ObjectIdentity(OID_FW_NAME))):

        if errorIndication or errorStatus:
            return False, None
        
        for varBind in varBinds:
            return True, varBind[1].prettyPrint()

online_firewalls = []
offline_firewalls = []

for fw in FIREWALLS:
    status, name = get_firewall_status(fw, USER, AUTH_PASS, PRIV_PASS)
    if status:
        online_firewalls.append((fw, name))
    else:
        offline_firewalls.append(fw)

print("\n Firewalls Online ")
for fw, name in online_firewalls:
    print(f"{fw} - {name} ")

print("\n Firewalls Offline ")
for fw in offline_firewalls:
    print(f"{fw} ")
