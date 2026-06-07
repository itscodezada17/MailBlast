import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let email = await extractEmail()
            await MainActor.run { presentResult(for: email) }
        }
    }

    private func presentResult(for email: String?) {
        guard let email else {
            showAlert(title: "No Email Found",
                      message: "Select an email address first, then share it to MailBlast.")
            return
        }
        UIPasteboard.general.string = email
        showAlert(title: "Email Copied",
                  message: "\(email)\n\nOpen MailBlast — it will fill in this address automatically.")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.extensionContext?.completeRequest(returningItems: nil)
        })
        present(alert, animated: true)
    }

    private func extractEmail() async -> String? {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return nil }
        for item in items {
            if let text = item.attributedContentText?.string, let email = firstEmail(in: text) {
                return email
            }
            for provider in item.attachments ?? [] {
                if let email = await email(from: provider) {
                    return email
                }
            }
        }
        return nil
    }

    private func email(from provider: NSItemProvider) async -> String? {
        if let url = try? await loadURL(from: provider) {
            if url.scheme == "mailto" {
                return String(url.absoluteString.dropFirst("mailto:".count))
            }
            if let email = firstEmail(in: url.absoluteString) {
                return email
            }
        }
        if let text = try? await loadText(from: provider), let email = firstEmail(in: text) {
            return email
        }
        return nil
    }

    private func loadText(from provider: NSItemProvider) async throws -> String? {
        for identifier in [UTType.plainText.identifier, UTType.text.identifier] {
            guard provider.hasItemConformingToTypeIdentifier(identifier) else { continue }
            if let text = try await provider.loadItem(forTypeIdentifier: identifier) as? String {
                return text
            }
        }
        return nil
    }

    private func loadURL(from provider: NSItemProvider) async throws -> URL? {
        guard provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) else { return nil }
        return try await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL
    }

    private func firstEmail(in text: String) -> String? {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }
}
