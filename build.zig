const std = @import("std");

fn copyLib(self: *std.build.Step, progress: *std.Progress.Node) !void {
    _ = progress;
    _ = self;

    std.fs.cwd().copyFile("zig-out/lib/smol-string.wasm", std.fs.cwd(), "ts-lib/src/module.wasm", .{}) catch |err| {
        std.log.err("Unable to copy smol-string.wasm to www/: {s}", .{@errorName(err)});
    };
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });

    var lib = b.addSharedLibrary(.{
        .name = "smol-string",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/wasm.zig" },
        .target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
        .optimize = .ReleaseSmall,
    });
    lib.rdynamic = true;

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(lib);

    const copyStep = b.step("copy", "copy libraries to www/");
    copyStep.dependOn(&lib.step);
    copyStep.dependOn(b.getInstallStep());
    copyStep.makeFn = copyLib;

    b.default_step = copyStep;

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/testAll.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const profile = b.addExecutable(.{
        .name = "profile",
        .root_source_file = .{ .path = "src/profile.zig" },
        .target = target,
        .optimize = .Debug,
    });
    b.installArtifact(profile);

    const run_profile = b.addRunArtifact(profile);

    const run_profile_step = b.step("run_profile", "Run the profile executable");
    run_profile_step.dependOn(&run_profile.step);
}
