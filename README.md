# Cloud Tasks API — Projeto Final de Computação em Nuvem

**Integrantes:** Guilherme Brasil · Gabriel Rodrigues · Gabriel Gonçalves

| Item | Onde |
|---|---|
| Aplicação na EC2 (enquanto o laboratório estiver ativo) | http://52.23.142.189/health · `/version` · `/tasks` |
| Imagens versionadas por SHA | GHCR: `ghcr.io/guilherme-brasil-cst/cloud-tasks-cicd:<sha-do-commit>` (aba *Packages*) |
| Relatório (diagrama, infraestrutura, evidências, custos) | [docs/RELATORIO.md](docs/RELATORIO.md) |
| Guia de configuração | [docs/CONFIGURACAO.md](docs/CONFIGURACAO.md) |

Aplicação Flask/SQLite preparada para um laboratório de **CI/CD com GitHub Actions, Docker, GHCR e AWS EC2**. A base contém código, testes e workflows; cabe ao grupo aprovisionar a nuvem, configurar segredos, usar branches/PRs, implementar uma evolução funcional e comprovar a esteira.

## Arquitetura
`Branch/PR -> CI (pytest + Docker build) -> merge main -> CI (publicação GHCR por SHA) -> CD (runner auto-hospedado na EC2 -> SSH -> docker pull/run) -> /health + /version`

O job de deploy roda em um **runner auto-hospedado instalado na própria EC2**, como usuário sem privilégios e com conexão apenas de saída para o GitHub. Assim **a porta 22 não é aberta para a internet** (nem para os IPs variáveis dos runners do GitHub). Um segundo job, em runner hospedado do GitHub, confere de fora que `/health` responde e que `/version` devolve exatamente o SHA implantado.

## Rodar localmente
```bash
python -m venv .venv
# Linux/macOS: source .venv/bin/activate  |  Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
python -m pytest -q
python -m flask --app app.main run --port 5000
```
Ou execute `docker compose up --build` e abra `http://localhost:8080/health`.

## API
| Método | Rota | Função |
|---|---|---|
| GET | `/` | Informações |
| GET | `/health` | Saúde da aplicação/banco |
| GET | `/tasks` | Lista tarefas |
| POST | `/tasks` | Cria tarefa (`{"title":"..."}`) |
| GET | `/tasks?done=true\|false` | Filtra tarefas por situação (**novo**) |
| PATCH | `/tasks/<id>` | Atualiza conclusão (`{"done":true}`) |
| DELETE | `/tasks/<id>` | Exclui: **204** se excluída, **404** se não existe (**novo**) |
| GET | `/version` | SHA do commit da imagem em execução (**novo**) |

Exemplos:
```bash
curl http://localhost:8080/health
curl -X POST http://localhost:8080/tasks -H 'Content-Type: application/json' -d '{"title":"Minha tarefa"}'
curl http://localhost:8080/tasks
curl 'http://localhost:8080/tasks?done=false'
curl -i -X DELETE http://localhost:8080/tasks/1
curl http://localhost:8080/version
```

## Configuração AWS + GitHub
Leia [docs/CONFIGURACAO.md](docs/CONFIGURACAO.md).

## Workflows
| Arquivo | Gatilho | O que faz |
|---|---|---|
| `.github/workflows/ci.yml` | PR e push na `main` | pytest + build Docker; **somente em push na `main`** publica `ghcr.io/<owner>/<repo>:<sha>` |
| `.github/workflows/cd.yml` | CI concluída com sucesso a partir de push na `main` | Deploy via SSH (runner na EC2) + checagem pública de `/health` e `/version` |
| `.github/workflows/persistence.yml` | Manual (*Run workflow*) | Cria tarefa, recria o contêiner e prova que o dado continua no volume |

## Configuração usada (Settings → Secrets and variables → Actions)
| Nome | Tipo | Conteúdo |
|---|---|---|
| `EC2_HOST` | Secret | IP privado da EC2 (o runner fica dentro da VPC) |
| `EC2_SSH_KEY` | Secret | Chave privada ed25519 dedicada ao deploy |
| `EC2_KNOWN_HOSTS` | Secret | Chave pública do host, lida do console da instância |
| `EC2_USER` | Variable | `ubuntu` |
| `PUBLIC_HOST` | Variable | IP elástico público, usado na checagem externa |

Nenhuma chave, token ou senha está versionada neste repositório.

## Infraestrutura
- `infra/provision.sh` — criação da EC2, Security Group e IP elástico (AWS CLI no CloudShell).
- `infra/user-data.sh` — bootstrap da instância (Docker, chave de deploy restrita, usuário do runner).
- `scripts/setup-runner-ec2.sh` — instalação do runner auto-hospedado (SHA-256 do pacote conferido).
- `infra/teardown.sh` — **encerramento**: remove instância, volume, IP elástico e Security Group.

## Segurança e limitações didáticas
O deploy é simplificado: não há TLS, balanceamento, rollback automatizado nem alta disponibilidade. Não colocar dados reais na API e não usar este modelo sem endurecimento em produção. SSH a partir de runner hospedado exige planejamento de rede seguro; veja o guia. `docker` group equivale a privilégios elevados na EC2.
