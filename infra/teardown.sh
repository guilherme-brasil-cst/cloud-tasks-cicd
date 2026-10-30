#!/usr/bin/env bash
# Encerramento: remove TODOS os recursos criados (evita custo de EC2, EBS e Elastic IP).
# Executar no AWS CloudShell apos a apresentacao. Remova tambem o runner em
# GitHub > Settings > Actions > Runners.
set -euo pipefail
export AWS_DEFAULT_REGION=us-east-1
IID=$(aws ec2 describe-instances --filters Name=tag:Name,Values=cloud-tasks-api Name=instance-state-name,Values=pending,running,stopping,stopped \
  --query 'Reservations[].Instances[].InstanceId' --output text)
for A in $(aws ec2 describe-addresses --filters Name=instance-id,Values=$IID --query 'Addresses[].AllocationId' --output text); do
  aws ec2 disassociate-address --association-id "$(aws ec2 describe-addresses --allocation-ids "$A" --query 'Addresses[0].AssociationId' --output text)"
  aws ec2 release-address --allocation-id "$A"
done
aws ec2 terminate-instances --instance-ids $IID >/dev/null
aws ec2 wait instance-terminated --instance-ids $IID
aws ec2 delete-security-group --group-id "$(aws ec2 describe-security-groups --filters Name=group-name,Values=cloud-tasks-sg --query 'SecurityGroups[0].GroupId' --output text)"
echo "Recursos removidos. Volumes restantes do projeto:"
aws ec2 describe-volumes --filters Name=tag:Project,Values=cc-cicd --query 'Volumes[].VolumeId' --output text
