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
    const content_length = output.items.len;
    output.ensureTotalCapacity(output.items.len + 4) catch {
        return 0;
    };
    output.appendAssumeCapacity(@intCast(content_length >> 16));
    output.appendAssumeCapacity(@intCast(content_length & 0xFFFF));
    output.appendAssumeCapacity(@intCast(output.capacity >> 16));
    output.appendAssumeCapacity(@intCast(output.capacity & 0xFFFF));

    return @intCast(@intFromPtr(output.items.ptr + content_length));
}

export fn decompress(ptr: [*]const u16, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u16 = ptr[0..length];
    var output = impl.decompress(u16, 0, 0xFFFE, data, allocator) catch {
        return 0;
    };

    const content_length = output.items.len;
    output.ensureTotalCapacity(output.items.len + 8) catch {
        return 0;
    };
    output.appendAssumeCapacity(@intCast((content_length >> 24) & 0xFF));
    output.appendAssumeCapacity(@intCast((content_length >> 16) & 0xFF));
    output.appendAssumeCapacity(@intCast((content_length >> 8) & 0xFF));
    output.appendAssumeCapacity(@intCast((content_length >> 0) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 24) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 16) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 8) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 0) & 0xFF));

    return @intCast(@intFromPtr(output.items.ptr + content_length));
}
