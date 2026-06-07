import Foundation
import SwiftData

@MainActor
final class HistoryViewModel: ObservableObject {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    func delete(_ entry: HistoryEntry, in context: ModelContext) {
        context.delete(entry)
    }
}
