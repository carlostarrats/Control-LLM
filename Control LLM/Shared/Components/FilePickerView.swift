import SwiftUI
import UIKit

struct FilePickerView: UIViewControllerRepresentable {
    @Binding var selectedUrl: URL?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("🔥 FilePickerView: Creating UIDocumentPickerViewController")
        // Allow picking any content type, you can restrict this to ["public.pdf"] if needed
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.content], asCopy: true)
        picker.delegate = context.coordinator
        print("🔥 FilePickerView: UIDocumentPickerViewController created with delegate")
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
            print("🔥 FilePickerView: documentPicker didPickDocumentsAt called with \(urls.count) URLs")
            if let url = urls.first {
                print("🔥 FilePickerView: Setting selectedUrl to: \(url.path)")
                parent.selectedUrl = url
            }
            print("🔥 FilePickerView: Dismissing picker")
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
