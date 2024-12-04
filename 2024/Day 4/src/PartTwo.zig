const std = @import("std");

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var lines_iterator = std.mem.tokenizeSequence(u8, input, "\r\n");
    var lines: usize = 0;
    while (lines_iterator.next()) |_| {
        lines += 1;
    }
    var grid = try allocator.alloc([]u8, lines);
    {
        var y_index: usize = 0;
        lines_iterator.reset();

        while (lines_iterator.next()) |line| {
            var x = try allocator.alloc(u8, line.len);
            for (line, 0..) |char, index| {
                x[index] = char;
            }
            grid[y_index] = x;
            y_index += 1;
        }
    }
    var found: usize = 0;
    for (0..grid.len - 1) |y_index| {
        for (1..grid[y_index].len - 1) |x_index| {
            if (grid[y_index][x_index] != 'A')
                continue;
            if (checkMas(x_index, y_index, grid)) {
                found += 1;
            }
        }
    }
    if (writer) |wt|
        try wt.print("{}", .{found});
}

fn checkMas(x: usize, y: usize, grid: [][]u8) bool {
    if (x <= 0 or y <= 0) {
        return false;
    }
    var char_buffer = [_]u8{0} ** 9;
    const index_x = x - 1;
    var index_y = y - 1;

    var row: usize = 0;
    for (0..3) |_| {
        char_buffer[row] = grid[index_y][index_x];
        char_buffer[row + 1] = grid[index_y][index_x + 1];
        char_buffer[row + 2] = grid[index_y][index_x + 2];
        row += 3;
        index_y += 1;
    }

    var matching: usize = 0;
    for (Masks) |mask| {
        const a = @as(u72, @bitCast(char_buffer)) & @as(u72, @bitCast(mask));
        if (std.mem.eql(u8, &@as([9]u8, @bitCast(a)), &mask)) {
            matching += 1;
        }
    }
    if (matching == 2) {
        return true;
    }

    return false;
}

const Masks = [_][9]u8{
    .{ 'S', 0, 0, 0, 'A', 0, 0, 0, 'M' },
    .{ 'M', 0, 0, 0, 'A', 0, 0, 0, 'S' },
    .{ 0, 0, 'M', 0, 'A', 0, 'S', 0, 0 },
    .{ 0, 0, 'S', 0, 'A', 0, 'M', 0, 0 },
};
