FROM ubuntu:latest
WORKDIR /usr/src/app
RUN echo -e "Instalando ferramentas necessárias..." && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y cron unzip maven curl openjdk-21-jdk

RUN echo -e "Criando diretório de credentials AWS..." && \
        mkdir -p ~/.aws && \
        touch ~/.aws/credentials && \
	echo "aws_access_key_id=$AWS_ACCESS_KEY" >> ~/.aws/credentials && \  
	echo "aws_secret_access_key=$AWS_SECRECT_ACCESS_KEY" >> ~/.aws/credentials && \
	echo "aws_session_token=$AWS_SESSION_TOKEN" >> ~/.aws/credentials


RUN echo -e "Criando diretório para a configuração da AWS CLI" && \
        touch ~/.aws/config && \
        echo "[default]" > ~/.aws/config && \
        echo "region=us-east-1" >> ~/.aws/config && \
        echo "output=json" >> ~/.aws/config

COPY conexao-java/ /usr/src/app/

RUN chmod +x /usr/src/app/start.sh

CMD ["tail", "-f", "/dev/null"]

EXPOSE 3030
