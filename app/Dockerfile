FROM node:5.10-slim
MAINTAINER Calvin Low <calsaviour@gmail.com>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install

COPY server.js /usr/src/app/

EXPOSE 8080
CMD [ "npm", "start" ]