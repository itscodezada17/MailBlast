import SwiftUI
import UIKit

enum AppTab: Hashable {
    case sendMail
    case history
    case editProfile
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .sendMail
    @Published var pendingRecipient: String?

    private var lastPasteboardChangeCount = -1

    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    func handle(_ url: URL) {
        guard url.scheme?.lowercased() == "emailblast" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let recipient = components?.queryItems?.first(where: { $0.name == "to" })?.value,
              !recipient.isEmpty else { return }
        route(to: recipient)
    }

    func checkClipboardForSharedEmail() {
        let pasteboard = UIPasteboard.general
        guard pasteboard.changeCount != lastPasteboardChangeCount else { return }
        lastPasteboardChangeCount = pasteboard.changeCount
        guard pasteboard.hasStrings,
              let text = pasteboard.string,
              let range = text.range(of: Self.emailRegex, options: .regularExpression) else { return }
        route(to: String(text[range]))
    }

    private func route(to recipient: String) {
        pendingRecipient = recipient
        selectedTab = .sendMail
    }
}
