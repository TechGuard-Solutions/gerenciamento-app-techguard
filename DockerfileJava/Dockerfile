FROM ubuntu:latest
WORKDIR /usr/src/app
RUN echo -e "Instalando ferrementas necessárias..." && \
	apt-get update && apt-get upgrade -y && \
	apt-get install -y openjdk-21-jdk && apt-get install cron -y && \
	apt-get install unzip -y && \
	apt-get install maven -y && \
	apt-get install curl -y
	
RUN echo -e "Criando diretório de credentials AWS..." && \
	mkdir -p ~/.aws && \
	touch ~/.aws/credentials

RUN echo -e "Criando diretório para a configuração da AWS CLI" && \
	touch ~/.aws/config && \
	echo "[default]" > ~/.aws/config && \
	echo "region=us-east-1" >> ~/.aws/config && \
	echo "output=json" >> ~/.aws/config

COPY conexao-java/ /usr/src/app/

RUN echo -e '#!/bin/bash ' > start.sh && \
	echo -e '\n mvn clean package' >> start.sh && \
	echo -e '\n chmod +rx target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar' && \
	echo -e "\n echo '10 18 * * * java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar' > /etc/cron.d/mycron" >> start.sh && \
	echo -e '\n crontab /etc/cron.d/mycron' >> start.sh && \
	echo -e '\n crontab -l' >> start.sh && \
	echo -e '\n chmod +rx target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar' >> start.sh && \
	echo -e '\n java -jar target/Integracao-1.0-SNAPSHOT-jar-with-dependencies.jar' >> start.sh

RUN chmod +x /usr/src/app/start.sh

CMD ["tail", "-f", "/dev/null"]
# COPY conexao-java/start.sh /usr/src/app/start.sh
#RUN chmod +x /usr/src/app/start.sh && \
#	dos2unix /usr/src/app/start.sh && \
#	/usr/src/app/start.sh --help || true

EXPOSE 3030
# CMD ["bash", "/usr/src/app/start.sh"]
