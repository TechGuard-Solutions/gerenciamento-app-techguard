FROM node:latest
WORKDIR /usr/src/app
COPY ./site-institucional/package*.json ./
RUN npm install
COPY site-institucional/ .
EXPOSE 8080
CMD ["npm", "start"]
