use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn main() {
    // Get the current directory
    let current_dir = env::current_dir().expect("Failed to get current directory");

    // Read the Cargo.toml file
    let cargo_toml = current_dir.join("Cargo.toml");
    let cargo_toml_content = fs::read_to_string(cargo_toml).expect("Failed to read Cargo.toml");

    // Extract the package name from Cargo.toml
    let package_name = cargo_toml_content
        .lines()
        .find(|line| line.starts_with("name = "))
        .map(|line| line.trim_start_matches("name = ").trim_matches('"'))
        .expect("Failed to find package name in Cargo.toml");

    // Construct the path to the build binary
    let build_path = current_dir
        .join("target")
        .join("thumbv6m-none-eabi")
        .join("debug")
        .join(package_name);

    // Define the openocd command and arguments
    let openocd_command = "openocd";
    let openocd_args = [
        "-s", "tcl",
        "-f", "interface/cmsis-dap.cfg",
        "-f", "target/rp2040.cfg",
        "-c", "adapter speed 5000",
        "-c", &format!("program {} verify reset exit", build_path.display()),
    ];

    // Execute the openocd command
    let status = Command::new(openocd_command)
        .args(&openocd_args)
        .status()
        .expect("Failed to execute openocd");

    if !status.success() {
        panic!("openocd command failed with status: {}", status);
    }
}