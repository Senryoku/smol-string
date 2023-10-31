const std = @import("std");

pub fn allocUint8(length: u32) callconv(.C) [*]const u8 {
    const slice = std.heap.page_allocator.alloc(u8, length) catch
        @panic("failed to allocate memory");
    return slice.ptr;
}

pub fn allocUint16(length: u32) callconv(.C) [*]const u16 {
    const slice = std.heap.page_allocator.alloc(u16, length) catch
        @panic("failed to allocate memory");
    return slice.ptr;
}

pub fn free(ptr: [*]u8, length: usize) callconv(.C) void {
    std.heap.page_allocator.free(ptr[0..length]);
}
