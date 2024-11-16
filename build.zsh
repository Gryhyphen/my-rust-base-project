#!/bin/zsh

# Build the thing
cargo build

if [ $? -eq 0 ]; then
    echo "Build succeeded, flashing the binary to the board..."
else
    echo "Build failed, please check the errors and try again."
    exit 1
fi

# Get the current directory
current_dir=$(pwd)

# Read the Cargo.toml file
cargo_toml="$current_dir/Cargo.toml"
if [[ ! -f "$cargo_toml" ]]; then
    echo "Failed to find Cargo.toml"
    exit 1
fi

cargo_toml_content=$(cat "$cargo_toml")

# Extract the package name from Cargo.toml
package_name=$(echo "$cargo_toml_content" | grep '^name =' | sed 's/name = "\(.*\)"/\1/')
if [[ -z "$package_name" ]]; then
    echo "Failed to find package name in Cargo.toml"
    exit 1
fi

# Construct the path to the build binary
build_path="$current_dir/target/thumbv6m-none-eabi/debug/$package_name"

# Define the openocd command and arguments
openocd_command="sudo"
openocd_args=(
    "openocd"
    "-s" "tcl"
    "-f" "interface/cmsis-dap.cfg"
    "-f" "target/rp2040.cfg"
    "-c" "adapter speed 5000"
    "-c" "program $build_path verify reset exit"
)

# Execute the openocd command
$openocd_command "${openocd_args[@]}"
status=$?

if [[ $status -ne 0 ]]; then
    echo "openocd command failed with status: $status"
    exit 1
fi