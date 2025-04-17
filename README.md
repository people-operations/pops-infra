# pops-infra
Repositório contendo códigos de infraestrutura como código (IaC) para o projeto Pops.

### Estrutura de pastas
```
pops-infra/
├── database/
│   ├── inserts.sql
│   ├── Modelagem Poc Automação V2.png
│   └── script.sql
├── terraform/
│   ├── acl.tf
│   ├── ec2.tf
│   ├── igw.tf
│   ├── main.tf
│   ├── nat.tf
│   ├── rt.tf
│   ├── s3.tf
│   ├── sg.tf
│   ├── subnet.tf
│   ├── var.tf
│   └── vpc.tf
├── .gitignore
├── license.txt
├── private.sh
├── public.sh
└── README.md
```
### Itens que devem ser configurados para o funcionamento do projeto
- Criação do diretório 'keys' no disco local C://
- Criação de chaves "key-ec2-public-pops.pem" e "key-ec2-private-pops.pem" SSH para acesso ao servidor EC2 dentro da AWS
- As chaves criadas devem ser armazenadas no diretórios 'keys'
- Intalação e configuração do terraform versão 1.11.1 ou superior