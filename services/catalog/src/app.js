const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();
const service = process.env.SERVICE_NAME || 'service';
const products = [
  { id: 'sku-101', name: 'Wireless Headphones', price: 129.99, category: 'Electronics', region: 'North America', stock: 140 },
  { id: 'sku-102', name: 'Smart Watch Pro', price: 199.0, category: 'Wearables', region: 'Europe', stock: 88 },
  { id: 'sku-103', name: 'Ergonomic Desk Chair', price: 249.5, category: 'Office', region: 'Asia Pacific', stock: 52 },
  { id: 'sku-104', name: 'LED Monitor 27"', price: 179.0, category: 'Accessories', region: 'North America', stock: 64 },
  { id: 'sku-105', name: 'Mechanical Keyboard', price: 89.0, category: 'Accessories', region: 'Europe', stock: 210 },
  { id: 'sku-106', name: 'Portable SSD 1TB', price: 139.0, category: 'Storage', region: 'Global', stock: 72 },
  { id: 'sku-107', name: 'Smart Home Hub', price: 159.0, category: 'Home', region: 'Middle East', stock: 39 },
  { id: 'sku-108', name: 'Fitness Tracker', price: 79.0, category: 'Wearables', region: 'Latin America', stock: 120 }
];

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());
app.use(morgan('combined'));
app.use(
  rateLimit({
    windowMs: 60_000,
    max: 120,
  })
);

app.get('/', (req, res) => {
  res.json({ service, status: 'running' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service });
});

app.get('/ready', (req, res) => {
  res.json({ status: 'ready', service });
});

app.get('/startup', (req, res) => {
  res.json({ status: 'started', service });
});

app.get('/ping', (req, res) => {
  res.json({ service, pong: true });
});

app.get('/catalog/products', (req, res) => {
  const { q, region, category } = req.query;
  const query = (q || '').toString().trim().toLowerCase();
  const filtered = products.filter(product => {
    const matchesQuery = !query || `${product.name} ${product.category}`.toLowerCase().includes(query);
    const matchesRegion = !region || product.region === region;
    const matchesCategory = !category || product.category === category;
    return matchesQuery && matchesRegion && matchesCategory;
  });
  res.json(filtered);
});

app.get('/catalog/products/:id', (req, res) => {
  const product = products.find(item => item.id === req.params.id);
  if (!product) {
    return res.status(404).json({ error: 'not_found' });
  }
  return res.json(product);
});

module.exports = app;
