const std = @import("std");
const zbench = @import("zbench");

pub const example_input = @embedFile("input/example.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var args = std.process.argsWithAllocator(allocator) catch @panic("Out of Memory");
    defer args.deinit();
    _ = args.skip();

    var arguments = parse_input(&args);
    try arguments.run(allocator);
}

const BenchmarkFunction = struct {
    input: [:0]const u8,
    function_to_run: *const fn (allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) anyerror!void,

    pub fn run(fun: BenchmarkFunction, allocator: std.mem.Allocator) void {
        fun.function_to_run(allocator, fun.input, null) catch @panic("ooppps");
    }
};

const Part = enum {
    PartOne,
    PartTwo,
};

const Input = enum { Example, Real };

const BenchmarkFlag = enum { Bench };

const Runner = struct {
    function_to_run: *const fn (allocator: std.mem.Allocator, input: [:0]const u8, writer: ?std.fs.File.Writer) anyerror!void,
    input: [:0]const u8,
    benchmark: bool,

    pub fn run(runner: *Runner, allocator: std.mem.Allocator) !void {
        if (runner.benchmark == false) {
            const write = std.io.getStdOut().writer();
            try runner.function_to_run(allocator, runner.input, write);
        } else {
            try benchmark(allocator, BenchmarkFunction{
                .function_to_run = runner.function_to_run,
                .input = runner.input,
            });
        }
    }
};

fn parse_input(args: *std.process.ArgIterator) Runner {
    var part_arg: ?Part = null;
    var input_arg: ?Input = null;
    var bench_arg: ?BenchmarkFlag = null;
    while (args.next()) |arg| {
        std.debug.print("arg: {s}\n", .{arg});
        if (part_arg == null) {
            part_arg = std.meta.stringToEnum(Part, arg);
        }
        if (input_arg == null) {
            input_arg = std.meta.stringToEnum(Input, arg);
        }
        if (bench_arg == null) {
            bench_arg = std.meta.stringToEnum(BenchmarkFlag, arg);
        }
    }

    const functin_to_run: *const fn (
        allocator: std.mem.Allocator,
        input: [:0]const u8,
        writer: ?std.fs.File.Writer,
    ) anyerror!void = if (part_arg != null and part_arg.? == Part.PartOne)
        @import("PartOne.zig").partOne
    else if (part_arg != null and part_arg.? == Part.PartTwo)
        @import("PartTwo.zig").partTwo
    else
        @panic("Failed to Parse part_arg");

    const input = if (input_arg.? == Input.Example)
        @embedFile("./input/example.txt")
    else if (part_arg != null and part_arg.? == Part.PartOne and input_arg.? == Input.Real)
        @embedFile("./input/input1.txt")
    else if (part_arg != null and part_arg.? == Part.PartTwo and input_arg.? == Input.Real)
        @embedFile("./input/input2.txt")
    else
        @panic("Failed to Parse input_arg");

    const should_benchmark: bool = if (bench_arg != null and bench_arg.? == BenchmarkFlag.Bench)
        true
    else
        false;

    return Runner{
        .input = input,
        .function_to_run = functin_to_run,
        .benchmark = should_benchmark,
    };
}

fn benchmark(allocator: std.mem.Allocator, function: BenchmarkFunction) !void {
    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(allocator, .{
        .iterations = std.math.maxInt(u16),
        .max_iterations = std.math.maxInt(u16),
        .time_budget_ns = std.math.maxInt(u64),
    });
    defer bench.deinit();

    try bench.addParam("bench", &function, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}
