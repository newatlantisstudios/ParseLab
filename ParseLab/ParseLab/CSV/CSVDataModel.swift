import Foundation

/// Represents the entire CSV file data
class CSVDocument {
    var headers: [String]
    var rows: [[String]]
    var filePath: URL?
    
    init(headers: [String] = [], rows: [[String]] = [], filePath: URL? = nil) {
        self.headers = headers
        self.rows = rows
        self.filePath = filePath
    }
    
    var columnCount: Int {
        return headers.count
    }
    
    var rowCount: Int {
        return rows.count
    }
    
    func getValue(row: Int, column: Int) -> String? {
        guard row >= 0, row < rows.count,
              column >= 0, column < rows[row].count else {
            return nil
        }
        return rows[row][column]
    }
    
    func getValueByHeader(row: Int, header: String) -> String? {
        guard let columnIndex = headers.firstIndex(of: header) else {
            return nil
        }
        return getValue(row: row, column: columnIndex)
    }
    
    func setValue(row: Int, column: Int, value: String) -> Bool {
        guard row >= 0, row < rows.count,
              column >= 0, column < rows[row].count else {
            return false
        }
        rows[row][column] = value
        return true
    }
    
    func addRow(values: [String]) {
        // Pad or truncate the values to match the header count
        var rowValues = values
        if rowValues.count < columnCount {
            rowValues.append(contentsOf: Array(repeating: "", count: columnCount - rowValues.count))
        } else if rowValues.count > columnCount {
            rowValues = Array(rowValues[0..<columnCount])
        }
        rows.append(rowValues)
    }
    
    func deleteRow(at index: Int) -> Bool {
        guard index >= 0, index < rows.count else {
            return false
        }
        rows.remove(at: index)
        return true
    }
    
    func addColumn(header: String, defaultValue: String = "") {
        headers.append(header)
        // Add a new column to each row
        for i in 0..<rows.count {
            rows[i].append(defaultValue)
        }
    }
    
    func deleteColumn(at index: Int) -> Bool {
        guard index >= 0, index < headers.count else {
            return false
        }
        headers.remove(at: index)
        // Remove the column from each row
        for i in 0..<rows.count {
            if index < rows[i].count {
                rows[i].remove(at: index)
            }
        }
        return true
    }
    
    func toCSVString(delimiter: String = ",") -> String {
        var result = headers.joined(separator: delimiter) + "\n"
        
        for row in rows {
            let escapedValues = row.map { value -> String in
                if value.contains(delimiter) || value.contains("\"") || value.contains("\n") {
                    return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return value
            }
            result += escapedValues.joined(separator: delimiter) + "\n"
        }
        
        return result
    }
}

/// Manager for loading and saving CSV files
class CSVParser {
    static func parse(from url: URL) throws -> CSVDocument {
        let csvString = try String(contentsOf: url, encoding: .utf8)
        return parse(csvString: csvString, filePath: url)
    }
    
    static func parse(csvString: String, filePath: URL? = nil) -> CSVDocument {
        var lines = csvString.components(separatedBy: .newlines)
        lines = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard !lines.isEmpty else {
            print("[ERROR] CSV parsing found no valid lines")
            return CSVDocument(headers: ["Empty"], rows: [["No data"]], filePath: filePath)
        }
        
        // Get headers from first line
        let headers = parseCSVLine(lines[0])
        
        // Handle empty headers with default values
        let validHeaders = headers.isEmpty ? ["Column"] : headers
        
        var rows: [[String]] = []
        
        if lines.count > 1 {
            for i in 1..<lines.count {
                let row = parseCSVLine(lines[i])
                
                // Make sure row has same number of columns as headers
                var validRow = row
                if validRow.count < validHeaders.count {
                    // Pad with empty strings if needed
                    validRow.append(contentsOf: Array(repeating: "", count: validHeaders.count - validRow.count))
                } else if validRow.count > validHeaders.count {
                    // Truncate if needed
                    validRow = Array(validRow[0..<validHeaders.count])
                }
                
                rows.append(validRow)
            }
        }
        
        // If no rows, add an empty one for better UI
        if rows.isEmpty {
            rows.append(Array(repeating: "", count: validHeaders.count))
        }
        
        return CSVDocument(headers: validHeaders, rows: rows, filePath: filePath)
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentValue = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                if insideQuotes && line.dropFirst(currentValue.count + 1).first == "\"" {
                    // Handle escaped quotes (two double quotes in a row)
                    currentValue.append(char)
                    continue
                }
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentValue)
                currentValue = ""
            } else {
                currentValue.append(char)
            }
        }
        
        // Add the last value
        result.append(currentValue)
        
        return result
    }
    
    static func save(_ document: CSVDocument, to url: URL) throws {
        let csvString = document.toCSVString()
        try csvString.write(to: url, atomically: true, encoding: .utf8)
        document.filePath = url
    }
}