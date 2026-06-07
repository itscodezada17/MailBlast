import SwiftUI

struct ContentView: View {
    @AppStorage(PreferenceKey.onboardingDone) private var onboardingDone = false

    var body: some View {
        if onboardingDone {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            SendMailView()
                .tabItem {
                    Label("Send Mail", systemImage: "paperplane.fill")
                }
                .tag(AppTab.sendMail)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(AppTab.history)

            EditProfileView()
                .tabItem {
                    Label("Edit Profile", systemImage: "person.crop.circle")
                }
                .tag(AppTab.editProfile)
        }
    }
}

#Preview {
    ContentView()
}
