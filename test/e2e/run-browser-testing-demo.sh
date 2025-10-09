#!/bin/bash

# Master Demo Runner for Browser Testing with Gemini CLI
# Complete guided experience for the blog tutorial

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        Browser Testing Demo with Gemini CLI                   ║
║        + Docker MCP Toolkit + Playwright                      ║
║                                                                ║
║        Repository: catalog-service-node                       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo "This demo will guide you through automated E2E testing"
echo "using Gemini CLI to discover bugs in the catalog service."
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    echo ""
    
    local all_good=true
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✅ Docker installed${NC}"
    else
        echo -e "${RED}❌ Docker not found${NC}"
        all_good=false
    fi
    
    # Check Node
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✅ Node.js installed ($NODE_VERSION)${NC}"
    else
        echo -e "${RED}❌ Node.js not found${NC}"
        all_good=false
    fi
    
    # Check if services are running
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend accessible (http://localhost:5173)${NC}"
    else
        echo -e "${YELLOW}⚠️  Frontend not running${NC}"
        echo "   Run: docker compose up -d && npm run dev"
        all_good=false
    fi
    
    if curl -s http://localhost:3000/api/products > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API accessible (http://localhost:3000)${NC}"
    else
        echo -e "${YELLOW}⚠️  API not running${NC}"
        all_good=false
    fi
    
    echo ""
    
    if [ "$all_good" = false ]; then
        echo -e "${RED}Please fix the issues above before continuing.${NC}"
        echo ""
        echo "Quick fix:"
        echo "  ${YELLOW}docker compose up -d${NC}"
        echo "  ${YELLOW}npm install --omit=optional && npm run dev${NC}"
        echo ""
        exit 1
    fi
}

# Function to display menu
show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}              Available Test Scenarios             ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo "  1. 🎯 Product Listing Performance Test"
    echo "     Discovers: Large images, no pagination"
    echo "     Time: ~30 seconds"
    echo ""
    echo "  2. 🛒 Add to Cart Flow Test"
    echo "     Discovers: Basic functionality + race conditions"
    echo "     Time: ~45 seconds"
    echo ""
    echo "  3. ⚡ Inventory Race Condition (CRITICAL BUG)"
    echo "     Reproduces: Negative inventory bug from TODO"
    echo "     Time: ~60 seconds"
    echo ""
    echo "  4. 🔌 REST API Endpoint Testing"
    echo "     Discovers: Missing validation, error handling"
    echo "     Time: ~90 seconds"
    echo ""
    echo "  5. 📊 Performance & Lighthouse Audit"
    echo "     Discovers: Performance bottlenecks"
    echo "     Time: ~60 seconds"
    echo ""
    echo "  6. 🌐 Cross-Browser Compatibility Test"
    echo "     Tests: Chrome, Firefox, Safari (WebKit)"
    echo "     Time: ~120 seconds"
    echo ""
    echo "  7. 🚀 Run ALL tests (Full Demo)"
    echo "     Runs all 6 scenarios sequentially"
    echo "     Time: ~6 minutes"
    echo ""
    echo "  8. 📖 View Documentation"
    echo ""
    echo "  9. 🌱 Re-seed Test Data"
    echo ""
    echo "  0. ❌ Exit"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to display scenario
show_scenario() {
    local scenario_file=$1
    local scenario_name=$2
    
    clear
    echo -e "${CYAN}"
    echo "════════════════════════════════════════════════════"
    echo "  $scenario_name"
    echo "════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo ""
    
    cat "tests/e2e/scenarios/$scenario_file"
    
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📋 Instructions:"
    echo ""
    echo "1. Copy the prompt from the 'Gemini CLI Prompt' section above"
    echo "2. Open Gemini CLI in another terminal"
    echo "3. Paste the prompt"
    echo "4. Watch Gemini discover bugs and create GitHub issues!"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "Press ENTER to return to menu..."
}

# Function to run all tests
run_all_tests() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║          Running Full Test Suite                  ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "This will show you all 6 test scenarios."
    echo "You'll need to run each prompt in Gemini CLI manually."
    echo ""
    read -p "Press ENTER to begin..."
    
    scenarios=(
        "01-product-listing.md:Product Listing Performance Test"
        "02-add-to-cart-flow.md:Add to Cart Flow Test"
        "03-inventory-race-condition.md:Inventory Race Condition Test"
        "04-api-endpoint-testing.md:API Endpoint Testing"
        "05-performance-audit.md:Performance & Lighthouse Audit"
        "06-cross-browser-testing.md:Cross-Browser Compatibility Test"
    )
    
    for scenario in "${scenarios[@]}"; do
        IFS=':' read -r file name <<< "$scenario"
        show_scenario "$file" "$name"
    done
    
    echo ""
    echo -e "${GREEN}✅ All scenarios completed!${NC}"
    echo ""
    echo "Check for:"
    echo "  • Screenshots in tests/e2e/screenshots/"
    echo "  • Reports in tests/e2e/reports/"
    echo "  • GitHub issues created automatically"
    echo ""
    read -p "Press ENTER to return to menu..."
}

# Function to show documentation
show_docs() {
    clear
    echo -e "${CYAN}Documentation${NC}"
    echo ""
    cat tests/e2e/README.md | head -n 100
    echo ""
    echo "..."
    echo ""
    echo "Full documentation: tests/e2e/README.md"
    echo ""
    read -p "Press ENTER to return to menu..."
}

# Function to re-seed data
reseed_data() {
    clear
    echo -e "${YELLOW}Re-seeding test data...${NC}"
    echo ""
    
    if [ -f "tests/e2e/seed-test-data.sh" ]; then
        chmod +x tests/e2e/seed-test-data.sh
        ./tests/e2e/seed-test-data.sh
    else
        echo -e "${RED}❌ seed-test-data.sh not found${NC}"
        echo "Please run setup-browser-testing-demo.sh first"
    fi
    
    echo ""
    read -p "Press ENTER to return to menu..."
}

# Main loop
check_prerequisites

while true; do
    show_menu
    read -p "Select an option (0-9): " choice
    
    case $choice in
        1)
            show_scenario "01-product-listing.md" "Product Listing Performance Test"
            ;;
        2)
            show_scenario "02-add-to-cart-flow.md" "Add to Cart Flow Test"
            ;;
        3)
            show_scenario "03-inventory-race-condition.md" "Inventory Race Condition Test"
            ;;
        4)
            show_scenario "04-api-endpoint-testing.md" "API Endpoint Testing"
            ;;
        5)
            show_scenario "05-performance-audit.md" "Performance & Lighthouse Audit"
            ;;
        6)
            show_scenario "06-cross-browser-testing.md" "Cross-Browser Compatibility"
            ;;
        7)
            run_all_tests
            ;;
        8)
            show_docs
            ;;
        9)
            reseed_data
            ;;
        0)
            echo ""
            echo "Thanks for testing! 👋"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 2
            ;;
    esac
done
