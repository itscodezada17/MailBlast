import Foundation

enum PreferenceKey {
    static let onboardingDone = "onboarding_done"
    static let template = "email_template"
    static let subject = "email_subject"
}

struct UserPreferencesStore {
    static let shared = UserPreferencesStore()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var template: String {
        get { defaults.string(forKey: PreferenceKey.template) ?? "" }
        set { defaults.set(newValue, forKey: PreferenceKey.template) }
    }

    var subject: String {
        get { defaults.string(forKey: PreferenceKey.subject) ?? "" }
        set { defaults.set(newValue, forKey: PreferenceKey.subject) }
    }

    var onboardingDone: Bool {
        get { defaults.bool(forKey: PreferenceKey.onboardingDone) }
        set { defaults.set(newValue, forKey: PreferenceKey.onboardingDone) }
    }
}
