const std = @import("std");

pub fn partOne(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var disk_map = std.ArrayList(?usize).init(allocator);
    var disk_ids = std.ArrayList(?usize).init(allocator);

    var index: usize = 0;
    var id: usize = 0;
    while (index < input.len) : (index += 1) {
        switch (@mod(index, 2)) {
            0 => map_file(input[index], &disk_map, &disk_ids, &id),
            1 => map_space(input[index], &disk_map, &disk_ids),
            else => unreachable,
        }
    }

    std.debug.print("{any}\n", .{disk_map.items});
    std.debug.print("{any}\n", .{disk_ids.items});
    index = 0;
    while (index <= disk_map.items.len - 1) : (index += 1) {
        if (disk_map.items[index] == null) {
            const value = disk_map.swapRemove(index);
            _ = disk_ids.swapRemove(index);

            if (value == null) {
                swapWithLastNotNull(&disk_map, index);
                swapWithLastNotNull(&disk_ids, index);
            }
        }
    }

    std.debug.print("{any}\n", .{disk_map.items});
    std.debug.print("{any}\n", .{disk_ids.items});

    _ = writer;
}

fn map_file(char: u8, disk_map: *std.ArrayList(?usize), disk_id: *std.ArrayList(?usize), id: *usize) void {
    const number = std.fmt.parseInt(u8, &.{char}, 10) catch @panic("Not a number");
    for (0..number) |_| {
        disk_map.append(number) catch @panic("oom");
        disk_id.append(id.*) catch @panic("oom");
    }
    id.* += 1;
}

fn map_space(char: u8, disk_map: *std.ArrayList(?usize), disk_id: *std.ArrayList(?usize)) void {
    const number = std.fmt.parseInt(u8, &.{char}, 10) catch @panic("Not a number");
    for (0..number) |_| {
        disk_map.append(null) catch @panic("oom");
        disk_id.append(null) catch @panic("oom");
    }
}

pub fn swapWithLastNotNull(self: *std.ArrayList(?usize), i: usize) void {
    if (findLastNotNull(?usize, self.items)) |last_index| {
        std.mem.swap(?usize, &self.items[i], &self.items[last_index]);
    }
}

pub fn findLastNotNull(T: type, array: []T) ?usize {
    var index = array.len - 1;
    while (index > 0) : (index -= 1) {
        if (array[index] != null) {
            return index;
        }
    }
    return null;
}
