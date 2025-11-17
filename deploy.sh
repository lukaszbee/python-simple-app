#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting deployment...${NC}"

# Configuration
APP_NAME="simple-python-app"
APP_PORT="5000"
CONTAINER_PORT="5000"

# Stop and remove existing container
echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
podman stop $APP_NAME 2>/dev/null || true
podman rm $APP_NAME 2>/dev/null || true

# Build new image
echo -e "${YELLOW}🔨 Building new image...${NC}"
podman build -t $APP_NAME:latest .

# Run new container
echo -e "${YELLOW}🐳 Starting new container...${NC}"
podman run -d \
  --name $APP_NAME \
  -p $APP_PORT:$CONTAINER_PORT \
  --restart unless-stopped \
  $APP_NAME:latest

# Wait for app to start
echo -e "${YELLOW}⏳ Waiting for application to start...${NC}"
sleep 5

# Health check
echo -e "${YELLOW}🔍 Performing health check...${NC}"
if curl -f http://localhost:$APP_PORT/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🌐 Application is running on: http://localhost:$APP_PORT${NC}"
else
    echo -e "${RED}❌ Deployment failed!${NC}"
    echo -e "${RED}📋 Check logs with: podman logs $APP_NAME${NC}"
    exit 1
fi

# Show container status
echo -e "\n${YELLOW}📊 Container status:${NC}"
podman ps --filter "name=$APP_NAME"

echo -e "\n${GREEN}🎉 Deployment completed!${NC}"
