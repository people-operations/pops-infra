# pops-infra
Repositório contendo códigos de infraestrutura como código (IaC) para o projeto Pops.

### Estrutura de pastas
```
pops-infra/
├── database/
│ ├── inserts.sql
│ ├── Modelagem Poc Automação V2.png
│ └── script.sql
├── terraform/
│ ├── keys/
│ │ └── keys.ps1
│ ├── modules/
│ │ ├── compute/
│ │ ├── ec2/
│ │ │  ├── ec2.tf
│ │ │  └── variables.tf
│ │ ├── lambda/
│ │ │  ├── lambda.tf
│ │ │  └── variables.tf
│ │ ├── network/
│ │ │  ├── acl.tf
│ │ │  ├── igw.tf
│ │ │  ├── nat.tf
│ │ │  ├── outputs.tf
│ │ │  ├── sg.tf
│ │ │  ├── subnet.tf
│ │ │  └── vpc.tf
│ │ ├── storage/
│ │ │  ├── outputs.tf
│ │ │  ├── s3.tf
│ │ │  ├── sns.tf
│ │ │  └── variables.tf
│ ├── main.tf
│ └── variables.tf
├── .gitignore
├── public.sh
├── private.sh
├── README.md
```
### Itens que devem ser configurados para o funcionamento do projeto
- No diretorio `terraform/keys/` do script `keys.ps1` deve ser executado para a criação de chaves pem para AWS.
- Deve ser criado um arquivo chamado terraform.tfvars na raiz do projeto com as seguintes variáveis:
```
path_to_private_script
path_to_public_script
path_to_database_script
path_to_popsToRaw_script
path_to_popsToRawLote_script
path_to_popsEtl_script
path_to_popsSegregation_script
path_to_popsNotification_script
```
* Seguir o arquivo `terraform.tfvars.example` como exemplo.
- Atualizar o arquivo `.aws/credentials` com as credenciais da AWS toda vez que um laboratório novo for iniciado.'

### Executando o projeto
Para executar o projeto, siga os seguintes passos:
1. Navegue até o diretório `terraform/`.
2. Execute o comando `terraform init` para inicializar o Terraform.
3. Execute o comando `terraform plan` para visualizar as mudanças que serão aplicadas.
4. Execute o comando `terraform apply` para aplicar as mudanças e criar os recursos na AWS.
5. Ao final do processo, o Terraform irá gerar um arquivo `terraform.tfstate` que contém o estado atual da infraestrutura provisionada.
6. Para destruir os recursos criados, execute o comando `terraform destroy`.
