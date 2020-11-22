# Image
FROM node:12.4-alpine

# Set up work directory
WORKDIR /var/www/client

# Configure host
ENV HOST 0.0.0.0

ENV NODE_OPTIONS="--max-old-space-size=1024"

# Init command
CMD ["sh", "-c", "npm install && npm run build && npm run start"]
