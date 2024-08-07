const std = @import("std");

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

    var lib_target_query = std.Target.Query{ .cpu_arch = .wasm32, .os_tag = .freestanding };
    lib_target_query.cpu_features_add.addFeature(@intFromEnum(std.Target.wasm.Feature.bulk_memory));

    var lib = b.addExecutable(.{
        .name = "smol-string",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/wasm.zig" } },
        .target = b.resolveTargetQuery(lib_target_query),
        .optimize = .ReleaseSmall,
    });
    lib.entry = .disabled;
    lib.rdynamic = true;

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/testAll.zig" } },
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
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/profile.zig" } },
        .target = target,
        .optimize = .ReleaseSmall,
    });
    b.installArtifact(profile);

    const run_profile = b.addRunArtifact(profile);

    const run_profile_step = b.step("run_profile", "Run the profile executable");
    run_profile_step.dependOn(&run_profile.step);
}
