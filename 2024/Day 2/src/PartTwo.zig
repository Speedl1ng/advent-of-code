const std = @import("std");

const IsizeArray = std.ArrayList(isize);

pub fn partTwo(allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) !void {
    var report_list = std.ArrayList(IsizeArray).init(allocator);

    var report_iterator = std.mem.tokenizeAny(u8, input, "\r\n");
    while (report_iterator.next()) |report| {
        var level_iterator = std.mem.tokenizeAny(u8, report, " ");
        var levels = IsizeArray.init(allocator);
        var idx: usize = 0;
        while (level_iterator.next()) |level| : (idx += 1) {
            const ilevel = try std.fmt.parseInt(isize, level, 10);
            try levels.append(ilevel);
        }
        try report_list.append(levels);
    }

    var save_reports: usize = 0;
    for (report_list.items) |report| {
        for (0..report.items.len) |index| {
            var clone_report = try report.clone();
            defer clone_report.deinit();
            _ = clone_report.orderedRemove(index);
            if (validate_report(clone_report)) {
                save_reports += 1;
                break;
            }
        }
    }

    if (writer) |wt|
        try wt.print("save:reports: \n{}\n", .{save_reports});
}

fn validate_report(report: IsizeArray) bool {
    var decreasing = true;
    var increasing = true;
    var valid_diff = true;
    for (report.items[1..], 1..) |levels, index| {
        const prev = report.items[index - 1];
        const diff = prev - levels;
        if (diff > 0) {
            decreasing = false;
        }
        if (diff < 0) {
            increasing = false;
        }
        if (!(1 <= @abs(diff) and @abs(diff) <= 3)) {
            valid_diff = false;
            break;
        }
    }
    if (valid_diff and (decreasing or increasing)) {
        return true;
    }
    return false;
}
