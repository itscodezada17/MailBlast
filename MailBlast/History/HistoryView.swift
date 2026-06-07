import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HistoryEntry.sentAt, order: .reverse) private var entries: [HistoryEntry]
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }
            .navigationTitle("History")
        }
    }

    private var entryList: some View {
        List {
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.recipientEmail)
                        .font(.headline)
                    Text(entry.extractedName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedDate(entry.sentAt))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteEntries)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No emails sent yet",
            systemImage: "paperplane",
            description: Text("Sent emails will appear here.")
        )
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            viewModel.delete(entries[index], in: modelContext)
        }
    }
}
