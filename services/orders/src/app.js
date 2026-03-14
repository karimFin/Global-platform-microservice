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
let orders = [];
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
