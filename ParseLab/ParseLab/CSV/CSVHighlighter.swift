import UIKit

/// A syntax highlighter for CSV files
class CSVHighlighter {
    
    /// Highlight CSV content with appropriate styling
    /// - Parameters:
    ///   - csvString: The CSV content to highlight
    ///   - font: The base font to use
    /// - Returns: An attributed string with syntax highlighting
    func highlightCSV(_ csvString: String, font: UIFont?) -> NSAttributedString {
        let baseFont = font ?? UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        let headerFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .bold)
        
        let attributedString = NSMutableAttributedString(string: csvString)
        
        // Base attributes for the entire string
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: UIColor.label
        ]
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        // Split the string into lines
        let lines = csvString.components(separatedBy: .newlines)
        
        // Get the header line (first line)
        if let headerLine = lines.first, !headerLine.isEmpty {
            // Find range of the header line
            if let headerRange = csvString.range(of: headerLine) {
                let nsHeaderRange = NSRange(headerRange, in: csvString)
                
                // Add header attributes
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: headerFont,
                    .foregroundColor: UIColor.systemBlue
                ]
                attributedString.addAttributes(headerAttributes, range: nsHeaderRange)
            }
        }
        
        // Handle quotes and commas for better visual separation
        let quotePattern = "\"([^\"]|\"\")*\""
        do {
            let regex = try NSRegularExpression(pattern: quotePattern, options: [])
            let matches = regex.matches(in: csvString, options: [], range: NSRange(location: 0, length: csvString.count))
            
            for match in matches {
                let valueAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.systemGreen
                ]
                attributedString.addAttributes(valueAttributes, range: match.range)
            }
        } catch {
            print("Error creating regex: \(error)")
        }
        
        // Highlight commas for better visual separation
        let commaPattern = ","
        do {
            let regex = try NSRegularExpression(pattern: commaPattern, options: [])
            let matches = regex.matches(in: csvString, options: [], range: NSRange(location: 0, length: csvString.count))
            
            for match in matches {
                let commaAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.systemGray
                ]
                attributedString.addAttributes(commaAttributes, range: match.range)
            }
        } catch {
            print("Error creating regex: \(error)")
        }
        
        return attributedString
    }
}