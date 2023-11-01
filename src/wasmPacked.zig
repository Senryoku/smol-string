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

comptime {
    std.debug.assert(@bitSizeOf(usize) <= @bitSizeOf(u32));
}

export fn compressPacked(ptr: [*]u8, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u8 = ptr[0..length];
    var output = packed_impl.compressPacked(data, allocator) catch {
        return 0;
    };

    const content_length = output.arr.items.len * 4 + 2; // In u16
    output.arr.ensureTotalCapacity(output.arr.items.len + 2) catch {
        return 0;
    };
    // Token Count followed by the usual footer
    output.arr.appendAssumeCapacity((@as(u64, @intCast(content_length)) << 32) | output.size);
    output.arr.appendAssumeCapacity((@as(u64, @intCast(output.arr.capacity * 2))));

    return @intCast(@intFromPtr(output.arr.items.ptr + output.arr.items.len - 2) + 4);
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
