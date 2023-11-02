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
    const item_count = output.items.len;
    const content_length = 2 * item_count; // In bytes
    const capacity_in_bytes = 2 * output.capacity;
    output.ensureTotalCapacity(item_count + 4) catch {
        return 0;
    };
    output.appendAssumeCapacity(@intCast(content_length & 0xFFFF));
    output.appendAssumeCapacity(@intCast(content_length >> 16));
    output.appendAssumeCapacity(@intCast(capacity_in_bytes & 0xFFFF));
    output.appendAssumeCapacity(@intCast(capacity_in_bytes >> 16));

    return @intCast(@intFromPtr(output.items.ptr + item_count));
}

export fn decompress(ptr: [*]const u16, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u16 = ptr[0..length];
    var output = impl.decompress(u16, 0, 0xFFFE, data, allocator) catch {
        return 0;
    };
    const item_count = output.items.len;
    const content_length = item_count;
    output.ensureTotalCapacity(item_count + 8) catch {
        return 0;
    };
    output.appendAssumeCapacity(@intCast((content_length >> 0) & 0xFF));
    output.appendAssumeCapacity(@intCast((content_length >> 8) & 0xFF));
    output.appendAssumeCapacity(@intCast((content_length >> 16) & 0xFF));
    output.appendAssumeCapacity(@intCast((content_length >> 24) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 0) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 8) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 16) & 0xFF));
    output.appendAssumeCapacity(@intCast((output.capacity >> 24) & 0xFF));

    return @intCast(@intFromPtr(output.items.ptr + item_count));
}
