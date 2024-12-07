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

    const position_direction = find_start_position_and_direction(grid);
    var position: Vec2 = position_direction[0];
    var direction: Direction = position_direction[1];
    while (position_in_grid(position, grid)) {
        if (check_obstacle(position, direction, grid)) {
            direction.turn();
        }
        grid[@intCast(position[1])][@intCast(position[0])] = 'X';
        const move = direction.get_move();
        position += move;
    }

    var solution: usize = 0;
    for (grid) |line| {
        for (line) |char| {
            if (char == 'X')
                solution += 1;
        }
    }

    if (writer) |wt| {
        try wt.print("{}\n", .{solution});
    }
}

const Direction = enum {
    Up,
    Right,
    Down,
    Left,

    fn turn(direction: *Direction) void {
        direction.* = switch (direction.*) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
        };
    }

    fn get_move(direction: Direction) Vec2 {
        return switch (direction) {
            .Up => Vec2{ 0, -1 },
            .Right => Vec2{ 1, 0 },
            .Down => Vec2{ 0, 1 },
            .Left => Vec2{ -1, 0 },
        };
    }
};
const Vec2 = @Vector(2, i16);

fn find_start_position_and_direction(grid: [][]u8) struct { Vec2, Direction } {
    for (grid, 0..) |line, y_index| {
        for (line, 0..) |char, x_index| {
            if (char == 94)
                return .{ Vec2{ @intCast(x_index), @intCast(y_index) }, Direction.Up };
        }
    }
    unreachable;
}

fn position_in_grid(position: Vec2, grid: [][]u8) bool {
    const y: i16 = @intCast(grid.len);
    const x: i16 = @intCast(grid[0].len);

    if (position[0] < 0 or position[1] < 0) {
        return false;
    }

    if (position[0] >= x or position[1] >= y) {
        return false;
    }

    return true;
}

fn check_obstacle(position: Vec2, direction: Direction, grid: [][]u8) bool {
    const move = direction.get_move();
    const position_to_check = position + move;
    if (!position_in_grid(position_to_check, grid)) {
        return false;
    }
    if (grid[@intCast(position_to_check[1])][@intCast(position_to_check[0])] == '#') {
        return true;
    }
    return false;
}