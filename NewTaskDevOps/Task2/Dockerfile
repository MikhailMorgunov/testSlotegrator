FROM node:14

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY index.js ./

ENV LANG=C.UTF-8

EXPOSE 3000
CMD ["node", "index.js"]
