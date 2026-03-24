# Repository Architecture Analysis — Catalog Service (Node)

This repository is a demo catalog service built around a Node/Express API with supporting infrastructure for Postgres, Kafka, S3 (via LocalStack), and a simple React/Vite demo client.

## Frontend components

- `dev/webapp/` is a standalone React + Vite demo client.
- Entry points:
  - `dev/webapp/src/main.jsx` boots the React app.
  - `dev/webapp/src/App.jsx` renders the catalog table and controls (refresh + create).
  - `dev/webapp/src/ProductRow.jsx` renders per-product UI, including inventory fetch and image upload.
- UI behavior:
  - Fetches catalog via `GET /api/products`.
  - Creates products via `POST /api/products`.
  - Fetches per-product inventory via `GET /api/products/:id`.
  - Uploads an image via `POST /api/products/:id/image`.
  - Displays images via `GET /api/products/:id/image`.
- Static assets:
  - `dev/webapp/src/sample-products.json` seeds product names/descriptions.
  - `dev/webapp/src/product-image.png` used for demo image uploads.

## Backend logic

- Main server: `src/index.js` (Express)
  - Routes:
    - `GET /` health-ish “Hello World”.
    - `GET /api/products` lists catalog items.
    - `POST /api/products` creates a product and returns `201` + `Location`.
    - `GET /api/products/:id` returns product details + inventory info.
    - `GET /api/products/:id/image` streams S3 image.
    - `POST /api/products/:id/image` uploads image (multipart via `multer`).
  - Shutdown hooks: on `SIGINT`/`SIGTERM`, tears down DB and Kafka connections.
- Service modules in `src/services/`:
  - `ProductService.js`: catalog CRUD + inventory enrichment + image updates.
  - `InventoryService.js`: HTTP client to external inventory API.
  - `StorageService.js`: S3 (or LocalStack) image storage.
  - `PublisherService.js`: Kafka publishing for product/image events.

## Product catalog logic

- **Data model**
  - Defined in `dev/db/1-create-schema.sql`.
  - `products` table: `id`, `name`, `description`, `upc` (unique), `price`, `has_image`.
- **Listing products**
  - `ProductService.getProducts()` runs `SELECT * FROM products ORDER BY id ASC`.
- **Creating products**
  - `ProductService.createProduct()` inserts into Postgres and enforces UPC uniqueness.
  - Publishes a Kafka event `{ action: "product_created", ... }` on topic `products`.
- **Fetching a product**
  - `ProductService.getProductById()` loads product row and enriches with inventory data from `InventoryService.getInventoryForProduct(upc)`.
- **Images**
  - `StorageService.uploadFile()` writes `product.png` to S3 under `<id>/product.png`, then publishes `{ action: "image_uploaded", ... }` to Kafka.
  - `ProductService.uploadProductImage()` sets `has_image = TRUE`.
  - `StorageService.getFile()` streams the stored image back.
- **External dependencies**
  - Inventory service base URL via `INVENTORY_SERVICE_BASE_URL`.
  - S3 endpoint via `AWS_ENDPOINT_URL` (LocalStack in dev/integration tests).
  - Kafka brokers via `KAFKA_BOOTSTRAP_SERVERS`.

## Testing infrastructure

- **Test runner**: Jest (see `package.json` scripts).
- **Unit tests**:
  - `test/services/InventoryService.spec.js` mocks `node-fetch` to validate inventory error/success handling.
- **Integration tests (Testcontainers)**:
  - `test/integration/productCreation.integration.spec.js` spins up Postgres, Kafka, and LocalStack containers and validates:
    - product creation,
    - Kafka publishing,
    - image upload/round-trip from S3,
    - UPC uniqueness.
  - Helpers:
    - `test/integration/containerSupport.js` boots containers and wires env vars.
    - `test/integration/kafkaSupport.js` provides a Kafka consumer with message matching.
- **E2E scripts**:
  - `test/e2e/run-browser-testing-demo.sh` and `test/e2e/seed-test-data.sh` exist for demo flows.

## Supporting infrastructure and dev tooling

- `compose.yaml` defines local dependencies (Postgres, Kafka, LocalStack, WireMock, pgAdmin, kafbat).
- `dev/scripts/` contains helper scripts for API interactions (mentioned in `README.md`).
- `.env.node` (referenced by test scripts) is used for local/test configuration.

## Architectural summary

- **API service**: Node + Express, with a thin routing layer in `src/index.js`.
- **Persistence**: Postgres; schema initializes in `dev/db/1-create-schema.sql`.
- **Events**: Kafka topic `products` for product/image lifecycle events.
- **Binary storage**: S3-compatible storage (LocalStack in dev/tests).
- **External system**: Inventory API accessed via HTTP on product detail requests.
- **Frontend**: a lightweight React/Vite demo client in `dev/webapp/`.
