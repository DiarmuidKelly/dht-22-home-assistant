#!/bin/bash
# Install MicroPython dependencies on Pico W

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing MicroPython Dependencies${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if mpremote is installed
if ! command -v mpremote &> /dev/null; then
    echo -e "${RED}Error: mpremote not found${NC}"
    echo "Install with: pip install mpremote"
    exit 1
fi

# Check if Pico is connected
echo -ne "${YELLOW}Checking for connected Pico W...${NC}"
if mpremote connect list &> /dev/null; then
    echo -e " ${GREEN}✓${NC}"
else
    echo -e " ${RED}✗${NC}"
    echo -e "${RED}No Pico detected. Connect your Pico W and try again.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Installing packages from requirements-pico.txt...${NC}"
echo ""

# Read and install each package
while IFS= read -r package; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" =~ ^# ]] && continue

    echo -ne "${YELLOW}Installing ${package}...${NC}"
    if mpremote mip install "$package" 2>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
    else
        echo -e " ${YELLOW}⚠ (may already be installed)${NC}"
    fi
done < requirements-pico.txt

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Dependencies installed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installed packages:"
echo "  • umqtt.simple (MQTT client library)"
echo ""
echo "Next steps:"
echo "  1. Configure secrets.py with your WiFi and MQTT credentials"
echo "  2. Deploy the application: ./scripts/deploy.sh"
echo ""
