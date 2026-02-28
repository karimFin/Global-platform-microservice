const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();
const service = process.env.SERVICE_NAME || 'service';
const catalogLookup = {
  'sku-101': { name: 'Wireless Headphones', price: 129.99 },
  'sku-102': { name: 'Smart Watch Pro', price: 199.0 },
  'sku-103': { name: 'Ergonomic Desk Chair', price: 249.5 },
  'sku-104': { name: 'LED Monitor 27"', price: 179.0 },
  'sku-105': { name: 'Mechanical Keyboard', price: 89.0 },
  'sku-106': { name: 'Portable SSD 1TB', price: 139.0 },
  'sku-107': { name: 'Smart Home Hub', price: 159.0 },
  'sku-108': { name: 'Fitness Tracker', price: 79.0 }
};

let cart = {
  id: 'cart-1',
  currency: 'USD',
  items: []
};

const computeTotals = items => {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  return { subtotal: Number(subtotal.toFixed(2)), total: Number(subtotal.toFixed(2)) };
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

app.get('/cart', (req, res) => {
  const totals = computeTotals(cart.items);
  res.json({ ...cart, ...totals });
});

app.post('/cart/items', (req, res) => {
  const { productId, quantity = 1, name, price } = req.body || {};
  const resolved = catalogLookup[productId] || {};
  const itemName = name || resolved.name;
  const itemPrice = price || resolved.price;
  if (!productId || !itemName || !itemPrice) {
    return res.status(400).json({ error: 'invalid_item' });
  }
  const qty = Math.max(1, Number(quantity) || 1);
  const existing = cart.items.find(item => item.productId === productId);
  if (existing) {
    existing.quantity += qty;
  } else {
    cart.items.push({ productId, name: itemName, price: itemPrice, quantity: qty });
  }
  const totals = computeTotals(cart.items);
  return res.json({ ...cart, ...totals });
});

app.delete('/cart/items/:productId', (req, res) => {
  cart.items = cart.items.filter(item => item.productId !== req.params.productId);
  const totals = computeTotals(cart.items);
  res.json({ ...cart, ...totals });
});

app.post('/cart/clear', (req, res) => {
  cart.items = [];
  const totals = computeTotals(cart.items);
  res.json({ ...cart, ...totals });
});

module.exports = app;
