import Foundation

class DashboardHeaderVM {
    let context: Context

    var updateCPUState: ((CPUMonitor.CPUReport) -> Void)?
    var updateRAMState: ((RAMMonitor.RAMReport) -> Void)?
    var updateBatteryState: ((BatteryMonitor.BatteryReport) -> Void)?

    private var timer: Timer?

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    init(context: Context) {
        self.context = context
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateValues), userInfo: nil, repeats: true)
    }

    @objc func updateValues() {
        context.cpuMonitor.current.map { updateCPUState?($0) }
        context.ramMonitor.current.map { updateRAMState?($0) }
        context.batteryMonitor.current.map { updateBatteryState?($0) }
    }
}
