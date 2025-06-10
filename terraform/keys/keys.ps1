# Cria o diretório se não existir
$keysPath = "terraform/keys"
if (-not (Test-Path $keysPath)) {
    New-Item -ItemType Directory -Path $keysPath
}

# Gera chave privada e pública para key-ec2-public-pops
ssh-keygen -t rsa -b 2048 -m PEM -f "$keysPath/key-ec2-public-pops.pem" -N ""

# Gera chave privada e pública para key-ec2-private-pops
ssh-keygen -t rsa -b 2048 -m PEM -f "$keysPath/key-ec2-private-pops.pem" -N ""
