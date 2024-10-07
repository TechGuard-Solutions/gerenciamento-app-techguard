#!/bin/bash

# Definição de cores
GREEN='\033[0;32m'  # Cor verde
RED='\033[0;31m'    # Cor vermelha
YELLOW='\033[1;33m' # Cor amarela
NC='\033[0m'        # Sem cor (para resetar)

# Função para verificar o sucesso da última operação
check_last_command() {
  if [ $? -ne 0 ]; then
    echo -e "${RED}Erro durante a execução do último comando. Saindo...${NC}"
    exit 1
  fi
}

echo -e "${YELLOW}Atualizando sistema...${NC}"
sudo apt update && sudo apt upgrade -y
check_last_command
echo -e "${GREEN}Sistema atualizado!${NC}"

# Verificando instalação do Git
echo -e "${YELLOW}Verificando instalação do Git...${NC}"
git --version
if [ $? = 0 ]; then
  echo -e "${GREEN}Git instalado!${NC}"
else
  echo -e "${RED}Git não está instalado. Instalando...${NC}"
  sudo apt install git -y
  check_last_command
  echo -e "${GREEN}Git instalado com sucesso!${NC}"
fi

# Verificando instalação do Docker
echo -e "${YELLOW}Verificando instalação do Docker...${NC}"
docker --version
if [ $? = 0 ]; then
  echo -e "${GREEN}Docker instalado!${NC}"
else
  echo -e "${RED}Docker não instalado${NC}"
  echo -e "${YELLOW}Instalar o Docker?${NC}${RED}Caso não instale a aplicação não irá funcionar!!${NC}[y/n]"
  read get
  if [ "$get" == "y" ]; then
    sudo apt install docker.io -y
    check_last_command
    echo -e "${GREEN}Docker instalado com sucesso!${NC}"
  else
    echo -e "${RED}Docker é necessário para continuar. Saindo...${NC}"
    exit 1
  fi
fi

# Verificando instalação do curl
echo -e "${YELLOW}Verificando instalação do curl...${NC}"
curl --version
if [ $? = 0 ]; then
  echo -e "${GREEN}curl instalado!${NC}"
else
  echo -e "${RED}curl não está instalado. Instalando...${NC}"
  sudo apt install curl -y
  check_last_command
  echo -e "${GREEN}curl instalado com sucesso!${NC}"
fi

# Verificando instalação do unzip
echo -e "${YELLOW}Verificando instalação do unzip...${NC}"
unzip -v
if [ $? = 0 ]; then
  echo -e "${GREEN}unzip instalado!${NC}"
else
  echo -e "${RED}unzip não está instalado. Instalando...${NC}"
  sudo apt install unzip -y
  check_last_command
  echo -e "${GREEN}unzip instalado com sucesso!${NC}"
fi

# Verificando instalação do AWS CLI
echo -e "${YELLOW}Verificando instalação do AWS CLI...${NC}"
if ! command -v aws &> /dev/null; then
  echo -e "${RED}AWS CLI não encontrado. Iniciando instalação...${NC}"
  
  # Baixar o instalador do AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  check_last_command
  
  # Descompactar o arquivo
  unzip awscliv2.zip
  check_last_command
  
  # Executar a instalação
  sudo ./aws/install
  check_last_command
  
  # Remover arquivos temporários
  rm -rf awscliv2.zip aws
  echo -e "${GREEN}AWS CLI instalado com sucesso e arquivos temporários removidos!${NC}"
else
  echo -e "${GREEN}AWS CLI já está instalado!${NC}"
fi

# Criando Network Docker
sudo docker network create techguard-network
check_last_command

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

cd ..

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

cd ..

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

# Buildando imagem do JAVA
echo -e "${YELLOW}Buildando imagem...${NC}"
sudo docker build -t javatechguard-img .
check_last_command
echo -e "${GREEN}Build concluído com sucesso!${NC}"

# Iniciando container JAVA
echo -e "${YELLOW}Iniciando container...${NC}"
sudo docker run -d --name TechGuardJAVA --network techguard-network -p 3030:3030 javatechguard-img
check_last_command
echo -e "${GREEN}Container JAVA iniciado com sucesso!${NC}"

echo -e "${YELLOW}Garantindo inicialização dos contêiners...${NC}"
sudo docker start TechGuardDB
sudo docker start TechGuardAPP
sudo docker start TechGuardJAVA

cd ..

mkdir logs
cd logs
mkdir logsSistema
mkdir logsNode
mkdir logsJava
mkdir logsMysql
echo -e "${GREEN}Instalação finalizada!${NC}"