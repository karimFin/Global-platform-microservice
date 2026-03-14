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
