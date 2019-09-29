import Foundation
import CoreData

extension Alert {
    convenience init(metric: String, value: Float, state: String, date: Date, context: NSManagedObjectContext) {
        self.init(entity: Alert.entity(), insertInto: context)

        self.metric = metric
        self.value = value
        self.state = state
        self.date = date
    }
}
