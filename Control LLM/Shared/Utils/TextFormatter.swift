import Foundation
import SwiftUI

struct TextFormatter {
    
    /// Converts markdown text to AttributedString with proper formatting
    static func formatText(_ text: String) -> AttributedString {
        print("TextFormatter: Original text: \(text)")
        
        // First add line breaks for better readability
        let textWithBreaks = addLineBreaks(text)
        print("TextFormatter: After line breaks: \(textWithBreaks)")
        
        // Process the text to remove asterisks and clean up spaces
        let processedText = processMarkdown(textWithBreaks)
        print("TextFormatter: After markdown processing: \(processedText)")
        
        // Create AttributedString with the processed text
        var attributedString = AttributedString(processedText)
        
        // Apply bold and italic formatting using font attributes
        attributedString = applyFormatting(attributedString, originalText: textWithBreaks)
        
        return attributedString
    }
    
    /// Processes markdown text to remove asterisks and clean up spaces
    private static func processMarkdown(_ text: String) -> String {
        var result = text
        
        // Remove bold formatting (**text** -> text)
        result = result.replacingOccurrences(of: #"\*\*([^*]+)\*\*"#, with: "$1", options: .regularExpression)
        
        // Remove italic formatting (*text* -> text)
        result = result.replacingOccurrences(of: #"(?<!\*)\*([^*]+)\*(?!\*)"#, with: "$1", options: .regularExpression)
        
        // Fix numbered lists: "1.\n\ntext" -> "1. text"
        result = result.replacingOccurrences(of: #"(\d+\.)\s*\n\s*"#, with: "$1 ", options: .regularExpression)
        
        // Clean up extra spaces but preserve line breaks
        result = result.replacingOccurrences(of: #"[ \t]+"#, with: " ", options: .regularExpression)
        
        return result
    }
    
    /// Applies formatting attributes to the processed text
    private static func applyFormatting(_ attributedString: AttributedString, originalText: String) -> AttributedString {
        var result = attributedString
        let nsString = String(attributedString.characters)
        
        // Find bold patterns in original text and apply formatting
        do {
            let boldPattern = #"\*\*([^*]+)\*\*"#
            let boldRegex = try NSRegularExpression(pattern: boldPattern, options: [])
            let boldMatches = boldRegex.matches(in: originalText, options: [], range: NSRange(location: 0, length: originalText.count))
            
            for match in boldMatches.reversed() {
                if let contentRange = Range(match.range(at: 1), in: originalText) {
                    let content = String(originalText[contentRange])
                    
                    // Find the content in the processed text
                    if let range = nsString.range(of: content) {
                        let startIndex = result.index(result.startIndex, offsetByCharacters: range.lowerBound.utf16Offset(in: nsString))
                        let endIndex = result.index(result.startIndex, offsetByCharacters: range.upperBound.utf16Offset(in: nsString))
                        
                        // Apply bold formatting using font
                        result[startIndex..<endIndex].font = .system(size: 16, weight: .bold, design: .monospaced)
                    }
                }
            }
        } catch {
            print("TextFormatter: Error applying bold formatting: \(error)")
        }
        
        // Find italic patterns in original text and apply formatting
        do {
            let italicPattern = #"(?<!\*)\*([^*]+)\*(?!\*)"#
            let italicRegex = try NSRegularExpression(pattern: italicPattern, options: [])
            let italicMatches = italicRegex.matches(in: originalText, options: [], range: NSRange(location: 0, length: originalText.count))
            
            for match in italicMatches.reversed() {
                if let contentRange = Range(match.range(at: 1), in: originalText) {
                    let content = String(originalText[contentRange])
                    
                    // Find the content in the processed text
                    if let range = nsString.range(of: content) {
                        let startIndex = result.index(result.startIndex, offsetByCharacters: range.lowerBound.utf16Offset(in: nsString))
                        let endIndex = result.index(result.startIndex, offsetByCharacters: range.upperBound.utf16Offset(in: nsString))
                        
                        // Apply italic formatting using font and obliqueness
                        result[startIndex..<endIndex].font = .system(size: 16, weight: .regular, design: .monospaced)
                        result[startIndex..<endIndex].obliqueness = 0.2
                    }
                }
            }
        } catch {
            print("TextFormatter: Error applying italic formatting: \(error)")
        }
        
        return result
    }
    
    /// Adds intelligent line breaks for better readability
    private static func addLineBreaks(_ text: String) -> String {
        var result = text
        
        // Add line breaks after sentences ending with period, exclamation, or question mark
        result = result.replacingOccurrences(of: #"([.!?])\s+([A-Z])"#, with: "$1\n\n$2", options: .regularExpression)
        
        // Add line breaks before numbered lists (1., 2., etc.)
        result = result.replacingOccurrences(of: #"\n\s*(\d+\.\s)"#, with: "\n\n$1", options: .regularExpression)
        
        // Add line breaks before bullet points (- or *)
        result = result.replacingOccurrences(of: #"\n\s*[-*]\s"#, with: "\n\n• ", options: .regularExpression)
        
        // Add line breaks before section headers (lines starting with #)
        result = result.replacingOccurrences(of: #"\n\s*#+\s"#, with: "\n\n", options: .regularExpression)
        
        // Add line breaks after colons (for lists or explanations)
        result = result.replacingOccurrences(of: #":\s+([A-Z])"#, with: ":\n\n$1", options: .regularExpression)
        
        // Clean up multiple consecutive line breaks (more than 2)
        result = result.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)
        
        // Clean up line breaks at the beginning and end
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
}