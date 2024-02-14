const std = @import("std");
const arr = std.ArrayList;
const map = std.StringHashMap;
const cli_writer = std.io.getStdOut().writer();
const page_alloc = std.heap.page_allocator;

const NUMS = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn findNum(line: []u8, forward: bool) !u8 {
    for (line, 0..) |char, c_idx| { // For char in line
        const line_slice = line[c_idx..];
        for (NUMS, 0..) |number, w_idx| {
            var buffer = [_]u8{33} ** 5;
            std.mem.copyForwards(u8, &buffer, number);

            var buffer_max_idx = 5 - @as(u64, std.mem.count(u8, &buffer, "!"));
            var buffer_slice = buffer[0..buffer_max_idx];

            if (!forward) {
                std.mem.reverse(u8, buffer_slice);
            }

            if (std.mem.startsWith(u8, line_slice, buffer_slice)) {
                return @intCast(w_idx + 1 + '0');
            }
        }
        if (char >= '0' and char <= '9') { // if byte value is ASCII digit
            return char; // return valid digit
        }
    }
    return 0;
}

fn rFindNum(line: []u8) !u8 {
    std.mem.reverse(u8, line);
    return findNum(line, false);
}

fn combineFirstAndLast(first: u8, last: u8) !u7 {
    const digit: [2]u8 = .{ first, last };
    return try std.fmt.parseInt(u7, &digit, 10); // return int from the ArrayList string (base 10)
}

pub fn main() !void {
    var sum: u16 = 0; // For storing total

    var file = try std.fs.cwd().openFile("day_1.txt", .{}); // Open file in
    defer file.close(); // Don't close the file until we finish

    var buffered = std.io.bufferedReader(file.reader()); // Read file in
    var reader = buffered.reader(); // Init reader for buffer to read line by line

    var line_buffer = arr(u8).init(page_alloc); // Temp storage for each line
    defer line_buffer.deinit(); // Don't close until finished

    while (true) { // Endless loop while we read
        reader.streamUntilDelimiter(line_buffer.writer(), '\n', null) catch |err| switch (err) { // From buffer, read into line buffer until newline
            error.EndOfStream => break, // if err == EndOfStream break loop
            else => return err, // raise any other err to program
        };
        sum += try combineFirstAndLast(try findNum(line_buffer.items, true), try rFindNum(line_buffer.items)); // Find first and last digit in line and make them an int ("onetwo3four5" => 35)

        line_buffer.clearRetainingCapacity(); // Clear line buffer for next line
    }
    try cli_writer.print("Total: {d}\n", .{sum}); // Print Sum
}
