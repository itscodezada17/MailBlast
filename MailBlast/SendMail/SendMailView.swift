import SwiftUI
import SwiftData

struct SendMailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = SendMailViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("HR email address", text: $viewModel.recipientEmail)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                } footer: {
                    if !viewModel.recipientEmail.isEmpty {
                        Text("Name: \(viewModel.extractedName)  ·  Company: \(viewModel.extractedCompany)")
                    }
                }

                Section {
                    Button {
                        viewModel.send()
                    } label: {
                        Label("Send Mail", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.recipientEmail.isEmpty)
                }
            }
            .navigationTitle("Send Mail")
            .onAppear(perform: consumePendingRecipient)
            .onChange(of: appState.pendingRecipient) { _, _ in
                consumePendingRecipient()
            }
            .sheet(isPresented: $viewModel.showingComposer) {
                MailComposerView(
                    recipient: viewModel.recipientEmail,
                    subject: viewModel.composedSubject,
                    body: viewModel.composedBody,
                    attachmentData: viewModel.attachmentData,
                    attachmentFileName: PDFStorageHelper.fileName
                ) { result in
                    if result == .sent {
                        recordSentEmail()
                    }
                }
            }
            .alert(
                "Cannot Send",
                isPresented: Binding(
                    get: { viewModel.alertMessage != nil },
                    set: { if !$0 { viewModel.alertMessage = nil } }
                ),
                presenting: viewModel.alertMessage
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }

    private func consumePendingRecipient() {
        guard let recipient = appState.pendingRecipient else { return }
        viewModel.recipientEmail = recipient
        appState.pendingRecipient = nil
    }

    private func recordSentEmail() {
        let entry = HistoryEntry(
            recipientEmail: viewModel.recipientEmail,
            extractedName: viewModel.extractedName
        )
        modelContext.insert(entry)
        viewModel.recipientEmail = ""
    }
}
