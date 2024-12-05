const std = @import("std");

pub fn partOne(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var input_split_iter = std.mem.tokenizeSequence(u8, input, "\r\n\r\n");

    const rules = if (input_split_iter.next()) |rules|
        try parse_rules(rules, allocator)
    else
        @panic("Input could not been parsed");
    const updates = if (input_split_iter.next()) |updates|
        try parse_updates(updates, allocator)
    else
        @panic("Input could not been parsed");

    std.debug.print("rules: {any}\n", .{rules.items});
    for (updates.items) |item|
        std.debug.print("updates: {any}\n", .{item.items});

    _ = writer;
}

fn parse_rules(rules: []const u8, allocator: std.mem.Allocator) !std.ArrayList(u16) {
    var rules_iter = std.mem.tokenizeSequence(u8, rules, "\r\n");
    var rules_list = std.ArrayList(u16).init(allocator);
    while (rules_iter.next()) |rule| {
        var pair_iter = std.mem.tokenizeSequence(u8, rule, "|");
        const left = try std.fmt.parseInt(u16, pair_iter.next().?, 10);
        const right = try std.fmt.parseInt(u16, pair_iter.next().?, 10);

        try rules_list.append(left);
        try rules_list.append(right);
    }
    return rules_list;
}

fn parse_updates(updates: []const u8, allocator: std.mem.Allocator) !std.ArrayList(std.ArrayList(u16)) {
    var updates_iter = std.mem.tokenizeSequence(u8, updates, "\r\n");
    var updates_book = std.ArrayList(std.ArrayList(u16)).init(allocator);
    while (updates_iter.next()) |update| {
        var updates_page = std.ArrayList(u16).init(allocator);

        var iter = std.mem.tokenizeSequence(u8, update, ",");
        while (iter.next()) |entry| {
            const number = try std.fmt.parseInt(u16, entry, 10);

            try updates_page.append(number);
        }
        try updates_book.append(updates_page);
    }
    return updates_book;
}
