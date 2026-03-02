const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();
const service = process.env.SERVICE_NAME || 'service';
const serviceUrls = {
  catalog: process.env.CATALOG_URL || 'http://catalog:8080',
  cart: process.env.CART_URL || 'http://cart:8080',
  checkout: process.env.CHECKOUT_URL || 'http://checkout:8080',
  orders: process.env.ORDERS_URL || 'http://orders:8080',
  search: process.env.SEARCH_URL || 'http://search:8080',
  ai: process.env.AI_URL || 'http://transformer-api:8080'
};

const forward = async (req, res, target) => {
  const hasBody = req.method !== 'GET' && req.method !== 'HEAD';
  const response = await fetch(target, {
    method: req.method,
    headers: { 'Content-Type': 'application/json' },
    body: hasBody ? JSON.stringify(req.body || {}) : undefined
  });
  const text = await response.text();
  let data;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  res.status(response.status).json(data);
};

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
  const query = new URLSearchParams(req.query).toString();
  const url = `${serviceUrls.catalog}/catalog/products${query ? `?${query}` : ''}`;
  return forward(req, res, url);
});

app.get('/catalog/products/:id', (req, res) => {
  return forward(req, res, `${serviceUrls.catalog}/catalog/products/${req.params.id}`);
});

app.get('/search', (req, res) => {
  const query = new URLSearchParams(req.query).toString();
  const url = `${serviceUrls.search}/search${query ? `?${query}` : ''}`;
  return forward(req, res, url);
});

app.get('/cart', (req, res) => {
  return forward(req, res, `${serviceUrls.cart}/cart`);
});

app.post('/cart/items', (req, res) => {
  return forward(req, res, `${serviceUrls.cart}/cart/items`);
});

app.delete('/cart/items/:productId', (req, res) => {
  return forward(req, res, `${serviceUrls.cart}/cart/items/${req.params.productId}`);
});

app.post('/cart/clear', (req, res) => {
  return forward(req, res, `${serviceUrls.cart}/cart/clear`);
});

app.post('/checkout', (req, res) => {
  return forward(req, res, `${serviceUrls.checkout}/checkout`);
});

app.get('/orders', (req, res) => {
  return forward(req, res, `${serviceUrls.orders}/orders`);
});

app.get('/orders/:id', (req, res) => {
  return forward(req, res, `${serviceUrls.orders}/orders/${req.params.id}`);
});

app.post('/ai/infer', (req, res) => {
  return forward(req, res, `${serviceUrls.ai}/infer`);
});

app.post('/ai/infer/batch', (req, res) => {
  return forward(req, res, `${serviceUrls.ai}/infer/batch`);
});

module.exports = app;
