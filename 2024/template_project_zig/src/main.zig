const std = @import("std");
const zbench = @import("zbench");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(allocator, .{});
    defer bench.deinit();

    try bench.add("Template Function", templateFunction, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn templateFunction(allocator: std.mem.Allocator) void {
    for (0..1000) |_| {
        const buf = allocator.alloc(u8, 512) catch @panic("Out of memory");
        defer allocator.free(buf);
    }
}
