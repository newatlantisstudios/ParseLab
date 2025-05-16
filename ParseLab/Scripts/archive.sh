#!/bin/bash
# Archive script for ParseLab with xcbeautify and quiet mode

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default configuration
SCHEME="ParseLab"
CONFIG="Release"
ARCHIVE_PATH="./build/ParseLab.xcarchive"
EXPORT_PATH="./build/Export"
EXPORT_OPTIONS="./Scripts/ExportOptions.plist"

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
        -c|--config)
            CONFIG="$2"
            shift 2
            ;;
        -a|--archive-path)
            ARCHIVE_PATH="$2"
            shift 2
            ;;
        -e|--export-path)
            EXPORT_PATH="$2"
            shift 2
            ;;
        -o|--export-options)
            EXPORT_OPTIONS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: archive.sh [options]"
            echo "Options:"
            echo "  -s, --scheme           Specify scheme (default: ParseLab)"
            echo "  -c, --config           Specify configuration (default: Release)"
            echo "  -a, --archive-path     Specify archive path (default: ./build/ParseLab.xcarchive)"
            echo "  -e, --export-path      Specify export path (default: ./build/Export)"
            echo "  -o, --export-options   Specify export options plist (default: ./Scripts/ExportOptions.plist)"
            echo "  -h, --help             Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

echo -e "${YELLOW}Archiving ParseLab...${NC}"
echo "Scheme: $SCHEME"
echo "Configuration: $CONFIG"
echo "Archive Path: $ARCHIVE_PATH"

# Create build directory if it doesn't exist
mkdir -p "$(dirname "$ARCHIVE_PATH")"

# Archive
echo "Creating archive..."
xcodebuild \
    -project ParseLab.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -quiet \
    clean archive | xcbeautify

# Check archive status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}Archive created successfully!${NC}"
else
    echo -e "${RED}Archive failed!${NC}"
    exit 1
fi

# Export if export options exist
if [ -f "$EXPORT_OPTIONS" ]; then
    echo -e "${YELLOW}Exporting IPA...${NC}"
    echo "Export Path: $EXPORT_PATH"
    
    # Create export directory
    mkdir -p "$EXPORT_PATH"
    
    xcodebuild \
        -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS" \
        -quiet | xcbeautify
    
    # Check export status
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}Export completed successfully!${NC}"
        echo "IPA location: $EXPORT_PATH/ParseLab.ipa"
    else
        echo -e "${RED}Export failed!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Skipping export (no export options plist found)${NC}"
    echo "Create $EXPORT_OPTIONS to enable export"
fi
