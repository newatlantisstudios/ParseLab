#!/bin/bash
# Test script for ParseLab with xcbeautify and quiet mode

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default configuration
SCHEME="ParseLab"
DESTINATION="platform=iOS Simulator,name=iPhone 15"

# Check if xcbeautify is installed
if ! command -v xcbeautify &> /dev/null; then
    echo -e "${RED}Error: xcbeautify is not installed.${NC}"
    echo "Install it with: brew install xcbeautify"
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--scheme)
            SCHEME="$2"
            shift 2
            ;;
        -d|--destination)
            DESTINATION="$2"
            shift 2
            ;;
        -u|--unit-only)
            UNIT_ONLY=true
            shift
            ;;
        -i|--ui-only)
            UI_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: test.sh [options]"
            echo "Options:"
            echo "  -s, --scheme          Specify scheme (default: ParseLab)"
            echo "  -d, --destination     Specify destination (default: iPhone 15 simulator)"
            echo "  -u, --unit-only       Run unit tests only"
            echo "  -i, --ui-only         Run UI tests only"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

echo -e "${YELLOW}Running ParseLab tests...${NC}"
echo "Scheme: $SCHEME"
echo "Destination: $DESTINATION"

# Run tests based on options
if [ "$UI_ONLY" = true ]; then
    echo "Running UI tests only..."
    TEST_PLAN="ParseLabUITests"
elif [ "$UNIT_ONLY" = true ]; then
    echo "Running unit tests only..."
    TEST_PLAN="ParseLabTests"
else
    echo "Running all tests..."
    TEST_PLAN=""
fi

# Run tests with xcbeautify
if [ -n "$TEST_PLAN" ]; then
    xcodebuild \
        -project ParseLab.xcodeproj \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -quiet \
        test-without-building \
        -only-testing:"$TEST_PLAN" | xcbeautify
else
    xcodebuild \
        -project ParseLab.xcodeproj \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -quiet \
        test | xcbeautify
fi

# Check test status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}Tests completed successfully!${NC}"
else
    echo -e "${RED}Tests failed!${NC}"
    exit 1
fi
