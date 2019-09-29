import Foundation

class SettingsStore {
    let preferenceKeys: [String] = ["cpu", "ram", "battery"]

    var preferences: [String: AlertingPreferences] = [:]

    init() {
        preferences = preferenceKeys.reduce([String: AlertingPreferences]()) { [weak self] in
            guard let self = self else { return $0 }
            var dict = $0
            dict[$1] = self.preferences(for: $1)
            return dict
        }
    }

    private func preferences(for key: String) -> AlertingPreferences {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else { return AlertingPreferences.empty }
        guard let preferences = try? PropertyListDecoder().decode(AlertingPreferences.self, from: data) else { return AlertingPreferences.empty }
        return preferences
    }

    func save(preference: AlertingPreferences, for key: String) {
        preferences[key] = preference
        if let data = try? PropertyListEncoder().encode(preference) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
