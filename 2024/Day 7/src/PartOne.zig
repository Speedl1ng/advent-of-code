const std = @import("std");

const Operations = enum {
    Multiplie,
    Addition,

    fn operate(operation: Operations, A: usize, B: usize) usize {
        return switch (operation) {
            .Multiplie => A * B,
            .Addition => A + B,
        };
    }

    fn get_from_number(mask: isize) Operations {
        const first_bit: isize = mask & 0b00000000_00000000_00000000_00000001;
        return switch (first_bit) {
            0 => .Addition,
            1 => .Multiplie,
            else => @panic("used wrong "),
        };
    }
};

const Equation = struct {
    result: usize,
    values: std.ArrayList(usize),

    fn parse(input: []const u8, allocator: std.mem.Allocator) !Equation {
        var input_iter = std.mem.tokenizeScalar(u8, input, ':');

        const result = if (input_iter.next()) |val|
            try std.fmt.parseInt(usize, val, 10)
        else
            @panic("failed to parse input");

        const value_string = input_iter.next().?;
        var value_iter = std.mem.tokenizeScalar(u8, value_string, ' ');
        var values = std.ArrayList(usize).init(allocator);
        while (value_iter.next()) |val_string| {
            const val = try std.fmt.parseInt(usize, val_string, 10);
            try values.append(val);
        }
        return .{
            .result = result,
            .values = values,
        };
    }

    fn solve(equation: Equation, _: std.mem.Allocator) ?usize {
        const values = equation.values.items.len;

        const number_of_possible_calculations = std.math.pow(usize, 2, (values));
        var current_iteration: isize = 0;
        std.mem.reverse(usize, equation.values.items);
        while (current_iteration < number_of_possible_calculations) : (current_iteration += 1) {
            const res = calculate(equation.values.items[0], equation.values.items[1..], current_iteration);

            if (res == equation.result) {
                return res;
            }
        }

        return null;
    }
};

fn calculate(left: usize, right: []usize, operation_number: isize) usize {
    const operation = Operations.get_from_number(operation_number);
    if (right.len == 1) {
        return operation.operate(left, right[0]);
    }
    return operation.operate(left, calculate(right[0], right[1..], operation_number >> 1));
}

pub fn partOne(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var input_iter = std.mem.tokenizeSequence(u8, input, "\r\n");
    var equations = std.ArrayList(Equation).init(allocator);
    while (input_iter.next()) |line| {
        const equation = try Equation.parse(line, allocator);
        try equations.append(equation);
    }

    var solution: usize = 0;
    for (equations.items) |equation| {
        if (equation.solve(allocator)) |result| {
            solution += result;
        }
    }

    if (writer) |wt|
        try wt.print("solution: {}", .{solution});
}
