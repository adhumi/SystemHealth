import Foundation
import CoreData

extension Context {
    public func alerts() -> NSFetchedResultsController<Alert> {
        let request: NSFetchRequest<Alert> = Alert.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Alert.date), ascending: false)]
        request.fetchLimit = 100
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: store.context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
