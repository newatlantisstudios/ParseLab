#!/bin/bash
# Clean script for ParseLab

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
SCHEME="ParseLab"
DEEP_CLEAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--deep)
            DEEP_CLEAN=true
            shift
            ;;
        -s|--scheme)
            SCHEME="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: clean.sh [options]"
            echo "Options:"
            echo "  -d, --deep       Deep clean (includes DerivedData)"
            echo "  -s, --scheme     Specify scheme (default: ParseLab)"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

echo -e "${YELLOW}Cleaning ParseLab...${NC}"

# Clean build folder
echo "Cleaning build folder..."
xcodebuild \
    -project ParseLab.xcodeproj \
    -scheme "$SCHEME" \
    -quiet \
    clean

# Deep clean if requested
if [ "$DEEP_CLEAN" = true ]; then
    echo "Performing deep clean..."
    
    # Clean DerivedData
    DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
    if [ -d "$DERIVED_DATA_PATH" ]; then
        echo "Cleaning DerivedData..."
        PARSELAB_DIRS=$(find "$DERIVED_DATA_PATH" -name "ParseLab-*" -type d 2>/dev/null || true)
        if [ -n "$PARSELAB_DIRS" ]; then
            echo "$PARSELAB_DIRS" | while read -r dir; do
                echo "Removing: $dir"
                rm -rf "$dir"
            done
        fi
    fi
    
    # Clean module cache
    echo "Cleaning module cache..."
    rm -rf "$HOME/Library/Developer/Xcode/DerivedData/ModuleCache"
    
    # Clean build folder
    if [ -d "build" ]; then
        echo "Removing local build folder..."
        rm -rf build
    fi
fi

echo -e "${GREEN}Clean completed successfully!${NC}"
