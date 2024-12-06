a#!/bin/bash

LOG_DIR="/home/ubuntu/logs/logsJava"
LOG_FILE="$LOG_DIR/log_java_$(date +%d-%m-%Y_%H-%M-%S).log"

S3_BUCKET="bucket-base-de-dados"

# Verifica se o diretório de logs existe; caso contrário, cria-o.
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

# Inicia a gravação das informações no arquivo de log.
{
  echo "======================"
  echo "Log gerado em: $(date)"
  echo "======================"

  echo "Uptime:"
  uptime

  echo "Logs do Docker (TechGuardJAVA):"
  sudo docker logs TechGuardJAVA 2>&1  # Redireciona a saída e erros do Docker para o log.

  echo "======================"
  echo "Log concluído."
} >> "$LOG_FILE" 2>&1  # Redireciona tanto a saída padrão quanto os erros para o arquivo de log.

# Envia o arquivo de log para o bucket S3.
echo "Enviando log para o S3: $S3_BUCKET"
aws s3 cp "$LOG_FILE" s3://$S3_BUCKET/logs/logsJava/ >> "$LOG_FILE" 2>&1

# Verifica se o upload foi bem-sucedido e registra no log.
if [ $? -eq 0 ]; then
  echo "Log enviado com sucesso para o S3." >> "$LOG_FILE" 2>&1
else
  echo "Falha ao enviar log para o S3." >> "$LOG_FILE" 2>&1
fi
