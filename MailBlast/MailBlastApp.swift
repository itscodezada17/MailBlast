import SwiftUI
import SwiftData

@main
struct MailBlastApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    appState.handle(url)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        appState.checkClipboardForSharedEmail()
                    }
                }
        }
        .modelContainer(for: HistoryEntry.self)
    }
}
