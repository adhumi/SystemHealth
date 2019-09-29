import Foundation
import UIKit

class BatteryMonitor: Monitor {
    static let newReportNotificationName = NSNotification.Name("\(BatteryMonitor.self).newReport")

    struct BatteryReport: Report {
        let level: Float
        let state: UIDevice.BatteryState

        let timestamp = NSDate().timeIntervalSince1970
    }

    var history: [BatteryReport] = []

    func start() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)

        storeBatteryState()
    }

    func stop() {
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
}

extension BatteryMonitor {
    @objc
    func batteryLevelDidChange() {
        storeBatteryState()
    }

    @objc
    func batteryStateDidChange() {
        storeBatteryState()
    }
}

extension BatteryMonitor {
    private func storeBatteryState() {
        let report = BatteryReport(level: UIDevice.current.batteryLevel, state: UIDevice.current.batteryState)
        history.append(report)
        NotificationCenter.default.post(name: type(of: self).newReportNotificationName, object: report)
    }
}

extension UIDevice.BatteryState {
    public var readableValue: String {
        switch self {
        case .unplugged:
            return "Unplugged"
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        default:
            return "Unknown"
        }
    }
}

extension UIDevice.BatteryState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        default:
            return "unknown"
        }
    }
}
