#!/bin/bash

# Seed test data script for Browser Testing Demo
# Creates products with specific characteristics to reveal bugs

set -e

API_URL="http://localhost:3000/api"

echo "🌱 Seeding test data for browser testing demo..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if API is accessible
if ! curl -s "$API_URL/products" > /dev/null; then
    echo "❌ API not accessible at $API_URL"
    echo "Please make sure the application is running:"
    echo "  docker compose up -d"
    echo "  npm run dev"
    exit 1
fi

echo -e "${GREEN}✅ API is accessible${NC}"
echo ""

# Create products with specific characteristics
echo -e "${BLUE}Creating test products...${NC}"

# Product 1: Normal product (control)
echo "1. Creating normal product (Vintage Camera)..."
curl -s -X POST "$API_URL/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vintage Camera",
    "description": "Classic 35mm film camera",
    "price": 299.99,
    "sku": "CAM-001",
    "category": "Electronics"
  }' > /dev/null

# Product 2: Last item in stock (for race condition test)
echo "2. Creating limited stock product (Rare Vinyl Record)..."
curl -s -X POST "$API_URL/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Rare Vinyl Record",
    "description": "Limited edition album - ONLY 1 LEFT!",
    "price": 149.99,
    "sku": "VINYL-001",
    "category": "Music",
    "inventory": 1
  }' > /dev/null

# Product 3: Product with very large image (performance test)
echo "3. Creating product with large image (Professional Camera)..."
curl -s -X POST "$API_URL/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Professional DSLR Camera",
    "description": "High-resolution 50MP camera with 8K video",
    "price": 2499.99,
    "sku": "CAM-PRO-001",
    "category": "Electronics",
    "imageUrl": "https://images.unsplash.com/photo-1606980598951-b39f5b7f2fdb?w=4000"
  }' > /dev/null

# Product 4: Duplicate SKU (should fail validation - bug!)
echo "4. Attempting to create duplicate SKU (tests validation)..."
curl -s -X POST "$API_URL/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Another Vintage Camera",
    "description": "Same SKU as product 1",
    "price": 299.99,
    "sku": "CAM-001",
    "category": "Electronics"
  }' > /dev/null
echo "   ⚠️  This should fail but might succeed (validation bug)"

# Product 5: Negative price (should fail - validation bug!)
echo "5. Attempting negative price (tests validation)..."
curl -s -X POST "$API_URL/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Broken Pricing",
    "description": "This has a negative price",
    "price": -50.00,
    "sku": "BROKEN-001",
    "category": "Test"
  }' > /dev/null
echo "   ⚠️  This should fail but might succeed (validation bug)"

# Product 6-20: Bulk products for pagination test
echo "6-20. Creating bulk products (tests pagination issue)..."
for i in {6..20}; do
    curl -s -X POST "$API_URL/products" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"Test Product $i\",
        \"description\": \"Product for bulk testing\",
        \"price\": $((RANDOM % 500 + 50)).99,
        \"sku\": \"BULK-$(printf '%03d' $i)\",
        \"category\": \"Test\"
      }" > /dev/null
    echo "   Created: Test Product $i"
done

echo ""
echo -e "${GREEN}✅ Test data seeded successfully${NC}"
echo ""

# Verify products were created
PRODUCT_COUNT=$(curl -s "$API_URL/products" | grep -o '"id"' | wc -l)
echo "📊 Total products in database: $PRODUCT_COUNT"
echo ""

# Create a test summary file
cat > tests/e2e/TEST-DATA.md << 'EOF'
# Test Data Reference

This document describes the test data seeded for browser testing scenarios.

## Test Products

### 1. Vintage Camera (CAM-001)
- **Purpose**: Normal product (control)
- **Price**: $299.99
- **Stock**: Normal
- **Tests**: Basic functionality

### 2. Rare Vinyl Record (VINYL-001)
- **Purpose**: Race condition testing
- **Price**: $149.99
- **Stock**: 1 (last item!)
- **Tests**: Inventory synchronization bug
- **Expected Bug**: Two users can both purchase the last item

### 3. Professional DSLR Camera (CAM-PRO-001)
- **Purpose**: Performance testing
- **Price**: $2,499.99
- **Image**: 4000px wide (large file)
- **Tests**: Image optimization TODO
- **Expected Issue**: Slow page load, large image size

### 4. Another Vintage Camera (CAM-001) - Duplicate SKU
- **Purpose**: Validation testing
- **SKU**: CAM-001 (duplicate!)
- **Tests**: Duplicate SKU validation TODO
- **Expected Bug**: Should fail but might succeed

### 5. Broken Pricing (BROKEN-001)
- **Purpose**: Validation testing
- **Price**: -$50.00 (negative!)
- **Tests**: Price validation TODO
- **Expected Bug**: Should fail but might succeed

### 6-20. Test Product 1-15 (BULK-001 to BULK-015)
- **Purpose**: Pagination testing
- **Tests**: Pagination TODO
- **Expected Issue**: All 20+ products load at once (performance)

## Test Scenarios Using This Data

### Scenario 1: Product Listing
Uses: All products
Expected Finding: Page loads slowly, all products at once (no pagination)

### Scenario 2: Add to Cart
Uses: Product #1 (Vintage Camera)
Expected Finding: Basic functionality works

### Scenario 3: Race Condition
Uses: Product #2 (Rare Vinyl Record)
Expected Finding: Two simultaneous purchases both succeed, inventory goes negative

### Scenario 4: API Validation
Uses: Products #4 and #5
Expected Finding: Duplicate SKU accepted, negative price accepted

### Scenario 5: Performance
Uses: Product #3 (Professional DSLR) + all products
Expected Finding: Large images not optimized, no lazy loading

## Verifying Test Data

Check products in database:
```bash
curl http://localhost:3000/api/products | jq '.'
```

Or use pgAdmin:
- URL: http://localhost:5050
- Password: postgres
- Query: `SELECT * FROM products;`

## Resetting Test Data

To reset and re-seed:
```bash
# Drop and recreate database
docker compose down -v
docker compose up -d

# Wait for services to start
sleep 10

# Re-seed data
./seed-test-data.sh
```
EOF

echo -e "${BLUE}📄 Test data reference created: tests/e2e/TEST-DATA.md${NC}"
echo ""

echo "🎯 Ready for testing!"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:5173 to see the products"
echo "2. Run ${YELLOW}cd tests/e2e && ./quick-start.sh${NC}"
echo "3. Choose a test scenario"
echo "4. Watch Gemini CLI find the bugs!"
echo ""
