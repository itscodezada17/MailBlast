import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
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
                    if viewModel.resumeImported {
                        Label("resume.pdf attached", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    Button {
                        showingPicker = true
                    } label: {
                        Label(
                            viewModel.resumeImported ? "Re-upload resume PDF" : "Upload resume PDF",
                            systemImage: "doc.badge.plus"
                        )
                    }
                    if let importError = viewModel.importError {
                        Text(importError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $showingPicker) {
                DocumentPickerView { url in
                    viewModel.importResume(from: url)
                }
            }
            .alert("Saved", isPresented: $viewModel.didSave) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your profile has been updated.")
            }
        }
    }
}
