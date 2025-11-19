#!/bin/bash
# Deployment script for Raspberry Pi Pico W
# Uploads all necessary files to the Pico

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  DHT22 Home Assistant Sensor - Deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if mpremote is installed
if ! command -v mpremote &> /dev/null; then
    echo -e "${RED}Error: mpremote not found${NC}"
    echo "Install with: pip install mpremote"
    exit 1
fi

# Check if Pico is connected
if ! mpremote connect list &> /dev/null; then
    echo -e "${YELLOW}Warning: No Pico detected. Make sure it's connected.${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Get version
VERSION=$(cat VERSION)
echo -e "${GREEN}Version: ${VERSION}${NC}"
echo ""

# Check if secrets.py exists
if [ ! -f "secrets.py" ]; then
    echo -e "${YELLOW}Warning: secrets.py not found!${NC}"
    echo "You need to create secrets.py with your WiFi and MQTT credentials."
    echo ""
    read -p "Copy secrets.example.py to secrets.py now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp secrets.example.py secrets.py
        echo -e "${GREEN}✓ Created secrets.py${NC}"
        echo -e "${YELLOW}⚠ Please edit secrets.py with your credentials before deploying!${NC}"
        exit 0
    else
        echo -e "${RED}Deployment cancelled. Please create secrets.py first.${NC}"
        exit 1
    fi
fi

echo "Files to deploy:"
echo "  • main.py"
echo "  • logging.py"
echo "  • secrets.py"
echo ""

read -p "Deploy to Pico W? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Installing dependencies...${NC}"

# Install umqtt.simple library
echo -ne "${YELLOW}Installing umqtt.simple...${NC}"
if mpremote mip install umqtt.simple 2>/dev/null; then
    echo -e " ${GREEN}✓${NC}"
else
    echo -e " ${YELLOW}⚠ (may already be installed)${NC}"
fi

echo ""
echo -e "${BLUE}Uploading files...${NC}"

# Upload main application files
echo -ne "${YELLOW}Uploading main.py...${NC}"
mpremote cp main.py : 2>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${RED}✗${NC}"

echo -ne "${YELLOW}Uploading logging.py...${NC}"
mpremote cp logging.py : 2>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${RED}✗${NC}"

echo -ne "${YELLOW}Uploading secrets.py...${NC}"
mpremote cp secrets.py : 2>/dev/null && echo -e " ${GREEN}✓${NC}" || echo -e " ${RED}✗${NC}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Verify your secrets.py configuration"
echo "  2. Reset the Pico W to start the application"
echo "  3. Monitor logs with: mpremote run utils/read_logs.py"
echo ""
echo "Or run immediately with:"
echo "  mpremote run main.py"
echo ""
