import Foundation

protocol Report {
    var timestamp: TimeInterval { get }
}

enum MonitoringNotificationInstruction {
    case reached
    case cooldown
    case none
}

protocol Monitor {
    associatedtype T: Report
    func start()
    func stop()
    var current: T? { get }
    var history: [T] { get }

    var checkStatus: ((T, T?) -> MonitoringNotificationInstruction)? { get set }

    static var newReportNotificationName: NSNotification.Name { get }
    static var thresholdReachedNotificationName: NSNotification.Name { get }
    static var thresholdCooldownNotificationName: NSNotification.Name { get }
}

extension Monitor {
    var current: T? {
        return history.last
    }

    func checkThreshold(for report: T) {
        switch checkStatus?(report, history.last) {
        case .reached:
            NotificationCenter.default.post(name: type(of: self).thresholdReachedNotificationName, object: report)
        case .cooldown:
            NotificationCenter.default.post(name: type(of: self).thresholdCooldownNotificationName, object: report)
        default: break
        }
    }
}
