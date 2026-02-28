const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();
const service = process.env.SERVICE_NAME || 'service';
let orders = [];

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

app.get('/orders', (req, res) => {
  res.json(orders);
});

app.get('/orders/:id', (req, res) => {
  const order = orders.find(item => item.id === req.params.id);
  if (!order) {
    return res.status(404).json({ error: 'not_found' });
  }
  return res.json(order);
});

app.post('/orders', (req, res) => {
  const { items = [], currency = 'USD', total = 0, payment = null, status = 'created' } = req.body || {};
  const id = `ord-${Date.now()}`;
  const order = { id, items, currency, total, payment, status };
  orders = [order, ...orders].slice(0, 25);
  res.status(201).json(order);
});

module.exports = app;
