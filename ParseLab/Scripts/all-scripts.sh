#!/bin/bash
# Main build script runner with xcbeautify support

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname \"${BASH_SOURCE[0]}\")" && pwd)"

# Check if xcbeautify is installed
if ! command -v xcbeautify &> /dev/null; then
    echo -e "${RED}Error: xcbeautify is not installed.${NC}"
    echo "Install it with: brew install xcbeautify"
    echo ""
    echo "xcbeautify improves xcodebuild output formatting."
    exit 1
fi

# Show usage
show_usage() {
    echo -e "${BLUE}ParseLab Build Scripts${NC}"
    echo ""
    echo "Usage: all-scripts.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build       Build the project"
    echo "  test        Run tests"
    echo "  run         Build and run on simulator"
    echo "  clean       Clean build artifacts"
    echo "  archive     Create archive and IPA"
    echo "  setup       Make all scripts executable"
    echo ""
    echo "Options:"
    echo "  Pass any options through to the specific script"
    echo "  Use <command> -h for command-specific help"
    echo ""
    echo "Examples:"
    echo "  ./all-scripts.sh build -r            # Release build"
    echo "  ./all-scripts.sh test -u             # Unit tests only"
    echo "  ./all-scripts.sh run \"iPhone 15\"    # Run on specific device"
    echo "  ./all-scripts.sh clean -d            # Deep clean"
}

# Make scripts executable
setup_scripts() {
    echo -e "${YELLOW}Setting up scripts...${NC}"
    chmod +x "$SCRIPT_DIR"/*.sh
    echo -e "${GREEN}All scripts are now executable!${NC}"
}

# Check if no arguments
if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

# Parse command
COMMAND=$1
shift

# Execute command
case $COMMAND in
    build)
        "$SCRIPT_DIR/build.sh" "$@"
        ;;
    test)
        "$SCRIPT_DIR/test.sh" "$@"
        ;;
    run)
        "$SCRIPT_DIR/run.sh" "$@"
        ;;
    clean)
        "$SCRIPT_DIR/clean.sh" "$@"
        ;;
    archive)
        "$SCRIPT_DIR/archive.sh" "$@"
        ;;
    setup)
        setup_scripts
        ;;
    -h|--help|help)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac
