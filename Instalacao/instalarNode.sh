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

# Criando diretório para Node
DIRECTORY="DockerfileNode"
if [ -d "$DIRECTORY" ]; then
  echo -e "${YELLOW}Diretório DockerfileNode já existe. Pulando criação.${NC}"
else
  echo -e "${YELLOW}Criando diretório de imagem Node...${NC}"
  mkdir DockerfileNode
  check_last_command
  echo -e "${GREEN}Diretório criado com sucesso!${NC}"
fi

echo -e "${YELLOW}Acessando diretório...${NC}"
cd DockerfileNode
check_last_command
echo -e "${GREEN}Diretório acessado${NC}"

# Clonando repositório
if [ -d "site-institucional" ]; then
  echo -e "${YELLOW}Repositório já clonado. Pulando...${NC}"
else
  echo -e "${YELLOW}Clonando repositório da aplicação...${NC}"
  git clone https://github.com/TechGuard-Solutions/site-institucional.git
  check_last_command
  echo -e "${GREEN}Repositório clonado com sucesso!${NC}"
fi

# Criando Dockerfile para Node
echo -e "${YELLOW}Criando Dockerfile com imagem Node...${NC}"
DOCKERFILE="Dockerfile"
cat <<EOF >$DOCKERFILE
FROM node:latest
WORKDIR /usr/src/app
COPY site-institucional/package*.json ./
RUN npm install
COPY site-institucional/ .
EXPOSE 8080
CMD ["npm", "start"]
EOF
check_last_command
echo -e "${GREEN}Dockerfile criado com sucesso!${NC}"

# Buildando imagem do Node
echo -e "${YELLOW}Buildando imagem...${NC}"
sudo docker build -t nodetechguard-img .
check_last_command
echo -e "${GREEN}Build concluído com sucesso!${NC}"

# Iniciando container Node
echo -e "${YELLOW}Iniciando container...${NC}"
sudo docker run -d --name TechGuardAPP --network techguard-network -p 8080:8080 nodetechguard-img
check_last_command
echo -e "${GREEN}Container Node iniciado com sucesso!${NC}"