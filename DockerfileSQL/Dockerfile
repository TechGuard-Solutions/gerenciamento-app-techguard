FROM mysql:latest
ENV MYSQL_ROOT_PASSWORD=solutions
COPY ./site-institucional/src/database/ /docker-entrypoint-initdb.d/
EXPOSE 3306
