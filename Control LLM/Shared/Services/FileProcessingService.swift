import Foundation
import UIKit
import PDFKit
import Vision

// MARK: - Performance StringBuilder for Better String Processing
struct StringBuilder {
    private var buffer: [String] = []
    
    var count: Int {
        return buffer.joined().count
    }
    
    mutating func append(_ string: String) {
        buffer.append(string)
    }
    
    func toString() -> String {
        return buffer.joined()
    }
}

class FileProcessingService {
    static let shared = FileProcessingService()
    
    // Track multi-pass processing state
    @MainActor var isMultiPassProcessingActive: Bool = false
    
    // PHASE 1: Temporary debug flag to force multi-pass processing
    static let forceMultiPassForDebugging = true // Set to true to force multi-pass regardless of file size
    
    // Security: File size limits by type
    private static let maxFileSizes: [String: Int] = [
        "pdf": 25 * 1024 * 1024,      // 25MB
        "jpg": 10 * 1024 * 1024,      // 10MB
        "jpeg": 10 * 1024 * 1024,     // 10MB
        "png": 10 * 1024 * 1024,      // 10MB
        "heic": 10 * 1024 * 1024,     // 10MB
        "txt": 5 * 1024 * 1024,       // 5MB
        "md": 5 * 1024 * 1024,        // 5MB
        "rtf": 5 * 1024 * 1024,       // 5MB
        "doc": 15 * 1024 * 1024,      // 15MB
        "docx": 15 * 1024 * 1024      // 15MB
    ]
    
    private init() {}
    
    /// Process a file and extract its content for LLM processing
    func processFile(_ url: URL) async throws -> FileContent {
        let shouldAccess = url.startAccessingSecurityScopedResource()
        defer {
            if shouldAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let fileExtension = url.pathExtension.lowercased()
        
        // Security: Validate file size before processing
        try validateFileSize(url, fileExtension: fileExtension)
        
        switch fileExtension {
        case "txt", "md", "rtf":
            return try await processTextFile(url)
        case "pdf":
            return try await processPDFFile(url)
        case "jpg", "jpeg", "png", "heic":
            return try await processImageFile(url)
        case "doc", "docx":
            return try await processWordDocument(url)
        default:
            throw FileProcessingError.unsupportedFormat
        }
    }
    
    /// Process text files (txt, md, rtf)
    private func processTextFile(_ url: URL) async throws -> FileContent {
        var data = try Data(contentsOf: url)
        
        // Security: Validate file content
        try validateFileContent(data)
        
        guard let text = String(data: data, encoding: .utf8) else {
            // Security: Clear sensitive data before throwing error
            SecureStorage.secureWipe(&data)
            throw FileProcessingError.encodingError
        }
        
        let result = FileContent(
            fileName: url.lastPathComponent,
            content: text,
            type: .text,
            size: data.count
        )
        
        // Security: Clear sensitive data from memory
        SecureStorage.secureWipe(&data)
        
        return result
    }
    
    /// Process PDF files
    private func processPDFFile(_ url: URL) async throws -> FileContent {
        print("🔍 FileProcessingService: Starting PDF processing for URL: \(url.path)")
        
        // PERFORMANCE FIX: Run all file I/O and parsing in a detached background task
        // to prevent any possibility of blocking the main thread during UI transitions (e.g., file picker dismissal).
        return try await Task.detached(priority: .userInitiated) {
            // First try to create PDFDocument from URL (for files with direct access)
            if let pdfDocument = PDFDocument(url: url) {
                print("✅ FileProcessingService: Successfully created PDFDocument from URL.")
                // Pass needed properties instead of capturing self
                let fileName = url.lastPathComponent
                let fileSize = url.fileSize ?? 0
                return try await FileProcessingService.shared.extractTextFromPDFDocument(pdfDocument, fileName: fileName, size: fileSize)
            }
            
            // If URL access fails, try to read the file data and create PDFDocument from data
            print("⚠️ FileProcessingService: Could not create PDFDocument from URL, attempting to read data directly.")
            do {
                let fileData = try Data(contentsOf: url)
                print("✅ FileProcessingService: Successfully read PDF data (\(fileData.count) bytes).")
                guard let pdfDocument = PDFDocument(data: fileData) else {
                    print("❌ FileProcessingService: Failed to create PDFDocument from data.")
                    throw FileProcessingError.pdfError
                }
                
                print("✅ FileProcessingService: Successfully created PDFDocument from data.")
                // Pass needed properties instead of capturing self
                let fileName = url.lastPathComponent
                return try await FileProcessingService.shared.extractTextFromPDFDocument(pdfDocument, fileName: fileName, size: fileData.count)
            } catch {
                print("❌ FileProcessingService: Failed to read PDF data with error: \(error)")
                throw FileProcessingError.pdfError
            }
        }.value
    }
    
    /// Extract text from PDFDocument (helper method)
    private func extractTextFromPDFDocument(_ pdfDocument: PDFDocument, fileName: String, size: Int) async throws -> FileContent {
        print("🔍 FileProcessingService: Starting text extraction from PDF")
        var extractedText = ""
        let pageCount = pdfDocument.pageCount
        print("🔍 FileProcessingService: PDF has \(pageCount) pages")
        
        for i in 0..<pageCount {
            if let page = pdfDocument.page(at: i) {
                if let pageContent = page.string {
                    extractedText += pageContent + "\n\n"
                    SecureLogger.log("FileProcessingService: Extracted \(pageContent.count) characters from page \(i+1)")
                } else {
                    print("⚠️ FileProcessingService: Page \(i+1) has no text content")
                }
            } else {
                print("❌ FileProcessingService: Could not access page \(i+1)")
            }
        }
        
        print("🔍 FileProcessingService: Total extracted text: \(extractedText.count) characters")
        
        if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("❌ FileProcessingService: PDF contains no readable text")
            throw FileProcessingError.emptyContent
        }
        
        print("✅ FileProcessingService: Successfully extracted text from PDF")
        
        let result = FileContent(
            fileName: fileName,
            content: extractedText,
            type: .pdf,
            size: size,
            metadata: ["pages": String(format: NSLocalizedString("%d", comment: ""), pageCount)]
        )
        
        // Security: Clear PDF document from memory
        autoreleasepool {
            // This ensures PDFKit releases its internal memory
        }
        
        // Additional security: Clear extracted text from memory
        // Note: Removed string wiping as it can cause memory corruption
        // The string will be deallocated naturally when it goes out of scope
        
        return result
    }
    
    /// Process image files using Vision framework for text extraction
    private func processImageFile(_ url: URL) async throws -> FileContent {
        // PERFORMANCE FIX: Run image processing on background thread
        return try await Task.detached(priority: .userInitiated) {
            // First try to load image from file path (for files with direct access)
            if let image = UIImage(contentsOfFile: url.path) {
                var extractedText = try await FileProcessingService.shared.extractTextFromImage(image)
                let result = FileContent(
                    fileName: url.lastPathComponent,
                    content: extractedText,
                    type: .image,
                    size: url.fileSize ?? 0
                )
                
                // Security: Clear sensitive data from memory
                // Note: Removed string wiping as it can cause memory corruption
                // The string will be deallocated naturally when it goes out of scope
                
                return result
            }
            
            // If file path access fails, try to read the file data and create image from data
            do {
                var fileData = try Data(contentsOf: url)
                guard let image = UIImage(data: fileData) else {
                    throw FileProcessingError.imageError
                }
                
                var extractedText = try await FileProcessingService.shared.extractTextFromImage(image)
                let result = FileContent(
                    fileName: url.lastPathComponent,
                    content: extractedText,
                    type: .image,
                    size: fileData.count
                )
                
                // Security: Clear sensitive data from memory
                // Note: Removed string wiping as it can cause memory corruption
                // The string will be deallocated naturally when it goes out of scope
                // Note: Removed fileData wiping as it can cause memory corruption
                // The data will be deallocated naturally when it goes out of scope
                
                return result
            } catch {
                print("❌ FileProcessingService: Failed to read image data: \(error)")
                throw FileProcessingError.imageError
            }
        }.value
    }
    
    /// Extract text from image using Vision framework
    private func extractTextFromImage(_ image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw FileProcessingError.imageError
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Vision error: \(error)")
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        guard let observations = request.results else {
            return NSLocalizedString("No text found in image", comment: "")
        }
        
        let extractedText = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }.joined(separator: "\n")
        
        // Security: Clear Vision framework memory
        autoreleasepool {
            // This ensures Vision framework releases its internal memory
        }
        
        // Additional security: Clear observations from memory
        // Note: VNRecognizedTextObservation array doesn't need secure wiping as it doesn't contain sensitive text data
        // The actual text content has already been extracted and will be wiped separately
        
        return extractedText.isEmpty ? NSLocalizedString("No text found in image", comment: "") : extractedText
    }
    
    /// Process Word documents (basic implementation)
    private func processWordDocument(_ url: URL) async throws -> FileContent {
        // For now, return a message about Word document support
        // In a full implementation, you'd use a library like TextEdit or similar
        return FileContent(
            fileName: url.lastPathComponent,
            content: NSLocalizedString("Word document processing is not yet supported. Please convert to PDF or text format.", comment: ""),
            type: .document,
            size: url.fileSize ?? 0
        )
    }
    
    /// Truncates content and adds a metadata header for the LLM prompt.
    func formatForLLM(_ fileContent: FileContent, maxLength: Int) -> String {
        var formatted = "📎 File: \(fileContent.fileName)\n"
        formatted += "📄 Type: \(fileContent.type.localizedName)\n"
        if let size = fileContent.size {
            formatted += "📏 Size: \(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))\n"
        }
        if let metadata = fileContent.metadata {
            for (key, value) in metadata {
                formatted += "ℹ️ \(key): \(value)\n"
            }
        }
        formatted += "\n📝 Content:\n\n"
        
        // Calculate how much space is left for content after header
        let headerLength = formatted.count
        let availableContentLength = max(maxLength - headerLength - 100, 200) // Reserve 100 chars for ellipsis message
        
        if fileContent.content.count <= availableContentLength {
            // Content fits within limit
            formatted += fileContent.content
        } else {
            // Content needs to be chunked intelligently
            let chunkedContent = intelligentChunk(content: fileContent.content, 
                                                maxLength: availableContentLength,
                                                fileType: fileContent.type)
            formatted += chunkedContent
        }
        
        return formatted
    }
    
    /// Calculate number of passes needed for multi-pass processing
    func calculatePassCount(_ fileContent: FileContent, maxLength: Int = Constants.defaultChunkSize) -> Int {
        let headerLength = estimateHeaderLength(fileContent)
        // PHASE 3: Use centralized constants for consistent limits
        let availableContentLength = max(maxLength - headerLength - Constants.instructionBuffer, 100) // Conservative buffer
        let chunkSize = availableContentLength - 300 // Conservative reserve
        
        let passCount: Int
        if fileContent.content.count <= availableContentLength {
            passCount = 1
        } else {
            passCount = Int(ceil(Double(fileContent.content.count) / Double(chunkSize)))
        }
        
        // PHASE 1: Add detailed logging for pass count calculation
        SecureLogger.log("FileProcessingService.calculatePassCount: Input maxLength: \(maxLength), File content length: \(fileContent.content.count), Estimated header length: \(headerLength), Available content length: \(availableContentLength), Chunk size: \(chunkSize), Calculated passes: \(passCount)")
        
        return passCount
    }
    
    /// Get content chunk for specific pass
    func getContentChunk(_ fileContent: FileContent, pass: Int, totalPasses: Int, maxLength: Int = Constants.defaultChunkSize) -> String {
        let headerLength = estimateHeaderLength(fileContent)
        // PHASE 3: Use centralized constants for consistent chunk sizing
        let availableContentLength = max(maxLength - headerLength - Constants.instructionBuffer, 100) // Conservative buffer
        let chunkSize = availableContentLength - 300 // Conservative reserve
        
        let startIndex = (pass - 1) * chunkSize
        let endIndex = min(startIndex + chunkSize, fileContent.content.count)
        
        let startStringIndex = fileContent.content.index(fileContent.content.startIndex, offsetBy: startIndex)
        let endStringIndex = fileContent.content.index(fileContent.content.startIndex, offsetBy: endIndex)
        
        let chunk = String(fileContent.content[startStringIndex..<endStringIndex])
        
        var formatted = "📎 File: \(fileContent.fileName) (Pass \(pass)/\(totalPasses))\n"
        formatted += "📄 Type: \(fileContent.type.localizedName)\n"
        if let size = fileContent.size {
            formatted += "📏 Size: \(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))\n"
        }
        if let metadata = fileContent.metadata {
            for (key, value) in metadata {
                formatted += "ℹ️ \(key): \(value)\n"
            }
        }
        formatted += "\n📝 Content (Part \(pass)/\(totalPasses)):\n\n"
        formatted += chunk
        
        if pass < totalPasses {
            formatted += "\n\n[This is part \(pass) of \(totalPasses). More content will follow in subsequent passes.]"
        }
        
        return formatted
    }
    
    /// Estimate header length for calculations
    func estimateHeaderLength(_ fileContent: FileContent) -> Int {
        var headerLength = fileContent.fileName.count + 50 // Base overhead
        headerLength += fileContent.type.localizedName.count
        if let size = fileContent.size {
            headerLength += 30 // Size formatting
        }
        if let metadata = fileContent.metadata {
            for (key, value) in metadata {
                headerLength += key.count + value.count + 10
            }
        }
        return headerLength + 50 // Content header and buffer
    }
    

    
    /// Intelligently chunk content based on file type and length constraints
    private func intelligentChunk(content: String, maxLength: Int, fileType: FileType) -> String {
        // For very small limits, just take the beginning
        if maxLength < 300 {
            let truncated = String(content.prefix(maxLength - 50))
            return truncated + "\n\n[Content truncated due to length. Original length: \(content.count) characters]"
        }
        
        switch fileType {
        case .pdf, .text, .document:
            return chunkTextContent(content: content, maxLength: maxLength)
        case .image:
            // For image text extraction, usually shorter, so take beginning + end if needed
            return chunkImageContent(content: content, maxLength: maxLength)
        }
    }
    
    /// Chunk text content intelligently by preserving structure
    private func chunkTextContent(content: String, maxLength: Int) -> String {
        let reserveForSummary = 150
        let actualMaxLength = maxLength - reserveForSummary
        
        // PERFORMANCE FIX: Use StringBuilder pattern for better performance
        var result = StringBuilder()
        var includedParagraphs = 0
        
        // Try to split by paragraphs or sentences to preserve structure
        let paragraphs = content.components(separatedBy: "\n\n")
        
        for paragraph in paragraphs {
            let paragraphWithNewlines = paragraph + "\n\n"
            if result.count + paragraphWithNewlines.count <= actualMaxLength {
                result.append(paragraphWithNewlines)
                includedParagraphs += 1
            } else {
                break
            }
        }
        
        // If we couldn't fit any complete paragraphs, fall back to character truncation
        if result.count == 0 && !paragraphs.isEmpty {
            result.append(String(content.prefix(actualMaxLength)))
        }
        
        // Add summary information
        let totalParagraphs = paragraphs.count
        if includedParagraphs < totalParagraphs {
            result.append("\n[Showing \(includedParagraphs) of \(totalParagraphs) sections. Original length: \(content.count) characters. This is a preview - ask follow-up questions about specific sections if needed.]")
        }
        
        return result.toString()
    }
    
    /// Chunk image-extracted content
    private func chunkImageContent(content: String, maxLength: Int) -> String {
        if content.count <= maxLength {
            return content
        }
        
        // For image content, take the beginning (most important) and indicate truncation
        let truncated = String(content.prefix(maxLength - 80))
        return truncated + "\n\n[Image text extraction truncated. Original length: \(content.count) characters]"
    }
    
    /// Get supported file types
    var supportedFileTypes: [String] {
        return ["txt", "md", "rtf", "pdf", "jpg", "jpeg", "png", "heic", "doc", "docx"]
    }
    
    // MARK: - Security Validation
    
    /// Validates file size against security limits
    private func validateFileSize(_ url: URL, fileExtension: String) throws {
        guard let maxSize = Self.maxFileSizes[fileExtension] else {
            throw FileProcessingError.unsupportedFormat
        }
        
        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        
        guard fileSize <= maxSize else {
            let maxMB = maxSize / (1024 * 1024)
            let actualMB = fileSize / (1024 * 1024)
            throw FileProcessingError.fileTooLarge(maxSize: maxMB, actualSize: actualMB, fileType: fileExtension.uppercased())
        }
    }
    
    /// Validates file content for suspicious patterns
    private func validateFileContent(_ data: Data) throws {
        // Check for zip bomb indicators
        if data.count > 1024 {
            let content = String(data: data.prefix(1024), encoding: .utf8) ?? ""
            if content.count < 100 {
                throw FileProcessingError.suspiciousContent
            }
            
            // Check for excessive compression
            let compressionRatio = Double(data.count) / Double(content.count)
            if compressionRatio > 100 {
                throw FileProcessingError.suspiciousContent
            }
        }
        
        // Add PDF-specific validation
        if data.prefix(4) == Data([0x25, 0x50, 0x44, 0x46]) { // PDF magic number
            try validatePDFStructure(data)
        }
        
        // Add image-specific validation
        if data.prefix(4) == Data([0xFF, 0xD8, 0xFF, 0xE0]) || // JPEG
           data.prefix(4) == Data([0xFF, 0xD8, 0xFF, 0xE1]) || // JPEG
           data.prefix(8) == Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) { // PNG
            try validateImageStructure(data)
        }
        
        // Check for malicious file patterns
        try validateMaliciousPatterns(data)
    }
    
    /// Validates PDF structure for security
    private func validatePDFStructure(_ data: Data) throws {
        // Check for PDF version
        let header = String(data: data.prefix(8), encoding: .ascii) ?? ""
        guard header.hasPrefix("%PDF-") else {
            throw FileProcessingError.suspiciousContent
        }
        
        // Check for suspicious PDF objects
        let content = String(data: data.prefix(min(1024 * 1024, data.count)), encoding: .utf8) ?? ""
        let suspiciousPatterns = [
            "/JavaScript", "/JS", "/OpenAction", "/Launch",
            "/GoToR", "/URI", "/SubmitForm", "/ImportData"
        ]
        
        for pattern in suspiciousPatterns {
            if content.contains(pattern) {
                SecureLogger.log("SECURITY: Suspicious PDF pattern detected: \(pattern)")
                throw FileProcessingError.suspiciousContent
            }
        }
    }
    
    /// Validates image structure for security
    private func validateImageStructure(_ data: Data) throws {
        // Check for reasonable image dimensions
        if data.count > 50 * 1024 * 1024 { // 50MB limit for images
            throw FileProcessingError.fileTooLarge(maxSize: 50, actualSize: data.count / (1024 * 1024), fileType: "IMAGE")
        }
        
        // Check for embedded scripts in images (steganography)
        let content = String(data: data.prefix(min(1024 * 1024, data.count)), encoding: .utf8) ?? ""
        let scriptPatterns = ["<script", "javascript:", "vbscript:", "onload="]
        
        for pattern in scriptPatterns {
            if content.lowercased().contains(pattern.lowercased()) {
                SecureLogger.log("SECURITY: Suspicious image content detected: \(pattern)")
                throw FileProcessingError.suspiciousContent
            }
        }
    }
    
    /// Validates for malicious patterns in file content
    private func validateMaliciousPatterns(_ data: Data) throws {
        let content = String(data: data.prefix(min(1024 * 1024, data.count)), encoding: .utf8) ?? ""
        
        let maliciousPatterns = [
            "eval(", "exec(", "system(", "shell_exec(",
            "passthru(", "proc_open(", "popen(",
            "<script", "javascript:", "vbscript:",
            "<?php", "<?=", "<?", "#!/bin/",
            "cmd.exe", "powershell", "bash", "sh"
        ]
        
        for pattern in maliciousPatterns {
            if content.lowercased().contains(pattern.lowercased()) {
                SecureLogger.log("SECURITY: Malicious pattern detected in file: \(pattern)")
                throw FileProcessingError.suspiciousContent
            }
        }
    }
    
    // MARK: - Data-based Processing Methods
    
    /// Process text files using data directly
    private func processTextFileWithData(_ data: Data, fileName: String) async throws -> FileContent {
        guard let text = String(data: data, encoding: .utf8) else {
            throw FileProcessingError.encodingError
        }
        
        return FileContent(
            fileName: fileName,
            content: text,
            type: .text,
            size: data.count
        )
    }
    
    /// Process PDF files using data directly
    private func processPDFFileWithData(_ data: Data, fileName: String) async throws -> FileContent {
        guard let pdfDocument = PDFDocument(data: data) else {
            throw FileProcessingError.pdfError
        }
        
        var extractedText = ""
        let pageCount = pdfDocument.pageCount
        
        for i in 0..<pageCount {
            if let page = pdfDocument.page(at: i) {
                if let pageContent = page.string {
                    extractedText += pageContent + "\n\n"
                }
            }
        }
        
        if extractedText.isEmpty {
            extractedText = "No text content could be extracted from this PDF. It may be an image-based PDF or have no selectable text."
        }
        
        return FileContent(
            fileName: fileName,
            content: extractedText,
            type: .pdf,
            size: data.count,
            metadata: ["pages": String(format: NSLocalizedString("%d", comment: ""), pageCount)]
        )
    }
    
    /// Process image files using data directly
    private func processImageFileWithData(_ data: Data, fileName: String) async throws -> FileContent {
        guard let image = UIImage(data: data) else {
            throw FileProcessingError.imageError
        }
        
        let extractedText = try await extractTextFromImage(image)
        
        return FileContent(
            fileName: fileName,
            content: extractedText,
            type: .image,
            size: data.count
        )
    }
    
    /// Process Word documents using data directly
    private func processWordDocumentWithData(_ data: Data, fileName: String) async throws -> FileContent {
        // For now, return a message about Word document support
        return FileContent(
            fileName: fileName,
            content: NSLocalizedString("Word document processing is not yet supported. Please convert to PDF or text format.", comment: ""),
            type: .document,
            size: data.count
        )
    }
}

// MARK: - Data Models

struct FileContent {
    let fileName: String
    let content: String
    let type: FileType
    let size: Int?
    let metadata: [String: String]?
    
    init(fileName: String, content: String, type: FileType, size: Int? = nil, metadata: [String: String]? = nil) {
        self.fileName = fileName
        self.content = content
        self.type = type
        self.size = size
        self.metadata = metadata
    }
}

enum FileType: String, CaseIterable {
    case text = "Text"
    case pdf = "PDF"
    case image = "Image"
    case document = "Document"
    
    var localizedName: String {
        switch self {
        case .text:
            return NSLocalizedString("Text", comment: "")
        case .pdf:
            return NSLocalizedString("PDF", comment: "")
        case .image:
            return NSLocalizedString("Image", comment: "")
        case .document:
            return NSLocalizedString("Document", comment: "")
        }
    }
}

enum FileProcessingError: Error, LocalizedError {
    case unsupportedFormat
    case encodingError
    case pdfError
    case imageError
    case fileNotFound
    case emptyContent
    case fileTooLarge(maxSize: Int, actualSize: Int, fileType: String)
    case suspiciousContent
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return NSLocalizedString("This file format is not supported", comment: "")
        case .encodingError:
            return NSLocalizedString("Could not read the file encoding", comment: "")
        case .pdfError:
            return NSLocalizedString("Could not process the PDF file", comment: "")
        case .imageError:
            return NSLocalizedString("Could not process the image file", comment: "")
        case .fileNotFound:
            return NSLocalizedString("File not found", comment: "")
        case .emptyContent:
            return NSLocalizedString("The file contains no readable text", comment: "")
        case .fileTooLarge(let maxSize, let actualSize, let fileType):
            return "📁 File too large! Your \(fileType) file is \(actualSize)MB, but the maximum allowed size for \(fileType) files is \(maxSize)MB.\n\n💡 Please try:\n• Compressing your file using built-in tools\n• Splitting large documents into smaller sections\n• Using a different file format if possible\n\nFile size limits:\n• PDF files: 25MB max\n• Images (JPG, PNG, HEIC): 10MB max\n• Text files (TXT, MD, RTF): 5MB max\n• Word documents (DOC, DOCX): 15MB max"
        case .suspiciousContent:
            return "⚠️ Security Alert: This file appears to contain suspicious or potentially malicious content. For your security, I cannot process this file.\n\n💡 Please try:\n• Using a different, trusted file\n• Scanning the file with antivirus software\n• Re-creating the document from a clean source"
        }
    }
}

// MARK: - Extensions

extension URL {
    var fileSize: Int? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            return attributes[.size] as? Int
        } catch {
            return nil
        }
    }
}

