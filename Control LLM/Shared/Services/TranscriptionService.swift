import Foundation
import UIKit
import PDFKit

@MainActor
class TranscriptionService: ObservableObject {
    // MARK: - Published Properties
    @Published var isTranscribing = false
    @Published var transcriptionProgress: Double = 0.0
    @Published var errorMessage: String?
    
    // MARK: - File Management
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let transcriptionDirectory = "WhisperTranscriptions"
    
    init() {
        createTranscriptionDirectory()
    }
    
    // MARK: - Directory Setup
    private func createTranscriptionDirectory() {
        let transcriptionPath = documentsPath.appendingPathComponent(transcriptionDirectory)
        if !FileManager.default.fileExists(atPath: transcriptionPath.path) {
            do {
                try FileManager.default.createDirectory(at: transcriptionPath, withIntermediateDirectories: true)
            } catch {
                print("Failed to create transcription directory: \(error)")
            }
        }
    }
    
    // MARK: - PDF Generation
    func generateTranscriptionPDF(audioTitle: String, transcription: String, timestamp: Date) -> URL? {
        guard !audioTitle.isEmpty && !transcription.isEmpty else {
            errorMessage = "Invalid transcription data"
            return nil
        }
        
        // Create PDF data
        let pdfData = NSMutableData()
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        
        // Create PDF context
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPage()
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(pageRect)
        
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        
        let titleString = NSAttributedString(string: audioTitle, attributes: titleAttributes)
        let titleRect = CGRect(x: 50, y: 50, width: pageRect.width - 100, height: 50)
        titleString.draw(in: titleRect)
        
        // Timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let timestampAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ]
        
        let timestampString = NSAttributedString(string: "Recorded: \(dateFormatter.string(from: timestamp))", attributes: timestampAttributes)
        let timestampRect = CGRect(x: 50, y: 100, width: pageRect.width - 100, height: 30)
        timestampString.draw(in: timestampRect)
        
        // Transcription content
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        
        let contentString = NSAttributedString(string: transcription, attributes: contentAttributes)
        let contentRect = CGRect(x: 50, y: 150, width: pageRect.width - 100, height: pageRect.height - 200)
        contentString.draw(in: contentRect)
        
        UIGraphicsEndPDFContext()
        
        // Save PDF to file
        let pdfURL = getTranscriptionDirectory().appendingPathComponent("\(audioTitle)_transcription.pdf")
        
        do {
            try pdfData.write(to: pdfURL)
            return pdfURL
        } catch {
            print("Failed to save PDF: \(error)")
            errorMessage = "Failed to save transcription PDF: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - File Management
    func getTranscriptionDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("WhisperTranscriptions")
    }
    
    func getTranscriptionFileURL(for audioURL: URL) -> URL {
        let audioFileName = audioURL.deletingPathExtension().lastPathComponent
        return getTranscriptionDirectory().appendingPathComponent("\(audioFileName).pdf")
    }
    
    func getAllTranscriptionFiles() -> [URL] {
        let transcriptionPath = getTranscriptionDirectory()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: transcriptionPath, includingPropertiesForKeys: [.creationDateKey], options: [])
            return fileURLs.filter { $0.pathExtension == "pdf" }
                .sorted { url1, url2 in
                    let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1! > date2!
                }
        } catch {
            print("Failed to get transcription files: \(error)")
            return []
        }
    }
    
    func deleteTranscriptionFile(url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("Failed to delete transcription file: \(error)")
            errorMessage = "Failed to delete transcription file"
            return false
        }
    }
    
    func getFileSize(url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
        } catch {
            return "Unknown size"
        }
    }
    
    // MARK: - File Sharing
    func shareFile(url: URL) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        return activityViewController
    }
    
    // MARK: - Files App Integration
    func saveFileToFilesApp(url: URL, completion: @escaping (Bool) -> Void) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [url])
        documentPicker.shouldShowFileExtensions = true
        
        // Get the current window scene and present the picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(documentPicker, animated: true) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    // MARK: - Utility Functions
    func formatFileSize(_ bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    func getFileCreationDate(url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date
        } catch {
            return nil
        }
    }
}
