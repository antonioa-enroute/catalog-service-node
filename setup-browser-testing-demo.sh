#!/bin/bash

# Setup script for Browser Testing Demo with Gemini CLI
# Adds E2E testing capabilities to catalog-service-node

set -e

echo "🚀 Setting up Browser Testing Demo for catalog-service-node..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the catalog-service-node root directory."
    exit 1
fi

echo -e "${BLUE}📁 Creating test directories...${NC}"
mkdir -p tests/e2e
mkdir -p tests/e2e/scenarios
mkdir -p tests/e2e/screenshots
mkdir -p tests/e2e/reports

echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Create test scenario files
echo -e "${BLUE}📝 Creating test scenario documentation...${NC}"

# Scenario 1: Product Listing Test
cat > tests/e2e/scenarios/01-product-listing.md << 'EOF'
# Scenario 1: Product Listing Test

## Objective
Test the product listing page loads correctly and displays all products from the database.

## Gemini CLI Prompt
```
Test the product listing page at http://localhost:5173. 
Verify that:
1. The page loads without errors
2. Products are displayed in a grid layout
3. Each product shows: name, price, image, and "Add to Cart" button
4. Console has no JavaScript errors
5. All product images load successfully

Take screenshots of:
- Full page view
- Any errors found
- Browser console

If issues are found, create a GitHub issue with screenshots and details.
```

## Expected Results
✅ Page loads in < 2 seconds
✅ All products from database are displayed
✅ Images load from S3/LocalStack
✅ No console errors

## Known Issues to Discover
- Large unoptimized images (performance issue from TODO comment)
- No pagination - loads all 500+ products at once
- Missing alt text on images (accessibility issue)

## Success Criteria
- Gemini CLI identifies performance issues
- Screenshots captured
- GitHub issue created with details
EOF

# Scenario 2: Add to Cart Flow
cat > tests/e2e/scenarios/02-add-to-cart-flow.md << 'EOF'
# Scenario 2: Add to Cart Flow Test

## Objective
Test the complete flow of adding a product to the shopping cart.

## Gemini CLI Prompt
```
Test the "Add to Cart" functionality:
1. Navigate to http://localhost:5173
2. Click on the first product to view details
3. Click "Add to Cart" button
4. Verify cart count updates in the navigation
5. View cart page and verify product appears
6. Check if quantity can be updated
7. Monitor network requests to the API

Take screenshots at each step.
If any race conditions or bugs are found, create a GitHub issue.
```

## Expected Results
✅ Product details page loads
✅ Add to Cart button is clickable
✅ Cart count updates correctly
✅ Cart page shows added product
✅ API requests complete successfully

## Known Issues to Discover
- Race condition when adding same item multiple times quickly
- Cart count sometimes shows incorrect number
- API doesn't validate negative quantities

## Success Criteria
- Gemini CLI discovers the race condition
- Network timing issues documented
- GitHub issue created with reproduction steps
EOF

# Scenario 3: Inventory Race Condition
cat > tests/e2e/scenarios/03-inventory-race-condition.md << 'EOF'
# Scenario 3: Inventory Synchronization Race Condition Test

## Objective
Reproduce and document the inventory race condition mentioned in TODO comments.

## Gemini CLI Prompt
```
Test for inventory race condition:
1. Open two browser windows/tabs simultaneously
2. In both tabs, navigate to the same product (last item in stock)
3. Click "Add to Cart" in both tabs at exactly the same time
4. Check the inventory count in the database
5. Verify if both purchases succeeded (they shouldn't!)

Expected: One should succeed, one should fail with "out of stock"
Bug: Both succeed, inventory goes negative

Document this with:
- Screenshots from both browser tabs
- Database query showing negative inventory
- Network request timing
- Link to the TODO comment in InventoryService.js

Create a detailed GitHub issue validating the TODO comment is a real bug.
```

## Related TODO Comment
```javascript
// TODO: Add proper inventory synchronization
// Race condition exists when multiple users try to purchase the last item
// See: src/services/InventoryService.js:23
```

## Expected Results
❌ Both purchases succeed (BUG!)
❌ Inventory count goes negative
❌ No locking mechanism in place

## Success Criteria
- Race condition successfully reproduced
- Evidence captured (screenshots, DB query, network logs)
- GitHub issue links back to TODO comment
- Suggested fix included (optimistic locking or database constraints)
EOF

# Scenario 4: API Endpoint Testing
cat > tests/e2e/scenarios/04-api-endpoint-testing.md << 'EOF'
# Scenario 4: REST API Endpoint Testing

## Objective
Validate all REST API endpoints return correct responses and handle errors properly.

## Gemini CLI Prompt
```
Test all REST API endpoints of the catalog service:

1. GET /api/products
   - Verify returns 200
   - Check response schema matches expected format
   - Validate all required fields present

2. GET /api/products/:id
   - Test with valid product ID
   - Test with invalid product ID (should return 404)
   - Test with missing product (check error handling)

3. POST /api/products (create product)
   - Test with valid data
   - Test with missing required fields
   - Test with invalid data types
   - Verify S3 image upload (check for TODO bug about failed uploads)

4. PUT /api/products/:id (update product)
   - Test successful update
   - Test validation on negative prices
   - Test duplicate SKU validation (TODO mentions this is missing)

5. DELETE /api/products/:id
   - Test successful deletion
   - Verify S3 image cleanup (TODO mentions this is not implemented)

For each endpoint:
- Document response codes
- Validate response schemas
- Check error messages
- Test edge cases

Create GitHub issues for:
- Missing 404 handling
- S3 upload failures silently ignored
- No validation on duplicate SKUs
- Negative price validation missing
```

## Related TODO Comments
- StorageService.js: "No error handling for S3 upload failures"
- ProductService.js: "No validation for duplicate SKUs"
- ProductService.js: "Product deletion doesn't clean up S3 images"

## Success Criteria
- All endpoints tested
- Schema validation performed
- TODO bugs confirmed
- GitHub issues created with API test results
EOF

# Scenario 5: Performance Audit
cat > tests/e2e/scenarios/05-performance-audit.md << 'EOF'
# Scenario 5: Performance & Lighthouse Audit

## Objective
Analyze page performance and identify optimization opportunities.

## Gemini CLI Prompt
```
Run a comprehensive performance audit on http://localhost:5173:

1. Run Lighthouse audit and capture scores for:
   - Performance
   - Accessibility
   - Best Practices
   - SEO

2. Identify specific performance issues:
   - Large unoptimized images (TODO mentions this)
   - Missing pagination (loads all products at once)
   - Slow API requests
   - Render-blocking resources

3. Check accessibility issues:
   - Missing alt text on images
   - Color contrast problems
   - Keyboard navigation
   - ARIA labels

4. Generate a detailed performance report with:
   - Current scores
   - Specific issues found
   - Recommendations for improvement
   - Estimated performance gains

Create GitHub issues for each category of problems found.
Link back to relevant TODO comments.
```

## Related TODO Comments
- ProductService.js: "Add pagination support for product listing"
- StorageService.js: "Image resizing/optimization needed"

## Expected Findings
- Performance Score: < 70 (Poor)
- Large image sizes (>500KB each)
- No lazy loading
- All 500+ products loaded at once
- Missing image alt text
- Color contrast issues

## Success Criteria
- Lighthouse audit completed
- Performance bottlenecks identified
- Accessibility issues documented
- GitHub issues created with metrics
- Links to TODO comments included
EOF

# Scenario 6: Cross-Browser Testing
cat > tests/e2e/scenarios/06-cross-browser-testing.md << 'EOF'
# Scenario 6: Cross-Browser Compatibility Testing

## Objective
Verify the application works correctly across different browsers.

## Gemini CLI Prompt
```
Test the product catalog in multiple browsers:

1. Chromium (default)
   - Test full product flow
   - Capture baseline screenshots

2. Firefox
   - Test same flows as Chromium
   - Compare screenshots for visual differences
   - Check for browser-specific CSS issues

3. WebKit (Safari simulation)
   - Test on mobile viewport (375x812 - iPhone)
   - Test on tablet viewport (768x1024 - iPad)
   - Check for touch interaction issues

For each browser:
- Take screenshots of key pages
- Test "Add to Cart" functionality
- Check image rendering
- Verify CSS grid layouts
- Test responsive design breakpoints

Generate a cross-browser compatibility report with:
- Browser-specific bugs found
- Visual differences (screenshot comparisons)
- Recommendations for fixes

Create GitHub issues for any browser-specific bugs.
```

## Test Viewports
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x812

## Expected Findings
- CSS differences between browsers
- Touch interaction issues on mobile
- Image rendering differences
- Layout shifts on smaller screens

## Success Criteria
- All three browsers tested
- Screenshots captured for comparison
- Browser-specific bugs documented
- GitHub issues created
EOF

echo -e "${GREEN}✅ Test scenarios created in tests/e2e/scenarios/${NC}"
echo ""

# Create README for the test suite
cat > tests/e2e/README.md << 'EOF'
# Browser Testing Demo with Gemini CLI + Playwright MCP

This directory contains E2E test scenarios for the catalog-service-node application using Gemini CLI with Docker MCP Toolkit.

## Prerequisites

1. **Docker Desktop 4.40+** with MCP Toolkit enabled
2. **Gemini CLI** installed
3. **Playwright MCP Server** configured in Docker MCP Toolkit
4. **GitHub MCP Server** configured (for creating issues)
5. **Filesystem MCP Server** configured (for saving screenshots)

## Setup Instructions

### 1. Start the Application

```bash
# Start all services
docker compose up -d

# Install dependencies and start the app
npm install --omit=optional
npm run dev
```

The React frontend will be available at http://localhost:5173

### 2. Configure Playwright MCP Server

In Docker Desktop:
1. Go to **MCP Toolkit** → **Catalog**
2. Search for "Playwright"
3. Click **+ Add** on "Playwright" or "Browser" MCP
4. Click **Start Server**

### 3. Verify MCP Connection

```bash
# In Gemini CLI
gemini mcp list

# Should show:
# ✓ Playwright
# ✓ GitHub  
# ✓ Filesystem
```

## Running Test Scenarios

Each scenario in the `scenarios/` directory can be run by copying the "Gemini CLI Prompt" section and pasting it into Gemini CLI.

### Example: Run Product Listing Test

```bash
# Start Gemini CLI in the project directory
gemini

# Then paste this prompt:
Test the product listing page at http://localhost:5173. 
Verify that:
1. The page loads without errors
2. Products are displayed in a grid layout
3. Each product shows: name, price, image, and "Add to Cart" button
4. Console has no JavaScript errors
5. All product images load successfully

Take screenshots and if issues are found, create a GitHub issue.
```

### Available Test Scenarios

1. **01-product-listing.md** - Tests product display and performance
2. **02-add-to-cart-flow.md** - Tests shopping cart functionality
3. **03-inventory-race-condition.md** - Reproduces race condition bug
4. **04-api-endpoint-testing.md** - Validates REST API endpoints
5. **05-performance-audit.md** - Runs Lighthouse performance audit
6. **06-cross-browser-testing.md** - Tests across browsers and devices

## What Gemini CLI Will Do

For each test scenario, Gemini CLI will:

1. ✅ Use **Playwright MCP** to control the browser
2. ✅ Navigate through the application
3. ✅ Take screenshots of key moments
4. ✅ Capture browser console errors
5. ✅ Monitor network requests
6. ✅ Use **Filesystem MCP** to save screenshots
7. ✅ Use **GitHub MCP** to create issues for bugs found
8. ✅ Generate test reports

## Expected Bugs to Discover

These bugs correspond to TODO comments in the codebase:

- ❌ **Performance**: Large unoptimized images
- ❌ **Performance**: No pagination (loads 500+ products)
- ❌ **Race Condition**: Inventory can go negative
- ❌ **Validation**: No duplicate SKU checking
- ❌ **Error Handling**: S3 upload failures silently ignored
- ❌ **Cleanup**: Product deletion doesn't remove S3 images
- ❌ **Accessibility**: Missing alt text on images
- ❌ **API**: Missing 404 handling

## Test Results Location

- Screenshots: `tests/e2e/screenshots/`
- Reports: `tests/e2e/reports/`
- GitHub Issues: Created automatically in your repository

## Tips for Best Results

1. **Run one scenario at a time** - Let Gemini complete each test fully
2. **Review screenshots** - Check the captured images for accuracy
3. **Verify GitHub issues** - Make sure issue details are correct
4. **Start with simple tests** - Begin with product listing before race conditions
5. **Clean up between tests** - Reset database if needed

## Workflow Comparison

### Before (Manual Testing)
```
1. Open browser → 1 min
2. Click through flows → 5 min
3. Take screenshots → 2 min
4. Check console → 1 min
5. Write bug report → 5 min
6. Create GitHub issue → 3 min
Total: ~17 minutes per test
```

### After (Gemini CLI + MCP)
```
1. Paste prompt in Gemini → 5 sec
2. Gemini runs full test → 30 sec
3. Screenshots captured → automatic
4. GitHub issue created → automatic
Total: ~35 seconds per test
```

**Time saved: 16+ minutes per test scenario!**

## Troubleshooting

### Application not accessible
```bash
# Check if services are running
docker compose ps

# Check if app is running
curl http://localhost:5173
```

### Playwright MCP not responding
```bash
# Restart the MCP server in Docker Desktop
# MCP Toolkit → Servers → Playwright → Restart
```

### Screenshots not saving
```bash
# Verify Filesystem MCP is configured
# Check allowed paths include this directory
```

## Next Steps

After running these tests:

1. Review all created GitHub issues
2. Compare with TODO comments in the codebase
3. Prioritize fixes based on severity
4. Create a sprint plan for addressing issues
5. Re-run tests after fixes to validate

## Learn More

- [Gemini CLI Documentation](https://ai.google.dev/gemini-api/docs)
- [Docker MCP Toolkit](https://docs.docker.com/desktop/mcp/)
- [Playwright Documentation](https://playwright.dev/)
EOF

echo -e "${GREEN}✅ README created${NC}"
echo ""

# Create a quick start script
cat > tests/e2e/quick-start.sh << 'EOF'
#!/bin/bash

echo "🚀 Quick Start: Browser Testing Demo"
echo ""
echo "This script will help you run the browser testing demo with Gemini CLI"
echo ""

# Check if services are running
if ! curl -s http://localhost:5173 > /dev/null; then
    echo "❌ Application is not running!"
    echo "Please start it with:"
    echo "  docker compose up -d"
    echo "  npm install --omit=optional && npm run dev"
    exit 1
fi

echo "✅ Application is running at http://localhost:5173"
echo ""

echo "📋 Available Test Scenarios:"
echo ""
echo "1. Product Listing Test (Performance)"
echo "2. Add to Cart Flow (Functionality)"
echo "3. Inventory Race Condition (Bug Reproduction)"
echo "4. API Endpoint Testing (Backend Validation)"
echo "5. Performance Audit (Lighthouse)"
echo "6. Cross-Browser Testing (Compatibility)"
echo ""

read -p "Which scenario would you like to run? (1-6): " choice

case $choice in
    1)
        scenario="01-product-listing.md"
        ;;
    2)
        scenario="02-add-to-cart-flow.md"
        ;;
    3)
        scenario="03-inventory-race-condition.md"
        ;;
    4)
        scenario="04-api-endpoint-testing.md"
        ;;
    5)
        scenario="05-performance-audit.md"
        ;;
    6)
        scenario="06-cross-browser-testing.md"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Opening scenario: scenarios/$scenario"
echo ""
cat "scenarios/$scenario"
echo ""
echo "---"
echo ""
echo "Copy the 'Gemini CLI Prompt' section above and paste it into Gemini CLI"
echo ""
EOF

chmod +x tests/e2e/quick-start.sh

echo -e "${GREEN}✅ Quick start script created${NC}"
echo ""

# Create a sample GitHub issue template
cat > tests/e2e/.github-issue-template.md << 'EOF'
# Bug Report Template

## Issue Title
[Brief description of the bug]

## Description
[Detailed description of what's wrong]

## Steps to Reproduce
1. Navigate to http://localhost:5173
2. Click on [specific element]
3. Observe [unexpected behavior]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Screenshots
![Screenshot](../screenshots/[filename].png)

## Browser Console Errors
```
[Console errors if any]
```

## Environment
- Browser: Chromium/Firefox/WebKit
- Viewport: 1920x1080 / Mobile
- Node Version: 22.x
- Date: [timestamp]

## Related TODO Comment
See: `src/services/[file].js:line`

## Suggested Fix
[Potential solution or next steps]

## Labels
`bug`, `e2e-testing`, `needs-triage`
EOF

echo -e "${GREEN}✅ GitHub issue template created${NC}"
echo ""

# Final summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Browser Testing Demo Setup Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "📁 Files created:"
echo "  └── tests/e2e/"
echo "      ├── README.md                              # Full documentation"
echo "      ├── quick-start.sh                         # Interactive runner"
echo "      ├── .github-issue-template.md              # Issue template"
echo "      └── scenarios/                             # 6 test scenarios"
echo "          ├── 01-product-listing.md"
echo "          ├── 02-add-to-cart-flow.md"
echo "          ├── 03-inventory-race-condition.md"
echo "          ├── 04-api-endpoint-testing.md"
echo "          ├── 05-performance-audit.md"
echo "          └── 06-cross-browser-testing.md"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. Start the application (if not already running):"
echo "   ${YELLOW}docker compose up -d${NC}"
echo "   ${YELLOW}npm install --omit=optional && npm run dev${NC}"
echo ""
echo "2. Configure Playwright MCP in Docker Desktop:"
echo "   • MCP Toolkit → Catalog → Search 'Playwright'"
echo "   • Click '+ Add' and 'Start Server'"
echo ""
echo "3. Run the quick start:"
echo "   ${YELLOW}cd tests/e2e${NC}"
echo "   ${YELLOW}./quick-start.sh${NC}"
echo ""
echo "4. Or read the full documentation:"
echo "   ${YELLOW}cat tests/e2e/README.md${NC}"
echo ""
echo -e "${GREEN}Happy Testing! 🎉${NC}"
echo ""
