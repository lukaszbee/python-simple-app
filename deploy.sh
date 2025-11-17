#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Starting deployment on HOST...${NC}"

# Configuration
APP_NAME="simple-python-app"
APP_PORT="5000"
CONTAINER_PORT="5000"

# Use host Podman through socket
PODMAN_CMD="podman --url unix:///var/run/podman/podman.sock"

echo -e "${YELLOW}🔧 Using host Podman: $PODMAN_CMD${NC}"

# Stop and remove existing container on HOST
echo -e "${YELLOW}🛑 Stopping existing container on host...${NC}"
$PODMAN_CMD stop $APP_NAME 2>/dev/null || true
$PODMAN_CMD rm $APP_NAME 2>/dev/null || true

# Build new image on HOST
echo -e "${YELLOW}🔨 Building new image on host...${NC}"
$PODMAN_CMD build -t $APP_NAME:latest .

# Run new container on HOST
echo -e "${YELLOW}🐳 Starting new container on host...${NC}"
$PODMAN_CMD run -d \
  --name $APP_NAME \
  -p $APP_PORT:$CONTAINER_PORT \
  --restart unless-stopped \
  $APP_NAME:latest

# Wait for app to start
echo -e "${YELLOW}⏳ Waiting for application to start on host...${NC}"
sleep 5

# Health check
echo -e "${YELLOW}🔍 Performing health check...${NC}"
if curl -f http://localhost:$APP_PORT/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🌐 Application is running on: http://localhost:$APP_PORT${NC}"
else
    echo -e "${RED}❌ Deployment failed!${NC}"
    echo -e "${RED}📋 Check logs with: $PODMAN_CMD logs $APP_NAME${NC}"
    exit 1
fi

# Show container status on HOST
echo -e "\n${YELLOW}📊 Container status on host:${NC}"
$PODMAN_CMD ps --filter "name=$APP_NAME"

echo -e "\n${GREEN}🎉 Deployment completed on HOST!${NC}"
