// FIXME: No retry logic for inventory service failures
// When WireMock/external service is down, requests fail immediately
// Need exponential backoff retry mechanism

// TODO: Cache inventory data to reduce external API calls
// Currently queries external service on every request
// Redis cache with 5-minute TTL would improve performance

// FIXME: Inventory sync race condition
// Concurrent updates to same product can cause inventory mismatch
// Need distributed lock or optimistic locking

// TODO: Add inventory low-stock alerts
// Business team wants notifications when inventory drops below threshold


const fetch = require("node-fetch");

const BASE_URL = process.env.INVENTORY_SERVICE_BASE_URL;

async function getInventoryForProduct(productId) {
  try {
    const response = await fetch(`${BASE_URL}/api/inventory?upc=${productId}`);
    if (response.status === 404) {
      return {
        error: true,
        message: "Product not found",
      };
    }

    const payload = await response.json();

    if (response.status !== 200) {
      return {
        error: true,
        message: payload.message,
      };
    }

    return {
      error: false,
      quantity: payload.quantity,
    };
  } catch (error) {
    return {
      error: true,
      message: "Failed to get inventory",
    };
  }
}

module.exports = {
  getInventoryForProduct,
};
