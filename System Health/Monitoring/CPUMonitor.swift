import Foundation

class CPUMonitor: Monitor {
    struct CPUReport: Report {
        /// `system` and `nice` are always empty on iOS.
        /// We keep them here for consistency with internal APIs and in case of future evolutions.
        let user: Double
        let system: Double
        let idle: Double
        let nice: Double

        let timestamp = NSDate().timeIntervalSince1970

        fileprivate init(load: host_cpu_load_info, previousLoad: host_cpu_load_info) {
            let userDiff = Double(load.cpu_ticks.0 - previousLoad.cpu_ticks.0)
            let sysDiff  = Double(load.cpu_ticks.1 - previousLoad.cpu_ticks.1)
            let idleDiff = Double(load.cpu_ticks.2 - previousLoad.cpu_ticks.2)
            let niceDiff = Double(load.cpu_ticks.3 - previousLoad.cpu_ticks.3)
            let totalTicks = sysDiff + userDiff + niceDiff + idleDiff

            system = sysDiff / totalTicks
            user = userDiff / totalTicks
            idle = idleDiff / totalTicks
            nice = niceDiff / totalTicks
        }
    }

    private let refreshRate: TimeInterval = 1 // In seconds

    var history: [CPUReport] = []
    private var previousLoad = try? CPUMonitor.hostCPULoadInfo()

    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(timeInterval: refreshRate, target: self, selector: #selector(checkCPU), userInfo: nil, repeats: true)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    private func checkCPU() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let cpuLoad = try? CPUMonitor.hostCPULoadInfo() {
                self?.store(load: cpuLoad)
            }
        }
    }

    private func store(load: host_cpu_load_info) {
        guard let previousLoad = previousLoad else {
            self.previousLoad = load
            return
        }
        let report = CPUReport(load: load, previousLoad: previousLoad)
        history.append(report)
        self.previousLoad = load
        print(report)
    }
}

enum CPUMonitorErrors: Error {
    case invalidResult(code: Int32)
}

extension CPUMonitor {
    private static func hostCPULoadInfo() throws -> host_cpu_load_info {
        let hostCPULoadInfoCount = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(hostCPULoadInfoCount)
        var cpuLoadInfo = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: hostCPULoadInfoCount) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }

        if result != KERN_SUCCESS {
            throw CPUMonitorErrors.invalidResult(code: result)
        }

        return cpuLoadInfo
    }
}
