#!/bin/bash
# Run script for ParseLab with device options

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
SCHEME="ParseLab"
CONFIG="Debug"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--scheme)
            SCHEME="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG="$2"
            shift 2
            ;;
        -l|--list-devices)
            echo -e "${BLUE}Available devices:${NC}"
            xcrun simctl list devices available | grep -E '(iPhone|iPad)'
            exit 0
            ;;
        -h|--help)
            echo "Usage: run.sh [options] [device]"
            echo "Options:"
            echo "  -s, --scheme          Specify scheme (default: ParseLab)"
            echo "  -c, --config          Specify configuration (default: Debug)"
            echo "  -l, --list-devices    List available simulator devices"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./run.sh                           # Run on default simulator"
            echo "  ./run.sh \"iPhone 15\"              # Run on specific device"
            echo "  ./run.sh -c Release \"iPad Air\"    # Run release build on iPad"
            exit 0
            ;;
        *)
            DEVICE="$1"
            shift
            ;;
    esac
done

echo -e "${YELLOW}Running ParseLab...${NC}"
echo "Scheme: $SCHEME"
echo "Configuration: $CONFIG"

# Determine destination
if [ -n "$DEVICE" ]; then
    DESTINATION="platform=iOS Simulator,name=$DEVICE"
    echo "Device: $DEVICE"
else
    # Get the most recent iPhone simulator
    DEVICE=$(xcrun simctl list devices available | grep "iPhone" | sort -r | head -1 | sed 's/.*(//' | sed 's/).*//')
    DESTINATION="platform=iOS Simulator,name=$DEVICE"
    echo "Device: $DEVICE (default)"
fi

# Build and run
echo ""
echo "Building and running..."
xcodebuild \
    -project ParseLab.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -destination "$DESTINATION" \
    -quiet \
    build | xcbeautify

# Check build status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}Build completed successfully!${NC}"
    
    # Launch the app
    echo "Launching app..."
    xcrun simctl boot "$DEVICE" 2>/dev/null || true
    open -a Simulator
    
    # Install and launch the app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name ParseLab.app -type d | grep -v "__PRODUCTS" | sort -r | head -1)
    if [ -n "$APP_PATH" ]; then
        echo "Installing app..."
        xcrun simctl install "$DEVICE" "$APP_PATH"
        echo "Launching ParseLab..."
        xcrun simctl launch "$DEVICE" com.parselab.ParseLab
        echo -e "${GREEN}App launched successfully!${NC}"
    else
        echo -e "${RED}Could not find built app${NC}"
        exit 1
    fi
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
