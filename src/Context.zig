const std = @import("std");

// Basic Hash Map implementation using linear probing and fixed power of two capacity.
// No deletion, no resizing, no rehashing.
pub fn Context(comptime V: type) type {
    return struct {
        const Self = @This();

        const Entry = packed struct(u8) {
            used: bool = false,
            hash_low: u7 = undefined, // Used as a 'fast' equality check, before comparing the keys. In practice, this doesn't seem to make much of a difference, but neither does reducing the size of entries to a single bit.
        };

        entries: []Entry,
        keys: [][]const u8,
        values: []V,
        mask: usize, // Capacity mask. Used to quickly calculate the modulo.

        allocator: std.mem.Allocator,

        pub fn initCapacity(allocator: std.mem.Allocator, capacity: usize) !Self {
            std.debug.assert(capacity < (std.math.maxInt(usize) >> 1));
            // Use next power of two for our capacity. This way we can simplify the modulo
            // using a bitwise and.
            var c = @as(usize, 1) << @intCast(1 + (@bitSizeOf(usize) - @clz(capacity)));
            // Make extra sure we won't come too close to the capacity limit.
            if (@clz(c) > 0 and @as(f32, @floatFromInt(c)) / @as(f32, @floatFromInt(capacity)) < 1.2) c <<= 1;
            var r = Self{
                .entries = try allocator.alloc(Entry, c),
                .keys = try allocator.alloc([]const u8, c),
                .values = try allocator.alloc(V, c),
                .mask = c - 1,
                .allocator = allocator,
            };
            r.clearRetainingCapacity();
            return r;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.values);
            self.allocator.free(self.keys);
            self.allocator.free(self.entries);
        }

        fn hash(s: []const u8) u64 {
            return std.hash.CityHash64.hash(s);
        }

        fn eql(a: []const u8, b: []const u8) bool {
            // return std.mem.eql(u8, a, b);
            if (a.len != b.len) return false;
            const vec_size = 4;
            for (0..a.len / vec_size) |i| {
                const l: @Vector(vec_size, u8) = a[i * vec_size ..][0..vec_size].*;
                const r: @Vector(vec_size, u8) = b[i * vec_size ..][0..vec_size].*;
                if (@reduce(.Or, l != r)) return false;
            }
            for (a.len - a.len % vec_size..a.len) |i| {
                if (a[i] != b[i]) return false;
            }
            return true;
        }

        pub fn get(self: *Self, key: []const u8) ?V {
            const h = Self.hash(key);
            const index = h & self.mask;
            var i: usize = @intCast(index);
            const entry: u8 = @bitCast(Entry{ .used = true, .hash_low = @truncate(h) });
            while (true) : (i = (i + 1) & self.mask) {
                if (!self.entries[i].used) return null;
                if (@as(u8, @bitCast(self.entries[i])) == entry and Self.eql(key, self.keys[i]))
                    return self.values[i];
            }
        }

        pub fn putAssumeCapacityNoClobber(self: *Self, key: []const u8, value: V) void {
            const h = Self.hash(key);
            const index = h & self.mask;
            var i: usize = @intCast(index);
            while (self.entries[i].used) : (i = (i + 1) & self.mask) {
                std.debug.assert(!Self.eql(key, self.keys[i]));
            }
            self.entries[i] = .{ .used = true, .hash_low = @truncate(h) };
            self.keys[i] = key;
            self.values[i] = value;
        }

        pub fn clearRetainingCapacity(self: *Self) void {
            @memset(self.entries, .{});
        }
    };
}
