const std = @import("std");

const Vec2 = @Vector(2, isize);

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var input_iter = std.mem.tokenizeSequence(u8, input, "\r\n");
    var frequenzy_map = std.AutoHashMap(usize, std.ArrayList(Vec2)).init(allocator);
    var width: usize = 0;
    var height: usize = 0;
    while (input_iter.next()) |line| {
        width = line.len;
        height += 1;
    }

    input_iter.reset();
    var y: usize = 0;
    while (input_iter.next()) |line| {
        for (line, 0..) |char, x| {
            if (char == '.')
                continue;
            var entr = frequenzy_map.getOrPutValue(char, std.ArrayList(Vec2).init(allocator)) catch @panic("oom");
            try entr.value_ptr.append(Vec2{ @intCast(x), @intCast(y) });
        }
        y += 1;
    }
    //const map_size = Vec2{ @intCast(x), @intCast(y) };

    var frequenzy_iter = frequenzy_map.iterator();
    var antinodes = std.AutoHashMap(Vec2, void).init(allocator);
    while (frequenzy_iter.next()) |entry| {
        find_antinodes(entry.value_ptr.items, height, width, &antinodes);
    }

    var unique_positions: usize = 0;
    var antinodes_iter = antinodes.keyIterator();
    while (antinodes_iter.next()) |coord| {
        if (!(coord[1] >= 0 and coord[1] < height))
            continue;
        if (!(coord[0] >= 0 and coord[0] < width))
            continue;

        std.debug.print("coord: {}\n", .{coord.*});
        unique_positions += 1;
    }

    if (writer) |wt|
        try wt.print("unique_positions: {}", .{unique_positions});
}

fn find_antinodes(antennas: []Vec2, map_height: usize, map_width: usize, antinodes: *std.AutoHashMap(Vec2, void)) void {
    std.debug.print("searching {} antennas\n", .{antennas.len});
    for (antennas) |antenna| {
        for (antennas) |other_antenna| {
            if (std.meta.eql(antenna, other_antenna)) {
                continue;
            }
            var loop: Vec2 = Vec2{ 0, 0 };
            while (true) {
                const diff_vec: Vec2 = antenna - other_antenna;
                const anti_node1 = antenna + (diff_vec * loop);
                if (!(anti_node1[1] >= 0 and anti_node1[1] < map_height))
                    break;
                if (!(anti_node1[0] >= 0 and anti_node1[0] < map_width))
                    break;

                antinodes.put(anti_node1, {}) catch @panic("oom");
                loop += Vec2{ 1, 1 };
            }
        }
    }
}
