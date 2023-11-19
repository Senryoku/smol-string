const std = @import("std");

const Context = @import("Context.zig");

pub fn compress(comptime TokenType: type, comptime reserved_codepoints: TokenType, comptime sentinel_token: TokenType, data: []const u8, allocator: std.mem.Allocator) !std.ArrayList(TokenType) {
    if (data.len == 0) return std.ArrayList(TokenType).init(allocator);

    const first_allocated_token: TokenType = comptime std.math.maxInt(u8) + 1 + reserved_codepoints;
    var next_value: TokenType = first_allocated_token;
    var context = Context.HashMap(TokenType).init(allocator);
    defer context.deinit();
    try context.ensureTotalCapacity(@min(sentinel_token + 1, data.len));

    var output = try std.ArrayList(TokenType).initCapacity(allocator, data.len);

    var i: usize = 0;
    var curr_len: usize = 2;
    var prev_value: ?TokenType = null;
    while (i + curr_len < data.len) {
        const str = data[i .. i + curr_len];
        const value = context.get(str);
        if (value == null) {
            output.appendAssumeCapacity(if (str.len == 2) (@as(TokenType, @intCast(str[0])) + reserved_codepoints) else prev_value.?);

            i += curr_len - 1;
            curr_len = 2;

            if (next_value == sentinel_token) {
                // Restart compression from here with a fresh context
                context.clearRetainingCapacity();
                // Insert special token. We can use next_value since it will never be used as currently written.
                output.appendAssumeCapacity(sentinel_token);
                next_value = first_allocated_token;
                continue;
            } else {
                context.putAssumeCapacityNoClobber(str, next_value);
                next_value += 1;
            }
        } else {
            curr_len += 1;
            prev_value = value;
        }
    }

    // Handle the last unencoded bytes.
    if (i + 1 >= data.len) {
        output.appendAssumeCapacity(@as(TokenType, @intCast(data[i])) + reserved_codepoints);
    } else {
        const value = context.get(data[i .. i + curr_len]);
        if (value == null) {
            output.appendAssumeCapacity(if (curr_len == 2) (@as(TokenType, @intCast(data[i])) + reserved_codepoints) else context.get(data[i .. i + curr_len - 1]).?);
            output.appendAssumeCapacity(@as(TokenType, @intCast(data[i + curr_len - 1])) + reserved_codepoints);
        } else {
            output.appendAssumeCapacity(value.?);
        }
    }

    return output;
}

pub fn decompress(comptime TokenType: type, comptime reserved_codepoints: TokenType, comptime sentinel_token: TokenType, data: []const TokenType, allocator: std.mem.Allocator) !std.ArrayList(u8) {
    if (data.len == 0) return std.ArrayList(u8).init(allocator);

    const first_allocated_token: TokenType = comptime std.math.maxInt(u8) + 1 + reserved_codepoints;
    var next_value: TokenType = first_allocated_token;
    var context = std.ArrayList(?[]u8).init(allocator);
    defer context.deinit();
    try context.ensureTotalCapacity(std.math.maxInt(TokenType));
    context.appendNTimesAssumeCapacity(null, std.math.maxInt(TokenType));

    // FIXME: We need to make sure pointers to that buffer will be stable for the slices in context to stay valid.
    var output = try std.ArrayList(u8).initCapacity(allocator, 24 * data.len);
    output.appendAssumeCapacity(@intCast(data[0] - reserved_codepoints));

    context.items[data[0]] = output.items[0..1];

    var prev_start: usize = 0;
    var i: usize = 1;
    while (i < data.len) {
        const v = data[i];

        // Special reset token
        if (v == sentinel_token) {
            i += 1; // Skip special token
            if (i >= data.len) break;
            // Reinitialize state
            next_value = first_allocated_token;
            context.clearRetainingCapacity();
            context.appendNTimesAssumeCapacity(null, std.math.maxInt(TokenType));
            prev_start = output.items.len;
            try std.testing.expect(data[i] < first_allocated_token);
            output.appendAssumeCapacity(@intCast(data[i] - reserved_codepoints));
            i += 1;
            continue;
        }

        const new_start = output.items.len;

        if (v < first_allocated_token) {
            output.appendAssumeCapacity(@intCast(v - reserved_codepoints));
        } else {
            const str = context.items[v];
            if (str == null) {
                // I think the only case where this might happen, is repeating characters.
                // For example, 'aaaa' will be encoded as [129, 288, 129], with 288 representing 'aa'.
                // However the decoder will never have encountered 'aa' before.
                // FIXME: Thoroughly test this.
                output.appendSliceAssumeCapacity(output.items[prev_start..new_start]);
                output.appendAssumeCapacity(output.items[prev_start]);
            } else output.appendSliceAssumeCapacity(context.items[v].?);
        }

        //                          equivalent to concat(prev_str, str[0])
        context.items[next_value] = output.items[prev_start .. new_start + 1];
        next_value += 1;

        prev_start = new_start;

        i += 1;
    }

    return output;
}

fn testRound(str: []const u8) !void {
    const compressed = try compress(u16, 32, 0xDFFE, str, std.testing.allocator);
    defer compressed.deinit();
    const decompressed = try decompress(u16, 32, 0xDFFE, compressed.items, std.testing.allocator);
    defer decompressed.deinit();
    try std.testing.expectEqualSlices(u8, str, decompressed.items);
}

test "basic" {
    try testRound("");
    try testRound("a");
    try testRound("aa");
    try testRound("aaaa");
    try testRound("aaaaaa");
    try testRound("aabbaaccaaccaavvbbaaxaaaavwaa");
    try testRound("1212121");
    try testRound("3737373");
    try testRound("3333737370");
    try testRound("3333737370000000000000000000000");
    try testRound("12121212");
    try testRound("37373737");
    try testRound("33337373737");
    try testRound("3333737373700000000000000000000");
    try testRound("3333773737373777777373773737373");
}

test "fuzzing" {
    // Doesn't ensure that the string is valid UTF-8, but it should not matter.
    // Note: In the future, use std.testing.random_seed. See https://github.com/ziglang/zig/issues/17609.
    const seed = std.crypto.random.int(u64);
    errdefer std.debug.print("\nFuzzing Test FAILED\n\tSeed: {d}\n", .{seed});
    var rng = std.rand.DefaultPrng.init(seed);
    for (0..10) |_| {
        const length = rng.random().intRangeAtMost(usize, 0, 10_000_000); // Up to ~10MB
        var str = try std.testing.allocator.alloc(u8, length);
        defer std.testing.allocator.free(str);
        rng.fill(str);
        try testRound(str);
    }
}

fn testFile(path: []const u8) !void {
    const str = try std.fs.cwd().readFileAlloc(std.testing.allocator, path, 1e8);
    defer std.testing.allocator.free(str);
    try testRound(str);
}

test "json 64KB" {
    try testFile("test/data/64KB.json");
}

test "json 128KB" {
    try testFile("test/data/128KB.json");
}

test "json 256KB" {
    try testFile("test/data/256KB.json");
}

test "json 512KB" {
    try testFile("test/data/512KB.json");
}

test "json 1MB" {
    try testFile("test/data/1MB.json");
}

test "json 5MB" {
    try testFile("test/data/5MB.json");
}

test "real world medium" {
    try testFile("test/data/rw_medium.json");
}

test "real world large" {
    try testFile("test/data/rw_large.json");
}
