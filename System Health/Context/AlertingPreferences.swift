import Foundation

struct AlertingPreferences {
    var active: Bool
    var threshold: Float
    var cooldownAlert: Bool

    static var empty: AlertingPreferences {
        return AlertingPreferences(active: false, threshold: 0.5, cooldownAlert: false)
    }
}

extension AlertingPreferences: Codable {}
