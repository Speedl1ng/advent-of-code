const std = @import("std");

pub fn partOne(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var left_input = std.ArrayList(u32).init(allocator);
    var right_input = std.ArrayList(u32).init(allocator);

    var iterator = std.mem.tokenizeAny(u8, input, "\r\n");
    while (iterator.next()) |line| {
        var numbers = std.mem.tokenizeAny(u8, line, "  ");
        const left_token = if (numbers.next()) |val| val else @panic("wrong input format");
        const right_token = if (numbers.next()) |val| val else @panic("wrong input format");
        const left_number = try std.fmt.parseInt(u32, left_token, 10);
        const right_number = try std.fmt.parseInt(u32, right_token, 10);

        try left_input.append(left_number);
        try right_input.append(right_number);
    }

    std.debug.assert(left_input.items.len == right_input.items.len);
    var total: u32 = 0;
    std.mem.sort(u32, left_input.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right_input.items, {}, std.sort.asc(u32));

    for (0..right_input.items.len) |i| {
        const smallest_left = left_input.items[i];
        const smallest_right = right_input.items[i];
        total += @abs(@as(i32, @intCast(smallest_left)) - @as(i32, @intCast(smallest_right)));
    }

    if (writer) |out|
        try out.print("total: {}", .{total});
}

fn popSmallestFromArray(T: type, array: *std.ArrayList(T)) T {
    var index_from_smallest_number: usize = 0;
    var smallest_number: usize = std.math.maxInt(usize);

    for (array.items, 0..) |item, index| {
        if (item < smallest_number) {
            smallest_number = item;
            index_from_smallest_number = index;
        }
    }

    const check = array.swapRemove(index_from_smallest_number);
    std.debug.assert(check == smallest_number);
    return @intCast(smallest_number);
}
