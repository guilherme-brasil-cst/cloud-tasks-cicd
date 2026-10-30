#!/bin/bash
# Cloud Tasks API - bootstrap da instancia (Ubuntu 24.04)
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io curl jq
systemctl enable --now docker
usermod -aG docker ubuntu
# Chave de deploy (somente comando, sem pty/forwarding)
install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ssh
echo 'restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP621AIREQdUIHGU8wLhufeHizDiFd41kxoMVcTcfe8M gha-deploy@cloud-tasks' >> /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
# Usuario sem privilegios para o runner self-hosted (fora do grupo docker e sem sudo)
id ghrunner || useradd --create-home --shell /bin/bash ghrunner
# SSH somente por chave
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' > /etc/ssh/sshd_config.d/99-hardening.conf
systemctl reload ssh || true
