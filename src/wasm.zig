const std = @import("std");

const impl = @import("lzw.zig");

const wasmAllocator = @import("./wasmAllocator.zig");
comptime {
    @export(wasmAllocator.allocUint8, .{ .name = "allocUint8", .linkage = .Strong });
    @export(wasmAllocator.allocUint16, .{ .name = "allocUint16", .linkage = .Strong });
    @export(wasmAllocator.free, .{ .name = "free", .linkage = .Strong });
}

export fn compress(ptr: [*]const u8, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u8 = ptr[0..length];
    var output = impl.compress(u16, 0, 0xFFFE, data, allocator) catch {
        return 0;
    };
    const r = output.toOwnedSliceSentinel(0) catch {
        return 0;
    };
    return @intCast(@intFromPtr(r.ptr));
}

export fn decompress(ptr: [*]const u16, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u16 = ptr[0..length];
    var output = impl.decompress(u16, 0, 0xFFFE, data, allocator) catch {
        return 0;
    };
    const r = output.toOwnedSliceSentinel(0) catch {
        return 0;
    };
    return @intCast(@intFromPtr(r.ptr));
}
