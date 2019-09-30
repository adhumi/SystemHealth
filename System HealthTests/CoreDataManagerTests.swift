import XCTest
@testable import System_Health
import CoreData

class CoreDataManagerTests: XCTestCase {
    let context = Context()

    override func tearDown() {
        let psc = context.store.container.persistentStoreCoordinator
        let storeUrl = psc.persistentStores.first!.url!
        try! psc.destroyPersistentStore(at: storeUrl, ofType: NSSQLiteStoreType, options: nil)
        
        context.settingsStore.preferenceKeys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }

    func testStoreCreation() {
        let psc = context.store.container.persistentStoreCoordinator
        let storeUrl = psc.persistentStores.first!.url!
        XCTAssertTrue(FileManager.default.fileExists(atPath: storeUrl.path))
    }

    func testAddAndRetrieveAlerts() {
        let alert = Alert(metric: "cpu", value: 0.27, state: "reached", date: Date(), context: context.store.context)
        context.store.save()

        let frc = context.alerts()
        try! frc.performFetch()
        let retrievedAlert = frc.fetchedObjects?.first

        XCTAssertEqual(retrievedAlert, alert)
    }
}
