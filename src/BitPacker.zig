const std = @import("std");

// initial_bit_size: Determine the initial expected max values.
// reserved_bits: Skip this number of bits in each array item. Reduces the packer efficiency to produce valid values for your target encoding.
pub fn BitPacker(comptime _UnderlyingType: type, comptime _ValueType: type, comptime initial_bit_size: u8, comptime reserved_bits: u8) type {
    return struct {
        arr: std.ArrayList(UnderlyingType),

        size: usize,
        size_since_reset: usize,
        value_size: u8,
        bit: u8 = reserved_bits, // Current bit position

        const Self = @This();
        pub const UnderlyingType = _UnderlyingType;
        pub const ValueType = _ValueType;

        pub fn bitsPerItem() u8 {
            return @bitSizeOf(UnderlyingType) - reserved_bits;
        }

        pub fn init(allocator: std.mem.Allocator) !@This() {
            return @This(){
                .arr = std.ArrayList(UnderlyingType).init(allocator),
                .size = 0,
                .size_since_reset = 0,
                .value_size = initial_bit_size,
            };
        }

        pub fn initCapacity(allocator: std.mem.Allocator, initial_capacity: usize) !@This() {
            return @This(){
                .arr = try std.ArrayList(UnderlyingType).initCapacity(allocator, initial_capacity),
                .size = 0,
                .size_since_reset = 0,
                .value_size = initial_bit_size,
            };
        }

        // FIXME: This should return a const version of @This()
        pub fn fromSlice(allocator: std.mem.Allocator, data: []UnderlyingType, size: usize) !@This() {
            return @This(){
                .arr = std.ArrayList(UnderlyingType).fromOwnedSlice(allocator, data),
                .size = size,
                .size_since_reset = 0,
                .value_size = 0, // FIXME: This is intended to be read-only. Passing a wrong value on purpose here.
            };
        }

        pub fn unpack(self: @This(), allocator: std.mem.Allocator) ![]const ValueType {
            var r = try std.ArrayList(ValueType).initCapacity(allocator, self.size);
            var it = self.iterator();
            while (it.next()) |v| {
                r.appendAssumeCapacity(v);
            }
            return r.toOwnedSlice();
        }

        pub fn unpackWithReset(self: @This(), allocator: std.mem.Allocator, sentinel_token: ValueType) ![]const ValueType {
            var r = try std.ArrayList(ValueType).initCapacity(allocator, self.size);
            var it = self.iterator();
            while (it.next()) |v| {
                r.appendAssumeCapacity(v);
                if (v == sentinel_token) {
                    it.resetValueSize();
                }
            }
            return r.toOwnedSlice();
        }

        pub fn deinit(self: *@This()) void {
            self.arr.deinit();
        }

        pub fn resetValueSize(self: *@This()) void {
            self.value_size = initial_bit_size;
            self.size_since_reset = 0;
        }

        pub fn append(self: *@This(), value: ValueType) !void {
            if (self.value_size < @bitSizeOf(ValueType) and self.size_since_reset + (comptime std.math.pow(usize, 2, @max(0, initial_bit_size - 1))) >= (@as(u32, 1) << @intCast(self.value_size)) - 1) {
                self.value_size += 1;
            }

            std.debug.assert(self.value_size <= @bitSizeOf(ValueType));
            std.debug.assert(self.value_size == @bitSizeOf(ValueType) or (value >> @intCast(self.value_size)) == 0);

            var remaining_bits = self.value_size;
            while (remaining_bits > 0) {
                if (self.bit == @bitSizeOf(UnderlyingType) or self.arr.items.len == 0) {
                    try self.arr.append(0);
                    self.bit = reserved_bits;
                }

                const to_write = @min(remaining_bits, @bitSizeOf(UnderlyingType) - self.bit);

                // FIXME: This can probably be simplified
                if (comptime (@bitSizeOf(ValueType) < @bitSizeOf(UnderlyingType))) {
                    var shifted: UnderlyingType = @as(UnderlyingType, @intCast(value)) << @intCast(@bitSizeOf(UnderlyingType) - remaining_bits); // "Mask" high bits
                    shifted >>= @intCast(self.bit);
                    self.arr.items[self.arr.items.len - 1] |= shifted;
                } else {
                    var shifted: ValueType = value << @intCast(@bitSizeOf(ValueType) - remaining_bits); // "Mask" high bits
                    shifted >>= @intCast(self.bit + (@bitSizeOf(ValueType) - @bitSizeOf(UnderlyingType)));
                    self.arr.items[self.arr.items.len - 1] |= @intCast(shifted);
                }
                remaining_bits -= to_write;

                self.bit += to_write;
            }

            self.size += 1;
            self.size_since_reset += 1;
        }

        const Iterator = struct {
            bp: *const Self,

            index: usize,
            index_since_reset: usize,
            arr_index: usize,
            bit: u8,
            value_size: u8,

            pub fn resetValueSize(self: *@This()) void {
                self.value_size = initial_bit_size;
                self.index_since_reset = 0;
            }

            pub fn next(self: *@This()) ?ValueType {
                if (self.index >= self.bp.size) return null;

                if (self.value_size < @bitSizeOf(ValueType) and self.index_since_reset + (comptime std.math.pow(usize, 2, @max(0, initial_bit_size - 1))) >= (@as(u32, 1) << @intCast(self.value_size)) - 1) {
                    self.value_size += 1;
                }

                self.index += 1;
                self.index_since_reset += 1;

                var output: ValueType = 0;

                var remainding_bits = self.value_size;
                while (remainding_bits > 0) {
                    if (self.bit == @bitSizeOf(UnderlyingType)) {
                        self.arr_index += 1;
                        self.bit = reserved_bits;
                    }

                    const to_output = @min(remainding_bits, @bitSizeOf(UnderlyingType) - self.bit);
                    var shifted = self.bp.arr.items[self.arr_index] << @intCast(self.bit); // "Mask" upper bits
                    shifted >>= @intCast(@bitSizeOf(UnderlyingType) - to_output); // "Mask" lower bits
                    output |= @as(ValueType, @intCast(shifted)) << @intCast(remainding_bits - to_output);
                    remainding_bits -= to_output;
                    self.bit += to_output;
                }
                return output;
            }
        };

        pub fn iterator(self: *const @This()) Iterator {
            return Iterator{
                .bp = self,
                .index = 0,
                .index_since_reset = 0,
                .arr_index = 0,
                .bit = reserved_bits,
                .value_size = initial_bit_size,
            };
        }
    };
}

// NOTE: (/FIXME) 'expected' and 'actual' are flipped in all these expectEqual calls. Type isn't coerced correctly otherwise, and I'd rather have a weird error message than writing a workaround for that right now.

test "basics" {
    var bp = try BitPacker(u16, u16, 3, 0).init(std.testing.allocator);
    defer bp.deinit();

    try bp.append(2);
    try std.testing.expectEqual(bp.arr.items[0], 2 << @intCast(16 - 3));
    try std.testing.expectEqual(bp.bit, 3);

    try bp.append(3);
    try std.testing.expectEqual(bp.arr.items[0], (2 << @intCast(16 - 3)) | (3 << @intCast(16 - 3 * 2)));
    try std.testing.expectEqual(bp.bit, 6);

    var it = bp.iterator();
    try std.testing.expectEqual(it.next(), 2);
    try std.testing.expectEqual(it.next(), 3);
}

test "reserved bits" {
    const reserved_bits = 1;
    var bp = try BitPacker(u16, u16, 3, reserved_bits).init(std.testing.allocator);
    defer bp.deinit();

    try bp.append(2);
    try std.testing.expectEqual(bp.arr.items[0], 2 << @intCast(16 - 3 - reserved_bits));
    try std.testing.expectEqual(bp.bit, 3 + reserved_bits);

    try bp.append(3);
    try std.testing.expectEqual(bp.arr.items[0], (2 << @intCast(16 - 3 - reserved_bits)) | (3 << @intCast(16 - 3 * 2 - reserved_bits)));
    try std.testing.expectEqual(bp.bit, 6 + reserved_bits);

    var it = bp.iterator();
    try std.testing.expectEqual(it.next(), 2);
    try std.testing.expectEqual(it.next(), 3);
}

test "incrementing bit size" {
    var bp = try BitPacker(u16, u16, 3, 0).init(std.testing.allocator);
    defer bp.deinit();

    for (0..64) |v| {
        try bp.append(@intCast(v));
    }

    var it = bp.iterator();
    for (0..64) |v| {
        try std.testing.expectEqual(it.next(), @intCast(v));
    }
}

test "incrementing bit size and reserved bits" {
    var bp = try BitPacker(u16, u16, 3, 1).init(std.testing.allocator);
    defer bp.deinit();

    for (0..64) |v| {
        try bp.append(@intCast(v));
    }

    // Make sure the reserved bit is unset
    for (bp.arr.items) |v| {
        try std.testing.expectEqual(v >> 15, 0);
    }

    var it = bp.iterator();
    for (0..64) |v| {
        try std.testing.expectEqual(it.next(), @intCast(v));
    }
}

test "initial_bit_size(2) and reserved_bits(0)" {
    var bp = try BitPacker(u16, u16, 2, 0).init(std.testing.allocator);
    defer bp.deinit();

    for (0..32768) |v| {
        try bp.append(@intCast(v));
    }

    var it = bp.iterator();
    for (0..32768) |v| {
        try std.testing.expectEqual(it.next(), @intCast(v));
    }
}

test "initial_bit_size(9) and reserved_bits(1)" {
    var bp = try BitPacker(u16, u16, 9, 1).init(std.testing.allocator);
    defer bp.deinit();

    for (0..32768) |v| {
        try bp.append(@intCast(v));
    }

    // Make sure the reserved bit is unset
    for (bp.arr.items) |v| {
        try std.testing.expectEqual(v >> 15, 0);
    }

    var it = bp.iterator();
    for (0..32768) |v| {
        try std.testing.expectEqual(it.next(), @intCast(v));
    }
}

test "underlying_type(u16), value_type(u32), initial_bit_size(9) and reserved_bits(1)" {
    var bp = try BitPacker(u16, u32, 9, 1).init(std.testing.allocator);
    defer bp.deinit();

    for (0..131072) |v| {
        try bp.append(@intCast(v));
    }

    // Make sure the reserved bit is unset
    for (bp.arr.items) |v| {
        try std.testing.expectEqual(v >> 15, 0);
    }

    var it = bp.iterator();
    for (0..131072) |v| {
        try std.testing.expectEqual(it.next(), @intCast(v));
    }

    const unpacked = try bp.unpack(std.testing.allocator);
    defer std.testing.allocator.free(unpacked);

    for (unpacked) |v| {
        try std.testing.expectEqual(v, @intCast(v));
    }
}
