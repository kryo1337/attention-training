# Reaction Time

Minimal web-based reaction time game using Zig targeting `wasm32-freestanding`, with a Canvas/JS loader.

## Controls

- Space or mouse click: start / react
- Restart button: trigger next round

## Notes

- Rendering: OffscreenCanvas Worker with main-thread fallback, background only re-drawn on state changes.
- Input: pointer events with `passive:false`; timestamped measurement (event.timeStamp - readyAt) to avoid frame quantization.
- Timing: high-res timers via COOP/COEP headers (crossOriginIsolated)

