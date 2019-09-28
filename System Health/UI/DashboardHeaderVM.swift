import Foundation

class DashboardHeaderVM {
    let context: Context

    var updateCPUState: ((CPUMonitor.CPUReport) -> Void)?
    var updateRAMState: ((RAMMonitor.RAMReport) -> Void)?
    var updateMemoryState: ((BatteryMonitor.BatteryReport) -> Void)?

    private var timer: Timer?

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    init(context: Context) {
        self.context = context
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCPU), userInfo: nil, repeats: true)
    }

    @objc func updateCPU() {
        context.cpuMonitor.current.map { updateCPUState?($0) }
    }
}
