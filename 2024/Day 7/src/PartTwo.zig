const std = @import("std");

const Operations = enum {
    Multiplie,
    Addition,
    Concat,

    fn operate(operation: Operations, A: usize, B: usize) usize {
        return switch (operation) {
            .Multiplie => A * B,
            .Addition => A + B,
            .Concat => concat_numbers(A, B),
        };
    }

    fn get_from_list(list: Operationlist) Operations {
        const op = list;
        return op[0];
    }

    fn next_opeartion(operation: *Operations) void {
        operation.* = switch (operation.*) {
            .Addition => .Multiplie,
            .Multiplie => .Concat,
            .Concat => .Addition,
        };
    }
};

fn concat_numbers(a: usize, b: usize) usize {
    var buffer = [_]u8{0} ** 16;
    const str = std.fmt.bufPrint(&buffer, "{}{}", .{ b, a }) catch @panic("failed to concat numbers");
    return std.fmt.parseInt(usize, str, 10) catch @panic("failed to concat numbers");
}

pub const Operationlist = struct {
    operations: []Operations,

    fn next(list: *Operationlist, index: usize) void {
        if (index >= list.operations.len) {
            return;
        }
        list.operations[index].next_opeartion();
        if (list.operations[index] == .Addition) {
            list.next(index + 1);
        }
    }

    fn pop(list: Operationlist) Operationlist {
        return Operationlist{ .operations = list.operations[1..] };
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

    fn solve(equation: Equation, allocator: std.mem.Allocator) ?usize {
        const values_len = equation.values.items.len;
        const opeartion_buffer = allocator.alloc(Operations, values_len) catch @panic("oom");
        for (opeartion_buffer) |*operation| {
            operation.* = Operations.Addition;
        }
        var opeartion_list = Operationlist{
            .operations = opeartion_buffer,
        };
        const number_of_possible_calculations = std.math.pow(usize, 3, (values_len));
        var current_iteration: isize = 0;
        std.mem.reverse(usize, equation.values.items);
        while (current_iteration < number_of_possible_calculations) {
            const res = calculate(equation.values.items[0], equation.values.items[1..], opeartion_list);
            opeartion_list.next(0);
            current_iteration += 1;

            if (res == equation.result) {
                return res;
            }
        }

        return null;
    }
};

fn calculate(left: usize, right: []usize, operation_list: Operationlist) usize {
    const operation = operation_list.operations[0];
    if (right.len == 1) {
        return operation.operate(left, right[0]);
    }
    return operation.operate(left, calculate(right[0], right[1..], operation_list.pop()));
}

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
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
