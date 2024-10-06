const std = @import("std");

const bp = @import("./BitPacker.zig");

const impl = @import("lzw.zig");

const wasmAllocator = @import("./wasmAllocator.zig");
comptime {
    @export(&wasmAllocator.allocUint8, .{ .name = "allocUint8", .linkage = .strong });
    @export(&wasmAllocator.allocUint16, .{ .name = "allocUint16", .linkage = .strong });
    @export(&wasmAllocator.free, .{ .name = "free", .linkage = .strong });
}

comptime {
    std.debug.assert(@bitSizeOf(usize) == @bitSizeOf(u32));
}

export fn compress(ptr: [*]u8, length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []const u8 = ptr[0..length];
    var output = impl.compress(data, allocator) catch {
        return -1;
    };

    const item_count = output.arr.items.len;
    const content_length: u64 = item_count * @sizeOf(impl.BitPacker.UnderlyingType) + 2 * @sizeOf(u32); // In bytes. Compressed stream followed by the token count and expected output length.
    output.arr.ensureTotalCapacity(item_count + 2) catch {
        return -1;
    };
    // Token Count and Expected Output Length followed by the usual footer
    output.arr.appendAssumeCapacity((@as(u64, @intCast(length)) << @bitSizeOf(u32)) | output.size);
    output.arr.appendAssumeCapacity((@as(u64, @intCast(output.arr.capacity)) * @sizeOf(impl.BitPacker.UnderlyingType)) << @bitSizeOf(u32) | content_length);

    return @intCast(@intFromPtr(output.arr.items.ptr + item_count) + 2 * @sizeOf(u32));
}

export fn decompress(ptr: [*]impl.BitPacker.UnderlyingType, length: usize, token_count: usize, expected_output_length: usize) i32 {
    const allocator = std.heap.page_allocator;
    const data: []impl.BitPacker.UnderlyingType = ptr[0..length];

    const packedData = impl.BitPacker.fromSlice(allocator, data, token_count) catch {
        return -1;
    };
    // Note: Although the BitPacker (or rather, the Array under the BitPacker) technically takes ownership of the slice here,
    //       we still won't deinit it here and leave the responsibility to the caller to keep the consistency with other APIs.

    const unpackedData = packedData.unpackWithReset(allocator, std.math.maxInt(impl.BitPacker.ValueType)) catch {
        return -1;
    };

    var output = impl.decompress(impl.BitPacker.ValueType, 0, std.math.maxInt(impl.BitPacker.ValueType), unpackedData, expected_output_length, allocator) catch {
        return -1;
    };

    const item_count = output.items.len;
    const content_length = item_count;
    output.ensureTotalCapacity(output.items.len + 2 * @sizeOf(usize)) catch {
        return -1;
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
