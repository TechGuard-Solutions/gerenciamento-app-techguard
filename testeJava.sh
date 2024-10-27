sudo docker network create techguard-network

# Criando diretório para JAVA
DIRECTORY="DockerfileJava"
if [ -d "$DIRECTORY" ]; then
  echo -e "${YELLOW}Diretório DockerfileJava já existe. Pulando criação.${NC}"
else
  echo -e "${YELLOW}Criando diretório de imagem Java...${NC}"
  mkdir DockerfileJava
  echo -e "${GREEN}Diretório criado com sucesso!${NC}"
fi
cd DockerfileJava/
script="start.sh"
cat <<EOF >$script
#!/bin/bash
apt update && apt upgrade -y
apt install curl -y
apt install cron -y
apt install unzip -y
apt install maven -y

cat <<EOL > ~/.aws/credentials
[default]
aws_access_key_id=$AWS_ACCESS_KEY
aws_secret_access_key=$AWS_SECRECT_ACCESS_KEY
aws_session_token=$AWS_SESSION_TOKEN
EOL

cat <<EOL > ~/.aws/config
[default]
region=us-east-1
output=json
EOL

apt install -y openjdk-21-jdk
service cron start
echo "0 16 * * * java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar" > /etc/cron.d/mycron
crontab /etc/cron.d/mycron
crontab -l
java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar
EOF
chmod +x start.sh
git clone https://github.com/TechGuard-Solutions/conexao-java.git
echo -e "${GREEN}Diretório acessado${NC}"

# Buildando o projeto com Maven
echo -e "${YELLOW}Buildando o projeto com Maven...${NC}"
cd conexao-java
mvn clean package
cd ..
echo -e "${GREEN}Build do projeto concluído!${NC}"

# Criando Dockerfile para JAVA
echo -e "${YELLOW}Criando Dockerfile com imagem JAVA...${NC}"
DOCKERFILE="Dockerfile"
cat <<EOF >$DOCKERFILE
FROM ubuntu:latest
WORKDIR /usr/src/app
RUN apt update && \
    apt install -y curl cron unzip maven openjdk-21-jdk && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

COPY conexao-java/ /usr/src/app/
COPY start.sh /usr/src/app/start.sh
EXPOSE 3030
CMD ["/usr/src/app/start.sh"]
EOF
echo -e "${GREEN}Dockerfile criado com sucesso!${NC}"

# Buildando imagem do JAVA
echo -e "${YELLOW}Buildando imagem...${NC}"
sudo docker build -t javatechguard-img .
echo -e "${GREEN}Build concluído com sucesso!${NC}"

# Iniciando container JAVA
echo -e "${YELLOW}Iniciando container...${NC}"
sudo docker run -d --name TechGuardJAVA --network techguard-network -p 3030:3030 javatechguard-img
echo -e "${GREEN}Container JAVA iniciado com sucesso!${NC}"