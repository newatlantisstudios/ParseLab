#!/bin/bash
# Build script for ParseLab with xcbeautify and quiet mode

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default configuration
CONFIG="Debug"
SCHEME="ParseLab"
DESTINATION="generic/platform=iOS Simulator"

# Check if xcbeautify is installed
if ! command -v xcbeautify &> /dev/null; then
    echo -e "${RED}Error: xcbeautify is not installed.${NC}"
    echo "Install it with: brew install xcbeautify"
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--release)
            CONFIG="Release"
            shift
            ;;
        -d|--device)
            DESTINATION="generic/platform=iOS"
            shift
            ;;
        -s|--scheme)
            SCHEME="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: build.sh [options]"
            echo "Options:"
            echo "  -r, --release     Build in Release configuration (default: Debug)"
            echo "  -d, --device      Build for device (default: simulator)"
            echo "  -s, --scheme      Specify scheme (default: ParseLab)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

echo -e "${YELLOW}Building ParseLab...${NC}"
echo "Configuration: $CONFIG"
echo "Scheme: $SCHEME"
echo "Destination: $DESTINATION"

# Build with xcbeautify
xcodebuild \
    -project ParseLab.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -destination "$DESTINATION" \
    -quiet \
    clean build | xcbeautify

# Check build status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}Build completed successfully!${NC}"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
