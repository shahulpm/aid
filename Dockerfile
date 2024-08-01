from node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Bundle app source
COPY . .

EXPOSE 3000

# Start the server using the production build
CMD [ "node","app.js" ]