const std = @import("std");

const lzw = @import("lzw.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const str = try std.fs.cwd().readFileAlloc(allocator, "test/data/rw_large.json", 1e8);
    defer allocator.free(str);

    const start = try std.time.Instant.now();
    for (0..10) |_| {
        var compressed = try lzw.compress(str, allocator);
        defer compressed.deinit();
    }
    const end = try std.time.Instant.now();

    const elapsed: f64 = @floatFromInt(end.since(start));
    std.debug.print("Time: {d:.3}ms\n", .{
        elapsed / std.time.ns_per_ms,
    });
}
