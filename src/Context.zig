const std = @import("std");

pub const StringContext = struct {
    pub fn hash(self: @This(), s: []const u8) u64 {
        _ = self;
        return std.hash.CityHash64.hash(s);
    }
    pub fn eql(self: @This(), a: []const u8, b: []const u8) bool {
        _ = self;
        return std.mem.eql(u8, a, b);
    }
};

pub fn HashMap(comptime V: type) type {
    return std.HashMap([]const u8, V, StringContext, 80);
}
