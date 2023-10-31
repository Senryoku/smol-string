const std = @import("std");

const impl = @import("lzw.zig");

const wasmAllocator = @import("./wasmAllocator.zig");
comptime {
    @export(wasmAllocator.allocUint8, .{ .name = "allocUint8", .linkage = .Strong });
    @export(wasmAllocator.allocUint16, .{ .name = "allocUint16", .linkage = .Strong });
    @export(wasmAllocator.free, .{ .name = "free", .linkage = .Strong });
}

export fn compress(null_terminated: [*:0]const u8) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u8 = std.mem.span(null_terminated); // FIXME: Should we pass a length?
    var output = impl.compress(u16, 0, 0xFFFE, data, allocator) catch {
        return 0;
    };
    const r = output.toOwnedSliceSentinel(0) catch {
        return 0;
    };
    return @intCast(@intFromPtr(r.ptr));
}

export fn decompress(null_terminated: [*:0]const u16) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u16 = std.mem.span(null_terminated);
    var output = impl.decompress(u16, 0, 0xFFFE, data, allocator) catch {
        return 0;
    };
    const r = output.toOwnedSliceSentinel(0) catch {
        return 0;
    };
    return @intCast(@intFromPtr(r.ptr));
}
