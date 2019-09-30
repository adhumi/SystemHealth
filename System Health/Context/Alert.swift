import Foundation
import CoreData

extension Alert {
    convenience init(metric: String, value: Float, state: String, date: Date, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Alert", in: context) else { fatalError() }
        self.init(entity: entity, insertInto: context)

        self.metric = metric
        self.value = value
        self.state = state
        self.date = date
    }
}
