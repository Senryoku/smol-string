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
    defer output.deinit();

    // We could preallocate the array and leave space for our 'header' to avoid this copy.
    // However this should only be the responsibility of this WASM interface, not compressPacked.
    // We could also ask for an additional buffer to output these information...
    var r = allocator.alloc(u16, output.arr.items.len + 4) catch {
        return 0;
    };
    r[0] = @intCast(r.len >> 16);
    r[1] = @intCast(r.len & 0xFFFF);
    r[2] = @intCast(output.size >> 16);
    r[3] = @intCast(output.size & 0xFFFF);
    std.mem.copy(u16, r[4..], output.arr.items);

    return @intCast(@intFromPtr(r.ptr));
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
    const r = output.toOwnedSliceSentinel(0) catch {
        return 0;
    };
    return @intCast(@intFromPtr(r.ptr));
}
