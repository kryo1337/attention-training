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
  switch (msg.type) {
    case 'init':
      canvas = msg.canvas;
      W = msg.size.W; H = msg.size.H;
      ctx = canvas.getContext('2d', { 
        alpha: false, 
        desynchronized: true 
      });
      ctx.imageSmoothingEnabled = false;
      return;
    case 'paint':
      if (!ctx) return;
      const s = msg.state;
      if (msg.repaint) drawBackground(s);

      switch (s) {
        case 3: {
          const ms = msg.ms;
          ctx.fillStyle = '#ffcc00';
          ctx.font = '24px monospace';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';
          ctx.fillText(ms + ' ms', W >> 1, H >> 1);
          ctx.font = '14px monospace';
          ctx.fillStyle = '#ffffff';
          ctx.fillText('Click to begin next trial', W >> 1, (H >> 1) + 28);
          break;
        }
        case 0:
          ctx.fillStyle = '#ffffff';
          ctx.font = '16px monospace';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';
          ctx.fillText('Click to begin', W >> 1, H >> 1);
          break;
        case 4:
          ctx.fillStyle = '#ffffff';
          ctx.font = '18px monospace';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';
          ctx.fillText('False start! Click to restart trial', W >> 1, H >> 1);
          break;
      }
      break;
  }
};


