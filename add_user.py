##Inserir novo usuário em switches cisco
##CRIE UM ARQUIVO .TXT PARA SERVIR DE INGESTION
import subprocess

HOSTS_FILE = "hosts.txt"

SSH_USER = "INSIRA SEU USUARIO"
SSH_PASS = "INSIRA SUA SENHA"

NEW_USER = "INSIRA LOGIN DO NOVO USUARIO"
NEW_PASS = "INSIRA SENHA DO NOVO USUARIO"
PRIV = "1"

def configure_host(ip):
    print(f"\n🔹 Conectando em {ip}...")

    # Comandos Cisco como uma única sequência
    cmd = (
        f"terminal length 0 ; "
        f"conf t ; "
        f"username {NEW_USER} privilege {PRIV} secret {NEW_PASS} ; "
        f"end ; "
        f"write memory"
    )

    ssh_cmd = [
        "sshpass", "-p", SSH_PASS,
        "ssh",
        "-oStrictHostKeyChecking=no",
        "-oUserKnownHostsFile=/dev/null",
        "-oKexAlgorithms=+diffie-hellman-group14-sha1",
        "-oHostKeyAlgorithms=+ssh-rsa",
        f"{SSH_USER}@{ip}",
        cmd
    ]

    try:
        result = subprocess.run(
            ssh_cmd,
            capture_output=True,
            text=True,
            timeout=25
        )

        print("📤 OUTPUT:")
        print(result.stdout)

        if result.returncode == 0:
            print(f"✅ SUCESSO em {ip}")
        else:
            print(f"❌ FALHA em {ip}")

    except Exception as e:
        print(f"❌ ERRO em {ip}: {e}")

def main():
    print("\n=== ADICIONAR USUÁRIO READ-ONLY EM SWITCHES CISCO ===")

    with open(HOSTS_FILE, "r") as f:
        hosts = [line.strip() for line in f if line.strip()]

    print(f"\n📌 {len(hosts)} hosts carregados.")

    for ip in hosts:
        configure_host(ip)

    print("\n✅ FINALIZADO ✅\n")

if __name__ == "__main__":
    main()
