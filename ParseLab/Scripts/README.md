# ParseLab Build Scripts

This directory contains build scripts for ParseLab that use `xcbeautify` for improved output formatting and quiet mode for cleaner builds.

## Prerequisites

Install `xcbeautify` using Homebrew:

```bash
brew install xcbeautify
```

## Scripts Overview

### all-scripts.sh
Main script runner that provides access to all other scripts.

```bash
./all-scripts.sh <command> [options]
```

Commands:
- `build` - Build the project
- `test` - Run tests
- `run` - Build and run on simulator
- `clean` - Clean build artifacts
- `archive` - Create archive and IPA
- `setup` - Make all scripts executable

### build.sh
Builds the ParseLab project with various options.

```bash
./build.sh [options]
```

Options:
- `-r, --release` - Build in Release configuration (default: Debug)
- `-d, --device` - Build for device (default: simulator)
- `-s, --scheme` - Specify scheme (default: ParseLab)

### test.sh
Runs tests with options for unit or UI tests.

```bash
./test.sh [options]
```

Options:
- `-s, --scheme` - Specify scheme (default: ParseLab)
- `-d, --destination` - Specify destination (default: iPhone 15 simulator)
- `-u, --unit-only` - Run unit tests only
- `-i, --ui-only` - Run UI tests only

### run.sh
Builds and runs the app on a specified simulator.

```bash
./run.sh [options] [device]
```

Options:
- `-s, --scheme` - Specify scheme (default: ParseLab)
- `-c, --config` - Specify configuration (default: Debug)
- `-l, --list-devices` - List available simulator devices

Examples:
```bash
./run.sh                    # Run on default simulator
./run.sh "iPhone 15"        # Run on specific device
./run.sh -c Release "iPad" # Run release build on iPad
```

### clean.sh
Cleans build artifacts with optional deep clean.

```bash
./clean.sh [options]
```

Options:
- `-d, --deep` - Deep clean (includes DerivedData)
- `-s, --scheme` - Specify scheme (default: ParseLab)

### archive.sh
Creates an archive and optionally exports an IPA.

```bash
./archive.sh [options]
```

Options:
- `-s, --scheme` - Specify scheme (default: ParseLab)
- `-c, --config` - Specify configuration (default: Release)
- `-a, --archive-path` - Specify archive path
- `-e, --export-path` - Specify export path
- `-o, --export-options` - Specify export options plist

## Usage Examples

```bash
# First-time setup
./all-scripts.sh setup

# Build for debug
./all-scripts.sh build

# Build for release
./all-scripts.sh build -r

# Run all tests
./all-scripts.sh test

# Run unit tests only
./all-scripts.sh test -u

# Run on specific simulator
./all-scripts.sh run "iPhone 15 Pro"

# Clean build artifacts
./all-scripts.sh clean

# Deep clean including DerivedData
./all-scripts.sh clean -d

# Create release archive
./all-scripts.sh archive
```

## Configuration

### Export Options

To enable IPA export, update `ExportOptions.plist` with your team ID:

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>
```

## Features

- **Quiet Mode**: All scripts use `xcodebuild -quiet` for cleaner output
- **xcbeautify**: Formats xcodebuild output for better readability
- **Error Handling**: Scripts exit on error with clear status messages
- **Colored Output**: Uses color coding for different message types
- **Parallel Support**: Build status is properly tracked with pipefail

## Troubleshooting

### xcbeautify not found

If you get an error about xcbeautify not being installed:

```bash
brew install xcbeautify
```

### Permission Denied

If scripts aren't executable:

```bash
chmod +x Scripts/*.sh
```

Or use the setup command:

```bash
./all-scripts.sh setup
```

### Build Failures

For detailed build output without quiet mode:

```bash
# Temporarily remove -quiet flag from the script
# or run xcodebuild directly:
xcodebuild -project ParseLab.xcodeproj -scheme ParseLab build
```
