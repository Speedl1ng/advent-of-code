const std = @import("std");

pub fn partOne(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
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

    for (grid, 0..) |line, y_index| {
        for (line, 0..) |char, x_index| {
            if (char == 'X') {
                for (Directions) |direction|
                    if (checkXmas(x_index, y_index, grid, direction)) {
                        found += 1;
                    };
            }
        }
    }
    if (writer) |wt|
        try wt.print("{}", .{found});
}

const Directions = [_]*const fn (usize, usize) struct { usize, usize }{
    horizontal, //should be: 3, are: 3
    horizontalBackwards, //should be: 2,are: 2
    vertical, //should be: 1,are: 1
    verticalBackwards, //should be: 2,are: 2
    diagonalLeftRightTopBottom, //should be: 1,are: 1
    diagonalLeftRightBottomTop, //should be: 4,are: 4
    diagonalRightLeftTopBottom, //should be: 1,are: 1
    diagonalRightLeftBottomTop, //should be: 4,are: 4
};

fn horizontal(x: usize, y: usize) struct { usize, usize } {
    return .{ x + 1, y };
}

fn vertical(x: usize, y: usize) struct { usize, usize } {
    return .{ x, y + 1 };
}

fn horizontalBackwards(x: usize, y: usize) struct { usize, usize } {
    const res = @subWithOverflow(x, 1);
    return .{ res[0], y };
}

fn verticalBackwards(x: usize, y: usize) struct { usize, usize } {
    const res = @subWithOverflow(y, 1);
    return .{ x, res[0] };
}

fn diagonalLeftRightTopBottom(x: usize, y: usize) struct { usize, usize } {
    return .{ x + 1, y + 1 };
}

fn diagonalLeftRightBottomTop(x: usize, y: usize) struct { usize, usize } {
    const res = @subWithOverflow(y, 1);

    return .{ x + 1, res[0] };
}

fn diagonalRightLeftTopBottom(x: usize, y: usize) struct { usize, usize } {
    const res = @subWithOverflow(x, 1);

    return .{ res[0], y + 1 };
}

fn diagonalRightLeftBottomTop(x: usize, y: usize) struct { usize, usize } {
    const res_x = @subWithOverflow(x, 1);
    const res_y = @subWithOverflow(y, 1);

    return .{ res_x[0], res_y[0] };
}

fn checkXmas(x: usize, y: usize, grid: [][]u8, search_algo: *const fn (usize, usize) struct { usize, usize }) bool {
    const xmas = "XMAS";
    var char_buffer = [_]u8{0} ** 4;

    var x_index: usize = @intCast(x);
    var y_index: usize = @intCast(y);

    for (0..4) |index| {
        if (y_index >= grid.len or x_index >= grid[@intCast(y_index)].len) {
            return false;
        }
        const char_found = grid[@intCast(y_index)][@intCast(x_index)];
        char_buffer[index] = char_found;

        const new_index = search_algo(x_index, y_index);
        x_index = new_index[0];
        y_index = new_index[1];
    }
    std.debug.print("normal: {s}\n", .{char_buffer});

    if (std.mem.eql(u8, &char_buffer, xmas)) {
        return true;
    }

    return false;
}
