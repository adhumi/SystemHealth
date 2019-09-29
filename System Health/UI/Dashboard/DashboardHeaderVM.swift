import Foundation

class DashboardHeaderVM {
    let context: Context

    var updateCPUState: ((CPUMonitor.CPUReport) -> Void)?
    var updateRAMState: ((RAMMonitor.RAMReport) -> Void)?
    var updateBatteryState: ((BatteryMonitor.BatteryReport) -> Void)?

    private var cpuObserver: NSObjectProtocol?
    private var ramObserver: NSObjectProtocol?
    private var batteryObserver: NSObjectProtocol?

    private var timer: Timer?

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    init(context: Context) {
        self.context = context

        cpuObserver = NotificationCenter.default.addObserver(forName: CPUMonitor.newReportNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? CPUMonitor.CPUReport else { return }
            self?.updateCPUState?(report)
        }

        ramObserver = NotificationCenter.default.addObserver(forName: RAMMonitor.newReportNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? RAMMonitor.RAMReport else { return }
            self?.updateRAMState?(report)
        }

        batteryObserver = NotificationCenter.default.addObserver(forName: BatteryMonitor.newReportNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            self?.updateBatteryState?(report)
        }
    }

    var lastCPUReport: CPUMonitor.CPUReport? {
        return context.cpuMonitor.current
    }

    var lastRAMReport: RAMMonitor.RAMReport? {
        return context.ramMonitor.current
    }

    var lastBatteryReport: BatteryMonitor.BatteryReport? {
        return context.batteryMonitor.current
    }
}
