# Apresentação e encerramento do projeto

## Roteiro do vídeo (3–5 min)

| Tempo aproximado | Ação e evidência na tela |
|---|---|
| 0:00–0:45 | Apresentar a API de tarefas e abrir um PR para main. Mostrar as alterações e o CI verde antes do merge. |
| 0:45–1:15 | Realizar o merge durante a apresentação, após as revisões necessárias. Identificar o novo SHA da main. |
| 1:15–2:15 | Abrir a aba Actions e mostrar o CI da main e, após seu sucesso, o CD em execução. Mostrar a conclusão dos jobs de deploy e verificação pública. |
| 2:15–2:45 | Abrir http://52.23.142.189/version e comparar o campo version com o SHA da execução que originou o deploy. |
| 2:45–4:15 | Abrir http://52.23.142.189/tasks e mostrar a prova de persistência descrita em docs/TESTES_PRODUCAO.md: tarefa antes e depois da recriação do contêiner, IDs diferentes dos contêineres e confirmação de que os dados permaneceram no volume. |
| 4:15–5:00 | Recapitular as evidências de CI/CD e persistência e apresentar o checklist de encerramento abaixo. |

Preparar as abas e o terminal antes da gravação. Se as execuções excederem o tempo do vídeo, usar cortes entre as etapas, mantendo visíveis a identificação das execuções e o SHA implantado.

## Checklist de encerramento

Executar após a apresentação e o registro das evidências.

- [ ] Abrir o AWS CloudShell na conta do projeto e acessar a raiz do repositório.
- [ ] Executar `bash infra/teardown.sh` e conferir a saída e eventuais erros. O script usa a região us-east-1.
- [ ] Remover o runner do repositório em Settings → Actions → Runners.
- [ ] No console EC2, na região us-east-1, confirmar que a instância do projeto está encerrada (terminated) e que não há outra instância do projeto ativa ou parada.
- [ ] Conferir Volumes e confirmar que não restou volume EBS do projeto, inclusive os identificados pela tag Project=cc-cicd. O script lista volumes restantes; essa listagem deve ser conferida.
- [ ] Conferir Elastic IPs e confirmar que o IP elástico do projeto foi liberado.
- [ ] Conferir Security Groups e confirmar que o grupo cloud-tasks-sg foi removido.
- [ ] Registrar as evidências do encerramento. Se algum recurso do projeto permanecer, resolver a pendência e repetir a conferência antes de considerar o encerramento concluído.
