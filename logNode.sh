#!/bin/bash

LOG_DIR="/home/ubuntu/logs/logsNode"
LOG_FILE="$LOG_DIR/logs_node_$(date +%d-%m-%Y_%H-%M-%S).log"

S3_BUCKET="bucket-base-de-dados"

# Verifica se o diretório de logs existe, caso contrário, cria
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

# Escreve o cabeçalho do log com data e hora
echo "======================" >> "$LOG_FILE"
echo "Log gerado em: $(date)" >> "$LOG_FILE"
echo "======================" >> "$LOG_FILE"

# Adiciona o uptime do sistema ao log
echo "Uptime:" >> "$LOG_FILE"
uptime >> "$LOG_FILE"

# Captura os logs do container Docker e adiciona ao arquivo de log
echo "Logs do container TechGuardAPP:" >> "$LOG_FILE"
sudo docker logs TechGuardAPP >> "$LOG_FILE" 2>&1

# Envia o arquivo de log para o bucket S3
echo "Enviando log para o S3: $S3_BUCKET"
aws s3 cp "$LOG_FILE" s3://$S3_BUCKET/logs/logsNode/

# Verifica se o upload foi bem-sucedido
if [ $? -eq 0 ]; then
  echo "Log enviado com sucesso para o S3."
else
  echo "Falha ao enviar log para o S3."
fi
