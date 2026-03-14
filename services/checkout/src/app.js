const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const crypto = require('crypto');
const { trace } = require('@opentelemetry/api');
const { Counter, Histogram, Registry, collectDefaultMetrics } = require('prom-client');

const app = express();
const service = process.env.SERVICE_NAME || 'service';
const ordersUrl = process.env.ORDERS_URL || 'http://orders:8080';
const metricsRegistry = new Registry();
collectDefaultMetrics({
  register: metricsRegistry,
  prefix: `${service.replace(/-/g, '_')}_`,
});
const requestCounter = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['service', 'method', 'route', 'status_code'],
  registers: [metricsRegistry],
});
const requestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['service', 'method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5],
  registers: [metricsRegistry],
});

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
app.use((req, res, next) => {
  const traceId = req.header('x-trace-id') || crypto.randomUUID();
  const span = trace.getTracer(service).startSpan(`${req.method} ${req.path}`);
  req.traceId = traceId;
  res.setHeader('x-trace-id', traceId);
  const started = process.hrtime.bigint();
  res.on('finish', () => {
    const seconds = Number(process.hrtime.bigint() - started) / 1e9;
    const route = req.route?.path || req.path;
    const statusCode = String(res.statusCode);
    requestCounter.inc({
      service,
      method: req.method,
      route,
      status_code: statusCode,
    });
    requestDuration.observe(
      {
        service,
        method: req.method,
        route,
        status_code: statusCode,
      },
      seconds
    );
    span.setAttribute('http.method', req.method);
    span.setAttribute('http.route', route);
    span.setAttribute('http.status_code', res.statusCode);
    span.setAttribute('gmp.trace_id', traceId);
    span.end();
  });
  next();
});

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

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', metricsRegistry.contentType);
  res.end(await metricsRegistry.metrics());
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
