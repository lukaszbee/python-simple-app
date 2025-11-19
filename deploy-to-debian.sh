#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Deploying Python app to Debian container...${NC}"

CONTAINER_NAME="python-app-server"
APP_DIR="/opt/python-app"

# Sprawdź czy kontener istnieje i działa
if ! podman ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Container $CONTAINER_NAME is not running!${NC}"
    echo -e "${YELLOW}💡 Run create-debian-container.sh first${NC}"
    exit 1
fi

# Przygotuj katalog aplikacji w kontenerze
echo -e "${YELLOW}📁 Preparing application directory...${NC}"
podman exec "$CONTAINER_NAME" mkdir -p "$APP_DIR"

# Skopiuj pliki aplikacji do kontenera
echo -e "${YELLOW}📤 Copying application files to container...${NC}"
podman cp app.py "$CONTAINER_NAME:$APP_DIR/"
podman cp requirements.txt "$CONTAINER_NAME:$APP_DIR/"

# Zainstaluj zależności Pythona w kontenerze
echo -e "${YELLOW}📦 Installing Python dependencies in container...${NC}"
podman exec "$CONTAINER_NAME" pip3 install -r "$APP_DIR/requirements.txt"

# Zatrzymaj istniejącą instancję aplikacji jeśli działa
echo -e "${YELLOW}🛑 Stopping existing application if running...${NC}"
podman exec "$CONTAINER_NAME" pkill -f "python3.*app.py" || true
sleep 2

# Uruchom aplikację w kontenerze Debian
echo -e "${YELLOW}🐍 Starting Python application in container...${NC}"
podman exec -d "$CONTAINER_NAME" bash -c "cd $APP_DIR && python3 app.py"

# Poczekaj aż aplikacja się uruchomi
echo -e "${YELLOW}⏳ Waiting for application to start...${NC}"
sleep 5

# Sprawdź czy aplikacja działa
echo -e "${YELLOW}🔍 Testing application...${NC}"
if curl -f "http://localhost:8080/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application deployed successfully!${NC}"
    echo -e "${GREEN}🌐 Application is running at: http://localhost:8080${NC}"
    
    # Pokaż informacje o aplikacji
    echo -e "${YELLOW}📊 Application info:${NC}"
    curl -s "http://localhost:8080/api/info" | python3 -m json.tool
    
else
    echo -e "${RED}❌ Application deployment failed!${NC}"
    echo -e "${YELLOW}📋 Checking logs...${NC}"
    podman exec "$CONTAINER_NAME" ps aux | grep python || echo "No Python processes found"
    exit 1
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
