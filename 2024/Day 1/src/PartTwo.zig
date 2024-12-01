const std = @import("std");

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
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

    var total: usize = 0;
    for (left_input.items) |item| {
        const findings = findAppearencesInArray(u32, item, right_input);
        const appearence_count = item * findings;

        total += appearence_count;
    }

    if (writer) |out|
        try out.print("total: {}", .{total});
}

fn findAppearencesInArray(T: type, number_to_check: u32, array: std.ArrayList(T)) usize {
    var number_of_times: usize = 0;
    for (0..array.items.len) |i| {
        if (array.items[i] == number_to_check) {
            number_of_times += 1;
        }
    }

    return number_of_times;
}
