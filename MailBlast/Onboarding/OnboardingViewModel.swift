import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var template: String = "Hi {hr_name},\n\nI came across an opening at {company_name} and would love to be considered. My resume is attached.\n\nBest regards"
    @Published var subject: String = "Application for the open role at {company_name}"
    @Published var resumeImported: Bool = PDFStorageHelper.hasStoredResume
    @Published var importError: String?

    private var store = UserPreferencesStore.shared

    var canComplete: Bool {
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

    func persistPreferences() {
        store.template = template
        store.subject = subject
    }
}
