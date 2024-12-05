const std = @import("std");

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var input_split_iter = std.mem.tokenizeSequence(u8, input, "\r\n\r\n");

    const rules = if (input_split_iter.next()) |rules|
        try parse_rules(rules, allocator)
    else
        @panic("Input could not been parsed");
    const pages = if (input_split_iter.next()) |updates|
        try parse_updates(updates, allocator)
    else
        @panic("Input could not been parsed");

    var ordering_rules = std.AutoHashMap(u16, std.ArrayList(u16)).init(allocator);

    var i: usize = 0;
    while (i < rules.items.len) : (i += 2) {
        const left = rules.items[i];
        const right = rules.items[i + 1];

        var result = try ordering_rules.getOrPutValue(left, std.ArrayList(u16).init(allocator));
        try result.value_ptr.append(right);
    }

    var sorted_pages = std.ArrayList(std.ArrayList(u16)).init(allocator);
    var unsorted_pages = std.ArrayList(std.ArrayList(u16)).init(allocator);

    for (pages.items) |page| {
        if (check_if_page_is_sorted(ordering_rules, page)) {
            try sorted_pages.append(page);
        } else {
            try unsorted_pages.append(page);
        }
    }

    var sum: usize = 0;
    for (sorted_pages.items) |page| {
        const mid = @divTrunc(page.items.len, 2);
        sum += page.items[mid];
    }

    if (writer) |wt|
        try wt.print("solution: {}", .{sum});
}

fn check_if_page_is_sorted(ordering_rules: std.AutoHashMap(u16, std.ArrayList(u16)), page: std.ArrayList(u16)) bool {
    var already_seen = [_]u16{0} ** 100;

    for (page.items) |number| {
        //get ruleset for this number
        const rule: std.ArrayList(u16) = if (ordering_rules.get(number)) |n|
            n
        else {
            already_seen[number] = number;

            continue;
        };

        //check if any number from rule set was already seen once
        for (rule.items) |entry| {
            const seen = already_seen[entry];
            if (seen != entry) {
                continue;
            }
            return false;
        }
        already_seen[number] = number;
    }

    return true;
}

fn sort_page(ordering_rules: std.AutoHashMap(u16, std.ArrayList(u16)), page: std.ArrayList(u16)) void {
    var already_seen = [_]u16{0} ** 100;

    for (page.items) |number| {
        //get ruleset for this number
        const rule: std.ArrayList(u16) = if (ordering_rules.get(number)) |n|
            n
        else {
            already_seen[number] = number;

            continue;
        };

        //check if any number from rule set was already seen once
        for (rule.items) |entry| {
            const seen = already_seen[entry];
            if (seen != entry) {
                continue;
            }
            return false;
        }
        already_seen[number] = number;
    }

    return true;
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
