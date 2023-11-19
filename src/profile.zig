const std = @import("std");

const lzw = @import("lzwPacked.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const str = try std.fs.cwd().readFileAlloc(allocator, "test/data/rw_large.json", 1e8);
    defer allocator.free(str);

    for (0..10) |_| {
        var compressed = try lzw.compressPacked(str, allocator);
        defer compressed.deinit();
    }
}
