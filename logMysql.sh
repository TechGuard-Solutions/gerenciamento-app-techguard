#!/bin/bash

LOG_DIR="/var/log/myapp"
LOG_FILE="$LOG_DIR/logs/logs_DB_$(date +%d%m%Y_%H%M%S).log"

S3_BUCKET="techguard-bucket"

if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

echo "======================" >> "$LOG_FILE"
echo "Log gerado em: $(date)" >> "$LOG_FILE"
echo "======================" >> "$LOG_FILE"

echo "Uptime:" >> "$LOG_FILE"
uptime >> "$LOG_FILE"

sudo docker logs TechGuardDB

echo "======================" >> "$LOG_FILE"
echo "Log concluído." >> "$LOG_FILE"

echo "Enviando log para o S3: $S3_BUCKET"
aws s3 cp "$LOG_FILE" s3://$S3_BUCKET/logs/logDB

if [ $? -eq 0 ]; then
  echo "Log enviado com sucesso para o S3."
else
  echo "Falha ao enviar log para o S3."
fi