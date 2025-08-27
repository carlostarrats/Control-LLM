import Foundation
import UIKit
import PDFKit
import Vision

class FileProcessingService {
    static let shared = FileProcessingService()
    
    private init() {}
    
    /// Process a file and extract its content for LLM processing
    func processFile(_ url: URL) async throws -> FileContent {
        let fileExtension = url.pathExtension.lowercased()
        
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
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw FileProcessingError.encodingError
        }
        
        return FileContent(
            fileName: url.lastPathComponent,
            content: text,
            type: .text,
            size: data.count
        )
    }
    
    /// Process PDF files
    private func processPDFFile(_ url: URL) async throws -> FileContent {
        guard let pdfDocument = PDFDocument(url: url) else {
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
        
        return FileContent(
            fileName: url.lastPathComponent,
            content: extractedText,
            type: .pdf,
            size: url.fileSize ?? 0,
            metadata: ["pages": String(format: NSLocalizedString("%d", comment: ""), pageCount)]
        )
    }
    
    /// Process image files using Vision framework for text extraction
    private func processImageFile(_ url: URL) async throws -> FileContent {
        guard let image = UIImage(contentsOfFile: url.path) else {
            throw FileProcessingError.imageError
        }
        
        let extractedText = try await extractTextFromImage(image)
        
        return FileContent(
            fileName: url.lastPathComponent,
            content: extractedText,
            type: .image,
            size: url.fileSize ?? 0
        )
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
    
    /// Format file content for LLM processing
    func formatForLLM(_ fileContent: FileContent) -> String {
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
        formatted += fileContent.content
        
        return formatted
    }
    
    /// Get supported file types
    var supportedFileTypes: [String] {
        return ["txt", "md", "rtf", "pdf", "jpg", "jpeg", "png", "heic"]
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
