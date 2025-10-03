import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname } from 'node:path';

const port = process.env.PORT || 3000;

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
};

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);
    let path = url.pathname;
    if (path === '/' || path === '') path = '/index.html';
    const filePath = new URL(`.${path}`, import.meta.url);
    const data = await readFile(filePath);
    const type = mime[extname(path)] || 'application/octet-stream';
    res.writeHead(200, { 'content-type': type, 'cache-control': 'no-store' });
    res.end(data);
  } catch (err) {
    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Not found');
  }
});

server.listen(port, () => {
  console.log(`listening on :${port}`);
});

