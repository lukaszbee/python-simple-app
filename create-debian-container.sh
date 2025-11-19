#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Creating Debian container for Python app...${NC}"

CONTAINER_NAME="python-app-server"
CONTAINER_IMAGE="debian:12"
APP_PORT="8080"

# Sprawdź czy kontener już istnieje
if podman ps -a --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
    echo -e "${YELLOW}⚠️ Container $CONTAINER_NAME already exists, removing...${NC}"
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    podman rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Utwórz nowy kontener Debian
echo -e "${YELLOW}🔨 Creating new Debian container...${NC}"
podman run -d \
    --name "$CONTAINER_NAME" \
    --hostname "$CONTAINER_NAME" \
    -p "$APP_PORT":5000 \
    --restart unless-stopped \
    "$CONTAINER_IMAGE" \
    sleep infinity

echo -e "${YELLOW}⏳ Waiting for container to start...${NC}"
sleep 3

# Zainstaluj Python i zależności w kontenerze Debian
echo -e "${YELLOW}🐍 Installing Python and dependencies in container...${NC}"
podman exec "$CONTAINER_NAME" apt update
podman exec "$CONTAINER_NAME" apt install -y python3 python3-pip python3-venv curl

# Sprawdź instalację
echo -e "${YELLOW}🔍 Verifying installation...${NC}"
podman exec "$CONTAINER_NAME" python3 --version
podman exec "$CONTAINER_NAME" pip3 --version

echo -e "${GREEN}✅ Debian container '$CONTAINER_NAME' created successfully!${NC}"
echo -e "${GREEN}🌐 Container will be available on port: $APP_PORT${NC}"
echo -e "${GREEN}📊 Container status:${NC}"
podman ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
