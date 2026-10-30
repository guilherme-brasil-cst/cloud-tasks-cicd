#!/usr/bin/env bash
# Provisionamento usado no AWS Academy Learner Lab (executado no AWS CloudShell, us-east-1).
# Cria: Security Group (apenas HTTP 80 de entrada), instancia Ubuntu 24.04 t3.micro com
# IMDSv2 obrigatorio, EBS gp3 criptografado, perfil LabInstanceProfile (SSM) e Elastic IP.
set -euo pipefail
export AWS_DEFAULT_REGION=us-east-1
VPC=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
SG=$(aws ec2 create-security-group --group-name cloud-tasks-sg \
  --description "Cloud Tasks API: HTTP 80 publico; sem SSH de entrada" --vpc-id "$VPC" \
  --tag-specifications 'ResourceType=security-group,Tags=[{Key=Project,Value=cc-cicd}]' \
  --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id "$SG" --ip-permissions \
  'IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=0.0.0.0/0,Description=HTTP-API-publica}]'
AMI=$(aws ssm get-parameter --name /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id \
  --query Parameter.Value --output text)
IID=$(aws ec2 run-instances --image-id "$AMI" --instance-type t3.micro --security-group-ids "$SG" \
  --iam-instance-profile Name=LabInstanceProfile \
  --metadata-options HttpTokens=required,HttpEndpoint=enabled \
  --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=8,VolumeType=gp3,Encrypted=true,DeleteOnTermination=true}' \
  --user-data file://infra/user-data.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cloud-tasks-api},{Key=Project,Value=cc-cicd}]' \
  --query 'Instances[0].InstanceId' --output text)
aws ec2 wait instance-running --instance-ids "$IID"
ALLOC=$(aws ec2 allocate-address --domain vpc --query AllocationId --output text)
aws ec2 associate-address --instance-id "$IID" --allocation-id "$ALLOC"
# known_hosts confiavel: chave do host lida do console da instancia (API da AWS),
# e nao de um ssh-keyscan pela rede.
PRIV=$(aws ec2 describe-instances --instance-ids "$IID" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
aws ec2 get-console-output --instance-id "$IID" --latest --output text \
  | sed -n '/BEGIN SSH HOST KEY KEYS/,/END SSH HOST KEY KEYS/p' | grep '^ssh-ed25519' \
  | awk -v h="$PRIV" '{print h, $1, $2}'
