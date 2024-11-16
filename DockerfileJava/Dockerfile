FROM ubuntu:latest
WORKDIR /usr/src/app
RUN echo -e "Instalando ferrementas necessárias..." && \
	apt-get update && apt-get upgrade -y && \
	apt-get install -y openjdk-21-jdk && apt-get install cron -y && \
	apt-get install unzip -y && \
	apt-get install maven -y && \
	apt-get install curl -y && \
	apt-get install dos2unix -y && \  
	apt-get install -y curl jq

RUN echo -e "Baixando instalador do AWS CLI..." && \
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" unzip awscliv2.zip && \
	

RUN echo -e "Acessando as credenciais da EC2..." && \
	ROLE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/) && \
	CREDENTIALS=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE_NAME) && \
	AWS_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.AccessKeyId') && \
    	AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.SecretAccessKey') && \
    	AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Token') 

RUN echo -e "Criando diretório de credentials AWS..." && \
	mkdir -p ~/.aws && \
	echo "[default]" > ~/.aws/credentials && \
	echo "aws_access_key_id=${AWS_ACCESS_KEY}" >> ~/.aws/credentials && \
	echo "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials && \
	echo "aws_session_token=${AWS_SESSION_TOKEN}" >> ~/.aws/credentials

RUN echo -e "Criando diretório para a configuração da AWS CLI" && \
	mkdir -p ~/.aws/config && \
	echo "[default]" > ~/.aws/config && \
	echo "region=us-east-1" >> ~/.aws/config && \
	echo "output=json" >> ~/.aws/config

RUN echo -e "Configurando cron e comando para contêiner" && \
       	service cron start && \
	echo "0 18 * * * java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar" > /etc/cron.d/mycron && \
	crontab /etc/cron.d/mycron && \
	crontab -l && \
	chmod +rx target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar && \
	java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar && \
	tail -f /dev/null


COPY conexao-java/ /usr/src/app/
# COPY conexao-java/start.sh /usr/src/app/start.sh

#RUN chmod +x /usr/src/app/start.sh && \
#	dos2unix /usr/src/app/start.sh && \
#	/usr/src/app/start.sh --help || true

EXPOSE 3030
# CMD ["bash", "/usr/src/app/start.sh"]
CMD ["java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar"]

