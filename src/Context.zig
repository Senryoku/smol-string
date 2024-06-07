const std = @import("std");

pub fn Context(comptime V: type) type {
    return struct {
        const Self = @This();

        const Entry = packed struct {
            used: bool = false,
            hash_low: u7 = undefined,
        };

        entries: []Entry,
        keys: [][]const u8,
        values: []V,
        mask: usize,
        allocator: std.mem.Allocator,

        pub fn initCapacity(allocator: std.mem.Allocator, capacity: usize) !Self {
            const c = @as(usize, 1) << @intCast(1 + (@bitSizeOf(usize) - @clz(capacity)));
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
            while (true) : (i = (i + 1) & self.mask) {
                if (!self.entries[i].used) return null;
                if (self.entries[i].hash_low == @as(u7, @truncate(h)) and Self.eql(key, self.keys[i]))
                    //if (Self.eql(key, self.keys[i]))
                    return self.values[i];
            }
        }

        pub fn putAssumeCapacityNoClobber(self: *Self, key: []const u8, value: V) void {
            const h = Self.hash(key);
            const index = h & self.mask;
            var i: usize = @intCast(index);
            while (self.entries[i].used) : (i = (i + 1) & self.mask) {}
            self.entries[i] = .{ .used = true, .hash_low = @truncate(h) };
            //self.entries[i] = .{ .used = true };
            self.keys[i] = key;
            self.values[i] = value;
        }

        pub fn clearRetainingCapacity(self: *Self) void {
            @memset(self.entries, .{});
        }
    };
}
