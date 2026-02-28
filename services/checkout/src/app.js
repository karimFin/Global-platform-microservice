const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();
const service = process.env.SERVICE_NAME || 'service';
const ordersUrl = process.env.ORDERS_URL || 'http://orders:8080';

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

app.post('/checkout', async (req, res) => {
  const { items = [], currency = 'USD' } = req.body || {};
  const total = items.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 0), 0);
  const payment = {
    id: `pay-${Date.now()}`,
    provider: 'MockPay Gateway',
    status: 'paid',
    reference: `mp-${Math.floor(Math.random() * 1e6)}`
  };
  const payload = {
    items,
    currency,
    total: Number(total.toFixed(2)),
    payment,
    status: 'confirmed'
  };
  try {
    const response = await fetch(`${ordersUrl}/orders`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await response.json();
    return res.status(response.status).json(data);
  } catch (error) {
    return res.status(502).json({ error: 'orders_unavailable', payment, fallback: payload });
  }
});

module.exports = app;
