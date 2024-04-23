const std = @import("std");

const lzw = @import("lzw.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const str = try std.fs.cwd().readFileAlloc(allocator, "test/data/rw_large.json", 1e8);
    defer allocator.free(str);

    {
        const start = try std.time.Instant.now();
        for (0..10) |_| {
            var compressed = try lzw.compress(str, allocator);
            defer compressed.deinit();
        }
        const end = try std.time.Instant.now();

        const elapsed: f64 = @floatFromInt(end.since(start));
        std.debug.print("Compression Time:   {d:.3}ms\n", .{elapsed / std.time.ns_per_ms});
    }

    var compressed = try lzw.compress(str, allocator);
    defer compressed.deinit();
    {
        const start = try std.time.Instant.now();
        for (0..100) |_| {
            const unpackedData = try compressed.unpackWithReset(allocator, std.math.maxInt(lzw.BitPacker.ValueType));
            defer allocator.free(unpackedData);
        }
        const end = try std.time.Instant.now();
        const elapsed: f64 = @floatFromInt(end.since(start));
        std.debug.print("Unpacking Time:     {d:.3}ms\n", .{elapsed / std.time.ns_per_ms});
    }

    {
        const unpackedData = try compressed.unpackWithReset(allocator, std.math.maxInt(lzw.BitPacker.ValueType));
        defer allocator.free(unpackedData);

        const start = try std.time.Instant.now();
        for (0..100) |_| {
            var decompressed = try lzw.decompress(lzw.BitPacker.ValueType, 0, std.math.maxInt(lzw.BitPacker.ValueType), unpackedData, str.len, allocator);
            defer decompressed.deinit();
        }
        const end = try std.time.Instant.now();

        const elapsed: f64 = @floatFromInt(end.since(start));
        std.debug.print("Decompression Time: {d:.3}ms\n", .{elapsed / std.time.ns_per_ms});
    }
}
