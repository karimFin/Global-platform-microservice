FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install -g npm@11.11.0
RUN npm install --omit=dev
COPY src ./src
EXPOSE 8080
CMD ["node", "src/server.js"]
