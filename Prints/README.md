# Prints da configuração na AWS

Capturas da infraestrutura de rede e computação do projeto (região us-east-1), feitas no Console da AWS e no AWS CloudShell. O ID da conta foi ocultado.

| Arquivo | O que mostra |
|---|---|
| [01-console-instancia-lista.png](01-console-instancia-lista.png) | Instância `cloud-tasks-api` (t3.micro) em execução, 3/3 verificações de status, IP elástico 52.23.142.189 |
| [02-console-instancia-resumo.png](02-console-instancia-resumo.png) | Resumo da instância: IP público/privado, VPC, sub-rede, função IAM (LabRole) e IMDSv2 obrigatório |
| [03-console-sg-regras-entrada.png](03-console-sg-regras-entrada.png) | Security Group `cloud-tasks-sg`: única regra de entrada, HTTP TCP/80 |
| [04-console-sg-regras-saida.png](04-console-sg-regras-saida.png) | Security Group `cloud-tasks-sg`: regra de saída (todo o tráfego) |
| [05-console-ip-elastico.png](05-console-ip-elastico.png) | IP elástico alocado e associado à instância |
| [06-cli-instancia.png](06-cli-instancia.png) | Configuração da instância via AWS CLI: AMI Ubuntu 24.04, zona, VPC, sub-rede, IPs, IMDSv2 e ausência de par de chaves |
| [07-cli-security-group.png](07-cli-security-group.png) | Regras de entrada e saída via AWS CLI, com a confirmação de **0 regras para a porta 22** |
| [08-cli-vpc-subrede-rotas.png](08-cli-vpc-subrede-rotas.png) | VPC (172.31.0.0/16), sub-rede pública (172.31.16.0/20), tabela de rotas (rota 0.0.0.0/0 para o Internet Gateway) |
| [09-cli-ip-elastico-interface.png](09-cli-ip-elastico-interface.png) | IP elástico e interface de rede (ENI) da instância com o Security Group aplicado |
| [10-cli-disco-ebs.png](10-cli-disco-ebs.png) | Volume EBS gp3 de 8 GiB, criptografado e excluído junto com a instância |
| [11-cli-ssm-e-teste-api.png](11-cli-ssm-e-teste-api.png) | Instância gerenciada pelo AWS Systems Manager (administração sem SSH) e API respondendo na porta 80 (`/health`, `/version`, `/tasks`) |
| [12-github-runner-auto-hospedado.png](12-github-runner-auto-hospedado.png) | Runner auto-hospedado `ec2-cloud-tasks` (label `ec2-deploy`) conectado ao GitHub, usado pelo CD sem abrir a porta 22 |
