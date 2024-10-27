DIRECTORY="DockerfileJava"
if [ -d "$DIRECTORY" ]; then
  echo -e "${YELLOW}Diretório DockerfileJava já existe. Pulando criação.${NC}"
else
  mkdir DockerfileJava
fi

cd DockerfileJava/
git clone https://github.com/TechGuard-Solutions/conexao-java.git

cd conexao-java
mvn clean package

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

sudo docker build -t javatechguard-img .