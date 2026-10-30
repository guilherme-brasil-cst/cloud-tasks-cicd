#!/usr/bin/env bash
# Instala o GitHub Actions runner auto-hospedado na EC2 como usuario SEM privilegios
# (ghrunner: fora do grupo docker e sem sudo). Executar como root (ex.: via SSM).
# Uso: setup-runner-ec2.sh <URL_DO_REPOSITORIO> <TOKEN_DE_REGISTRO>
# O token de registro vem de Settings > Actions > Runners > New self-hosted runner,
# expira em 1 hora e serve apenas para registrar o runner. Nao versionar.
set -euo pipefail
URL="${1:?URL do repositorio}"; TOKEN="${2:?token de registro}"
RUNNER_USER=ghrunner
id "$RUNNER_USER" >/dev/null 2>&1 || useradd --create-home --shell /bin/bash "$RUNNER_USER"
DIR=/home/$RUNNER_USER/actions-runner
REL=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest)
V=$(jq -r .tag_name <<<"$REL" | sed 's/^v//')
SHA=$(jq -r .body <<<"$REL" | sed -n 's/.*BEGIN SHA linux-x64 -->\([0-9a-f]\{64\}\)<!-- END SHA linux-x64.*/\1/p')
F=actions-runner-linux-x64-$V.tar.gz
install -d -o "$RUNNER_USER" -g "$RUNNER_USER" "$DIR"
cd "$DIR"
sudo -u "$RUNNER_USER" curl -fsSLo "$F" "https://github.com/actions/runner/releases/download/v$V/$F"
# Integridade do pacote conferida contra o SHA-256 publicado na release oficial.
test -n "$SHA" && echo "$SHA  $F" | sha256sum -c -
sudo -u "$RUNNER_USER" tar xzf "$F" && rm -f "$F"
./bin/installdependencies.sh >/dev/null
sudo -u "$RUNNER_USER" ./config.sh --unattended --replace --url "$URL" --token "$TOKEN" \
  --name ec2-cloud-tasks --labels ec2-deploy --work _work
./svc.sh install "$RUNNER_USER"
./svc.sh start
./svc.sh status | head -5
