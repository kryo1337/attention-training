const std = @import("std");

const FB_W: u32 = 480;
const FB_H: u32 = 270;
var fb_static: [FB_W * FB_H]u32 = undefined;
var framebuffer: []u32 = fb_static[0..];
var canvas_width: u32 = FB_W;
var canvas_height: u32 = FB_H;

var rng_state: u64 = 0x9e3779b97f4a7c15;
fn randomU32() u32 {
    rng_state = rng_state *% 2862933555777941757 +% 3037000493;
    return @truncate(rng_state >> 32);
}

const GameState = enum { Idle, Waiting, Ready, Measured, FalseStart };
var state: GameState = .Idle;
var timer_ms: f32 = 0.0;
var target_delay_ms: f32 = 0.0;
var last_reaction_ms: f32 = 0.0;
var clicked: bool = false;

fn clamp(comptime T: type, v: T, lo: T, hi: T) T {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
}

fn fill(color: u32) void {
    for (framebuffer, 0..) |*pix, i| {
        _ = i;
        pix.* = color;
    }
}

fn drawBar(value_0_to_1: f32) void {
    const w: usize = @intCast(canvas_width);
    const h: usize = @intCast(canvas_height);
    const bar_h: usize = @max(4, h / 24);
    const margin: usize = @max(4, h / 36);
    const filled: usize = @intFromFloat(@floor(@as(f32, @floatFromInt(w)) * clamp(f32, value_0_to_1, 0.0, 1.0)));

    const y0 = h - margin - bar_h;
    const y1 = y0 + bar_h;
    const bg: u32 = 0x202020ff;
    const fg: u32 = 0xffcc00ff;
    for (y0..y1) |y| {
        const row_off: usize = y * w;
        for (0..w) |x| {
            framebuffer[row_off + x] = if (x < filled) fg else bg;
        }
    }
}

fn rgba(r: u8, g: u8, b: u8, a: u8) u32 {
    return (@as(u32, a) << 24) | (@as(u32, b) << 16) | (@as(u32, g) << 8) | r;
}

fn render() void {
    switch (state) {
        .Idle => {
            fill(rgba(0, 64, 192, 255));
            drawBar(0.0);
        },
        .Waiting => {
            fill(rgba(192, 32, 48, 255));
            drawBar(clamp(f32, timer_ms / @max(1.0, target_delay_ms), 0.0, 1.0));
        },
        .Ready => {
            fill(rgba(24, 160, 64, 255));
            const v = clamp(f32, timer_ms / 500.0, 0.0, 1.0);
            drawBar(v);
        },
        .Measured => {
            fill(rgba(128, 32, 192, 255));
            const v = clamp(f32, last_reaction_ms / 500.0, 0.0, 1.0);
            drawBar(v);
        },
        .FalseStart => {
            fill(rgba(0, 64, 192, 255));
            drawBar(0.0);
        },
    }
}

export fn init(width: u32, height: u32) void {
    canvas_width = width;
    canvas_height = height;
    const ww: usize = @intCast(width);
    const hh: usize = @intCast(height);
    const len: usize = ww * hh;
    _ = len;
    framebuffer = fb_static[0..];
    canvas_width = width;
    canvas_height = height;
    state = .Idle;
    timer_ms = 0.0;
    last_reaction_ms = 0.0;
    clicked = false;
    render();
}

export fn update(dt_ms: f32) void {
    timer_ms += dt_ms;

    switch (state) {
        .Idle => {
            if (clicked) {
                clicked = false;
                state = .Waiting;
                timer_ms = 0.0;
                const r = randomU32();
                const delay = 1500.0 + @as(f32, @floatFromInt(r % 1501));
                target_delay_ms = delay;
            }
        },
        .Waiting => {
            if (clicked) {
                clicked = false;
                state = .FalseStart;
                timer_ms = 0.0;
            } else if (timer_ms >= target_delay_ms) {
                state = .Ready;
                timer_ms = 0.0;
            }
        },
        .Ready => {
            if (clicked) {
                clicked = false;
                last_reaction_ms = timer_ms;
                state = .Measured;
                timer_ms = 0.0;
            }
        },
        .Measured => {
            if (clicked) {
                clicked = false;
                state = .Waiting;
                timer_ms = 0.0;
                const r = randomU32();
                const delay = 1500.0 + @as(f32, @floatFromInt(r % 1501));
                target_delay_ms = delay;
            }
        },
        .FalseStart => {
            if (clicked) {
                clicked = false;
                state = .Waiting;
                timer_ms = 0.0;
                const r = randomU32();
                const delay = 1500.0 + @as(f32, @floatFromInt(r % 1501));
                target_delay_ms = delay;
            }
        },
    }

    render();
}

export fn on_action(down: u32) void {
    if (down != 0) {
        clicked = true;
    }
}

export fn get_framebuffer_ptr() usize {
    return @intFromPtr(framebuffer.ptr);
}

export fn get_framebuffer_size() usize {
    return framebuffer.len * @sizeOf(u32);
}

export fn get_state() u32 {
    return @intFromEnum(state);
}

export fn get_last_reaction_ms() f32 {
    return last_reaction_ms;
}

export fn reset() void {
    state = .Idle;
    timer_ms = 0.0;
    last_reaction_ms = 0.0;
    clicked = false;
    render();
}
