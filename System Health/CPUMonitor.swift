import Foundation

class CPUMonitor: Monitor {
    struct Report {
        let user: Double
        let system: Double
        let idle: Double
        let nice: Double

        init(loadInfo: host_cpu_load_info) {
            user = Double(loadInfo.cpu_ticks.0)
            system = Double(loadInfo.cpu_ticks.1)
            idle = Double(loadInfo.cpu_ticks.2)
            nice = Double(loadInfo.cpu_ticks.3)
        }
    }

    var reports: [Report] = []

    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkCPU), userInfo: nil, repeats: true)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    private func checkCPU() {
        if let cpuLoad = try? hostCPULoadInfo() {
            store(cpuLoadInfo: cpuLoad)
        }
    }

    private func store(cpuLoadInfo: host_cpu_load_info) {
        let report = Report(loadInfo: cpuLoadInfo)
        reports.append(report)
        print(currentLoad())
    }

    func currentLoad() -> (user: Float, system: Float, idle: Float)? {
        guard let lastReport = reports.last else { return nil }
        let previousReport = reports.count >= 2 ? reports[reports.count - 2] : nil

        let userDiff = lastReport.user - (previousReport?.user ?? 0)
        let systemDiff = lastReport.system - (previousReport?.system ?? 0)
        let idleDiff = lastReport.idle - (previousReport?.idle ?? 0)

        let totalTicks = userDiff + systemDiff + idleDiff

        let user = Float(userDiff) / Float(totalTicks)
        let system = Float(systemDiff) / Float(totalTicks)
        let idle = Float(idleDiff) / Float(totalTicks)

        return (user: user, system: system, idle: idle)
    }
}

enum CPUMonitorErrors: Error {
    case invalidResult(code: Int32)
}

extension CPUMonitor {
    private func hostCPULoadInfo() throws -> host_cpu_load_info {
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
