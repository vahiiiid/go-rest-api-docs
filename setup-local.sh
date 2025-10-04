#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 Go REST API Docs - Local Setup${NC}"
echo -e "${BLUE}===================================${NC}"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed.${NC}"
    echo -e "${YELLOW}Please install Python 3: https://www.python.org/downloads/${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python 3 found: $(python3 --version)${NC}"
echo ""

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo -e "${YELLOW}⚠️  Virtual environment already exists.${NC}"
    echo -e "${BLUE}Activating existing virtual environment...${NC}"
else
    echo -e "${BLUE}Creating virtual environment...${NC}"
    python3 -m venv venv
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Virtual environment created.${NC}"
    else
        echo -e "${RED}❌ Failed to create virtual environment.${NC}"
        exit 1
    fi
fi

echo ""

# Activate virtual environment
echo -e "${BLUE}Activating virtual environment...${NC}"
source venv/bin/activate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Virtual environment activated.${NC}"
else
    echo -e "${RED}❌ Failed to activate virtual environment.${NC}"
    exit 1
fi

echo ""

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependencies installed successfully.${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT: You must activate the virtual environment!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "  ${GREEN}1. Activate the virtual environment:${NC}"
echo -e "     ${YELLOW}source venv/bin/activate${NC}"
echo ""
echo -e "  ${GREEN}2. Start the development server:${NC}"
echo -e "     ${YELLOW}mkdocs serve${NC}"
echo ""
echo -e "  ${GREEN}3. Open your browser:${NC}"
echo -e "     ${YELLOW}http://127.0.0.1:8000${NC}"
echo ""
echo -e "  ${GREEN}4. When done, deactivate the virtual environment:${NC}"
echo -e "     ${YELLOW}deactivate${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}💡 Tip: Your shell prompt will show (venv) when activated${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Happy documenting! 📝${NC}"
