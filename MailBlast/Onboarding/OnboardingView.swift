import SwiftUI

struct OnboardingView: View {
    @AppStorage(PreferenceKey.onboardingDone) private var onboardingDone = false
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var showingPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    TextField("Subject line", text: $viewModel.subject)
                }

                Section {
                    TextEditor(text: $viewModel.template)
                        .frame(minHeight: 160)
                } header: {
                    Text("Email template")
                } footer: {
                    Text("Use {hr_name} for the recipient's first name and {company_name} for their company.")
                }

                Section("Resume") {
                    Button {
                        showingPicker = true
                    } label: {
                        Label(
                            viewModel.resumeImported ? "resume.pdf attached" : "Upload resume PDF",
                            systemImage: viewModel.resumeImported ? "checkmark.circle.fill" : "doc.badge.plus"
                        )
                    }
                    if let importError = viewModel.importError {
                        Text(importError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Set Up MailBlast")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.persistPreferences()
                        onboardingDone = true
                    }
                    .disabled(!viewModel.canComplete)
                }
            }
            .sheet(isPresented: $showingPicker) {
                DocumentPickerView { url in
                    viewModel.importResume(from: url)
                }
            }
        }
    }
}
