const std = @import("std");

pub fn partOne(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var tokens = collectIndexOfOccurences(input, "mul(", allocator);
    const end = collectIndexOfOccurences(input, ")", allocator);
    try tokens.appendSlice(end.items);
    end.deinit();

    std.mem.sort(usize, tokens.items, {}, std.sort.asc(usize));
    var solution: usize = 0;
    for (0.., 1..input.len) |x, y| {
        if (y >= tokens.items.len) {
            break;
        }
        if (tokens.items[x] >= input.len or (tokens.items[y] + 1) >= input.len) {
            break;
        }
        //std.debug.print("tokens: {s}\n", .{input[tokens.items[x] .. tokens.items[y] + 1]});
        if (parseToken(input[tokens.items[x] .. tokens.items[y] + 1])) |val|
            solution += val;
    }

    try if (writer) |wt|
        wt.print("solution: {}\n", .{solution});
}

pub fn parseToken(input: []const u8) ?usize {
    if (input.len < 3) {
        return null;
    }

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
