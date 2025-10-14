const std = @import("std");

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

export fn init(width: u32, height: u32) void {
    _ = width;
    _ = height;
    state = .Idle;
    timer_ms = 0.0;
    last_reaction_ms = 0.0;
    clicked = false;
}

export fn seed_rng(seed: u64) void {
    rng_state = seed;
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
}

export fn on_action(down: u32) void {
    if (down != 0) {
        clicked = true;
    }
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
}
