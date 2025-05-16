import Foundation

// Simple test of the PLIST parser
let plistString = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>name</key>
    <string>Test Item</string>
    <key>count</key>
    <integer>42</integer>
    <key>enabled</key>
    <true/>
</dict>
</plist>
"""

if let data = plistString.data(using: .utf8) {
    do {
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        print("PLIST parsed successfully: \(plist)")
        
        let jsonData = try JSONSerialization.data(withJSONObject: plist, options: [.prettyPrinted])
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON output:\n\(jsonString)")
        }
    } catch {
        print("Error: \(error)")
    }
} else {
    print("Failed to convert string to data")
}