import XCTest
@testable import System_Health
import CoreData

class AlertingTests: XCTestCase {
    let context = Context()

    override func tearDown() {
        context.stopMonitoring()

        let psc = context.store.container.persistentStoreCoordinator
        let storeUrl = psc.persistentStores.first!.url!
        try! psc.destroyPersistentStore(at: storeUrl, ofType: NSSQLiteStoreType, options: nil)

        context.settingsStore.preferenceKeys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }

    func testThresholdReachedAlert() {
        var cpuPreferences = context.settingsStore.preferences["cpu"]!
        cpuPreferences.active = true
        cpuPreferences.threshold = 0
        context.settingsStore.save(preference: cpuPreferences, for: "cpu")

        context.startMonitoring()

        expectation(forNotification: CPUMonitor.thresholdReachedNotificationName, object: nil, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
