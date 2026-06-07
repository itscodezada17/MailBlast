import Foundation
import SwiftData

@Model
final class HistoryEntry {
    var id: UUID
    var recipientEmail: String
    var extractedName: String
    var sentAt: Date

    init(recipientEmail: String, extractedName: String, sentAt: Date = Date()) {
        self.id = UUID()
        self.recipientEmail = recipientEmail
        self.extractedName = extractedName
        self.sentAt = sentAt
    }
}
