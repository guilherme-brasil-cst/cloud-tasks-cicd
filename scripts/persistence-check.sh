#!/usr/bin/env bash
# Prova de persistencia: cria uma tarefa, RECRIA o conteiner (docker rm -f + docker run
# com a mesma imagem e o mesmo volume) e confirma que a tarefa continua la.
set -euo pipefail
NAME=cloud-tasks-api
IMAGE=$(docker inspect -f '{{.Config.Image}}' "$NAME")
OLD_ID=$(docker inspect -f '{{.Id}}' "$NAME")
TITLE="persistencia-$(date -u +%Y%m%dT%H%M%SZ)"
echo "Imagem em execucao: $IMAGE"
curl --fail --silent --show-error -X POST http://127.0.0.1/tasks \
  -H 'Content-Type: application/json' -d "{\"title\":\"${TITLE}\"}"
echo
echo "--- Recriando o conteiner ---"
docker rm -f "$NAME" >/dev/null
docker run -d --name "$NAME" --restart unless-stopped -p 80:8000 -v cloud-tasks-data:/data \
  -e DB_PATH=/data/tasks.db "$IMAGE" >/dev/null
for i in $(seq 1 20); do
  curl --fail --silent http://127.0.0.1/health >/dev/null && break
  sleep 2
done
NEW_ID=$(docker inspect -f '{{.Id}}' "$NAME")
echo "Conteiner antigo: ${OLD_ID:0:12} | novo: ${NEW_ID:0:12}"
test "$OLD_ID" != "$NEW_ID"
echo "--- Tarefas apos recriacao ---"
curl --fail --silent --show-error http://127.0.0.1/tasks | tee /tmp/tasks.json
echo
grep -q "\"${TITLE}\"" /tmp/tasks.json && echo "OK: dados persistiram no volume cloud-tasks-data"
