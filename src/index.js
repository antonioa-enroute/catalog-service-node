// TODO: Add request rate limiting
// API has no throttling, vulnerable to abuse
// Need per-IP rate limiting

// FIXME: Error responses expose internal details
// Stack traces visible in production
// Should sanitize errors before returning to client

// TODO: Add health check endpoint
// Need /health endpoint for load balancer checks
// Should verify DB, Kafka, and S3 connectivity



require("dotenv").config();
const os = require("os");
const fs = require("fs");
const express = require("express");
const ProductService = require("./services/ProductService");
const PublisherService = require("./services/PublisherService");
const multer = require("multer");

const app = express();
app.use(express.json());
const upload = multer({ dest: os.tmpdir() });

app.get("/", (req, res) => {
  res.send("Hello World!!!");
});

app.get("/api/products", async (req, res) => {
  const products = await ProductService.getProducts();
  res.json(products);
});

app.post("/api/products", async (req, res) => {
  try {
    const newProduct = await ProductService.createProduct(req.body);

    res
      .status(201)
      .header("Location", `/api/products/${newProduct.id}`)
      .json(newProduct);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get("/api/products/:id", async (req, res) => {
  const product = await ProductService.getProductById(req.params.id);

  if (!product) {
    res.status(404).send();
    return;
  }

  res.json(product);
});

app.get("/api/products/:id/image", async (req, res) => {
  const product = await ProductService.getProductById(req.params.id);

  if (!product) {
    res.status(404).send();
    return;
  }

  const imageStream = await ProductService.getProductImage(req.params.id);

  if (!imageStream) {
    res.status(404).send();
    return;
  }

  res.contentType("image/png");
  imageStream.pipe(res);
});

app.post("/api/products/:id/image", upload.single("file"), async (req, res) => {
  const product = await ProductService.uploadProductImage(
    req.params.id,
    fs.readFileSync(req.file.path),
  );

  res.json(product);
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});

["SIGINT", "SIGTERM"].forEach((signal) => {
  process.on(signal, async () => {
    console.log(`Received ${signal}, shutting down...`);
    await ProductService.teardown();
    await PublisherService.teardown();
    process.exit(0);
  });
});
