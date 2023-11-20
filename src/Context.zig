const std = @import("std");

pub const StringContext = struct {
    pub fn hash(self: @This(), s: []const u8) u64 {
        _ = self;
        return std.hash.CityHash64.hash(s);
    }
    pub fn eql(self: @This(), a: []const u8, b: []const u8) bool {
        _ = self;
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
};

pub fn HashMap(comptime V: type) type {
    return std.HashMap([]const u8, V, StringContext, 80);
}
