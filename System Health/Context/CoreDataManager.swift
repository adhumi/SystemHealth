import Foundation
import CoreData

public class CoreDataManager {
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
