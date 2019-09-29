import Foundation

class RAMMonitor: Monitor {
    static let newReportNotificationName = NSNotification.Name("\(RAMMonitor.self).newReport")

    struct RAMReport: Report {
        /// There are more data avalable in `vm_statistics64` but those as the most widely used when tracking RAM usage.
        let free: Float
        let active: Float
        let inactive: Float
        let wired: Float

        var total: Float {
            return free + active + inactive + wired
        }

        var usage: Float {
            return (total - free - inactive) / total // Considering free and inactive as "free" memory
        }

        let timestamp = NSDate().timeIntervalSince1970

        init(statistics: vm_statistics64) {
            let pageSize = Float(vm_kernel_page_size)
            let gigabyte: Float = pow(2, 30) // Convert from bytes to gigabytes

            self.free = Float(statistics.free_count) * pageSize / gigabyte
            self.active = Float(statistics.active_count) * pageSize / gigabyte
            self.inactive = Float(statistics.inactive_count) * pageSize / gigabyte
            self.wired = Float(statistics.wire_count) * pageSize / gigabyte
        }
    }

    private let refreshRate: TimeInterval = 1 // In seconds

    var history: [RAMReport] = []

    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(timeInterval: refreshRate, target: self, selector: #selector(checkRAM), userInfo: nil, repeats: true)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    private func checkRAM() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let statistics = try? RAMMonitor.memoryStatistics() {
                self?.store(statistics: statistics)
            }
        }
    }

    private func store(statistics: vm_statistics64) {
        let report = RAMReport(statistics: statistics)
        history.append(report)
        NotificationCenter.default.post(name: type(of: self).newReportNotificationName, object: report)
    }
}

enum RAMMonitorErrors: Error {
    case invalidResult(code: Int32)
}

extension RAMMonitor {
    private static func memoryStatistics() throws -> vm_statistics64 {
        let hostCPULoadInfoCount = MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(hostCPULoadInfoCount)
        let info = vm_statistics64_t.allocate(capacity: 1)

        let result = info.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
        }

        let data = info.move()
        info.deallocate()

        if result != KERN_SUCCESS {
            throw RAMMonitorErrors.invalidResult(code: result)
        }

        return data
    }
}
