const std = @import("std");

const bp = @import("./BitPacker.zig");

const packed_impl = @import("lzwPacked.zig");
const impl = @import("lzw.zig");

const wasmAllocator = @import("./wasmAllocator.zig");
comptime {
    @export(wasmAllocator.allocUint8, .{ .name = "allocUint8", .linkage = .Strong });
    @export(wasmAllocator.allocUint16, .{ .name = "allocUint16", .linkage = .Strong });
    @export(wasmAllocator.free, .{ .name = "free", .linkage = .Strong });
}

export fn compressPacked(ptr: [*]u8, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u8 = ptr[0..length];
    var output = packed_impl.compressPacked(data, allocator) catch {
        return 0;
    };

    const content_length = output.arr.items.len + 2;
    output.arr.ensureTotalCapacity(output.arr.items.len + 6) catch {
        return 0;
    };
    output.arr.appendAssumeCapacity(@intCast(output.size >> 16));
    output.arr.appendAssumeCapacity(@intCast(output.size & 0xFFFF));
    output.arr.appendAssumeCapacity(@intCast(content_length >> 16));
    output.arr.appendAssumeCapacity(@intCast(content_length & 0xFFFF));
    output.arr.appendAssumeCapacity(@intCast(output.arr.capacity >> 16));
    output.arr.appendAssumeCapacity(@intCast(output.arr.capacity & 0xFFFF));

    return @intCast(@intFromPtr(output.arr.items.ptr + content_length));
}

export fn decompressPacked(ptr: [*]packed_impl.BitPacker.UnderlyingType, length: usize, token_count: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []packed_impl.BitPacker.UnderlyingType = ptr[0..length];

    const packedData = packed_impl.BitPacker.fromSlice(allocator, data, token_count) catch {
        return 0;
    };
    // Note: Although the BitPacker (or rather, the Array under the BitPacker) technically takes ownership of the slice here,
    //       we still won't deinit it here and leave the responsibility to the caller to keep the consistency with other APIs.

    const unpackedData = packedData.unpackWithReset(allocator, packed_impl.sentinel_token) catch {
        return 0;
    };

    var output = impl.decompress(packed_impl.BitPacker.ValueType, 0, packed_impl.sentinel_token, unpackedData, allocator) catch {
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
