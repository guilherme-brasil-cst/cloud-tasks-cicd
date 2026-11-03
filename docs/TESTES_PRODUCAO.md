# Testes manuais em produção

**Data:** 03/11/2026 (horário de Brasília).
**Responsável:** Gabriel Rodrigues (`Gaba061`).
**Ambiente:** http://52.23.142.189, HTTP na porta 80.
**Versão observada:** `67daa815ca33158b9b282d283afac8847b17deee`.

## Resultados

As requisições foram executadas contra a API publicada. Os corpos de POST e PATCH foram enviados com `Content-Type: application/json`. A tarefa criada para o teste recebeu o ID `3`; somente essa tarefa foi alterada e removida.

| Requisição | Esperado | Obtido | OK? |
|---|---|---|---|
| `GET /health` | 200 e status ok | 200; `{"status":"ok"}` | Sim |
| `GET /version` | 200 e SHA da imagem publicada | 200; versão `67daa815ca33158b9b282d283afac8847b17deee` | Sim |
| `GET /tasks` | 200 e lista de tarefas | 200; duas tarefas de persistência, IDs 1 e 2 | Sim |
| `POST /tasks` com `{"title":"Teste Rodrigues"}` | 201 e nova tarefa não concluída | 201; `{"done":false,"id":3,"title":"Teste Rodrigues"}` | Sim |
| `PATCH /tasks/3` com `{"done":true}` | 200 e tarefa concluída | 200; `{"done":true,"id":3}` | Sim |
| `GET /tasks?done=true` | 200 e somente tarefas concluídas | 200; tarefa 3 presente com `done=true` | Sim |
| `GET /tasks?done=false` | 200 e somente tarefas pendentes | 200; IDs 1 e 2 com `done=false`; tarefa 3 ausente | Sim |
| `DELETE /tasks/3` | 204, sem corpo | 204, corpo vazio | Sim |
| `DELETE /tasks/3` novamente | 404 | 404; `{"error":"tarefa nao encontrada"}` | Sim |
| `POST /tasks` com `{"title":"   "}` | 400 | 400; `{"error":"title deve ser texto nao vazio"}` | Sim |

A tarefa de teste foi removida. As tarefas previamente existentes não foram alteradas.

## Prova de persistência

- Workflow: **Prova de persistencia (manual)**, branch `main`.
- Execução: [run 41689996769](https://github.com/guilherme-brasil-cst/cloud-tasks-cicd/actions/runs/41689996769).
- Disparado por: `Gaba061`, em 03/11/2026 às 15:02 BRT.
- Resultado: **Success**, duração total de 22 segundos.
- Imagem: `ghcr.io/guilherme-brasil-cst/cloud-tasks-cicd:67daa815ca33158b9b282d283afac8847b17deee`.

O log registra a criação da tarefa `persistencia-20261103T180256Z` (ID 2), a recriação do contêiner e a presença dessa mesma tarefa após a recriação. Os identificadores dos contêineres mudaram, enquanto os dados permaneceram no volume `cloud-tasks-data`:

```text
{"done":false,"id":2,"title":"persistencia-20261103T180256Z"}
--- Recriando o conteiner ---
Conteiner antigo: 04fc000b4011 | novo: 44ea81b82a3e
--- Tarefas apos recriacao ---
OK: dados persistiram no volume cloud-tasks-data
```

A listagem após a recriação continha a tarefa ID 2, comprovando a persistência. O run também registra um aviso de depreciação do Node.js 20 em `actions/checkout@v4`; esse aviso não impediu a conclusão.
