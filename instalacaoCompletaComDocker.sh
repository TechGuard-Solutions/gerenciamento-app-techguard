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

echo -e "${YELLOW}Atualizando sistema...${NC}"
sudo apt update && sudo apt upgrade -y
apt list --upgradable
check_last_command
echo -e "${GREEN}Sistema atualizado!${NC}"

echo -e "${YELLOW}Configurando DPKG...${NC}"
sudo dpkg --configure -a
check_last_command

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

# Verificando instalação do Maven
echo -e "${YELLOW}Verificando instalação do Maven...${NC}"
mvn -v
if [ $? = 0 ]; then
  echo -e "${GREEN}Maven instalado!${NC}"
else
  echo -e "${RED}Maven não está instalado. Instalando...${NC}"
  sudo apt install maven -y
  check_last_command
  echo -e "${GREEN}Maven instalado com sucesso!${NC}"
fi

#Baixando CRON
echo -e "${YELLOW}Verificando instalação do CRON...${NC}"
dpkg -l | grep cron
if [ $? = 0 ]; then
  echo -e "${GREEN}CRON instalado!${NC}"
else
  echo -e "${RED}CRON não está instalado. Instalando...${NC}"
  sudo apt install cron -y
  check_last_command
  echo -e "${GREEN}CRON instalado com sucesso!${NC}"
fi

# Definindo os caminhos completos dos scripts
LOG_SISTEMA="/home/ubuntu/gerenciamento-app-techguard/logSistema.sh"
LOG_NODE="/home/ubuntu/gerenciamento-app-techguard/logNode.sh"
LOG_JAVA="/home/ubuntu/gerenciamento-app-techguard/logJava.sh"
LOG_MYSQL="/home/ubuntu/gerenciamento-app-techguard/logMysql.sh"

# Criando as entradas do cron
CRON_SISTEMA="0 17 * * * bash $LOG_SISTEMA"
CRON_NODE="0 17 * * * bash $LOG_NODE"
CRON_JAVA="0 17 * * * bash $LOG_JAVA"
CRON_MYSQL="0 17 * * * bash $LOG_MYSQL"

# Adiciona ou atualiza os cron jobs
(crontab -l | grep -Fxq "$CRON_SISTEMA") || (crontab -l; echo "$CRON_SISTEMA") | crontab -
(crontab -l | grep -Fxq "$CRON_NODE") || (crontab -l; echo "$CRON_NODE") | crontab -
(crontab -l | grep -Fxq "$CRON_JAVA") || (crontab -l; echo "$CRON_JAVA") | crontab -
(crontab -l | grep -Fxq "$CRON_MYSQL") || (crontab -l; echo "$CRON_MYSQL") | crontab -

echo "Todos os cron jobs foram configurados com sucesso!"

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
cd DockerfileJava/
git clone https://github.com/TechGuard-Solutions/conexao-java.git
check_last_command
echo -e "${GREEN}Diretório acessado${NC}"

# Buildando o projeto com Maven
echo -e "${YELLOW}Buildando o projeto com Maven...${NC}"
cd conexao-java
mvn clean package
check_last_command
echo -e "${GREEN}Build do projeto concluído!${NC}"

# Criando Dockerfile para JAVA
echo -e "${YELLOW}Criando Dockerfile com imagem JAVA...${NC}"
DOCKERFILE="Dockerfile"
cat <<EOF >$DOCKERFILE
FROM openjdk:21

RUN apt install -y cron && \
echo "0 16 * * * java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar" > /etc/cron.d/mycron
chmod 0644 /etc/cron.d/mycron && \
crontab /etc/cron.d/mycron

WORKDIR /usr/src/app
COPY conexao-java/ /usr/src/app/

COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh

EXPOSE 3030
CMD ["/usr/src/app/start.sh"]
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

echo -e "${YELLOW}Configurando CRON de Logs...${NC}"

echo -e "${GREEN}Instalação finalizada!${NC}"