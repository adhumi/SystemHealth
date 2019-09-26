import Foundation

protocol Report {
    var timestamp: TimeInterval { get }
}

protocol Monitor {
    associatedtype T: Report
    func start()
    func stop()
    var current: T? { get }
    var history: [T] { get }
}

extension Monitor {
    var current: T? {
        return history.last
    }
}
