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
  sudo rm -rf awscliv2.zip aws
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

# Baixando CRON
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

echo -e "${YELLOW}Configurando CRON de Logs...${NC}"

# Criando as entradas do cron
CRON_SISTEMA="* * * * * bash $LOG_SISTEMA"
CRON_NODE="* * * * * bash $LOG_NODE"
CRON_JAVA="* * * * * bash $LOG_JAVA"
CRON_MYSQL="* * * * * bash $LOG_MYSQL"

# Adiciona ou atualiza os cron jobs
(crontab -l | grep -Fxq "$CRON_SISTEMA") || (crontab -l; echo "$CRON_SISTEMA") | crontab -
(crontab -l | grep -Fxq "$CRON_NODE") || (crontab -l; echo "$CRON_NODE") | crontab -
(crontab -l | grep -Fxq "$CRON_JAVA") || (crontab -l; echo "$CRON_JAVA") | crontab -
(crontab -l | grep -Fxq "$CRON_MYSQL") || (crontab -l; echo "$CRON_MYSQL") | crontab -

echo "Todos os cron jobs foram configurados com sucesso!"

echo -e "${YELLOW}Criando docker compose...${NC}"
DOCKER_COMPOSE="docker-compose.yml" 
if [ -f "$DOCKER_COMPOSE" ]; then
   echo -e "${YELLOW}Docker compose já existe, pulando criação...${NC}"
else
cat <<EOF >$DOCKER_COMPOSE
volumes:
  mysql_techguard:
  node_techguard:
  java_techguard:

networks:
  techguard-network:
    driver: bridge

services:
  mysql:
    container_name: TechGuardDB
    image: arturmatukiwa/mysqlimagem:4.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: solutions
    ports:
      - "3306:3306"
    volumes:
      - mysql_techguard:/docker-entrypoint-initdb.d
    networks:
      - techguard-network

  node:
    container_name: TechGuardAPP
    image: arturmatukiwa/nodeimagem:4.0
    restart: always
    ports:
      - "8080:8080"
    volumes:
      - node_techguard:/usr/src/app
    networks:
      - techguard-network
    depends_on:
      - mysql

  java:
    container_name: TechGuardJAVA
    image: arturmatukiwa/javatechguard:4.0
    restart: always
    ports:
      - "3030:3030"
    volumes:
      - java_techguard:/usr/src/app
    networks:
      - techguard-network
EOF
check_last_command
fi
echo -e "${GREEN}Criação do docker compose realizada com sucesso!${NC}"

echo -e "${YELLOW}Iniciando criação de contêineres com docker compose...${NC}"
sudo docker-compose up -d
echo -e "${GREEN}Inicialização dos contêineres com sucesso!${NC}"

echo -e "${YELLOW}Configuração do portainer...${NC}"

docker volume create portainer_data
check_last_command
docker run -d -p 9000:9000 --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
check_last_command

echo -e "${GREEN}Configuração do portainer feita com sucesso!${NC}"
echo -e "${GREEN}Instalação finalizada!${NC}"

echo -e "${YELLOW}ALTERE AS CREDENCIAIS AWS DENTRO DO CONTAINER 'TechGuardJAVA'${NC}"


