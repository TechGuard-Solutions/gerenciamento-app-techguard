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
    # exit 1
  fi
}

# Criando diretório para JAVA
DIRECTORY="DockerfileJava"
if [ -d "$DIRECTORY" ]; then
  echo -e "${YELLOW}Diretório DockerfileJava já existe. Pulando criação.${NC}"
else
  echo -e "${YELLOW}Criando diretório de imagem Java...${NC}"
  mkdir DockerfileJava
  check_last_command
  echo -e "${GREEN}Diretório criado com sucesso!${NC}"
fi

echo -e "${YELLOW}Acessando diretório...${NC}"
cd DockerfileJava
git clone https://github.com/TechGuard-Solutions/conexao-java.git
check_last_command
echo -e "${GREEN}Diretório acessado${NC}"

# Buildando o projeto com Maven
echo -e "${YELLOW}Buildando o projeto com Maven...${NC}"
mvn clean package
check_last_command
echo -e "${GREEN}Build do projeto concluído!${NC}"

# Criando Dockerfile para JAVA
echo -e "${YELLOW}Criando Dockerfile com imagem JAVA...${NC}"
DOCKERFILE="Dockerfile"
cat <<EOF >$DOCKERFILE
FROM openjdk:21
WORKDIR /usr/src/app
COPY conexao-java/ /usr/src/app/
EXPOSE 3030
CMD ["java", "-jar", "target/iniciar.jar"]
EOF
check_last_command
echo -e "${GREEN}Dockerfile criado com sucesso!${NC}"

# # Buildando imagem do JAVA
echo -e "${YELLOW}Buildando imagem...${NC}"
sudo docker build -t javatechguard-img .
check_last_command
echo -e "${GREEN}Build concluído com sucesso!${NC}"

# # Iniciando container JAVA
echo -e "${YELLOW}Iniciando container...${NC}"
sudo docker run -d --name TechGuardJAVA --network techguard-network -p 3030:3030 javatechguard-img
check_last_command
echo -e "${GREEN}Container JAVA iniciado com sucesso!${NC}"

sudo docker start TechGuardJAVA