import XCTest
@testable import System_Health

class SettingsStoreTests: XCTestCase {
    let settingsStore = SettingsStore()

    override func tearDown() {
        settingsStore.preferenceKeys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }

    func testInitialization() {
        XCTAssertEqual(settingsStore.preferences.count, 3)

        let preference = settingsStore.preferences["cpu"]
        XCTAssertEqual(preference?.active, false)
        XCTAssertEqual(preference?.threshold, 0.5)
        XCTAssertEqual(preference?.cooldownAlert, false)
    }

    func testSaveAndRetrieve() {
        var preference = settingsStore.preferences["cpu"]!
        preference.active = true
        preference.threshold = 0.2
        preference.cooldownAlert = true
        settingsStore.save(preference: preference, for: "cpu")

        let anotherStore = SettingsStore()
        let retrievedPreference = anotherStore.preferences["cpu"]
        XCTAssertEqual(retrievedPreference?.active, true)
        XCTAssertEqual(retrievedPreference?.threshold, 0.2)
        XCTAssertEqual(retrievedPreference?.cooldownAlert, true)
    }
}
