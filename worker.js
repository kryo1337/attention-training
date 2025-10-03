let canvas = null;
let ctx = null;
let W = 0, H = 0;

function drawBackground(state) {
  if (state === 0) ctx.fillStyle = '#0040c0';
  else if (state === 1 || state === 4) ctx.fillStyle = '#c02030';
  else if (state === 2) ctx.fillStyle = '#18a040';
  else ctx.fillStyle = '#8020c0';
  ctx.fillRect(0, 0, W, H);
}

self.onmessage = (e) => {
  const msg = e.data;
  if (msg.type === 'init') {
    canvas = msg.canvas;
    W = msg.size.W; H = msg.size.H;
    ctx = canvas.getContext('2d');
    ctx.imageSmoothingEnabled = false;
    return;
  }
  if (!ctx) return;

  if (msg.type === 'paint') {
    const s = msg.state;
    if (msg.repaint) drawBackground(s);

    if (s === 3) {
      const ms = msg.ms;
      ctx.fillStyle = '#ffcc00';
      ctx.font = '24px system-ui, -apple-system, Segoe UI, Roboto, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(ms + ' ms', W >> 1, H >> 1);
      ctx.font = '14px system-ui, -apple-system, Segoe UI, Roboto, sans-serif';
      ctx.fillStyle = '#ffffff';
      ctx.fillText('Click to begin next trial', W >> 1, (H >> 1) + 28);
    } else if (s === 0) {
      ctx.fillStyle = '#ffffff';
      ctx.font = '16px system-ui, -apple-system, Segoe UI, Roboto, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('Click to begin', W >> 1, H >> 1);
    } else if (s === 4) {
      ctx.fillStyle = '#ffffff';
      ctx.font = '18px system-ui, -apple-system, Segoe UI, Roboto, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('False start! Click to restart trial', W >> 1, H >> 1);
    }
  }
};


