#!/bin/bash
# Pre-compile Python files to .mpy for faster loading and smaller size
# MicroPython bytecode compilation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  MicroPython Bytecode Compilation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if mpy-cross is installed
if ! command -v mpy-cross &> /dev/null; then
    echo -e "${YELLOW}mpy-cross not found. Installing...${NC}"
    pip install mpy-cross 2>/dev/null || {
        echo -e "${RED}Failed to install mpy-cross${NC}"
        echo "Install manually with: pip install mpy-cross"
        exit 1
    }
fi

# Create build directory
BUILD_DIR="build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

VERSION=$(cat VERSION)
echo -e "${GREEN}Version: ${VERSION}${NC}"
echo ""

echo -e "${BLUE}Compiling Python files to bytecode...${NC}"

# Compile each Python file
for file in main.py logging.py; do
    if [ -f "$file" ]; then
        echo -ne "${YELLOW}Compiling ${file}...${NC}"
        mpy-cross "$file" -o "$BUILD_DIR/${file%.py}.mpy" 2>/dev/null && \
            echo -e " ${GREEN}✓${NC}" || \
            echo -e " ${RED}✗${NC}"
    fi
done

# Copy non-compiled files
echo -ne "${YELLOW}Copying secrets.example.py...${NC}"
cp secrets.example.py "$BUILD_DIR/" && echo -e " ${GREEN}✓${NC}"

echo -ne "${YELLOW}Copying VERSION...${NC}"
cp VERSION "$BUILD_DIR/" && echo -e " ${GREEN}✓${NC}"

echo -ne "${YELLOW}Copying README.md...${NC}"
cp README.md "$BUILD_DIR/" && echo -e " ${GREEN}✓${NC}"

echo ""
echo -e "${BLUE}Creating release package...${NC}"

# Create tarball
RELEASE_NAME="dht22-ha-v${VERSION}"
tar -czf "${RELEASE_NAME}.tar.gz" -C "$BUILD_DIR" .

# Create zip
cd "$BUILD_DIR"
zip -q -r "../${RELEASE_NAME}.zip" .
cd ..

# Calculate sizes
ORIGINAL_SIZE=$(du -sh . | cut -f1)
COMPILED_SIZE=$(du -sh "$BUILD_DIR" | cut -f1)

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Compilation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Build artifacts:"
echo "  • build/ directory (compiled .mpy files)"
echo "  • ${RELEASE_NAME}.tar.gz"
echo "  • ${RELEASE_NAME}.zip"
echo ""
echo "Original size: ${ORIGINAL_SIZE}"
echo "Compiled size: ${COMPILED_SIZE}"
echo ""
echo "Benefits of .mpy files:"
echo "  • Faster loading on Pico"
echo "  • Smaller memory footprint"
echo "  • Slightly obfuscated source"
echo ""
echo "Deploy compiled version:"
echo "  mpremote cp build/main.mpy :"
echo "  mpremote cp build/logging.mpy :"
echo ""
