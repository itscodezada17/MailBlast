import SwiftUI
import MessageUI

struct MailComposerView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    let attachmentData: Data?
    let attachmentFileName: String
    let onResult: (MFMailComposeResult) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([recipient])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        if let attachmentData {
            composer.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: attachmentFileName)
        }
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult, dismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let onResult: (MFMailComposeResult) -> Void
        private let dismiss: DismissAction

        init(onResult: @escaping (MFMailComposeResult) -> Void, dismiss: DismissAction) {
            self.onResult = onResult
            self.dismiss = dismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            onResult(result)
            dismiss()
        }
    }
}
