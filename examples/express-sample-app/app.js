const express = require('express');
const { trace, context } = require('@opentelemetry/api');

const PORT = parseInt(process.env.PORT || '8080');
const app = express();
const tracer = trace.getTracer(process.env.OTEL_SERVICE_NAME);

async function getRandomNumber(min, max, parent) {
  const ctx = trace.setSpan(context.active(), parent);
  return tracer.startActiveSpan(
    'getRandomNumber',
    undefined,
    ctx,
    async (span) => {
      const val = Math.floor(Math.random() * (max - min) + min);
      span.setAttribute('key', 'value');
      // Annotate our span to capture metadata about our operation
      span.addEvent('invoking getRandomNumber');
      // end span
      span.end();
      return val;
    },
  );
}

app.get('/rolldice', async (req, res) => {
  // Create a span. A span must be closed.
  const parentSpan = tracer.startSpan('main');
  const number = (await getRandomNumber(1, 6, parentSpan)).toString();
  parentSpan.end();
  res.send(number);
});

app.listen(PORT, () => {
  console.log(`Listening for requests on http://localhost:${PORT}`);
});
