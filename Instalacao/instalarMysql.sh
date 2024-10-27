#!/bin/bash

# Definição de cores
GREEN='\033[0;32m'  # Cor verde
RED='\033[0;31m'    # Cor vermelha
YELLOW='\033[1;33m' # Cor amarela
NC='\033[0m'        # Sem cor (para resetar)

# Função para verificar o sucesso da última operação
check_last_command() {
  if [ $? -ne 0 ]; then
    echo -e "${RED}Erro durante a execução do último comando.${NC}"
    exit 1
  fi
}

# Criando diretório para MySQL
DIRECTORY="DockerfileMysql"
if [ -d "$DIRECTORY" ]; then
  echo -e "${YELLOW}Diretório DockerfileMysql já existe. Pulando criação.${NC}"
else
  echo -e "${YELLOW}Criando diretório de imagem MySQL...${NC}"
  mkdir DockerfileMysql
  check_last_command
  echo -e "${GREEN}Diretório criado com sucesso!${NC}"
fi

echo -e "${YELLOW}Acessando diretório...${NC}"
cd DockerfileMysql
mkdir database
check_last_command
echo -e "${GREEN}Diretório acessado${NC}"

echo -e "${YELLOW}Copiando arquivo .sql...${NC}"
cp ../DockerfileNode/site-institucional/src/database/script-tabelas.sql ../DockerfileMysql/database/
check_last_command
echo -e "${GREEN}Arquivo copiado com sucesso!${NC}"

# Criando Dockerfile para MySQL
echo -e "${YELLOW}Criando Dockerfile com imagem MySQL...${NC}"
DOCKERFILE="Dockerfile"
cat <<EOF >$DOCKERFILE
FROM mysql:latest
ENV MYSQL_ROOT_PASSWORD=solutions
COPY ./database/ /docker-entrypoint-initdb.d/
EXPOSE 3306
EOF
check_last_command
echo -e "${GREEN}Dockerfile criado com sucesso!${NC}"

# Buildando imagem do MySQL
echo -e "${YELLOW}Buildando imagem...${NC}"
sudo docker build -t mysqltechguard-img .
check_last_command
echo -e "${GREEN}Build concluído com sucesso!${NC}"

# Iniciando container MySQL
echo -e "${YELLOW}Iniciando container...${NC}"
sudo docker run -d --name TechGuardDB --network techguard-network -p 3306:3306 mysqltechguard-img
check_last_command
echo -e "${GREEN}Container MySQL iniciado com sucesso!${NC}"