const http = require('http');

const PORT = Number(process.env.PORT || 12580);

const ERROR_BODY = {
  error: {
    message:
      'Failed to forward request: POST "http://127.0.0.1:12580/tbe/vmodel/v1/chat/completions": 503 Service Unavailable {"code":"service_unavailable","message":"Service is temporarily unavailable. Please try again later.","type":"invalid_request_error"}',
    // message:"zidingyixiaoxi",
    type: 'api_error',
  },
};

const MATCHED_PATHS = new Set([
  '/v1/chat/completions',
  '/chat/completions',
  '/tbe/vmodel/v1/chat/completions',
]);

const server = http.createServer((req, res) => {
  const url = new URL(req.url || '/', `http://${req.headers.host || '127.0.0.1'}`);
  const body = JSON.stringify(ERROR_BODY);

  // Return a non-retryable 400 status for common model endpoints used by OpenCode/OpenAI-compatible clients.
  if (MATCHED_PATHS.has(url.pathname)) {
    res.writeHead(400, {
      'Content-Type': 'application/json; charset=utf-8',
      'Content-Length': Buffer.byteLength(body),
    });
    res.end(body);
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify({ error: { message: `Not Found: ${url.pathname}` } }));
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Mock 503 model server listening on http://127.0.0.1:${PORT}`);
  console.log('Available endpoints:');
  for (const path of MATCHED_PATHS) {
    console.log(`  - POST http://127.0.0.1:${PORT}${path}`);
  }
});
