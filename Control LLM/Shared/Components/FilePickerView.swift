import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct FilePickerView: UIViewControllerRepresentable {
    @Binding var selectedUrl: URL?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        SecureLogger.log("FilePickerView: Creating UIDocumentPickerViewController")
        // Restrict to specific file types for security
        let allowedTypes: [UTType] = [
            .pdf,
            .plainText,
            .rtf,
            .image,
            .jpeg,
            .png,
            .heic,
            .text,
            .data
        ]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.delegate = context.coordinator
        SecureLogger.log("FilePickerView: UIDocumentPickerViewController created with delegate")
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerView

        init(_ parent: FilePickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            SecureLogger.log("FilePickerView: documentPicker didPickDocumentsAt called with \(urls.count) URLs")
            if let url = urls.first {
                SecureLogger.log("FilePickerView: Setting selectedUrl to: \(url.path)")
                parent.selectedUrl = url
            }
            SecureLogger.log("FilePickerView: Dismissing picker")
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
