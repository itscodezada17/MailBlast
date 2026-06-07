import Foundation

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var template: String
    @Published var subject: String
    @Published var resumeImported: Bool
    @Published var importError: String?
    @Published var didSave = false

    private var store = UserPreferencesStore.shared

    init() {
        let store = UserPreferencesStore.shared
        self.template = store.template
        self.subject = store.subject
        self.resumeImported = PDFStorageHelper.hasStoredResume
    }

    var canSave: Bool {
        !template.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && resumeImported
    }

    func importResume(from url: URL) {
        do {
            try PDFStorageHelper.importResume(from: url)
            resumeImported = true
            importError = nil
        } catch {
            importError = "Could not import the PDF. Please try again."
        }
    }

    func save() {
        store.template = template
        store.subject = subject
        didSave = true
    }
}
