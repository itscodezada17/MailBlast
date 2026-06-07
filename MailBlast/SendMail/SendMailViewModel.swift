import Foundation
import MessageUI

@MainActor
final class SendMailViewModel: ObservableObject {
    @Published var recipientEmail: String = ""
    @Published var showingComposer = false
    @Published var alertMessage: String?

    private var store = UserPreferencesStore.shared

    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    var extractedName: String {
        EmailNameExtractor.extractFirstName(from: recipientEmail)
    }

    var extractedCompany: String {
        EmailNameExtractor.extractCompanyName(from: recipientEmail)
    }

    var composedSubject: String {
        applyPlaceholders(to: store.subject)
    }

    var composedBody: String {
        applyPlaceholders(to: store.template)
    }

    var attachmentData: Data? {
        PDFStorageHelper.resumeData()
    }

    private var isValidEmail: Bool {
        recipientEmail.range(of: Self.emailRegex, options: .regularExpression) != nil
    }

    func send() {
        guard isValidEmail else {
            alertMessage = "Please enter a valid email address."
            return
        }
        guard MFMailComposeViewController.canSendMail() else {
            alertMessage = "No mail account configured. Please set up the Mail app first."
            return
        }
        showingComposer = true
    }

    private func applyPlaceholders(to text: String) -> String {
        text
            .replacingPlaceholder("hr_name", "hr team", "hrname", with: extractedName)
            .replacingPlaceholder("company_name", "company name", "companyname", with: extractedCompany)
    }
}

private extension String {
    func replacingPlaceholder(_ variants: String..., with value: String) -> String {
        let alternatives = variants
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .joined(separator: "|")
        let pattern = "\\{\\s*(?:\(alternatives))\\s*\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return self
        }
        let range = NSRange(startIndex..., in: self)
        let template = NSRegularExpression.escapedTemplate(for: value)
        return regex.stringByReplacingMatches(in: self, range: range, withTemplate: template)
    }
}
