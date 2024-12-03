const std = @import("std");

const TokenTag = enum {
    mul,
    do,
    dont,
};

const Token = union(TokenTag) {
    mul: usize,
    do,
    dont,
};

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var mul = collectIndexOfOccurences(input, "mul(", allocator);
    const do_indicies = collectIndexOfOccurences(input, "do()", allocator);
    const dont_indicies = collectIndexOfOccurences(input, "don't()", allocator);

    const mul_end = collectIndexOfOccurences(input, ")", allocator);
    try mul.appendSlice(mul_end.items);
    mul_end.deinit();

    std.mem.sort(usize, mul.items, {}, std.sort.asc(usize));
    var tokens = std.ArrayList(indexEntry).init(allocator);
    for (0.., 1..input.len) |x, y| {
        if (y >= mul.items.len) {
            break;
        }
        if (mul.items[x] >= input.len or (mul.items[y] + 1) >= input.len) {
            break;
        }
        //std.debug.print("tokens: {s}\n", .{input[tokens.items[x] .. tokens.items[y] + 1]});
        if (parseMul(input[mul.items[x] .. mul.items[y] + 1])) |val| {
            const token = Token{ .mul = val };
            try tokens.append(.{ mul.items[x], token });
        }
    }

    for (do_indicies.items) |index| {
        const token: Token = .do;
        try tokens.append(.{ index, token });
    }

    for (dont_indicies.items) |index| {
        const token: Token = .dont;
        try tokens.append(.{ index, token });
    }

    std.mem.sort(indexEntry, tokens.items, {}, tokenAsc);

    var do: bool = true;
    var solution: usize = 0;
    for (tokens.items) |item| {
        const tag: Token = item[1];
        switch (tag) {
            .do => do = true,
            .dont => do = false,
            .mul => |val| {
                if (do) {
                    solution += val;
                }
            },
        }
    }

    try if (writer) |wt|
        wt.print("solution: {}\n", .{solution});
}

const indexEntry = struct { usize, Token };

pub fn tokenAsc(_: void, a: indexEntry, b: indexEntry) bool {
    return a[0] < b[0];
}

pub fn parseToken(input: []const u8) ?usize {
    if (input.len < 3) {
        return null;
    }
    std.debug.print("input: {s}\n", .{input});

    if (input[0] == 'm')
        return parseMul(input);
    if (input[0] == 'd')
        _ = @"parseDo's"(input);

    return null;
}

fn parseMul(input: []const u8) ?usize {
    if (std.mem.indexOf(u8, input, "(")) |start| {
        if (std.mem.indexOf(u8, input, ",")) |seperator| {
            if (std.mem.indexOf(u8, input, ")")) |end| {
                if (start >= input.len - 1 or seperator >= input.len or end >= input.len) return null;
                if (start > seperator or start > end) return null;

                const first = std.fmt.parseInt(usize, input[start + 1 .. seperator], 10) catch return null;
                const second = std.fmt.parseInt(usize, input[seperator + 1 .. end], 10) catch return null;
                return first * second;
            }
        }
    }
    return null;
}

fn @"parseDo's"(input: []const u8) ?bool {
    std.debug.print("do's: {s}\n", .{input});

    return null;
}

fn collectIndexOfOccurences(input: []const u8, to_find: []const u8, allocator: std.mem.Allocator) std.ArrayList(usize) {
    var indicies = std.ArrayList(usize).init(allocator);
    var copy = input[0..];
    var offset: usize = 0;
    while (true) {
        if (std.mem.indexOf(u8, copy, to_find)) |index| {
            indicies.append(index + offset) catch @panic("oom");
            const new_index = index + 1;
            offset += new_index;
            if (new_index > copy.len) {
                break;
            }
            copy = copy[new_index..];
        } else {
            break;
        }
    }
    return indicies;
}
