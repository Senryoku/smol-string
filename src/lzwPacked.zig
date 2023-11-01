const std = @import("std");

const bp = @import("./BitPacker.zig");

const impl = @import("lzw.zig");

pub const BitPacker = bp.BitPacker(u16, u20, 9, 0);
pub const sentinel_token = std.math.maxInt(BitPacker.ValueType);

pub fn compressPacked(data: []const u8, allocator: std.mem.Allocator) !BitPacker {
    if (data.len == 0) return BitPacker.init(allocator);

    const first_allocated_token: BitPacker.ValueType = comptime std.math.maxInt(u8) + 1;
    var next_value: BitPacker.ValueType = first_allocated_token;
    var context = std.StringHashMap(BitPacker.ValueType).init(allocator);
    defer context.deinit();

    var output = try BitPacker.initCapacity(allocator, data.len);

    var i: usize = 0;
    var curr_len: usize = 2;
    while (i + curr_len < data.len) {
        const str = data[i .. i + curr_len];
        const value = context.get(str);
        if (value == null) {
            try context.put(str, next_value);
            next_value += 1;
            try output.append(if (str.len == 2) (@as(BitPacker.ValueType, @intCast(str[0]))) else context.get(str[0 .. str.len - 1]).?);

            i += curr_len - 1;
            curr_len = 2;

            if (next_value == sentinel_token) {
                // Restart compression from here with a fresh context
                context.clearRetainingCapacity();
                // Insert special token. We can use next_value since it will never be used as currently written.
                try output.append(next_value);
                output.resetValueSize();
                next_value = first_allocated_token;
                continue;
            }
        } else curr_len += 1;
    }

    // Handle the last unencoded bytes.
    if (i + 1 >= data.len) {
        try output.append(@intCast(data[i]));
    } else {
        const value = context.get(data[i .. i + curr_len]);
        if (value == null) {
            try output.append(if (curr_len == 2) (@as(BitPacker.ValueType, @intCast(data[i]))) else context.get(data[i .. i + curr_len - 1]).?);
            try output.append(@intCast(data[i + curr_len - 1]));
        } else {
            try output.append(value.?);
        }
    }

    return output;
}

fn testRound(str: []const u8) !void {
    var compressed = try compressPacked(str, std.testing.allocator);
    defer compressed.deinit();
    const unpacked = try compressed.unpackWithReset(std.testing.allocator, sentinel_token);
    defer std.testing.allocator.free(unpacked);
    const decompressed = try impl.decompress(BitPacker.ValueType, 0, sentinel_token, unpacked, std.testing.allocator);
    defer decompressed.deinit();
    try std.testing.expectEqualSlices(u8, str, decompressed.items);
}

fn testFile(path: []const u8) !void {
    const str = try std.fs.cwd().readFileAlloc(std.testing.allocator, path, 1e8);
    defer std.testing.allocator.free(str);
    try testRound(str);
}

test "basic" {
    try testRound("");
    try testRound("a");
    try testRound("aa");
    try testRound("aaa");
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
